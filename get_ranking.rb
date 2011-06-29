#!/usr/bin/env ruby
# $Id$

$:.push( File.dirname( $0 ) )
require "get_json.rb"
require "rubygems"
require "json"

# Get a weekly ranking.

if $0 == __FILE__
   # Specify a start day of a week.
   date = ARGV[0] ? Date.parse( ARGV[0] ) : ( Date.today - 7 )
   puts "Get a ranking since #{ date }..."
   users = Hash.new( 0 )
   7.times do |i|
      save_json_onday( date + i )
      Dir.glob( "#{ date + i }*.json" ) do |f|
         json = JSON.load( open( f ) )
         changes = json["query"]["recentchanges"]
         changes.each do |e|
            users[ e["user"] ] += 1
         end
      end
   end
   users.keys.sort_by{|e| -1 * users[e] }[ 0...20 ].each_with_index do |u, i|
      puts [ i+1, u, users[ u ] ].join( "\t" )
   end
end
