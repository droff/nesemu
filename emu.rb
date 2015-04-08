require_relative 'lib/nes'
include NES

code =
  'LDA #$01\n'\
  'TAX\n'\
  'ADC #$c4\n'\
  'LDY $0601\n'

code.split('\n').each { |line| puts line}
puts '-----------------------------------'

CPU.init
CPU.execute(code)
CPU.dump
