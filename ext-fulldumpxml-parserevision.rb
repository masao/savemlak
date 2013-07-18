#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Usage:
#   % gzip -cd 20110918-savemlak-full.xml.gz | ./ext-fulldumpxml.rb

require "time"

require "rubygems"
require "libxml"

SECTION_MAPPING = {
   /被害状況|被災状況|被害情報|被災情報/o => :damage,
   /運営状況|運営情報/o => :operation,
   /救援状況|救援情報/o => :rescue,
   /避難受入状況|避難受入情報/o => :refuge,
   /その他|自由記述/o => :other,
   /情報源|記入者|元情報/o => :source,
}
FACILITY_REGEXP = /\{\{(施設|図書館|博物館)(.*?)\}\}/mo

def parse_facility( text )
   if FACILITY_REGEXP =~ text
      $2
   else
      nil
   end
end

def parse_sections( text )
   section = :first
   result = {}
   text = text.gsub( FACILITY_REGEXP ) do |m|
      result[ :basic ] = m
      ""
   end
   text.split( /\r?\n/ ).each do |line|
      if /\A==([^=].*?)==\s*\Z/o =~ line
         section_str = $1.strip
         key = SECTION_MAPPING.keys.find{|k| k =~ section_str }
         if key
            section = SECTION_MAPPING[ key ]
         else
            puts "WARNING: unknown section: '#{ section_str }'. ignored."
         end
      end
      next if line.empty?
      if not parse_category( line ).empty?
         result[ :category ] ||= []
         result[ :category ] << line
      else
         result[ section ] ||= []
         result[ section ] << line
      end
   end
   result
end

def parse_category( text )
   m = text.scan( /\[\[(?:Category|カテゴリ)\:(.+?)\]\]/io )
   m.flatten
end

if $0 == __FILE__
   opt_mode = :page
   opt_til_201207 = false
   while( ARGV[0] and ARGV[0] =~ /\A-/ ) do
      if ARGV[0] and ARGV[0] =~ /\A--?(section|revision)/
         opt_mode = :section
         ARGV.shift
      elsif ARGV[0] and ARGV[0] =~ /\A--?standard/
         opt_til_201207 = true
         ARGV.shift
      end
   end

   time = Time.now
   parser = LibXML::XML::Parser.io( ARGF )
   doc = parser.parse
   #puts Time.now - time
   doc.root.namespaces.default_prefix = 'mw'
   pages = doc.find( "//mw:page" )
   #puts pages.size

   count_page = {
      :total => 0,
      :type => {
         :museum => 0,
         :library => 0,
         :archives => 0,
         :kominkan => 0,
      },
      :pref => {},
   }
   count_revision = {
      :total => 0,
      :type => {
         :museum => 0,
         :library => 0,
         :archives => 0,
         :kominkan => 0,
      },
      :pref => {},
   }

   pages.each do |page|
      next if not page.find( "./mw:ns" )[0].content == "0"
      revisions = page.find( "./mw:revision" ).to_a
      title = page.find( "./mw:title" )[0].content
      #puts [title, revisions.size].join("\t")
      revisions = revisions.find_all do |r|
         text = r.find( "./mw:text" )[0].content
         text =~ /\{\{(施設|図書館)\s*/o and not text =~ /\A#(REDIRECT|転送)/o
      end
      if opt_til_201207
      revisions = revisions.find_all do |r| # 2012-07-01以降のものは無視する
         timestamp = r.find( "./mw:timestamp" )[0].content
         timestamp < "2012-07-01"
      end
      end
      next if revisions.empty?

      count_page[ :total ] += 1
      count_revision[ :total ] += revisions.size

      latest_text = revisions[-1].find( "./mw:text" )[0].content
      categories = parse_category( latest_text )
      categories.each do |cat|
         case cat
            # 館種カウント:
         when "図書館"
            count_page[ :type ][ :library ] += 1
            count_revision[ :type ][ :library ] += revisions.size
         when "博物館", "美術館"
            count_page[ :type ][ :museum ] += 1
            count_revision[ :type ][ :museum ] += revisions.size
         when "公民館"
            count_page[ :type ][ :kominkan ] += 1
            count_revision[ :type ][ :kominkan ] += revisions.size
         when "文書館"
            count_page[ :type ][ :archives ] += 1
            count_revision[ :type ][ :archives ] += revisions.size
            # 都道府県カウント
         when /(都|道|府|県)\Z/
            count_page[ :pref ][ cat ] ||= 0
            count_page[ :pref ][ cat ] += 1
            count_revision[ :pref ][ cat ] ||= 0
            count_revision[ :pref ][ cat ] += revisions.size
         else
            # puts "# unknown cat: #{ cat.inspect }"
         end
      end

      if opt_mode == :section
         text, prev_text = nil
         revisions.each_with_index do |revision, i|
            edit_type = []
            timestamp = revision.find( "./mw:timestamp" )[0].content
            date = Time.parse( timestamp ).localtime.iso8601[ 0, 10 ]
            contributor = revision.find( "./mw:contributor" )[0]
            user = contributor.content
            if contributor.find( "./mw:username" ) and contributor.find( "./mw:username" )[0]
               user = contributor.find( "./mw:username" )[0].content
               if revision.find( "./mw:comment" ) and revision.find( "./mw:comment" )[0] and revision.find( "./mw:comment" )[0].content == "ロボットによる編集: check Yomi field"
                  user = contributor.find( "./mw:username" )[0].content + ":yomi"
               end
            elsif contributor.find( "./mw:ip" ) and contributor.find( "./mw:ip" )[0]
               user = contributor.find( "./mw:ip" )[0].content
            end

            text = revision.find( "./mw:text" )[0].content

            if i == 0
               edit_type << :new
            else
               sections = parse_sections( text )
               prev_sections = parse_sections( prev_text )
               sections.each do |sec, content|
                  if content != prev_sections[ sec ]
                     #if sec == :basic
                     #   p [ content, prev_sections[ sec ]]
                     #end
                     edit_type << sec
                  end
               end
            end

            if opt_mode == :section
               puts [ date, title,
                 edit_type.join(","),
                 user,
                 categories.join(",") ].join( "\t" )
            end

            prev_text = text
         end
      end
      if opt_mode == :page
         puts [ title, revisions.size, categories.join(",") ].join( "\t" )
      end
   end

   if opt_mode == :page
      STDERR.puts "Page statistics:"
      STDERR.puts "- Total: #{ count_page[ :total ]  }"
      STDERR.puts "- Subtotal by Type:"
      count_page[ :type ].each do |k,v|
         STDERR.puts [ k, v ].join( "\t" )
      end
      STDERR.puts "Subtotal by Prefecture:"
      count_page[ :pref ].each do |k,v|
         STDERR.puts [ k, v ].join( "\t" )
      end
      STDERR.puts "Revision statistics:"
      STDERR.puts "- Total: #{ count_revision[ :total ] }"
      STDERR.puts "- Subtotal by Type:"
      count_revision[ :type ].each do |k,v|
         STDERR.puts [ k, v ].join( "\t" )
      end
      STDERR.puts "Subtotal by Prefecture:"
      count_revision[ :pref ].each do |k,v|
         STDERR.puts [ k, v ].join( "\t" )
      end
   end
end
