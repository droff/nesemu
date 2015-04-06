module Instructions
  def setz(value)
    @reg.z =
      if value == 0
        1
      else
        0
      end
  end

  def setn(value)
    @reg.n =
      if value < 0
        1
      else
        0
      end
  end

  def setzn(value)
    setz(value)
    setn(value)
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
end
