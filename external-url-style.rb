#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

hash = {}
ARGF.each_with_index do |line, i|
   fname = ( ( i/20 ) + 1 ).to_s
   url, pages, = line.chomp.split( /\t/ )
   if not hash[ fname ]
      hash[ fname ] = <<EOF
EOF
   end
   hash[ fname ] << <<EOF
|-
|[#{ url }]
|{{jdsubmit|url=#{ url }}}
|#{ pages }
|
|
EOF
   # break if i > 100
end

hash.each_key do |fname|
   open( fname, "w" ) do |io|
      io.print <<EOF
{{saveMLAK:jdarchive/seeds/doc}}
{| class="wikitable"
!URL
!登録フォーム
!リンク元ページ
!入力済み?
!備考
#{ hash[ fname ] }
|}
[[Category:jdarchive/seeds]]
[[Category:jdarchive作業中]]
EOF
   end
end
