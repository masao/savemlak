#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

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
      puts title if text == "ここに本文が入ります。"
   end
end
