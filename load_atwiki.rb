#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

# http://www45.atwiki.jp/savelibrary/editx/30.html

require "uri"
require "open-uri"
require "pp"

require "rubygems"
require "libxml"

$KCODE = "u"

KML_HEADER = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://earth.google.com/kml/2.2">
<Folder>
  <name>図書館被害状況マップ</name>
  <description><![CDATA[東日本大地震による図書館の被災情報・救援情報
http://www45.atwiki.jp/savelibrary
にまとめられている情報を地図上で並べてみることができます。

※30分おきに更新します。ただし、一部読み込みに失敗することがあります。最新はウィキ上の情報を確認するようにしてください。
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
</Folder>
</kml>
EOF

BASEURL = "http://www45.atwiki.jp/savelibrary/editx/"
CALIL_BASEURL = "http://api.calil.jp/library?pref="

PREF_LIBRARIES = {
   "Iwate" => "21.html",
   "Miyagi" => "20.html",
   "Fukushima" => "22.html",
   "Yamagata" => "24.html",
   "Akita" => "25.html",
   "Aomori" => "27.html",
   "Ibaraki" => "23.html",
   "Gunma" => "34.html",
   "Tochigi" => "26.html",
   "Hokkaido" => "30.html",
   "Tokyo" => "14.html",
   "Saitama" => "32.html",
   "Chiba" => "16.html",
   "Kanagawa" => "15.html",
   "Nagano" => "29.html",
   "Niigata" => "28.html",
}

class String
   def escape_xml
      self.gsub( /&/, "&amp;" ).gsub( /</, "&lt;" ).gsub( />/, "&gt;" )
   end
end

def load_calil_xml( basename )
   cont = open( basename + ".xml" ){|io| io.read }
   parser = LibXML::XML::Parser.string( cont )
   doc = parser.parse
   calil_info = doc.find( "//Library" )
end

libraries = {}
PREF_LIBRARIES.each do |pref, url|
   STDERR.puts pref
   libraries[ pref ] ||= []
   calil_info = load_calil_xml( pref )
   calil_add_info = load_calil_xml( pref + "_add" )
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
            text = text.gsub( /[　 ]+\Z/, "" )
            next if section.size == 1
            if section.size == 2
               if not data.empty?
                  libraries[pref] << data
                  data = {}
               end
               text = text.gsub( /\A[　 ]+/, "" )
               text = text.gsub( /\&aname\(\w+\)\{(.+?)\}/ ){|m| $1 }
               text = text.gsub( /\[\[(.+?)>[^\]]*\]\]/ ){|m| $1 }
               text = text.gsub( /\A\s*図書館名?[ 　]*/, "" )
               text = text.gsub( /[（\(]\d{4}\/\d{2}\/\d{2}\s*更新[）\)]\s*\Z/, "" )
               text = text.gsub( /[（\(][\d\/\:\-\s]*(更新|作成|記入)[）\)]\s*\Z/, "" )
               data[ :title ] = text
               data[ :pref ] = pref
               data[ :calil ] = calil_info.find do |e|
                  formal = e.find( "./formal" )[0].content.strip
                  short  = e.find( "./short" )[0].content.strip
                  ( text == formal ) or
                     ( text == short ) or
                     ( text.gsub( /[　 ・]/, "" ) == formal.gsub( /[　 ・]/, "" ) ) or
                     ( text.gsub( /市立/, "市" ) == formal.gsub( /市立/, "市" ) ) or
                     ( text.gsub( /\s*中央図書館\Z/, "図書館" ) == formal.gsub( /\s*中央図書館\Z/, "図書館" ) ) or
                     ( text.gsub( /\s*中央館\Z/, "" ) == formal.gsub( /\s*中央館\Z/, "" ) ) or
                     ( text.gsub( /([市区町村])?立?(中央)?図書館\Z/, '\1図書館' ) == formal.gsub( /([市区町村])?立?(中央)?図書館\Z/, '\1図書館' ) ) or
                     ( text.gsub( /本館\Z/, '' ) == formal.gsub( /本館\Z/, '' ) ) or
                     ( text.gsub( /ケ/, "ヶ" ) == formal.gsub( /ケ/, "ヶ" ) ) or
                     ( text.gsub( /\(.+?\)\Z/, "" ) == formal.gsub( /\(.+?\)\Z/, "" ) ) or
                     ( text == e.find( "./systemname" )[0].content )
               end
               if data[ :calil ].nil?
                  data[ :calil ] = calil_add_info.find do |e|
                     ( text == e.find( "./formal" )[0].content ) or
                        ( text == e.find( "./short" )[0].content )
                  end
               end
            else
               data[ :text ] ||= []
               data[ :text ] << text
            end
         when ""
            if not data.empty?
               libraries[pref] << data
               data = {}
               #puts "--"
            end
         end
      end
      if not data.empty?
         libraries[pref] << data
      end
   end
end
puts KML_HEADER
libraries.keys.sort.each do |pref|
   puts <<EOF
  <Document>
    <name>#{ pref.escape_xml }</name>
    <open>0</open>
EOF
   libraries[pref].each do |lib|
   next if lib.empty?
   next if lib[:title] and lib[:title].empty?
   next if lib[:title] and lib[:title] == "図書館名"
   next if lib[:title] and lib[:title] =~ /\A参考（上記に掲載されていない(公共|大学)図書館）\Z/
   next if lib[:title] and lib[:title] =~ /\A以下東北大学附属図書館の図書室/
   if lib[ :title ].nil?
      warn lib.inspect
      next
   end
   geocode = lib[ :calil ].find( "./geocode" )[0].content if lib[ :calil ]
   if geocode.nil?
      warn lib.inspect
      next
      geocode=""
   end
   if lib[ :text ].nil?
      warn lib.inspect
   end
   point = "<Point><coordinates>#{ geocode.escape_xml },0.000000</coordinates></Point>"
   puts <<EOF
<Placemark>
  <name>#{ lib[:title].escape_xml }</name>
  <description><![CDATA[<div dir="ltr">#{ lib[:text].to_a.join("<br>") }</div>]]></description>
  <styleUrl>#style1</styleUrl>
  #{ point }
</Placemark>
EOF
   end
   puts "</Document>"
end
puts KML_FOOTER
