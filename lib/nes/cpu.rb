require './lib/nes/cpu/register'
require './lib/nes/memory'

class NES::CPU
  def initialize
    @reg = Register.new
    @memory = Memory.new
    @cycles = 0
    reset
  end

  def reset
    @reg.pc = @memory.fetch16(0xfffc)
  end

  def run
  end
end
