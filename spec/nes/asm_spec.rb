require 'spec_helper'

describe NES::ASM do
  context 'compile' do
    it 'branch' do
      asm = NES::ASM.new('data/branch.asm')
      asm.compile
      expect(asm.to_s).to eq 'a2 08 ca 8e 00 02 e0 03 d0 f8 8e 01 02 00'.split.map(&:upcase)
    end

    it 'indexed_indirect' do
      asm = NES::ASM.new('data/indexed_indirect.asm')
      asm.compile
      expect(asm.to_s).to eq 'a2 01 a9 05 85 01 a9 06 85 02 a0 0a 8c 05 06 a1 00'.split.map(&:upcase)
    end

    it 'lda_sta' do
      asm = NES::ASM.new('data/lda_sta.asm')
      asm.compile
      expect(asm.to_s).to eq 'a9 01 8d 00 02 a9 05 8d 01 02 a9 08 8d 02 02'.split.map(&:upcase)
    end

    it 'loop' do
      asm = NES::ASM.new('data/loop.asm')
      asm.compile
      expect(asm.to_s).to eq 'a2 01 e8 e0 05 d0 fb 00'.split.map(&:upcase)
    end

    it 'multibranching' do
      asm = NES::ASM.new('data/multibranching.asm')
      asm.compile
      expect(asm.to_s).to eq 'a9 01 a0 03 d0 04 a9 02 d0 f8 a2 03'.split.map(&:upcase)
    end

    it 'ex1' do
      asm = NES::ASM.new('data/ex1.asm')
      asm.compile
      expect(asm.to_s).to eq 'a2 05 e8 e0 07 d0 fb d0 00 c8'.split.map(&:upcase)
    end

    it 'ex2' do
      asm = NES::ASM.new('data/ex2.asm')
      asm.compile
      expect(asm.to_s).to eq 'a2 00 a0 00 8a 99 00 02 48 e8 c8 c0 10 d0 f5 68 99 00 02 c8 c0 20 d0 f7'.split.map(&:upcase)
    end
  end
end
