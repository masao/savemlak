#!/usr/bin/env ruby
# $Id$

count = {}
ARGF.each do |line|
   if line =~ /\A(201\d-\d\d)/
      m = $1
      count[ m ] ||= {}
      date, title, sections, categories, = line.chomp.split( /\t/ )
      sections.split( /,/ ).each do |sec|
         count[ m ][ sec ] ||= 0
         count[ m ][ sec ] += 1
      end
   end
end

count.keys.sort.each do |m|
   data = count[ m ]
   data.keys.sort.each do |sec|
      val = data[ sec ]
      puts [ m, sec, val ].join( "\t" )
   end
end
