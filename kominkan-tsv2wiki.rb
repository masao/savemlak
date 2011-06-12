#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "nkf"

$:.push( File.dirname($0) )
require "local_government.rb"

ARGF.each do |line|
   note1, pref_code, identifier, name, zipcode, address, tel1, tel2, tel3, fax1, fax2, fax3, = NKF.nkf( "-SwZ1", line.chomp ).split( /\t/ )
   pref_code = pref_code.to_i
   #p [ note1, pref_code, identifier, name, zipcode, address, tel1, tel2, tel3, fax1, fax2, fax3 ] if not PREF[ pref_code ]
   case pref_code
   when 1..15, 22
   else
      next
   end
   #puts name
   tel = fax = nil
   if tel1 and tel2 and tel3
      tel = [ tel1, tel2, tel3 ].join( "-" )
   end
   if fax1 and fax2 and fax3
      fax = [ fax1, fax2, fax3 ].join( "-" )
   end
   pagename = name.sub( /\A#{ PREF[ pref_code ] }(.+郡)?/, "" )
   local_gov = LOCAL[ identifier[0..4] ]
   local_gov2 = local_gov.gsub( /ケ/, "ヶ" )
   #puts [local_gov, local_gov2]
   if local_gov == local_gov2
      local_gov2 = local_gov.gsub( /ヶ/, "ケ" )
   end
   if local_gov =~ /\A(.+市)(.+区)\Z/
      local_gov2 = $1.dup
   end
   if pagename[ 0...local_gov.size ] != local_gov and pagename[ 0...local_gov2.size ] != local_gov2
      #puts name[ 0...local_gov2.size ]
      pagename = local_gov + pagename
      #puts [ name, pagename ] if pagename[0..3] == name[0..3]
   end
   #puts [ identifier[0..4], LOCAL[ identifier[ 0..4 ] ], name, pagename ]
   #puts pagename

   # escaping invalid pagename:
   pagename = pagename.sub( /:/, "：" )
   pagename = pagename.sub( /[\[\(\<]/, " (" )
   pagename = pagename.sub( /[\]\)\>]/, " )" )

   # extracting note:
   note = ""
   pagename = pagename.sub( /[\s　]*(※.*)/ ) do |m|
      note = $1.dup
      ""
   end

   open( pagename + ".txt", "w" ) do |io|
      io.print <<EOF
{{subst:新規施設
| 名称=#{ pagename }
| 都道府県=#{ PREF[ pref_code ] }
| 施設種別=公民館
| 所在地=#{ "〒" if zipcode  }#{ zipcode } #{ address }
| 電話番号=#{ tel }
| FAX=#{ fax }
| 備考=（典拠：全国公民館連合会調査・平成20年7月）
#{ note }
}}
EOF
   end
end
