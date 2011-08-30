#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "uri"

$KCODE = "utf-8"

def parse_url( url )
   uri = nil
   begin
      uri = URI.parse( url )
   rescue URI::InvalidURIError => e
      if url.sub!( /[\s\)）　].*\Z/, "" )
         uri = URI.parse( url )
      else
         raise e
      end
   end
   uri
end

def fullpagename( title, ns = 0 )
   ns = ns.to_i
   case ns
   when 0
      title
   when 1
      "Talk:" << title
   when 2
      "User:" << title
   when 3
      "User talk:" << title
   when 4
      "saveMLAK:" << title
   when 5
      "saveMLAK talk:" << title
   when 6
      "File:" << title
   when 8
      "MediaWiki:" << title
   when 10
      "Template:" << title
   when 12
      "Help:" << title
   when 14
      "Category:" << title
   when 274
      "Widget:" << title
   when 108
      "Concept:" << title
   else
      raise "Unknown namespace: #{ ns }"
   end
end

if $0 == __FILE__
   count = {}
   ARGF.each do |line|
      page_id, url, title, ns, = line.chomp.split( /\t/ )
      uri = nil
      begin
         uri = parse_url( url )
      rescue URI::InvalidURIError => e
         warn "#{ e }\t#{ page_id }"
      rescue URI::InvalidComponentError => e
         warn "#{ e }\t#{ page_id }"
      end
      next if uri.nil?
      case uri.host
      when /twitter\.com\Z/
         next
      end
      count[ url ] ||= []
      count[ url ] << fullpagename( title, ns )
   end
   count.keys.sort_by{|e| -1 * count[e].size }.each do |url|
      puts [ url, count[url] ].join("\t")
   end
end
