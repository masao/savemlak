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
      pagename = city + name
      if not name =~ /公民館|コミュニティセンター/
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
| 避難受入情報=#{ population ? "*避難者#{ population }名 #{ update_date ? "（更新 #{ update_date }）" : "" }" : "" }#{ notes ? "," + notes : "" }
| 避難受入規模=#{ capacity_str }
| その他=
| 記入者=
| 元情報=*[http://shelter-info.appspot.com/maps Google避難所情報], #{ source } #{ update_date ? "（更新 #{ update_date } #{ update_time }）" : "" }
}}
EOF
      open( "#{ pagename }.txt", "w" ){|io| io.print template }
      done[ pref ] ||= []
      done[ pref ] << pagename
      puts notes
   end
   done.each_key do |k|
      puts "*#{k}"
      puts "**#{done[k].map{|e| "[[#{ e }]]" }.join(", ") }"
      puts "**:非対象施設: <small>#{none_target[k].map{|e| "[[#{ e }]]" }.join(", ") }</small>"
   end
end
