module Instructions
  def lda(address, mode)
    case mode
    when 0
      @reg.a = address
    else
      @reg.a = @memory.fetch(address)
    end
    setzn(@reg.a)
  end

  def ldx(address, mode)
    case mode
    when 0
      @reg.x = address
    else
      @reg.x = @memory.fetch(address)
    end
    setzn(@reg.x)
  end

  def ldy(address, mode)
    case mode
    when 0
      @reg.y = address
    else
      @reg.y = @memory.fetch(address)
    end
    setzn(@reg.y)
  end

  def sta(address)
    @memory.store(address, @reg.a)
  end

  def stx(address)
    @memory.store(address, @reg.x)
  end

  def sty(address)
    @memory.store(address, @reg.y)
  end

  def tax
    @reg.x = @reg.a
    setzn(@reg.x)
  end

  def tay
    @reg.y = @reg.a
    setzn(@reg.y)
  end

  def txa
    @reg.a = @reg.x
    setzn(@reg.a)
  end

  def tya
    @reg.a = @reg.y
    setzn(@reg.a)
  end

  def tsx
    @reg.x = @reg.s
    setzn(@reg.x)
  end

  def txs
    @reg.s = @reg.x
    setzn(@reg.s)
  end

  def pha
    @reg.s = @reg.a
  end

  def php
    @reg.s = @reg.p
  end

  def pla
    @reg.a = @reg.s
  end

  def plp
    @reg.p = @reg.s
  end

  def and(address)
    @reg.a &= @memory.fetch(address)
    setzn(@reg.a)
  end

  def eor(address)
    @reg.a ^= @memory.fetch(address)
    setzn(@reg.a)
  end

  def ora(address)
    @reg.a |= @memory.fetch(address)
  end

  def bit(address)
    value = @memory.fetch(address)
    @reg.v = (value >> 6) & 1
    setz(value & @reg.a)
    setn(value)
  end

  def adc(address, mode)
    a = @reg.a
    case mode
    when 0
      b = address
    else
      b = @memory.fetch(address)
    end
    c = @reg.c

    @reg.a = a + b + c
    setzn(@reg.a)

    @reg.c =
      if (a + b + c) > 0xff
        1
      else
        0
      end

    @reg.v =
      if ((a ^ b) & 0x80 == 0) && ((a ^ @reg.a) & 0x80 != 0)
        1
      else
        0
      end
  end

  def sbc(address)
    a = @reg.a
    b = @memory.fetch(address)
    c = @reg.c

    @reg.a = a - b - (1 - c)
    setzn(@reg.a)

    @reg.c =
      if (a - b - (1 - c)) >= 0
        1
      else
        0
      end

    @reg.v =
      if ((a ^ b) & 0x80 != 0) && ((a ^ @reg.a) & 0x80 != 0)
        1
      else
        0
      end
  end

  def cmp(address)
    compare(@reg.a, @memory.fetch(address))
  end

  def cpx(address)
    compare(@reg.x, @memory.fetch(address))
  end

  def cpy(address)
    compare(@reg.y, @memoru.fetch(address))
  end

  def inc(address)
    value = @memory.fetch(address) + 1
    @memory.store(address, value)
    setzn(value)
  end

  def inx
    @reg.x += 1
    setzn(@reg.x)
  end

  def iny
    @reg.y += 1
    setzn(@reg.y)
  end

  def dec(address)
    value = @memory.fetch(address) - 1
    @memory.store(address, value)
    setzn(value)
  end

  def dex
    @reg.x -= 1
    setzn(@reg.x)
  end

  def dey
    @reg.y -= 1
    setzn(@reg.y)
  end

  def asl(address)
    if mode_acc?
      @reg.c = (@reg.a >> 7) & 1
      @reg.a <<= 1
      setzn(@reg.a)
    else
      value = @memory.fetch(address)
      @reg.c = (value >> 7) & 1
      value <<= 1
      @memory.store(address, value)
      setzn(value)
    end
  end

  def lsr(address)
    if mode_acc?
      @reg.c = @reg.a & 1
      @reg.a >>= 1
      setzn(@reg.a)
    else
      value = @memory.fetch(address)
      @reg.c = value & 1
      value >>= 1
      @memory.store(address, value)
      setzn(value)
    end
  end

  def rol(address)
    c = @reg.c

    if mode_acc?
      @reg.c = (@reg.a >> 7) & 1
      @reg.a = (@reg.a << 1) | c
      setzn(@reg.a)
    else
      value = @memory.fetch(address)
      @reg.c = (value >> 7) & 1
      value = (value << 1) | c
      @memory.store(address, value)
      setzn(value)
    end
  end

  def ror(address)
    c = @reg.c

    if mode_acc?
      @reg.c = @reg.a & 1
      @reg.a = (@reg.a >> 1) | (c << 7)
      setzn(@reg.a)
    else
      value = @memory.fetch(address)
      @reg.c = value & 1
      value = (value >> 1) | (c << 7)
      @memory.store(address, value)
      setzn(value)
    end
  end

  def jmp(address)
    @reg.pc = address
  end

  def jsr(address)
    push16(@reg.pc - 1)
    @reg.pc = address
  end

  def rts(address)
    @reg.pc = pop16 + 1
  end

  def bcc(address)
    if @reg.c == 0
      @reg.pc = address
      add_cycles(address)
    end
  end

  def bcs(address)
    if @reg.c != 0
      @reg.pc = address
      add_cycles(address)
    end
  end

  def beq(address)
    if @reg.z != 0
      @reg.pc = address
      add_cycles(address)
    end
  end

  def bmi(address)
    if @reg.n != 0
      @reg.pc = address
      add_cycles(address)
    end
  end

  def bne(address)
    if @reg.z == 0
      @reg.pc = address
      add_cycles(address)
    end
  end

  def bpl(address)
    if @reg.n == 0
      @reg.pc = address
      add_cycles(address)
    end
  end

  def bvc(address)
    if @reg.v == 0
      @reg.pc = address
      add_cycles(address)
    end
  end

  def bvs(address)
    if @reg.v != 0
      @reg.pc = address
      add_cycles(address)
    end
  end

  def clc
    @reg.c = 0
  end

  def cld
    @reg.d = 0
  end

  def cli
    @reg.i = 0
  end

  def clv
    @reg.v = 0
  end

  def sec
    @reg.c = 1
  end

  def sed
    @reg.d = 1
  end

  def sei
    @reg.i = 1
  end

  def brk(address)
    push16(@reg.pc)
    php(address)
    sei(address)
    @reg.pc = @memory.fetch(0xfffe)
  end

  def nop(address)
  end

  def rti(address)
    set_flags(pull & 0xef | 0x20)
    @reg.pc = pop16
  end

  private

  def mode(var, value, mode)
    case mode
    # imm
    when 0
      var = value
    # zp
    when 1
      var = value
    # zpx
    when 2
      get_lo(value + @reg.x)
    # zpy
    when 3
      #
    # abs
    when 4
      #
    # absx
    when 5
      #
    # absy
    when 6
      #
    # ind
    when 7
      #
    # indx
    when 8
      #
    # indy
    when 9
      #
    # sngl
    # bra
    end
  end

  def get_lo(value)
    value & 0xff
  end

  def get_hi(value)
    value >> 8
  end

  def diff(a, b)
    (a & 0xff00) != (b & 0xff00)
  end

  def add_cycles(address)
    @cycles += 1
    @cycles += 1 if diff(@reg.pc, @reg.address)
  end

  def push(value)
    @memory.store(0x100 | value, value)
    @reg.sp -= 1
  end

  def pop
    @reg.sp += 1
    @memory.fetch(0x100 | @reg.sp)
  end

  def push16(value)
    hi = value >> 8
    lo = value & 0xff
    push(hi)
    push(lo)
  end

  def pop16
    lo = pull
    hi = pull
    hi << 8 | lo
  end

  def compare(a, b)
    setzn(a - b)
    @reg.c = (a >= b) ? 1 : 0
  end

  def setz(value)
    @reg.z = (value == 0) ? 1 : 0
  end

  def setn(value)
    @reg.n = (value < 0) ? 1 : 0
  end

  def setzn(value)
    setz(value)
    setn(value)
  end
end
