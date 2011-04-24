#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "kconv"
require "rubygems"
require "fastercsv"

if $0 == __FILE__
   cont = ARGF.read
   csv = FasterCSV.parse( cont.toutf8 )

   done = {}
   none_target = {}
   csv.shift # skip first line (header).
   csv.each do |pref,area,city,district,name,population,capacity,update_date,update_time,source,notes,latlng,color|
      name.gsub!( /コミセン/, "コミュニティセンター" )
      city = "一関市" if city == "一関"
      city_n = city.gsub( /\A.*?郡/, "" )
      pagename = if name.index( city_n ) == 0
      		    name
		 else
		    city_n + name
		 end
      if not name =~ /公民館|コミュニティセンター|コミュニティー?センター?|市民センター|地区センター/
         none_target[ pref ] ||= []
	 none_target[ pref ] << pagename
	 next
      end
      capacity_str = if capacity
                        if capacity =~ /^\d+$/
                           "*最大#{ capacity }名 収容可能"
                        else
                           "*" << capacity
                        end
                     else
                        ""
                     end
      template = <<EOF
{{subst:新規施設
| 名称=#{ pagename }
| よみ=
| 都道府県=#{ pref }
| 施設種別=公民館
| 所在地  =#{ pref }#{ city }#{ district }
| 緯度経度=#{ latlng }
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
| 避難受入規模=#{ population ? "*避難者#{ population }名 #{ update_date ? "（更新 #{ update_date }）" : "" }" : "" }#{ notes ? "," + notes : "" }
#{ capacity_str }
| その他=
| 記入者=
| 元情報=*[http://shelter-info.appspot.com/maps Google避難所情報]#{ source ? ", #{ source }" : "" } #{ update_date ? "（更新 #{ update_date } #{ update_time.to_s.gsub( /:00$/, "" ) }）" : "" }
}}
EOF
      open( "#{ pagename }.txt", "w" ){|io| io.print template }
      done[ pref ] ||= []
      done[ pref ] << pagename
      #puts notes
   end
   done.each_key do |k|
      puts "*#{k}"
      puts "**対象施設 (#{done[k].size}): #{done[k].map{|e| "[[#{ e }]]" }.join(", ") }"
      puts "**非対象施設 (#{none_target[k].size}): #{none_target[k].map{|e| "[[#{ e }]]" }.join(", ") }"
   end
end