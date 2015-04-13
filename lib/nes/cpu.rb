require_relative 'cpu/instructions'
require_relative 'cpu/opcodes'
require_relative 'cpu/register'
require_relative 'cpu/stack'
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
        @reg.pc = 0x0200
        @reg.sp = 0x01ff
      end

      def execute(code)
        code = code.split('\n')
        assemble(code)

        # BRK
        @memory.store(@reg.pc, 0)
        @reg.pc += 1
        @reg.b = 1
      end

      def dump
        puts "A=#{hex(@reg.a)} X=#{hex(@reg.x)} Y=#{hex(@reg.y)}"
        puts "SP=#{hex(@reg.sp)}"
        puts "PC=#{hex(@reg.pc)}"
        puts "NV-BDIZC"
        puts "#{@reg.n}#{@reg.v}1#{@reg.b}#{@reg.d}#{@reg.i}#{@reg.z}#{@reg.c}"
        puts '-----------------------------------'
        puts @memory.dump(0x0200, @reg.pc)
        puts @memory.dump(0x01fa, 0x01ff + 2)
      end

      def assemble(code)
        code.each do |line|
          command, param = line.upcase.split(' ')
          mode, value, size = check_param(param)

          opcode = get_opcode(command, mode)
          @memory.store(@reg.pc, opcode)
          @reg.pc += 1

          address = check_mode(mode, value) unless value.nil?

          if value
            self.send(command.downcase.to_sym, address)
          else
            self.send(command.downcase.to_sym)
          end
        end
      end

      private

      def get_opcode(command, mode)
        if mode
          OPCODE_LIST[command][mode]
        else
          OPCODE_LIST[command][-2..-1].compact.first
        end
      end

      def byte(param)
        param.scan(/[0-9A-F]{1,2}/).first.to_i(16)
      end

      def word(param)
        param.scan(/[0-9A-F]{4}/).first.to_i(16)
      end

      def lo(value)
        value & 0xff
      end

      def hi(value)
        value >> 8
      end

      def hex(value)
        (value > 0xff ? "%04X" : "%02X") % value
      end

      def check_param(param)
        case param
        when MODE[:imm]
          [0, byte(param), 2]
        when MODE[:zpg]
          [1, byte(param), 2]
        when MODE[:zpx]
          [2, byte(param), 2]
        when MODE[:zpy]
          [3, byte(param), 2]
        when MODE[:abs]
          [4, word(param), 3]
        when MODE[:abx]
          [5, word(param), 3]
        when MODE[:aby]
          [6, word(param), 3]
        when MODE[:ind]
          [7, word(param), 3]
        when MODE[:idx]
          [8, byte(param), 2]
        when MODE[:idy]
          [9, byte(param), 2]
        else
          [nil, nil, nil]
        end
      end

      def check_mode(mode, value)
        mode_keys = MODE.keys
        address = @reg.pc

        case mode
        when mode_keys.index(:imm)
          @memory.store(@reg.pc, value)
          @reg.pc += 1
        when mode_keys.index(:zpg)
          address = lo(value)
          @memory.store(@reg.pc, lo(value))
          @reg.pc += 1
        when mode_keys.index(:zpx)
          @memory.store(@reg.pc, lo(value + @reg.x))
          @reg.pc += 1
        when mode_keys.index(:zpy)
          @memory.store(@reg.pc, lo(value + @reg.y))
          @reg.pc += 1
        when mode_keys.index(:abs)
          @memory.store(@reg.pc, lo(value))
          @reg.pc += 1
          @memory.store(@reg.pc, hi(value))
          @reg.pc += 1
        when mode_keys.index(:abx)
          value += @reg.x
          @memory.store(@reg.pc, lo(value))
          @reg.pc += 1
          @memory.store(@reg.pc, hi(value))
          @reg.pc += 1
        when mode_keys.index(:aby)
          value += @reg.y
          @memory.store(@reg.pc, lo(value))
          @reg.pc += 1
          @memory.store(@reg.pc, hi(value))
          @reg.pc += 1
        when mode_keys.index(:ind)
          @memory.store(@reg.pc, lo(value))
          @reg.pc += 1
          @memory.store(@reg.pc, hi(value))
          @reg.pc += 1
        when mode_keys.index(:idx)
          value += @reg.x
          @memory.store(@reg.pc, lo(value))
          @reg.pc += 1
          @memory.store(@reg.pc, hi(value))
          @reg.pc += 1
        when mode_keys.index(:idy)
          value += @reg.y
          @memory.store(@reg.pc, lo(value))
          @reg.pc += 1
          @memory.store(@reg.pc, hi(value))
          @reg.pc += 1
        else
        end

        address
      end
    end
  end
end
