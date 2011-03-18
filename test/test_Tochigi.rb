#!/usr/bin/env ruby

require "test/unit"
require "pp"

require "load_atwiki.rb"

class TestAtwiki < Test::Unit::TestCase
   def test_load_atwiki_Tochigi_Univ_Sakushin
      data = load_atwiki_data( [ 
         { :name => "Tochigi", :pref => "栃木県", :wikiname => "26.html" },
      ] )
      assert( data[ "Tochigi" ] )
      assert( data[ "Tochigi" ].size > 0 )
      #pp data[ "Tochigi" ]
      library = data[ "Tochigi" ].find{|e| e[:title] =~ /作新学院大学/ }
      assert( library, "There is no Sakushin Univ Library. (It may be changed in its name.)" )
      assert( library[ :calil ], "There is no Calil info for Sakushin Univ Library." )
   end
end
