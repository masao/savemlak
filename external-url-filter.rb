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

if $0 == __FILE__
   count = {}
   ARGF.each do |line|
      page_id, url, = line.chomp.split( /\t/ )
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
      count[ url ] << page_id
   end
   count.keys.sort_by{|e| -1 * count[e].size }.each do |url|
      puts [ url, count[url] ].join("\t")
   end
end
