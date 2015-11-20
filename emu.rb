require './lib/nes'

code1 =
  'label:',
  'LDA #$01',
  'TAX',
  'ADC #$c4',
  'LDY $0201',
  'INX'


code2 =
  'LDX #$08',
  'decrement:',
  'DEX',
  'STX $0200',
  'CPX #$03',
  'BNE decrement',
  'STX $0201',
  'BRK'

code3 =
  'LDA #$01',
  'CMP #$02',
  'BNE notequal',
  'STA $22',
  'notequal:',
  'BRK'

code4 =
  'JSR init',
  'JSR loop',
  'JSR end',
  'init:',
  'LDX #$00',
  'RTS',
  'loop:',
  'INX',
  'CPX #$05',
  'BNE loop',
  'RTS',
  'end:',
  'BRK'

dump1 = to_dump(%w(a2 08 ca 8e 00 02 e0 03 d0 f8 8e 01 02 00))
dump2 = to_dump(%w(a9 80 85 01 65 01 00))
dump3 = to_dump(%w(a9 01 c9 02 d0 02 85 22 00))
dump4 = to_dump(%w(a9 01 8d 00 00 a2 03 ca ec 00 00 d0 fa ac 00))
dump5 = to_dump(%w(a9 00 a8 18 71 70 c8 c0 05 d0 f8 60))
dump6 = to_dump(%w(a9 01 c9 02 d0 02 85 22 00))
dump7 = to_dump(%w(a9 01 85 f0 a9 cc 85 f1 6c f0 00))
dump8 = to_dump(%w(a2 01 a9 05 85 01 a9 02 85 02 a0 0a 8c 05 02 a1 00))
dump9 = to_dump(%w(a0 01 a9 03 85 01 a9 07 85 02 a2 0a 8e 04 07 b1 01))
dump10 = to_dump(%w(a2 00 a0 00 8a 99 00 06 48 e8 c8 c0 10 d0 f5 68 99 00 06 c8 c0 60 d0 f7))

NES::CPU.init
dump = NES::CPU.assemble(code4).map { |e| e.to_hex }.join(' ')
NES::CPU.load(to_dump(dump.split))
puts dump
#NES::CPU.load(dump9)
#puts NES::CPU.disassemble
#NES::CPU.execute
#NES::CPU.dump
