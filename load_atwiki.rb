#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

# http://www45.atwiki.jp/savelibrary/editx/30.html

require "open-uri"
require "pp"

$KCODE = "u"

KML_HEADER = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://earth.google.com/kml/2.2">
<Document>
  <name>図書館被害状況マップ</name>
  <description><![CDATA[東日本大地震による図書館の被災情報・救援情報
http://www45.atwiki.jp/savelibrary
にまとめられている情報を地図上で並べてみることができます。

※更新は手動なので、最新情報に追い付いていません。最新はウィキ上の情報を確認するようにしてください。
]]></description>
  <Style id="style1">
    <IconStyle>
      <Icon>
        <href>http://maps.gstatic.com/intl/ja_jp/mapfiles/ms/micons/blue-dot.png</href>
      </Icon>
    </IconStyle>
  </Style>
EOF
KML_FOOTER = <<EOF
</Document>
</kml>
EOF

BASEURL = "http://www45.atwiki.jp/savelibrary/editx/"

class String
   def escape_xml
      self.gsub( /&/, "&amp;" ).gsub( /</, "&lt;" ).gsub( />/, "&gt;" )
   end
end

libraries = []
%w[ 21.html ].each do |url|
   cont = open( BASEURL + url ){|io| io.read }
   if cont.match( /<textarea\s+name="source"[^>]*>(.*?)<\/textarea>/m )
      wikitext = $1
      lines = wikitext.strip.split( /\r?\n/ )
      data = {}
      lines.each do |line|
         case line
         when /\A(\*+)\s*(.*)\Z/
            section, text = $1, $2
            text = text.gsub( /&gt;/, ">" ).gsub( /&lt;/, "<" ).gsub( /&amp;/, "&" )
            next if section.size == 1
            if section.size == 2
               if not data.empty?
                  libraries << data
                  data = {}
               end
               data[ :title ] = text
            else
               #label1, text = text.split( /[:：]/, 2 )
               #if text and not text.empty?
               #   #text = text.join( ":" ) if text.respond_to?( :join )
               #   data[ label1 ] = text
               #end
               data[ :text ] ||= []
               data[ :text ] << text
            end
         when ""
            if not data.empty?
               libraries << data
               data = {}
               #puts "--"
            end
         end
      end
      if not data.empty?
         libraries << data
      end
   end
end
puts KML_HEADER
libraries.each do |lib|
   next if lib.empty?
   next if lib[:title] and lib[:title] == "図書館名"
   next if lib[:title] and lib[:title] =~ /\A参考（上記に掲載されていない(公共|大学)図書館）\Z/
   if lib[ :title ].nil?
      warn lib.inspect
      next
   end
   if lib[ :text ].nil?
      warn lib.inspect
   end
   puts <<EOF
<Placemark>
  <name>#{ lib[:title].escape_xml }</name>
  <description><![CDATA[<div dir="ltr">#{ lib[:text].join("<br>") }</div>]]></description>
</Placemark>
EOF
end
puts KML_FOOTER
