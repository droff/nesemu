class NES::File
  attr_reader :name, :prg_size, :chr_size, :flag6

  HEADER_SIZE  = 16
  TRAINER_SIZE = 0

  def initialize(filepath)
    @data = File.binread(filepath)
    @name, @prg_size, @chr_size, @flag6 = @data.unpack("a4CCC")
  end

  def header
    @data.unpack("a4CCCCCCC")
  end

  def prg_rom
    start_pos = HEADER_SIZE + TRAINER_SIZE
    end_pos = 16348 * @prg_size
    @data[start_pos..end_pos].unpack("C*")
  end
end
