require_relative 'cpu/instructions'
require_relative 'cpu/opcodes'
##
#
module NES
  ##
  # CPU 6502 implementation
  class CPU
    extend Instructions
    extend Opcodes

    FREQ = 1789773

    class << self
      attr_accessor :reg

      def init
        @reg = Register.new
        @memory = Memory.new
        @cycles = 0
        reset
      end

      def reset
        @reg.pc = 0x0600
        @reg.sp = 0xff
        set_flags(0x24)
      end

      def execute
      end

      def dump
        puts "A=#{hex(@reg.a)}"
        puts "X=#{hex(@reg.x)}"
        puts "Y=#{hex(@reg.y)}"
        puts "SP=#{hex(@reg.sp)}"
        puts "PC=#{hex(@reg.pc)}"
      end

      def hex(value)
        value.to_s(16)
      end
    end

    private

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

        @c = 0;
        @z = 0;
        @i = 0;
        @d = 0;
        @b = 0;
        @u = 0;
        @v = 0;
        @n = 0;
      end
    end
  end
end
