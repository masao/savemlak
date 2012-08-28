#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$:.push( File.dirname($0) )
require "local_government.rb"

require "rubygems"
require "libxml"

if $0 == __FILE__
   parser = LibXML::XML::Parser.io( ARGF )
   doc = parser.parse
   #puts Time.now - time
   doc.root.namespaces.default_prefix = 'mw'
   pages = doc.find( "//mw:page" )

   pages.each do |page|
      title = page.find( "./mw:title" )[0].content
      text = page.find( "./mw:revision/mw:text" )[0].content
      pref = nil
      if text == "ここに本文が入ります。"
         PREF.each do |k, v|
            if title.include? v
               pref = v
               break
            end
         end
         if not pref
            LOCAL.each do |k, v|
               next if v.empty?
               #p [ k, v ]
               if title.start_with? v
                  pref = PREF[ k[ 0, 2 ].to_i ]
                  #puts [ title, v ].join( "\t" )
                  break
               end
            end
         end
         cat = "[[Category:公共図書館]]"
         if pref.nil?
            pref = "○○県"
            cat = nil
         end

         #puts [ title, pref, cat ].join( "\t" )
         open( "#{ title }.txt", "w" ) do |io|
            io.print <<EOF
{{subst:新規施設
| 名称=#{ title }
| よみ=
| 都道府県=#{ pref }
| 施設種別=図書館
}}
#{ cat }
EOF
         end
      end
   end
end
