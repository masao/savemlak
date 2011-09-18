#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Usage:
#   % gzip -cd 20110918-savemlak-full.xml.gz | ./ext-fulldumpxml.rb [-all]

require "time"

require "rubygems"
require "libxml"

if $0 == __FILE__
   opt_all = false
   if ARGV[0] and ARGV[0] =~ /\A--?all\Z/
      opt_all = true
   end

   time = Time.now
   parser = LibXML::XML::Parser.io( STDIN )
   doc = parser.parse
   #puts Time.now - time
   doc.root.namespaces.default_prefix = 'mw'
   pages = doc.find( "//mw:page" )
   #puts pages.size

   pages.each do |page|
      revisions = page.find( "./mw:revision" ).to_a
      # puts revisions.size
      if revisions[0].find( "./mw:text" )[0].content == "ここに本文が入ります。"
         revisions.shift
      end
      next if revisions.empty?

      title = page.find( "./mw:title" )[0].content
      revisions.each_with_index do |revision, i|
         if i == 0 or opt_all
            timestamp = revision.find( "./mw:timestamp" )[0].content
            date = Time.parse( timestamp ).localtime.iso8601[ 0, 10 ]
            contributor = revision.find( "./mw:contributor" )[0]
            user = contributor.content
            if contributor.find( "./mw:username" ) and contributor.find( "./mw:username" )[0]
               user = contributor.find( "./mw:username" )[0].content
         elsif contributor.find( "./mw:ip" ) and contributor.find( "./mw:ip" )[0]
               user = contributor.find( "./mw:ip" )[0].content
            end
            puts [ date, title, user ].join( "\t" )
         end
      end
   end
end
