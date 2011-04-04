#!/usr/bin/env ruby

require "rubygems"
require "fastercsv"
require "./load_atwiki.rb"

if $0 == __FILE__
   libraries = load_atwiki_data(
#   { :name => "Iwate", :pref => "岩手県", :wikiname => "21.html" },
#   { :name => "Miyagi", :pref => "宮城県", :wikiname => "20.html" },
)
   csv = FasterCSV.open( "savelibrary.csv", "w" )
   csv << [ :Coordinates, :Prefecture, *LIB_FIELDS ]  # header
   libraries.each do |pref, array|
      array.each do |e|
         next if e[ :title ].nil?
         text = {}
         prev_field = nil
         if e[ :text ]
         e[ :text ].each do |line|
            line.gsub!( /\[\[([^\]]+?)>((?:https?|ftp):\/\/[^\]]+?)\]\]/ ){|m| "[#{$2} #{$1}]" }
            field = LIB_FIELDS.find do |f|
               line.gsub!( /\A#{ f }[：:※　\s]*(記載なし|不明)?[。]?\s*/, "" )
            end
            field = prev_field if field.nil? and prev_field
            if field
               text[ field ] ||= []
               text[ field ] << line
            else
               text[ :default ] ||= []
               text[ :default ] << line               
            end
            prev_field = field
         end
         end
         geocode = e[ :calil ].find( "./geocode" )[0].content if e[ :calil ]
         if geocode
            csv << [ geocode, e[:pref], e[:title], 
                 text[:default].to_a.join("\n"), 
                 *( LIB_FIELDS.map{|f| text[f].to_a.join("\n").strip } )
            ]
         end
      end
   end
end

