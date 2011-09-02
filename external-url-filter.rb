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
   #ns = ns.to_i
   case ns
   when 0, "0"
      title
   else
      "{{ns:#{ ns }}}:#{ title }"
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
      next if uri.scheme == "mailto"
      case uri.host
      when /twitter\.com\Z/
         next
      end
      next if title =~ /\A(jdarchive\/seeds|Yegusa\/jdarchive)/
      count[ url ] ||= []
      count[ url ] << fullpagename( title, ns )
   end
   count.keys.sort_by{|e| [ -1 * count[e].size, e ] }.each do |url|
      puts [ url, count[url].map{|e| "[[#{ e }]]" }.sort.join(" ") ].join("\t")
   end
end
