require './lib/nes'

asm = NES::ASM.new(ARGV[0])
asm.compile
