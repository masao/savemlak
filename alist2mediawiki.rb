#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "kconv"
require "rubygems"
require "fastercsv"

$KCODE = "u"

if $0 == __FILE__
   cont = ARGF.read
   csv = FasterCSV.parse( cont.toutf8, { :headers => true } )
   csv.each do |c|
      pagename = c['| 名称=']
      pagename = NKF.nkf( "-WwZ1", pagename )
      pagename = pagename.gsub( /[\s]+/, " " ).strip.tr( '[]|/', '()  ' )
      pagename = pagename.sub( /\A\((株|財)\)/, "" )
      pref = c['| 都道府県=']
      if not pref
         if c['| 所在地='] =~ /\A\s*(?:〒?\d\d\d-?(?:\d\d\d\d)?)?\s*(.+?[都道府県])/
            pref = $1
         end
      end
      notes = [ c['|備考='] ]
      notes << "英名称: #{ c['英文タイトル'] }" if c['英文タイトル']
      notes << "(典拠: #{ c['典拠'] })" if c['典拠']
      input_exist = [
         c['| 被害状況='],
         c['| 職員・利用者の被害='],
         c['| 施設の被害='],
         c['| 収蔵品・展示の被害='],
         c['| その他の被害='],
         c['| 運営情報='],
         c['| 救援状況='],
         c['| その他=']
      ].compact
      open( pagename + ".txt", "w" ) do |io|
         io.print <<EOF
{{subst:新規施設
|英文タイトル=
| 名称=#{ pagename }
| よみ=#{ c['| よみ='] }
| 都道府県=#{ pref }
| 施設種別=#{ c['| 施設種別='] or "文書館" }
| 所在地=#{ c['| 所在地='] }
| 緯度経度=#{ c['| 緯度経度='] }
| 電話番号=#{ c['|電話='] }
| FAX=#{ c['|FAX='] }
| メールアドレス=#{ c['| メールアドレス='] }
| URL=#{ c['| URL='] }
| Twitterアカウント=#{ c['| Twitterアカウント='] }
| 備考=#{ notes.compact.join( "\n" ) }
| 被害状況=#{ c['| 被害状況='] }
| 職員・利用者の被害=#{ c['| 職員・利用者の被害='] }
| 施設の被害=#{ c['| 施設の被害='] }
| 収蔵品・展示の被害=#{ c['| 収蔵品・展示の被害='] }
| その他の被害=#{ c['| その他の被害='] }
| 運営情報=#{ c['| 運営情報='] }
| 救援状況=#{ c['| 救援状況='] }
| その他=#{ c['| その他='] }
| 情報源=#{ c['| 情報源='] }
| 記入者=#{ "*@artemismarch" if not input_exist.empty? }
| 元情報=#{ c['| 元情報='] }
}}
EOF
      end
   end
end
