#!/usr/bin/env ruby

require "test/unit"
require "pp"

require "load_atwiki.rb"

class TestAtwiki_Akita < Test::Unit::TestCase
   def setup
      data = load_atwiki_data( [ 
         { :name => "Akita", :pref => "秋田県", :wikiname => "25.html" },
      ] )
      @data = data[ "Akita" ]
   end
   def test_load_atwiki_Akita_Univ_OUJ
      assert( @data )
      assert( @data.size > 0 )
      #pp data[ "Akita" ]
      library = @data.find{|e| e[:title] === "放送大学　秋田学習センター" }
      assert( library, "There is no OUJ Library. (It may be changed in its name.)" )
      assert( library[ :calil ], "There is no Calil info for OUJ Library." )
   end
   def test_load_atwiki_Akita_Univ_Health
      library = @data.find{|e| e[:title] =~ /秋田栄養短期大学/ }
      #pp library
      assert( library, "There is no Akita Health Univ Library. (It may be changed in its name.)" )
      assert( library[ :calil ], "There is no Calil info for Akita Health Univ Library." )
   end
end
