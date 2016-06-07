module Ext
  def to_hex
    self ?  (self > 0xff ? "%04X" : "%02X") % self : ''
  end

  def lo
    self & 0xff
  end

  def hi
    self >> 8
  end
end
