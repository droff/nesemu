module NES
  class Memory
    def initialize
      reset
    end

    def fetch(address)
      @mem[address]
    end

    def store(address, value)
      @mem[address] = value
    end

    def reset
      @mem = Array.new(0xffff, 0)
    end
  end
end
