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
        @labels = {}
        reset
      end

      def reset
        @reg.b = 1
        @reg.pc = @memory.fetch16(0xfffc)
        @reg.sp = 0xff
      end

      def execute(options = {})
        if options[:dump]
          options[:dump].each_with_index { |e, i| @memory.store(0x0200 + i, e) }
        else
          code = options[:code].split('\n')
          assemble(code)
        end
        
        puts '-' * 15
        disassemble

        run
      end

      def dump
        puts '-' * 15
        @reg.dump
        print_flags
        puts '-' * 15
        puts @memory.dump(0x0200, 0xf)
        puts @memory.dump(0x01fa, 5)
      end

      def assemble(code)
        code.each do |line|
          puts line
          command, param = line.upcase.split(' ')
          
          if command =~ /^\w+:$/
            @labels[command.gsub(':', '')] = @reg.pc
          else
            mode, value, size = check_param(param)

            opcode = get_opcode(command, mode)
            @reg.pc = @memory.store(@reg.pc, opcode)

            address = check_mode(mode, value) unless value.nil?
          end
        end
      end

      def disassemble
        @reg.pc = 0x0200

        loop do
          data = @memory.fetch(@reg.pc)
          nxt = @memory.fetch(@reg.pc + 1)
          break if (data == 0) && (nxt == 0)

          opcode, mode = find_opcode(data)
          size = SIZE[mode]
          @reg.pc += 1

          case size
          when 2
            value = @memory.fetch(@reg.pc)
          when 3
            value = @memory.fetch16(@reg.pc)
          else
            value = nil
          end

          puts "$#{@reg.pc.to_hex}\t#{data.to_hex} #{value.to_hex}\t#{opcode} #{value.to_hex}"

          @reg.pc += size - 1
        end
      end

      def run(options = {})
        @reg.pc = 0x0200
        loop do
          data = @memory.fetch(@reg.pc)
          nxt = @memory.fetch(@reg.pc + 1)
          break if (data == 0) && (nxt == 0)

          opcode, mode = find_opcode(data)
          size = SIZE[mode]
          @reg.pc += 1
          
          case size
          when 2
            value = @memory.fetch(@reg.pc)
          when 3
            value = @memory.fetch16(@reg.pc)
          else
            value = nil
          end

          address = check_mode(mode, value)
          puts opcode, mode

          if address
            self.send(opcode.downcase.to_sym, address)
          else
            self.send(opcode.downcase.to_sym)
          end

          @reg.pc += size - 1

          if options[:steps]
            puts "!\t#{opcode} #{mode} #{value.to_hex} #{address.to_hex}"
            dump
            gets
          end
        end
      end

      private

      def get_opcode(command, mode)
        mode = nil if mode == 10
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
        if value
          (value > 0xff ? "%04X" : "%02X") % value
        else
          ""
        end
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
        when MODE[:imp]
          [10, nil, 1]
        when MODE[:rel]
          [11, @labels[param], 3]
        else
          [nil, nil, nil]
        end
      end

      def check_mode(mode, value)
        address = @reg.pc

        case mode
        when :imm
          value = value
        when :zpg
          address = value
        when :zpx
          address = lo(value + @reg.x)
        when :zpy
          address = lo(value + @reg.y)
        when :abs
          value = [lo(value), hi(value)]
        when :abx
          value += @reg.x
          value = [lo(value), hi(value)]
        when :aby
          value += @reg.y
          value = [lo(value), hi(value)]
        when :ind
          value = [lo(value), hi(value)]
        when :idx
          value += @reg.x
          value = [lo(value), hi(value)]
        when :idy
          value += @reg.y
          value = [lo(value), hi(value)]
        when :imp
          address = nil
        when :rel
          value = check_label(value)
        else
        end

        #@reg.pc = @memory.store(@reg.pc, value)
        address
      end

      def check_label(value)
        value -= @reg.pc
        value < 0 ? 0xff + value : value
      end

      def print_flags
        puts "NV-BDIZC"
        puts "#{@reg.n}#{@reg.v}1#{@reg.b}#{@reg.d}#{@reg.i}#{@reg.z}#{@reg.c}"
      end
    end
  end
end
