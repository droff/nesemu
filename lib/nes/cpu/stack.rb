module NES
  private

  def push(value)
    @memory.store(@reg.sp, value)
    @reg.sp -= 1
  end

  def pop
    value = @memory.fetch(@reg.sp)
    @reg.sp += 1
  end
end
