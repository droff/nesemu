##
# CPU registers
class Register
  attr_accessor :a, :x, :y, :p, :sp, :pc, :c, :z, :i, :d, :b, :u, :v, :n

  def initialize
    @a = 0   # A: ACCUMULATOR
    @x = 0   # X: INDEX
    @y = 0   # Y: INDEX
    @p = 0   # P: PROCESSOR STATUS
    @sp = 0  # S: STACK POINTER
    @pc = 0  # PC: PROGRAM COUNTER (16-bit)

    @c = 0
    @z = 0
    @i = 0
    @d = 0
    @b = 0
    @u = 0
    @v = 0
    @n = 0
  end

  def dump
    puts "A=#{@a.to_hex} X=#{@x.to_hex} Y=#{@y.to_hex}"
    puts "SP=#{@sp.to_hex} PC=#{@pc.to_hex}"
  end
end
