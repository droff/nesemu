require './lib/nes'

code = File.read(ARGV[0])

NES::CPU.init
dump = NES::CPU.assemble(code).map { |e| e.to_hex }.join(' ')
NES::CPU.load(to_dump(dump.split))


#NES::CPU.load(dump)
puts NES::CPU.disassemble
NES::CPU.execute
NES::CPU.dump
