require './lib/nes'

code = File.read(ARGV[0])

NES::CPU.init
dump = NES::CPU.assemble(code)

NES::CPU.load(dump)
NES::CPU.run
NES::CPU.dump
