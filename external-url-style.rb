#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

if $0 == __FILE__
   hash = {}
   fname_stdout = false
   if ARGV[0] == "-"
      ARGV.shift
      fname_stdout = true
   end
   ARGF.each_with_index do |line, i|
      if fname_stdout
         fname = "-"
      else
         fname = ( ( i/20 ) + 1 ).to_s
      end
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

   hash.keys.sort.each do |fname|
      if fname_stdout
         io = $stdout
      else
         io = open( fname, "w" )
      end
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
