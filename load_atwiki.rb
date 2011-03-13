#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

# http://www45.atwiki.jp/savelibrary/editx/30.html

require "open-uri"
require "pp"

$KCODE = "u"

cont = open( "http://www45.atwiki.jp/savelibrary/editx/21.html" ){|io| io.read }
if cont.match( /<textarea\s+name="source"[^>]*>(.*?)<\/textarea>/m )
   wikitext = $1
   lines = wikitext.strip.split( /\r?\n/ )
   libraries = []
   data = {}
   lines.each do |line|
      case line
      when /\A(\*+)\s*(.*)\Z/
         section, text = $1, $2
         text = text.gsub( /&gt;/, ">" ).gsub( /&lt;/, "<" ).gsub( /&amp;/, "&" )
         next if section.size == 1
         if section.size == 2
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
   pp libraries
end
