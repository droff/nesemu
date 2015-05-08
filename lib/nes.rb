require_relative 'nes/cpu'
require_relative 'nes/cpu/instructions'
require_relative 'nes/memory'

module NES
end

module NESMP
	def to_hex
		if self
      (self > 0xff ? "%04X" : "%02X") % self
    else
      ''
    end
	end
end

Fixnum.include(NESMP)
NilClass.include(NESMP)

def to_dump(a)
  a.map { |e| e.to_i(16) }
end