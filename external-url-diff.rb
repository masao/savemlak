#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Output only the newly arrival URLs in the latest savemlak-el-YYYYMMDDD.txt

if $0 == __FILE__
   hash = {}
   ARGV.pop
   #p ARGV
   ARGV.each do |f|
      open( f ) do |io|
         io.each do |line|
            page_id, url, = line.split( /\t/ )
            hash[ url ] = true
            if url.sub!( /[\s\)）　].*\Z/, "" )
               hash[ url ] = true
            end
         end
      end
   end
   #p hash.size
   #p hash[ "http://www.syokubutsuen-kyokai.jp/index.html" ]
   #p hash.keys
   STDIN.each do |line|
      url, = line.split( /\t/ )
      #p [ url, hash[url] ]
      if not hash[ url ]
         puts line
      end
   end
end
