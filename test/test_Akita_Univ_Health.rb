#!/usr/bin/env ruby

require "test/unit"
require "pp"

require "load_atwiki.rb"

class TestAtwiki_Akita < Test::Unit::TestCase
   def test_load_atwiki_Akita_Univ_Health
      data = load_atwiki_data( [ 
         { :name => "Akita", :pref => "秋田県", :wikiname => "25.html" },
      ] )
      assert( data[ "Akita" ] )
      assert( data[ "Akita" ].size > 0 )
      #pp data[ "Akita" ]
      library = data[ "Akita" ].find{|e| e[:title] =~ /秋田栄養短期大学/ }
      #pp library
      assert( library, "There is no Akita Health Univ Library. (It may be changed in its name.)" )
      assert( library[ :calil ], "There is no Calil info for Akita Health Univ Library." )
   end
end
