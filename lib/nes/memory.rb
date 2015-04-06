module NES
  class Memory
    def initialize
      reset
    end

    def fetch16(address)
      lo = fetch(address)
      hi = fetch(address + 1)
      hi << 8 | lo
    end

    def fetch(address)
      case
      when address < 0x2000
        @mem[address % 0x800]
      else
        puts "allocated memory address: #{address.to_s(16)}"
      end
    end

    def store(address, value)
      case
      when address < 0x2000
        @mem[address % address] = value
      else
        puts "allocated memory address: #{address.to_s(16)}"
      end
    end

    def reset
      @mem = Array.new(0xffff, 0)
    end
  end
end
