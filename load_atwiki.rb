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

PREF_LIBRARIES = [
   { :name => "Iwate", :pref => "岩手県", :wikiname => "21.html" },
   { :name => "Miyagi", :pref => "宮城県", :wikiname => "20.html" },
   { :name => "Fukushima", :pref => "福島県", :wikiname => "22.html" },
   { :name => "Yamagata", :pref => "山形県", :wikiname => "24.html" },
   { :name => "Akita", :pref => "秋田県", :wikiname => "25.html" },
   { :name => "Aomori", :pref => "青森県", :wikiname => "27.html" },
   { :name => "Ibaraki", :pref => "茨城県", :wikiname => "23.html" },
   { :name => "Gunma", :pref => "群馬県", :wikiname => "34.html" },
   { :name => "Tochigi", :pref => "栃木県", :wikiname => "26.html" },
   { :name => "Hokkaido", :pref => "北海道", :wikiname => "30.html" },
   { :name => "Chiba", :pref => "千葉県", :wikiname => "16.html" },
   { :name => "Tokyo", :pref => "東京都", :wikiname => "14.html" },
   { :name => "Tokyo (East)", :pref => "東京都", :wikiname => "54.html", :pagename => "東京都（城東地区）" },
   { :name => "Tokyo (West)", :pref => "東京都", :wikiname => "56.html", :pagename => "東京都（城西地区）" },
   { :name => "Tokyo (North)", :pref => "東京都", :wikiname => "55.html", :pagename => "東京都（城北地区）" },
   { :name => "Tokyo (Central)", :pref => "東京都", :wikiname => "58.html", :pagename => "東京都（都心部）" },
   { :name => "Tokyo (South)", :pref => "東京都", :wikiname => "57.html", :pagename => "東京都（城南地区）" },
   { :name => "Saitama", :pref => "埼玉県", :wikiname => "32.html" },
   { :name => "Kanagawa", :pref => "神奈川県", :wikiname => "15.html" },
   { :name => "Nagano", :pref => "長野県", :wikiname => "29.html" },
   { :name => "Niigata", :pref => "新潟県", :wikiname => "28.html" },
   { :name => "Shizuoka", :pref => "静岡県", :wikiname => "46.html" },
   { :name => "Yamanashi", :pref => "山梨県", :wikiname => "47.html" },
]

class String
   def escape_xml
      self.gsub( /&/, "&amp;" ).gsub( /</, "&lt;" ).gsub( />/, "&gt;" )
   end
end

def load_calil_xml( xml )
   parser = LibXML::XML::Parser.string( xml )
   doc = parser.parse
   calil_info = doc.find( "//Library" )
end

