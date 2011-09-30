#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "cgi"
require "uri"

ARGV.each do |f|
   html = open( f ){|io| io.read }
   html_results = html.split( /<h3/ )
   html_results.shift
   html_results.each_with_index do |s,i|
      title = nil
      if s =~ /\A.*?<a href="([^"]*)"/
         url = CGI.unescapeHTML( $1 )
         uri = URI.parse( url )
         if uri.respond_to?( :request_uri )
            title = uri.request_uri.gsub( /\A\/wiki\//, "" )
            title = URI.unescape( title )
            cache_url = CGI.unescapeHTML( $1 ) if s =~ /\A.*?<a href="([^"]*)"[^>]*>キャッシュ/
            puts [ title, url, cache_url ].join("\t")
         else
            puts "WARN: url is not for 'http://' (#{ uri })"
         end
      else
         puts "WARN: html does not include anchor"
      end
   end
end
