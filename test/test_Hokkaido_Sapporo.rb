#!/usr/bin/env ruby

require "test/unit"
require "pp"

require "load_atwiki.rb"

class TestAtwiki < Test::Unit::TestCase
   def test_load_atwiki_Hokaido_Sapporo
      data = load_atwiki_data( [ 
         { :name => "Hokkaido", :pref => "北海道", :wikiname => "30.html" },
      ] )
      assert( data[ "Hokkaido" ] )
      assert( data[ "Hokkaido" ].size > 0 )
      pp data[ "Hokkaido" ]
      library = data[ "Hokkaido" ].find{|e| e[:title] === "札幌市中央図書館" }
      assert( library, "There is no Sapporo Library. (It may be changed in its name.)" )
      assert( library[ :calil ], "There is no Calil info for Sapporo  Library." )
   end
end
