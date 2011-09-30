#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

# google-cache.tsv にある URL からコンテンツを取得して、ファイルとして保存する。

require "open-uri"

ARGF.each do |line|
   title, url, cache_url, = line.chomp.split( /\t/ )
   fname = "cache/#{ title.gsub( /\//, "__" ) }.html"
   next if cache_url.nil?
   next if File.exist?( fname )

   p cache_url
   cont = nil
   begin
      cont = open( cache_url ){|io| io.read }
   rescue OpenURI::HTTPError => e
      cont = e.message
   end
   open( fname, "w" ){|io| io.print cont }
end
