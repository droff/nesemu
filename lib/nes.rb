require './lib/nes/cpu'
require './lib/nes/memory'

module NES
end

module NESMP
  def to_hex
    return '' unless self
    if self > 0xff
      printf("%02X %02X", lo, hi)
    else
      "%02X" % self
    end
  end

  def lo
    self & 0xff
  end

  def hi
    self >> 8
  end
end

Fixnum.include(NESMP)
NilClass.include(NESMP)

def to_dump(a)
  a.map { |e| e.to_i(16) }
end
