if options[:debug]
  puts "STEP: #{instruction.opcode.to_hex} #{instruction.mode} #{instruction.mnemonic} #{instruction.value.to_hex} #{instruction.address.to_hex}"
  puts dump
  gets
end

require './lib/nes/cpu/instructions'
require './lib/nes/cpu/instruction'
require './lib/nes/cpu/opcodes'
require './lib/nes/cpu/register'
require './lib/nes/cpu/stack'

##
# NES module
module NES
  ##
  # CPU 6502 implementation
  class CPU
    extend NES::Instructions
    extend NES::Opcodes
    extend NES::Stack

    FREQ = 1_789_773

    class << self
      attr_reader :reg, :memory

      def init
        @reg = Register.new
        @memory = Memory.new
        @cycles = 0
        reset
      end

      def reset
        @reg.b = 1
        @reg.pc = @memory.fetch16(0xfffc)
        @reg.sp = 0x01ff
        @reg.pc = 0x0200
      end

      def load(data)
        data.each_with_index { |e, i| @memory.store(0x0200 + i, e) }
      end

      def run
        loop do
          @cycles -= step

          if @cycles <= 0
            @cycles += 0
            break if @reg.i == 1
          end
        end
      end

      def step
        instruction = Instruction.new(@memory, @reg)
        cmd_cycles = NES::Instruction::CYCLES[instruction.opcode]
        extra_cycles = NES::Instruction::EXTRACYCLES[instruction.opcode]
        @reg.pc += instruction.size
        exec_instruction(instruction)
        cmd_cycles + extra_cycles
      end

      def dump
        puts '-' * 64
        puts @reg.dump_registers
        puts @reg.dump_flags
        puts @memory.dump(0x0000, 0xf)
        puts @memory.dump(0x0200, 0xf)
        puts @memory.dump(0x01fa, 0x5)
        puts '-' * 64
      end

      def assemble(code)
        @labels = Hash.new(0)
        @labels = parse_labels(code)
        index = 0
        data = []

        code.each_line do |line|
          @reg.pc = index
          command, param = line.upcase.split(' ')
          next if command =~ /^\w+:$/

          mode, value, size = check_param(param)
          data << get_opcode(command, mode)
          index += 1

          unless value.nil?
            if value > 0xff
              data << lo(value)
              data << hi(value)
              index += 2
            else
              data << value
              index += 1
            end
          end
        end
        data
      end

      def disassemble
        disasm_text = []
        @reg.pc = 0x0200

        loop do
          data = @memory.fetch(@reg.pc)

          opcode, mode = find_mnemonic(data)
          break if opcode == 'BRK'

          size = SIZE[mode]
          @reg.pc += 1

          value =
            case size
            when 2
              @memory.fetch(@reg.pc)
            when 3
              @memory.fetch16(@reg.pc)
            else
              nil
            end

          value = @reg.pc + check_label(value) if mode == :rel

          disasm_text << sprintf("$%04x %02s %04s    %03s %04s    :%s", @reg.pc-1, data.to_hex, value.to_hex, opcode, value.to_hex, mode)

          @reg.pc += size - 1
        end

        disasm_text
      end

      private

      def exec_instruction(instruction)
        if instruction.address
          self.send(instruction.mnemonic.downcase.to_sym, instruction.address)
        else
          self.send(instruction.mnemonic.downcase.to_sym)
        end
      end

      def get_opcode(command, mode)
        mode = nil if mode == 10
        if mode
          NES::Instruction::OPCODE_LIST[command][mode]
        else
          NES::Instruction::OPCODE_LIST[command][-2..-1].compact.first
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

      def check_param(param)
        case param
        when NES::Instruction::MODE[:imm]
          [0, byte(param), 2]
        when NES::Instruction::MODE[:zpg]
          [1, byte(param), 2]
        when NES::Instruction::MODE[:zpx]
          [2, byte(param), 2]
        when NES::Instruction::MODE[:zpy]
          [3, byte(param), 2]
        when NES::Instruction::MODE[:abs]
          [4, word(param), 3]
        when NES::Instruction::MODE[:abx]
          [5, word(param), 3]
        when NES::Instruction::MODE[:aby]
          [6, word(param), 3]
        when NES::Instruction::MODE[:ind]
          [7, word(param), 3]
        when NES::Instruction::MODE[:idx]
          [8, byte(param), 2]
        when NES::Instruction::MODE[:idy]
          [9, byte(param), 2]
        when NES::Instruction::MODE[:imp]
          [10, nil, 1]
        when NES::Instruction::MODE[:rel]
          [11, assemble_label(@labels[param]), 2]
        else
          [nil, nil, nil]
        end
      end

      def parse_labels(code)
        labels = {}
        current_postition = 0

        code.each_line do |line|
          command, param = line.upcase.split(' ')
          # if label:
          if command =~ /^\w+:$/
            labels[command.gsub(':', '')] = current_postition
            next
          end
          _, _, size = check_param(param)
          current_postition += size
        end

        labels
      end

      def check_label(value)
        value > 0x7f ? -(0xff - value) : value + 1
      end

      def assemble_label(value)
        if value
          value -= @reg.pc + 2
          value < 0 ? 0xff + value + 1 : value
        end
      end
    end
  end
end
