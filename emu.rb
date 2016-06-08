require './lib/nes'

asm = NES::ASM.new(ARGV[0])
asm.compile

cpu = NES::CPU.new
cpu.load(asm.bytes)
cpu.run
puts cpu.dump
