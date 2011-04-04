#!/usr/bin/env ruby

require "test/unit"
require "pp"

require "load_atwiki.rb"

class TestAtwiki_Tokyo_NDL < Test::Unit::TestCase
   def setup
      data = load_atwiki_data( [ 
         { :name => "Tokyo (NDL)", :pref => "東京都", :wikiname => "53.html" },
      ] )
      @data = data[ "Tokyo (NDL)" ]
   end
   def test_load_atwiki_Tokyo_NDL_AFFRIC_Tsukuba
      assert( @data )
      assert( @data.size > 0 )
      #pp data[ "Tokyo_NDL" ]
      library = @data.find{|e| e[:title] === "農林水産省図書館農林水産技術会議事務局筑波事務所分館(農林水産研究情報総合センター)" }
      assert( library, "There is no AFFRIC Tsukuba Center. (It may be changed in its name.)" )
      assert( library[ :calil ], "There is no Calil info for AFFRIC Tsukuba Center." )
   end
end
