#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "nkf"

class String
   def split_tabs
      NKF.nkf( "-EwZ1", self ).split( /\t/ )
   end
end

header = []
cols = ARGF.gets.chomp.split_tabs
cols.each do |col|
   case col
   when /\A\s*\|名称=/o
      header << :name
   when /\A\s*\|よみ=/o
      header << :yomi
   when /\A\s*\|所在地=/o
      header << :address
   when /\A\s*\|電話番号=/o
      header << :tel
   when /\A\s*\|FAX=/o
      header << :fax
   when /\A\s*\|メールアドレス=/o
      header << :email
   when /\A\s*\|URL=/o
      header << :url
   when /\A\s*\|備考=/o
      header << :note
   when /\A\s*\|== その他 ==/o
      header << :others
   else
      header << nil
   end
end
p header
ARGF.each do |line|
   data = {}
   array = line.chomp.split_tabs
   array.each_with_index do |e, i|
      #p header[i]
      if header[ i ]
         data[ header[i] ] = e
      else
         if e =~ /^\[\[Category:/i
            data[ :categories ] ||= []
            data[ :categories ] << e
         else
            warn "unknown column: #{ i }: #{ e }"
         end
      end
   end
   if data[ :others ]
      data[ :others ].gsub( /<br\s*\/>/i, "\n" ).strip
   end
   #next
   if not data[ :name ]
      p data
      next
   end
   #p data
   open( data[ :name ] + ".txt", "w" ) do |io|
      io.print <<EOF
{{施設
|名称=#{ data[ :name ] }
|よみ=#{ data[ :yomi ] }
|所在地=#{ data[ :address ] }
|緯度経度=
|電話番号=#{ data[ :tel ] }
|FAX=#{ data[ :fax ] }
|メールアドレス=#{ data[ :email ] }
|URL=#{ data[ :url ] }
|Twitterアカウント=
|備考=#{ data[ :note ] }
}}
== 被害状況 ==

=== 職員・利用者の被害 ===

=== 施設の被害 ===

=== 蔵書・収蔵品・展示の被害 ===

=== その他の被害 ===

== 運営情報 ==

== 救援状況 ==

== 避難受入情報 ==
=== 避難受入規模 ===

== その他 ==
#{ data[ :others ] }

== 情報源 ==
=== 記入者 ===

=== 元情報 ===

#{ data[ :categories ].join( "\n" ) }
EOF
   end
end
