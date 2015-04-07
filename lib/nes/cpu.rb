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

    FREQ = 1_789_773

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

      def execute(code)
        code = code.split('\n')
        assemble(code)
      end

      def dump
        puts "A=#{hex(@reg.a)}"
        puts "X=#{hex(@reg.x)}"
        puts "Y=#{hex(@reg.y)}"
        puts "SP=#{hex(@reg.sp)}"
        puts "PC=#{hex(@reg.pc)}"
        puts "---"
        puts @memory.dump(0x0600, @reg.pc)
      end

      def assemble(code)
        code.each do |line|
          command, param = line.upcase.split(' ')

          case param
          when /^\#/
            mode = 0
            value = get_value(param)
            lda(value, mode)
          when /^\$[\dABCDEF]{1,2}$/
            mode = 1
            value = get_value(param)
          when /^\$[\dABCDEF]{1,2}\,X$/
            mode = 2
            value = get_value(param)
          when /^\$[\dABCDEF]{4}$/
            mode = 3
            value = get_address(param)
          when /^\$[\dABCDEF]{4}\,X$/
            mode = 4
            value = get_address(param)
          when /^\$[\dABCDEF]{4}\,Y$/
            mode = 5
            value = get_address(param)
          when /^\(\$[\dABCDEF]{2}\,X\)$/
            mode = 6
            value = get_value(param)
          when /^\(\$[\dABCDEF]{2}\)\,Y$/
            mode = 7
            value = get_value(param)
          else
            mode = nil
            value = nil
          end

          opcode, size, cycles = OPCODE_LIST[command][mode]
          @memory.store(@reg.pc, opcode)
          @reg.pc += 1

          if size > 2
            word = (value & 0xff), (value >> 8)
            size.times do |i|
              @memory.store(@reg.pc, word[i])
              @reg.pc += 1
            end
          else
            @memory.store(@reg.pc, value)
            @reg.pc += 1
          end

          #@memory.store(@reg.pc, 0)
        end
      end

      private

      def get_value(param)
        param.scan(/[\dABCDEF]{1,2}/).first.to_i(16)
      end

      def get_address(param)
        param.scan(/[\dABCDEF]{4}/).first.to_i(16)
      end

      def hex(value)
        (value < 255 ? "%02X" : "%04X") % value
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
