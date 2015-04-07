require_relative 'lib/nes'
include NES

CPU.init

CPU.sed

CPU.lda(0x01)
CPU.sta(0x0200)

CPU.lda(0x05)
CPU.sta(0x201)

CPU.lda(0x08)
CPU.sta(0x0202)

CPU.dump
