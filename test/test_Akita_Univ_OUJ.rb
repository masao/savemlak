#!/usr/bin/env ruby

require "test/unit"
require "pp"

require "load_atwiki.rb"

class TestAtwiki < Test::Unit::TestCase
   def test_load_atwiki_Tokyo_Tachikawa
      data = load_atwiki_data( [ 
         { :name => "Akita", :pref => "秋田県", :wikiname => "25.html" },
      ] )
      assert( data[ "Akita" ] )
      assert( data[ "Akita" ].size > 0 )
      #pp data[ "Akita" ]
      library = data[ "Akita" ].find{|e| e[:title] === "放送大学　秋田学習センター" }
      assert( library, "There is no OUJ Library. (It may be changed in its name.)" )
      assert( library[ :calil ], "There is no Calil info for OUJ Library." )
   end
end
