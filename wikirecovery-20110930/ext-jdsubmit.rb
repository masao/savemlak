#!/usr/bin/env ruby
# $Id$

hash = {}
url = nil
ARGF.each do |line|
   line.chomp!
   case line
   when /\A\|\s*\{\{jdsubmit\|url=(.*?)\}\}\Z/
      url = $1
      #p url
   when /\A\|\s*(\[\[.+)\Z/
      pages = $1
      pages.scan( /\[\[([^\]]+)\]\]/ ).each do |page|
         hash[ page ] ||= []
         hash[ page ] << url
      end
   end
end

hash.keys.sort.each do |page|
   puts <<EOF
|-
|[[#{ page }]]
|#{ hash[ page ].map{|e| e =~ /\.png\Z/ ? "[#{e}]" : e }.join( "\n" ) }
|
EOF
end

STDERR.puts hash.size
