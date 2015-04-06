require_relative 'cpu/instructions'
##
#
module NES
  ##
  # CPU 6502 implementation
  class CPU
    extend Instructions

    FREQ = 1789773

    class << self
      attr_accessor :reg

      def init
        @reg = Register.new
        @memory = Memory.new
      end

      def reset
        @reg = Register.new
      end

      def execute
        @reg.pc = 0x2000
        @memory.store(@reg.pc, 0xff)
        lda(@reg.pc)
      end
    end

    private

    ##
    # CPU registers
    class Register
      attr_accessor :a, :x, :y, :p, :s, :pc, :c, :z, :i, :d, :v, :n

      FLAGS = {
        C: 0b00000001,
        Z: 0b00000010,
        I: 0b00000100,
        D: 0b00001000,
        V: 0b01000000,
        N: 0b10000000
      }

      def initialize
        @a = 0   # A: ACCUMULATOR
        @x = 0   # X: INDEX
        @y = 0   # Y: INDEX
        @p = 0   # P: PROCESSOR STATUS
        @s = 0   # S: STACK POINTER
        @pc = 0  # PC: PROGRAM COUNTER (16-bit)

        @c = 0;
        @z = 0;
        @i = 0;
        @d = 0;
        @v = 0;
        @n = 0;
      end
    end
  end
end
