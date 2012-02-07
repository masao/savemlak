#!/usr/bin/env ruby

require "nkf"

ARGF.each do |line|
   isil, name, = line.chomp.split( /,/ )
   next if not isil =~ /\AJP-/ # skip non ISIL data line.
   name = NKF.nkf( "-SwZ1", name )
   puts name
   system( "./check_isil.py '-isil:#{ isil }' '-page:#{ name }' -always" )
end
