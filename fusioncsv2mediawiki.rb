#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

# グーグル避難所情報サイトが提供しているFusionTableのCSVデータをウィキ形式に変換するスクリプト

require "kconv"
require "rubygems"
require "fastercsv"

if $0 == __FILE__
   data = {}
   done = {}
   none_target = {}
   ARGV.each do |f|
      cont = open( f ){|io| io.read }
      csv = FasterCSV.parse( cont.toutf8, { :headers => true } )
      ## header = csv.shift # skip first line (header).
      csv.each do |c|
         c["Name"].gsub!( /コミセン/, "コミュニティセンター" )
         c["City"] = "一関市" if c["City"] == "一関"
         c["Name"].gsub!( /㈲|㈱/, "" )
         city_n = c["City"].gsub( /\A.*?郡/, "" )
         pagename = if c["Name"].index( city_n ) == 0
                       c["Name"]
                    else
                       city_n + c["Name"]
                    end
         if not c["Name"] =~ /公民館|コミュニティセンター|コミュニティー?センター?|市民センター|地区センター/
            none_target[ c["Prefecture"] ] ||= []
            none_target[ c["Prefecture"] ] << pagename
            next
         end
         capacity_str = if c["Capacity"]
                           if c["Capacity"] =~ /^\d+$/
                              "*最大#{ c["Capacity"] }名 収容可能"
                           else
                              "*" << c["Capacity"]
                           end
                        else
                           ""
                        end
         updated = nil
         if c["UpdateDate"]
            updated = "更新 #{ c["UpdateDate"] }"
            updated << " " + c["UpdateTime"].to_s.gsub( /:00$/, "" ) if c["UpdateTime"]
         elsif c["Updated"]
            updated = c["Updated"]
         end
         data[ pagename ] ||= {}
         %w[ Prefecture City District LatLng ].each do |k|
            key = k.downcase.intern
            #p [ k , key, c[k] ]
            if data[ pagename ][ key ].nil? or data[ pagename ][ key ].empty?
               val = c[k]
               if val and val.size > 0
                  data[ pagename ][ key ] = val
               end
            end
         end
         if data[ pagename ][ :capacity_str ].nil? or data[ pagename ][ :capacity_str ].empty?
            if capacity_str and capacity_str.size > 0
               data[ pagename ][ :capacity_str ] = capacity_str
            end
         end
         data[ pagename ][ :size ] ||= []
         size_s = ""
         size_s << "*避難者#{ c["Population"] }名 #{ "（#{ updated }）" if updated }" if c["Population"]
         size_s << "※#{ c["Notes"] }" if c["Notes"]
         data[ pagename ][ :size ] << size_s
         data[ pagename ][ :source ] ||= []
         data[ pagename ][ :source ] << "*[http://shelter-info.appspot.com/maps Google避難所情報]#{ c["Source"] ? ", #{ c["Source"] }" : "" } #{ "（#{ updated }）" if updated }"
         done[ c["Prefecture"] ] ||= []
         done[ c["Prefecture"] ] << pagename
      end
   end
   data.each do |pagename, data|
      open( "#{ pagename }.txt", "w" ) do |io|
         io.print <<EOF
{{subst:新規施設
| 名称=#{ pagename }
| よみ=
| 都道府県=#{ data[:prefecture] }
| 施設種別=公民館
| 所在地  =#{ data[:prefecture] }#{ data[:city] }#{ data[:district] }
| 緯度経度=#{ data[:latlng] }
| 電話番号=
| FAX=
| メールアドレス=
| URL=
| Twitterアカウント=
| 備考=
| 被害状況=
| 職員・利用者の被害=
| 施設の被害=
| コレクションの被害=
| その他の被害=
| 運営情報=
| 救援状況=
| 避難受入情報=
| 避難受入規模=#{ data[:size].uniq.join("\n") }
#{ data[:capacity_str] ? "*" + data[:capacity_str] : "" }
| その他=
| 記入者=
| 元情報=#{ data[:source].uniq.join("\n") }
}}
EOF
      end
   end
   done.each_key do |k|
      puts "*#{k}"
      puts "**対象施設 (#{done[k].uniq.size}): #{done[k].uniq.map{|e| "[[#{ e }]]" }.join(", ") }"
      puts "**非公民館施設 (#{none_target[k].uniq.size}): #{none_target[k].uniq.map{|e| "[[#{ e }]]" }.join(", ") }"
   end
end
