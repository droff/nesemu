require_relative 'lib/nes'
include NES

code = 'LDA #$01\n'\
	#'LDA $2000\n'

puts "-----"
code.split('\n').each { |line| puts line}
puts "-----"

CPU.init
CPU.execute(code)
CPU.dump
