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
   puts [ identifier[0..4], LOCAL[ identifier[ 0..4 ] ], name ]
#    open( name + ".txt", "w" ) do |io|
#       print <<EOF
# {{subst:新規施設
# | 名称=#{ name }
# | 都道府県=#{ PREF[ pref_code ] }
# | 施設種別=公民館
# | 所在地=#{ "〒" if zipcode  }#{ zipcode } #{ address }
# | 電話番号=#{ tel }
# | FAX=#{ fax }
# | 備考=（典拠：全国公民館連合会調査・平成20年7月）
# }}
# EOF
#    end
end
