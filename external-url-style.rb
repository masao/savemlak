#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

if $0 == __FILE__
   basename = nil
   if ARGV[0] =~ /\A-base:(.+)\Z/
      ARGV.shift
      basename = $1
   end

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
      # break if fname_split and i > 100
   end

   hash.keys.sort.each do |name|
      fname = name
      fname = "#{ basename }-#{ name }" if basename
      io = open( fname, "w" )
      io.print <<EOF
{{saveMLAK:jdarchive/seeds/doc}}
{| class="wikitable"
!URL
!登録フォーム
!リンク元ページ
!入力済み?
!備考
#{ hash[ name ] }
|}
[[Category:jdarchive/seeds]]
[[Category:jdarchive作業中]]
EOF
   end
end
