require './lib/nes/asm/mnemonic'

module NES
  class ASM
    attr_reader :bytes

    def initialize(filename)
      @data = File.read(filename)
      @bytes = []
      @labels = {}
    end

    def compile
      @data.each_line do |line|
        command, param = line.upcase.split
        if command =~ /:/
          @labels[command.gsub(':', '')] = @bytes.size
          next
        end

        m = Mnemonic.new(command, param, @labels, @bytes.size)
        @bytes << [m.opcode, m.value].compact
        @bytes.flatten!
      end

      replace_label
    end

    def to_s
      @bytes.map(&:to_hex)
    end

    private

    def replace_label
      @bytes.each_with_index do |byte, i|
        @bytes[i] = (@labels[byte] - i - 1) unless @labels[byte].nil?
      end
    end

    def dump(line, m)
      value =
        if m.value && m.value.is_a?(Fixnum)
          m.value
        else
          0
        end
      puts line
      puts sprintf("%02X %02X mode=#{m.mode} size=#{m.size}", m.opcode, value)
      puts '-' * 64
    end
  end
end
