module NES
  class Mnemonic
    attr_reader :command, :param, :mode, :value, :size

    OPCODE_LIST= {
      'ADC' => [0x69, 0x65, 0x75,  nil, 0x6d, 0x7d, 0x79,  nil, 0x61, 0x71,  nil,  nil],
      'AND' => [0x29, 0x25, 0x35,  nil, 0x2d, 0x3d, 0x39,  nil, 0x21, 0x31,  nil,  nil],
      'ASL' => [ nil, 0x06, 0x16,  nil, 0x0e, 0x1e,  nil,  nil,  nil,  nil, 0x0a,  nil],
      'BIT' => [ nil, 0x24,  nil,  nil, 0x2c,  nil,  nil,  nil,  nil,  nil,  nil,  nil],
      'BPL' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x10],
      'BMI' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x30],
      'BVC' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x50],
      'BVS' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x70],
      'BCC' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x90],
      'BCS' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xb0],
      'BNE' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xd0],
      'BEQ' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xf0],
      'BRK' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x00,  nil],
      'CMP' => [0xc9, 0xc5, 0xd5,  nil, 0xcd, 0xdd, 0xd9,  nil, 0xc1, 0xd1,  nil,  nil],
      'CPX' => [0xe0, 0xe4,  nil,  nil, 0xec,  nil,  nil,  nil,  nil,  nil,  nil,  nil],
      'CPY' => [0xc0, 0xc4,  nil,  nil, 0xcc,  nil,  nil,  nil,  nil,  nil,  nil,  nil],
      'DEC' => [ nil, 0xc6, 0xd6,  nil, 0xce, 0xde,  nil,  nil,  nil,  nil,  nil,  nil],
      'EOR' => [0x49, 0x45, 0x55,  nil, 0x4d, 0x5d, 0x59,  nil, 0x41, 0x51,  nil,  nil],
      'CLC' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x18,  nil],
      'SEC' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x38,  nil],
      'CLI' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x58,  nil],
      'SEI' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x78,  nil],
      'CLV' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xb8,  nil],
      'CLD' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xd8,  nil],
      'SED' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xf8,  nil],
      'INC' => [ nil, 0xe6, 0xf6,  nil, 0xee, 0xfe,  nil,  nil,  nil,  nil,  nil,  nil],
      'JMP' => [ nil,  nil,  nil,  nil, 0x4c,  nil,  nil, 0x6c,  nil,  nil,  nil,  nil],
      'JSR' => [ nil,  nil,  nil,  nil, 0x20,  nil,  nil,  nil,  nil,  nil,  nil,  nil],
      'LDA' => [0xa9, 0xa5, 0xb5,  nil, 0xad, 0xbd, 0xb9,  nil, 0xa1, 0xb1,  nil,  nil],
      'LDX' => [0xa2, 0xa6,  nil, 0xb6, 0xae,  nil, 0xbe,  nil,  nil,  nil,  nil,  nil],
      'LDY' => [0xa0, 0xa4, 0xb4,  nil, 0xac, 0xbc,  nil,  nil,  nil,  nil,  nil,  nil],
      'LSR' => [ nil, 0x46, 0x56,  nil, 0x4e, 0x5e,  nil,  nil,  nil,  nil, 0x4a,  nil],
      'NOP' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xea,  nil],
      'ORA' => [0x09, 0x05, 0x15,  nil, 0x0d, 0x1d, 0x19,  nil, 0x01, 0x11,  nil,  nil],
      'TAX' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xaa,  nil],
      'TXA' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x8a,  nil],
      'DEX' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xca,  nil],
      'INX' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xe8,  nil],
      'TAY' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xa8,  nil],
      'TYA' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x98,  nil],
      'DEY' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x88,  nil],
      'INY' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xc8,  nil],
      'ROR' => [ nil, 0x66, 0x76,  nil, 0x6e, 0x7e,  nil,  nil,  nil,  nil, 0x6a,  nil],
      'ROL' => [ nil, 0x26, 0x36,  nil, 0x2e, 0x3e,  nil,  nil,  nil,  nil, 0x2a,  nil],
      'RTI' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x40,  nil],
      'RTS' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x60,  nil],
      'SBC' => [0xe9, 0xe5, 0xf5,  nil, 0xed, 0xfd, 0xf9,  nil, 0xe1, 0xf1,  nil,  nil],
      'STA' => [ nil, 0x85, 0x95,  nil, 0x8d, 0x9d, 0x99,  nil, 0x81, 0x91,  nil,  nil],
      'TXS' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x9a,  nil],
      'TSX' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0xba,  nil],
      'PHA' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x48,  nil],
      'PLA' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x68,  nil],
      'PHP' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x08,  nil],
      'PLP' => [ nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil, 0x28,  nil],
      'STX' => [ nil, 0x86,  nil, 0x96, 0x8e,  nil,  nil,  nil,  nil,  nil,  nil,  nil],
      'STY' => [ nil, 0x84, 0x94,  nil, 0x8c,  nil,  nil,  nil,  nil,  nil,  nil,  nil]
    }

    MODE = {
      imm: /^\#/,
      zpg: /^\$[0-9A-F]{1,2}$/,
      zpx: /^\$[0-9A-F]{1,2}\,X$/,
      zpy: /^\$[0-9A-F]{1,2}\,Y$/,
      abs: /^\$[0-9A-F]{4}$/,
      abx: /^\$[0-9A-F]{4}\,X$/,
      aby: /^\$[0-9A-F]{4}\,Y$/,
      ind: /^\(\$[0-9A-F]{4}\)$/,
      idx: /^\(\$[0-9A-F]{2}\,X\)$/,
      idy: /^\(\$[0-9A-F]{2}\)\,Y$/,
      imp: nil, #/^$/,
      rel: /^\w+$/
    }

    def initialize(command, param, labels, pos)
      @command = command
      @param = param
      @labels = labels
      @pos = pos
      @mode, @value, @size = get_param(param)
    end

    def opcode
      OPCODE_LIST[@command][@mode]
    end

    private

    def get_param(param)
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
        [11, relative, 2]
      else
        [nil, nil, nil]
      end
    end

    def relative
      label_pos = @labels[@param]
      return @param if label_pos.nil?

      if @pos > label_pos
        0xff - @pos + label_pos - 1
      else
        label_pos
      end
    end

    def byte(param)
      param.scan(/[0-9A-F]{1,2}/).first.to_i(16)
    end

    def word(param)
      value = param.scan(/[0-9A-F]{4}/).first
      hi, lo = value[0..1].to_i(16), value[2..3].to_i(16)
      [lo, hi]
    end
  end
end
