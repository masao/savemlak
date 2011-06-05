#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "rubygems"
require "json"

# get_json.rb で取得した JSON ファイルを解析して統計表形式に変換する
# 引数として、json ファイル名を指定すること
#
# USAGE: ./parse_json.rb *.json

puts <<EOF
{| class="wikitable sortable"
! nowrap | 時間帯
!編集回数
!編集ユーザ数
!編集ユーザ
EOF
count = 0
users = Hash.new(0)
ARGV.each do |f|
   changes = JSON.load( open(f) )["query"]["recentchanges"]
   changes.each do |e|
      users["[[特別:投稿記録/#{ e["user"] }|#{ e["user"] }]]"] += 1
   end
   puts <<EOF
|-
| #{ File.basename( f ).gsub(/\.json$/,"") }時台
| #{ changes.size }
| #{ users.size }
| #{ users.keys.sort_by{|e| users[e] }.reverse.join(", ") }
EOF
   count += changes.size
end
puts "|}"

STDERR.puts "#{ count } edits, #{ users.keys.size } users"
