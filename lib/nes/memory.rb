module NES
  class Memory
    def initialize
      reset
    end

    def fetch(address)
      @mem[address]
    end

    def fetch16(address)
      lo = fetch(address)
      hi = fetch(address + 1)
      hi << 8 | lo
    end

    def store(address, value)
      @mem[address] = value
    end

    def reset
      @mem = Array.new(0xffff, 0)
    end

    def dump(address, to)
      m = @mem[address..(to - 2)].map { |e| "%02X" % e }
      "#{"%04X" % address}: #{m.join(' ')}"
    end
  end
end
