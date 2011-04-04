#!/usr/bin/env ruby

require "test/unit"
require "pp"

require "load_atwiki.rb"

class TestAtwiki_Nagono < Test::Unit::TestCase
   def setup
      data = load_atwiki_data( [ 
         { :name => "Nagano", :pref => "長野県", :wikiname => "29.html" },
      ] )
      @data = data[ "Nagano" ]
   end
   def test_load_atwiki_Nagano_Nagano
      assert( @data )
      assert( @data.size > 0 )
      #pp @data
      library = @data.find{|e| e[:title] =~ /長野市立図書館/ }
      assert( library, "There is no Nagano City Library. (It may be changed in its name.)" )
      assert( library[ :calil ], "There is no Calil info for Nagano City Library." )
      assert_equal( "102507",
                    library[ :calil ].find( "./libid" )[0].content,
                    "Nagano City Library's Calil ID must be '102507'." )
   end
end
