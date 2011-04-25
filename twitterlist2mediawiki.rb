#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "net/http"
require "time"
require "rubygems"
require "json"

LIST = "shima_mossa/mla-official-jpn"
API_BASEURL = "http://api.twitter.com/1/#{ LIST }/members.json"

if $0 == __FILE__
   puts <<EOF
以下, http://twitter.com/shima_mossa/mla-official-jpn にてまとめられたものを元にしています：
{|class="wikitable sortable"
!名称
!アカウント名
!登録地
!説明
!URL
!ツイート数
!フォロワー数
!フォロー数
!登録日
|-
EOF
   #p conf
   conf[ "user" ]
   conf[ "password" ]
   cursor = -1
   uri = URI.parse( API_BASEURL )
   Net::HTTP.start( uri.host, uri.port ) do |http|
      while true do
         uri = URI.parse( API_BASEURL + "?cursor=#{ cursor }" )
         req = Net::HTTP::Get.new( uri.request_uri )
         # req.basic_auth( conf["user"], conf["password"] )
         response = http.request( req )
         data = JSON.load( response.body )
         data[ "users" ].each do |user|
            puts <<EOF
|[[#{ user["name"].to_s.gsub( /\[/, "(" ).gsub( /\]/, ")" ) }]]
|[http://twitter.com/#{ user["screen_name"] } @#{ user["screen_name"] }]
|#{ user["location"] }
|#{ user["description"].to_s.gsub( /\|/, " " ).gsub( /\s+/, " " ).strip }
|#{ user["url"] }
|#{ user["statuses_count"] }
|#{ user["followers_count"] }
|#{ user["friends_count"] }
|#{ DateTime.parse( user["created_at"] ).strftime("%Y-%m-%d") }
|-
EOF
            #p user.keys
            #p user[ "screen_name" ]
         end
         #p data[ "next_cursor" ]
         if data[ "next_cursor" ] and data[ "next_cursor" ] > 0
            cursor = data[ "next_cursor" ]
         else
            break
         end
      end
      puts "|}"
   end
end
