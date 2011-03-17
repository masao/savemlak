#!/usr/bin/env ruby

require "test/unit"
require "pp"

require "load_atwiki.rb"

class TestAtwiki < Test::Unit::TestCase
   def test_load_atwiki
      data = load_atwiki_data( [ 
   { :name => "Tokyo", :pref => "東京都", :wikiname => "14.html" },
      ] )
      assert( data[ "Tokyo" ] )
      assert( data[ "Tokyo" ].size > 0 )
      #pp data[ "Tokyo" ]
      tachikawa_library = data[ "Tokyo" ].find{|e| e[:title] === "立川市中央図書館" }
      assert( tachikawa_library, "There is no Tachikawa Library." )
      assert( tachikawa_library[ :calil ], "There is no Calil info for Tachikawa Library." )
      assert_equal( "104255",
                    tachikawa_library[ :calil ].find( "./libid" )[0].content, 
                    "Calil libid must be '104255' for Tachikawa Library." )
   end
end
