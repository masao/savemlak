#!/usr/bin/env ruby

require "open-uri"
require "rubygems"
require "json"
require "pp"

URL= "http://savemlak.jp/savemlak/api.php?action=query&list=search&srsearch=NIMS&srwhat=text&limit=5&format=json"

open( URL ) do |io|
   cont = io.read 
   result = JSON.load( cont )
   if result[ "query" ][ "searchinfo" ][ "totalhits" ] < 2
      puts "WARNING: search hit for savemlak is shorten."
      pp result
      puts
      puts URL
   end
end
