#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

# ウィキ祭の統計情報を得るため、更新記録から一時間ごとの json ファイルを取得する
# wget "http://savemlak.jp/savemlak/api.php?action=query&list=recentchanges&rcstart=20110604020000&rcend=20110424150000&rcdir=newer&rclimit=500&rcprop=user|title|timestamp&format=json

# USAGE: ./get_json.rb 2011-06-04
## 当該日付を引数に指定すること。

require "date"
require "time"
require "open-uri"

require "rubygems"
require "json"

BASEURL = "http://savemlak.jp/savemlak/api.php?action=query&list=recentchanges&rcdir=newer&rclimit=500&rcprop=user%7Ctitle%7Ctimestamp&format=json"

def save_json_onday( date )
   time = Time.local( date.year, date.month, date.day ).gmtime
   #p date.to_s
   #p time
   24.times do |i|
      start_t = ( time + ( i * 60 * 60 ) ).strftime( "%Y%m%d%H%M%S" )
      end_t   = ( time + ( (i+1) * 60 * 60 ) ).strftime( "%Y%m%d%H%M%S" )
      p [ i, start_t, end_t ]
      json = get_json( start_t, end_t )
      json_obj = JSON.parse( json )
      if json_obj["query-continue"]
         start_t2 = Time.parse( json_obj["query-continue"]["recentchanges"]["rcstart"] ).strftime( "%Y%m%d%H%M%S" )
         json2 = get_json( start_t2, end_t )
         json_obj["query"]["recentchanges"] += JSON.parse( json2 )["query"]["recentchanges"]
         json = JSON.dump( json_obj )
      end
      open( "#{ date }-#{ "%02d" % i }.json", "w" ) do |io|
         io.print json
      end
   end
end
def get_json( start_t, end_t )
   json = open( BASEURL + "&rcstart=#{ start_t }&rcend=#{ end_t }" ) do |http|
      http.read
   end
end

if $0 == __FILE__
   date = ARGV[0] ? Date.parse( ARGV[0] ) : Date.today
   puts "getting data of #{ date.to_s }..."
   save_json_onday( date )
end
