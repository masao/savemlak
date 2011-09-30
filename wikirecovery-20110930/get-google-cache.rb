#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

# google-cache.tsv にある URL からコンテンツを取得して、ファイルとして保存する。

require "open-uri"

ARGF.each do |line|
   title, url, cache_url, = line.chomp.split( /\t/ )
   fname = "cache/#{ title.gsub( /\//, "__" ) }.html"
   next if cache_url.nil?
   if File.exist?( fname )
      puts "skip #{ title }."
      next
   end

   p cache_url
   cont = nil
   begin
      cont = open( cache_url ){|io| io.read }
   rescue OpenURI::HTTPError => e
      begin
         cache_uri = URI.parse( cache_url )
         if cache_uri.query =~ /q=cache:([^\:]+):([^\+\&]+)/
            param_c = $1
            param_u = $2
            yahoo_cache_url = "http://cache.yahoofs.jp/search/cache?c=#{ param_c }&p=site:savemlak.jp&u=#{ param_u }"
            p yahoo_cache_url
            cont = open( yahoo_cache_url ){|io| io.read }
         else
            puts "WARN: cache query pattern changed: #{ cache_uri.query }"
         end
      rescue OpenURI::HTTPError => e
         cont = e.message
      end
   end
   open( fname, "w" ){|io| io.print cont }
end
