require './lib/nes/cpu/instructions'
require './lib/nes/cpu/instruction'
require './lib/nes/cpu/register'
require './lib/nes/cpu/opcodes'
require './lib/nes/cpu/stack'

class NES::CPU
  include NES::Instructions
  include NES::Opcodes
  include NES::Stack

  def initialize
    @reg = NES::Register.new
    @memory = NES::Memory.new
    @cycles = 0
    reset
  end

  def reset
    #@reg.pc = @memory.fetch16(0xfffc)
    @reg.pc = 0x0200
    @reg.sp = 0x01ff
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

  def dump
    puts '-' * 64
    puts @reg.dump_registers
    puts @reg.dump_flags
    puts @memory.dump(0x0000, 0xf)
    puts @memory.dump(0x0200, 0xf)
    puts @memory.dump(0x01fa, 0x5)
    puts '-' * 64
  end

  private

  def step
    instruction = NES::Instruction.new(@memory, @reg)
    cmd_cycles = NES::Instruction::CYCLES[instruction.opcode]
    extra_cycles = NES::Instruction::EXTRACYCLES[instruction.opcode]
    @reg.pc += instruction.size
    exec_instruction(instruction)
    cmd_cycles + extra_cycles
  end

  def exec_instruction(instruction)
    if instruction.address
      self.send(instruction.mnemonic.downcase.to_sym, instruction.address)
    else
      self.send(instruction.mnemonic.downcase.to_sym)
    end
  end

  def lo(value)
    value & 0xff
  end

  def hi(value)
    value >> 8
  end
end
