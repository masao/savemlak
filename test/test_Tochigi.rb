#!/usr/bin/env ruby

require "test/unit"
require "pp"

require "load_atwiki.rb"

class TestAtwiki_Tochigi < Test::Unit::TestCase
   def setup
      data = load_atwiki_data( [
         { :name => "Tochigi (Utsunomiya)", :pref => "栃木県", :wikiname => "62.html" },
      ] )
      @data = data[ "Tochigi (Utsunomiya)" ]
   end
   def test_load_atwiki_Tochigi_Univ_Sakushin
      assert( @data )
      assert( @data.size > 0 )
      #pp @data
      library = @data.find{|e| e[:title] =~ /作新学院大学/ }
      assert( library, "There is no Sakushin Univ Library. (It may be changed in its name.)" )
      assert( library[ :calil ], "There is no Calil info for Sakushin Univ Library." )
   end
end
