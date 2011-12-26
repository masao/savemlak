#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "nkf"

ARGF.each do |line|
   # |名称=	|よみ=	|所在地=	|電話番号=	|FAX=	|メールアドレス=	|URL=	|備考=	== その他 ==
   name, yomi, address, tel, fax, email, url, note, others, *categories = NKF.nkf( "-EwZ1", line.chomp ).split( /\t/ )
   others = others.gsub( /<br\s*\/>/i, "\n" ).strip
   #puts others
   #p categories
   next if name =~ /^\|/o
   open( name + ".txt", "w" ) do |io|
      io.print <<EOF
{{施設
|名称=#{ name }
|よみ=#{ yomi }
|所在地=#{ address }
|緯度経度=
|電話番号=#{ tel }
|FAX=#{ fax }
|メールアドレス=#{ email }
|URL=#{ url }
|Twitterアカウント=
|備考=#{ note }
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
#{ others }

== 情報源 ==
=== 記入者 ===

=== 元情報 ===

#{ categories.join( "\n" ) }
EOF
   end
end
