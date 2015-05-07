require_relative 'lib/nes'
include NES

def to_dump(a)
  a.map { |e| e.to_i(16) }
end

code1 =
	'label:',
  'LDA #$01',
  'TAX',
  'ADC #$c4',
  'LDY $0601',
  'INX'
  #'BNE label'

code2 =
	'LDX #$08',
	'decrement:',
  'DEX',
  'STX $0200',
  'CPX #$03',
  'BNE decrement',
  'STX $0201',
  'BRK'

# loop X <= 3
dump1 = to_dump(%w(a2 08 ca 8e 00 02 e0 03 d0 f8 8e 01 02 00))
#LDA #$80 STA $01 ADC $01
dump2 = to_dump(%w(a9 80 85 01 65 01 00))
# relative
dump3 = to_dump(%w(a9 01 c9 02 d0 02 85 22 00))

CPU.init
#puts CPU.assemble(code1).map { |e| e.to_hex }.join(' ')
CPU.load(dump3)
CPU.execute

CPU.dump
