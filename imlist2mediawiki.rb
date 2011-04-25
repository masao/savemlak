#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "kconv"

if $0 == __FILE__
   ARGF.gets
   ARGF.each do |line|
      name, zipcode, address, phone, url, pref, = line.toutf8.chomp.split( /\t/ )
      name.tr!( '[]|', '() ' )
      open( name + ".txt", "w" ) do |f|
         f.puts <<EOF
{{subst:新規施設
|名称=#{ name }
|所在地=#{ zipcode } #{ address }
|URL=#{ url }
|都道府県=#{ pref }
|施設種別=博物館
|電話番号=#{ phone }
}}
EOF
      end
   end
end
