require_relative 'cpu/instructions'
require_relative 'cpu/opcodes'
require_relative 'cpu/register'
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
        @memory.store(@reg.pc, 0)
        @reg.pc += 1
      end

      def dump
        puts "A=#{hex(@reg.a)} X=#{hex(@reg.x)} Y=#{hex(@reg.y)}"
        puts "SP=#{hex(@reg.sp)}"
        puts "PC=#{hex(@reg.pc)}"
        puts "-----------------------------------"
        puts @memory.dump(0x0600, @reg.pc)
      end

      def assemble(code)
        code.each do |line|
          command, param = line.upcase.split(' ')
          mode, value, size = check_param(param)

          opcode = get_opcode(command, mode)
          @memory.store(@reg.pc, opcode)
          @reg.pc += 1

          unless value.nil?
            if size > 2
              word = (value & 0xff), (value >> 8)
              (size-1).times do |i|
                @memory.store(@reg.pc, word[i])
                @reg.pc += 1
              end
            else
              @memory.store(@reg.pc, value)
              @reg.pc += 1
            end
          end

          if value.nil?
            self.send(command.downcase.to_sym)
          else
            self.send(command.downcase.to_sym, value, mode)
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

      def get_value(param)
        param.scan(/[0-9A-F]{1,2}/).first.to_i(16)
      end

      def get_address(param)
        param.scan(/[0-9A-F]{4}/).first.to_i(16)
      end

      def hex(value)
        (value > 255 ? "%04X" : "%02X") % value
      end

      def check_param(param)
        case param
        # imm
        when /^\#/
          [0, get_value(param), 2]
        # zp
        when /^\$[0-9A-F]{1,2}$/
          [1, get_value(param), 2]
        # zpx
        when /^\$[0-9A-F]{1,2}\,X$/
          [2, get_value(param), 2]
        # zpy
        when /^\$[0-9A-F]{1,2}\,Y$/
          [3, get_value(param), 2]
        # abs
        when /^\$[0-9A-F]{4}$/
          [4, get_address(param), 3]
        # absx
        when /^\$[0-9A-F]{4}\,X$/
          [5, get_address(param), 3]
        # absy
        when /^\$[0-9A-F]{4}\,Y$/
          [6, get_address(param), 3]
        # ind
        when /^\(\$[0-9A-F]{4}\)$/
          [7, get_address(param), 3]
        # indx
        when /^\(\$[0-9A-F]{2}\,X\)$/
          [8, get_value(param), 2]
        # indy
        when /^\(\$[0-9A-F]{2}\)\,Y$/
          [9, get_value(param), 2]
        else
          [nil, nil, nil]
        end
      end
    end
  end
end
