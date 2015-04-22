require_relative 'lib/nes'
include NES

def to_dump(a)
  a.map { |e| e.to_i(16) }
end

code1 =
  'LDA #$01\n'\
  'TAX\n'\
  'ADC #$c4\n'\
  'LDY $0601\n'\
  'INX\n'
# decrement X loop
dump1 = to_dump(%w(a2 08 ca 8e 00 02 e0 03 d0 f8 8e 01 02 00))

#LDA #$80 STA $01 ADC $01
dump2 = to_dump(%w(a9 80 85 01 65 01))

# relative
dump3 = to_dump(%w(a9 01 c9 02 d0 02 85 22 00))

CPU.init
CPU.execute(code: nil, dump: dump3)
CPU.dump