def load_atwiki_data( target = PREF_LIBRARIES )
libraries = {}
target.each do |pref|
   STDERR.puts pref[:name]
   libraries[ pref[:name] ] ||= []
   cont = open( CALIL_BASEURL + URI.escape(pref[:pref]) ){|io| io.read }
   calil_info = load_calil_xml( cont )
   cont = open( pref[:name].sub( /\s*\(.*\)\Z/, "" ) + "_add.xml" ){|io| io.read }
   calil_add_info = load_calil_xml( cont )
   cont = open( BASEURL + pref[:wikiname] ){|io| io.read }
   if cont.match( /<textarea\s+name="source"[^>]*>(.*?)<\/textarea>/m )
      wikitext = $1
      lines = wikitext.strip.split( /\r?\n/ )
      data = {}
      lines.each do |line|
         #p line
         case line
         when /\A(\*+)\s*(.*)\Z/
            section, text = $1, $2
            text = text.gsub( /&gt;/, ">" ).gsub( /&lt;/, "<" ).gsub( /&amp;/, "&" )
            text = text.gsub( /[　 ]+\Z/, "" )
            next if section.size == 1
            if section.size == 2
               if not data.empty?
                  libraries[pref[:name]] << data
                  data = {}
               end
               text = text.gsub( /\A[　 ]+/, "" )
               text = text.gsub( /\&aname\(\w+\)\{(.+?)\}/ ){|m| $1 }
               text = text.gsub( /\[\[(.+?)>[^\]]*\]\]/ ){|m| $1 }
               text = text.gsub( /\A\s*図書館名?[ 　]*/, "" )
               text = text.gsub( /[ 　]※.*?\s*\Z/, "" )
               text = text.gsub( /\s*-\s*\w*?\Z/, "" )
               text = text.gsub( /[（\(]([\d\/\:\-\s、]*(更新|作成|記入|草稿|追記|変更|現在|開館))*[）\)]\s*\Z/, "" )
               data[ :title ] = text
               data[ :pref ] = pref[:name]
               data[ :calil ] = calil_info.find do |e|
                  formal = e.find( "./formal" )[0].content.strip
                  short  = e.find( "./short" )[0].content.strip
                  #p [ formal, short ]
                  ( text == formal ) or
                     ( text == short ) or
                     ( text.gsub( /[　 ・「」\(\)]/, "" ) == formal.gsub( /[　 ・「」\(\)]/, "" ) ) or
                     ( text.gsub( /\A.+?県/, "" ) == formal.gsub( /\A.+?県/, "" ) ) or
                     ( text.gsub( /[市区町村]立?/, "" ) == formal.gsub( /[市区町村]立?/, "" ) ) or
                     ( text.gsub( /\s*中央図書館\Z/, "図書館" ) == formal.gsub( /\s*中央図書館\Z/, "図書館" ) ) or
                     ( text.gsub( /\s*(中央|本)館\Z/, "" ) == formal.gsub( /\s*(中央|本)館\Z/, "" ) ) or
                     ( text.gsub( /([市区町村])?立?(中央)?図書館\Z/, '\1図書館' ) == formal.gsub( /([市区町村])?立?(中央)?図書館\Z/, '\1図書館' ) ) or
                     ( text.gsub( /本館\Z/, '' ) == formal.gsub( /本館\Z/, '' ) ) or
                     ( text.gsub( /公民館[ 　]*図書室\Z/, '公民館' ) == formal.gsub( /公民館[ 　]*図書室\Z/, '公民館' ) ) or
                     ( text.gsub( /[　 ・「」\(\)]/, "" ).gsub( /学院大学/, '学院' ) == formal.gsub( /[　 ・「」\(\)]/, "" ).gsub( /学院大学/, '学院' ) ) or
                     ( text.gsub( /ケ/, "ヶ" ) == formal.gsub( /ケ/, "ヶ" ) ) or
                     ( text.gsub( /\(.+?\)\Z/, "" ) == formal.gsub( /\(.+?\)\Z/, "" ) ) or
                     ( text.gsub( /（.+?）\Z/, "" ) == formal.gsub( /（.+?）\Z/, "" ) ) or
                     ( text.gsub( /\s*-\s*.*?\Z/, "" ) == formal.gsub( /\s*-\s*.*?\Z/, "" ) ) or
                     ( text == e.find( "./systemname" )[0].content )
               end
               if data[ :calil ].nil?
                  data[ :calil ] = calil_add_info.find do |e|
                     formal = e.find( "./formal" )[0].content
                     ( text == formal ) or
                        ( text.gsub( /[　 ]（.+?）\Z/, "" ) == formal.gsub( /[　 ]（.+?）\Z/, "" ) ) or
                        ( text == e.find( "./short" )[0].content )
                  end
               end
            else
               data[ :text ] ||= []
               data[ :text ] << text
            end
         when /\A[\-]+(.+?)\Z/o
            if $1 and $1 != "-"
               data[ :text ] ||= []
               data[ :text ] << $1 
            end
         when ""
            if not data.empty?
               libraries[pref[:name]] << data
               data = {}
               #puts "--"
            end
         end
      end
      if not data.empty?
         libraries[pref[:name]] << data
      end
   end
end
libraries
end

if $0 == __FILE__
libraries = load_atwiki_data
puts KML_HEADER
PREF_LIBRARIES.each do |pref|
   puts <<EOF
  <Document>
    <name>#{ ( pref[:pagename ] or pref[:pref] ).escape_xml }</name>
    <open>0</open>
EOF
   libraries[pref[:name]].each do |lib|
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
end
