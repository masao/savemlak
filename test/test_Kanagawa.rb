#!/usr/bin/env ruby

require "test/unit"
require "pp"

require "load_atwiki.rb"

class TestAtwiki_Kanagawa < Test::Unit::TestCase
   def setup
      data = load_atwiki_data( [ 
         { :name => "Kanagawa", :pref => "神奈川県", :wikiname => "15.html" },
      ] )
      @data = data[ "Kanagawa" ]
   end
   def test_load_atwiki_Kanagawa_
      assert( @data )
      assert( @data.size > 0 )
      #pp @data
      library = @data.find{|e| e[:title] =~ /大和市立図書館/ }
      assert( library, "There is no Yamato City Library. (It may be changed in its name.)" )
      assert( library[ :calil ], "There is no Calil info for Yamato City Library." )
      assert_equal( "101976",
                    library[ :calil ].find( "./libid" )[0].content,
                    "Yamato City Library's Calil ID must be '101976'." )
   end
end
