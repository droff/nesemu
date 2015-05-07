module Instructions

  Instruction = Struct.new(:opcode, :mode, :mnemonic, :value, :size, :address) do
    def to_s
      "#{opcode.to_hex} #{mode} #{mnemonic} #{value.to_hex} #{size} #{address.to_hex}"
    end
  end

  def adc(address)
    a = @reg.a
    m = @memory.fetch(address)
    c = @reg.c
    t = a + m + c

    @reg.v = ( ((a >> 7) & 1) != ((t >> 7) & 1) ) ? 1 : 0
    if @reg.d == 1
      t = bcd(a) + bcd(m) + c
      @reg.c = (t > 99) ? 1 : 0
    else
      @reg.c = (t > 0xff) ? 1 : 0
    end
    @reg.a = t & 0xff
    setzn(@reg.a)
  end

  def and(address)
    @reg.a &= @memory.fetch(address)
    setzn(@reg.a)
  end

  def asl(address)
    m = @memory.fetch(address)
    setc(lo(m))
    m = (m << 1) & 0xfe
    setzn(m)
  end

  def bcc(address)
    m = @memory.fetch(address)

    if @reg.c == 0
      offset = check_branch(m) - 1
      @reg.pc += offset
    end
  end

  def bcs(address)
    m = @memory.fetch(address)

    if @reg.c == 1
      offset = check_branch(m) - 1
      @reg.pc += offset
    end
  end

  def beq(address)
    m = @memory.fetch(address)

    if @reg.z == 1
      offset = check_branch(m) - 1
      @reg.pc += offset
    end
  end

  def bit(address)
    m = @memory.fetch(address)
    @reg.v = (m >> 6) & 1
    setz(m & @reg.a)
    setn(m)
  end

  def bmi(address)
    m = @memory.fetch(address)

    if @reg.n == 1
      offset = check_branch(m) - 1
      @reg.pc += offset
    end
  end

  def bne(address)
    m = address#@memory.fetch(address)

    if @reg.z == 0
      @reg.pc = address
      #offset = check_branch(m) - 1
      #@reg.pc += offset
    end
  end

  def bpl(address)
    m = @memory.fetch(address)

    if @reg.n == 0
      offset = check_branch(m) - 1
      @reg.pc += offset
    end
  end

  def brk
    push16(@reg.pc)
    php
    sei
    @reg.pc = @memory.fetch16(0xfffe)
  end

  def bvc(address)
    m = @memory.fetch(address)

    if @reg.v == 0
      offset = check_branch(m) - 1
      @reg.pc += offset
    end
  end

  def bvs(address)
    m = @memory.fetch(address)

    if @reg.v == 1
      offset = check_branch(m) - 1
      @reg.pc += offset
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

  def cmp(address)
    m = @memory.fetch(address)
    t = @reg.a - m
    @reg.c = (@reg.a >= m) ? 1 : 0
    setzn(t)
  end

  def cpx(address)
    m = @memory.fetch(address)
    t = @reg.x - m
    @reg.c = (@reg.x >= m) ? 1 : 0
    setzn(t)
  end

  def cpy(address)
    m = @memory.fetch(address)
    t = @reg.y - m
    @reg.c = (@reg.y >= m) ? 1 : 0
    setzn(t)
  end

  def dec(address)
    m = @memory.fetch(address)
    t = (m - 1) & 0xff
    @memory.store(address, t)
    setzn(t)
  end

  def dex
    @reg.x -= 1
    setzn(@reg.x)
  end

  def dey
    @reg.y -= 1
    setzn(@reg.y)
  end

  def eor(address)
    m = @memory.fetch(address)
    @reg.a ^= m
    setzn(@reg.a)
  end

  def inc(address)
    m = @memory.fetch(address)
    t = (m + 1) & 0xff
    @memory.store(address, t)
    setzn(t)
  end

  def inx
    @reg.x += 1
    setzn(@reg.x)
  end

  def iny
    @reg.y += 1
    setzn(@reg.y)
  end

  def irq
    push16(@reg.pc)
    php
    @reg.pc = @memory.fetch16(0xfffe)
    @reg.i = 1
    @cycles += 7
  end

  def jmp(address)
    @reg.pc = @memory.fetch(address)
  end

  def jsr(address)
    t = @reg.pc - 1
    push16(t)
    @reg.pc = 0xa5b6
  end

  def lda(address)
    @reg.a = @memory.fetch(address)
    setzn(@reg.a)
  end

  def ldx(address)
    @reg.x = @memory.fetch(address)
    setzn(@reg.x)
  end

  def ldy(address)
    @reg.y = @memory.fetch(address)
    setzn(@reg.y)
  end

  def lsr(address)
    m = @memory.fetch(address)
    t = (m >> 1) & 0x7f
    @reg.n = 0
    @reg.c = (m >> 0) & 1
    @memory.store(address, t)
    setz(t)
  end

  def nmi
    push16(@reg.pc)
    php
    @reg.opc = @memory.fetch16(0xfffa)
    @reg.i = 1
    @cycles += 7
  end

  def nop
  end

  def ora(address)
    m = @memory.fetch(address)
    @reg.a |= m
    setzn(@reg.a)
  end

  def pha
    push(@reg.a)
  end

  def php
    push(@reg.p)
  end

  def pla
    @reg.a = pop
    setzn(@reg.a)
  end

  def plp
    @reg.p = pop
  end

  def rol(address)
    m = @memory.fetch(address)
    t = (m >> 7) & 1
    m = (m << 1) & 0xfe
    m |= @reg.c
    @reg.c = t
    setzn(m)
  end

  def ror(address)
    m = @memory.fetch(address)
    t = (m >> 0) & 1
    m = (m >> 1) & 0x7f
    m |= (@reg.c == 1) ? 0x80 : 0
    @reg.c = t
    setzn(m)
  end

  def rti
    @reg.p = pop
    l = pop
    h = pop << 8
    @reg.pc = h | l
  end

  def rts
    l = pop
    h = pop << 8
    @reg.pc = (h | l) + 1
  end

  def sbc(address)
    a = @reg.a
    m = @memory.fetch(address)
    c = @reg.c

    if @reg.d == 1
      t = bcd(a) - bcd(m) - (1 - c)
      @reg.v = (t.between?(0, 99)) ? 1 : 0
    else
      t = a - m - (1 - c)
      @reg.v = (t.between?(0x7f, 0xff)) ? 1 : 0
    end
    @reg.c = (t >= 0) ? 1 : 0
    @reg.a = t & 0xff
    setzn(@reg.a)
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

  def tsx
    @reg.x = @reg.sp
    setzn(@reg.x)
  end

  def txa
    @reg.a = @reg.x
    setzn(@reg.a)
  end

  def txs
    @reg.sp = @reg.x
  end

  def tya
    @reg.a = @reg.y
    setzn(@reg.a)
  end

  private

  def bcd(value)
    value.divmod(16).reverse.each_with_index
      .inject(0) { |sum, (e, i)| sum + (e * 10**i) }
  end

  def diff(a, b)
    (a & 0xff00) != (b & 0xff00)
  end

  def add_cycles(address)
    @cycles += 1
    @cycles += 1 if diff(@reg.pc, address)
  end

  def get_flags
    value = 0

    value |= @reg.c << 0
    value |= @reg.z << 1
    value |= @reg.i << 2
    value |= @reg.d << 3
    value |= @reg.b << 4
    value |= @reg.u << 5
    value |= @reg.v << 6
    value |= @reg.n << 7

    value
  end

  def set_flags(value)
    @reg.c = (value >> 0) & 1
    @reg.z = (value >> 1) & 1
    @reg.i = (value >> 2) & 1
    @reg.d = (value >> 3) & 1
    @reg.b = (value >> 4) & 1
    @reg.u = (value >> 5) & 1
    @reg.v = (value >> 6) & 1
    @reg.n = (value >> 7) & 1
  end

  def setc(value)
    @reg.c = (value > 0xff) ? 1 : 0
  end

  def setz(value)
    @reg.z = (value == 0) ? 1 : 0
  end

  def setn(value)
    @reg.n = (value >> 7) & 1
  end

  def setzn(value)
    setz(value)
    setn(value)
  end

  def check_branch(value)
    value.between?(0x00, 0x7f) ? value : -(0xff - value)
  end
end
