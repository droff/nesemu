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
      if value.is_a? Array
        value.each do |e, i| 
          @mem[address] = e
          address += 1
        end
      else
        @mem[address] = value
        address += 1
      end
      address
    end

    def reset
      @mem = Array.new(0xffff + 1, 0)
    end

    def dump(address, size)
      m = @mem[address..(address + size)].map(&:to_hex)
      "$#{address.to_hex}: #{m.join(' ')}"
    end
  end
end