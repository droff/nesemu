require_relative 'lib/nes'
include NES

code1 =
  'LDA #$01\n'\
  'TAX\n'\
  'ADC #$c4\n'\
  'LDY $0601\n'\
  'INX\n'

code2 =
  'LDA #$c0\n'\
  'TAX\n'\
  'INX\n'\
  'ADC #$c4\n'\
  'BRK\n'

code = code2


code.split('\n').each { |line| puts line}
puts '-----------------------------------'

CPU.init
CPU.execute(code)
CPU.dump
