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

code3 =
  'CLC\n'\
  'LDA $20\n'\
  'ADC $22\n'\
  'STA $24\n'\
  'LDA $21\n'\
  'ADC $23\n'\
  'STA $25'\

code = code2


code.split('\n').each { |line| puts line }
puts '-----------------------------------'

CPU.init
CPU.execute(code)
CPU.dump
