module NES
  private

  def push(value)
    @memory.store(@reg.sp, value)
    @reg.sp -= 1 if @reg.sp > 0x0100
  end

  def pop
    value = @memory.fetch(@reg.sp)
    @reg.sp += 1 if @reg.pc < 0x01ff
    value
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
