module NES
  private

  def push(value)
    @memory.store(0x0100 + @reg.sp, value)
    @reg.sp -= 1
  end

  def pop
    value = @memory.fetch(0x0100 + @reg.sp)
    @reg.sp += 1
  end

  def push16(value)
    push(hi(value))
    push(lo(value))
  end

  def pop16
    lo = pop
    hi = pop
    hi << 8 | lo
  end
end
