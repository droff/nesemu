require 'spec_helper'
include NES

describe CPU do
	before { CPU.init }
	let(:dump1) { to_dump(%w(A9 01 AA)) }
	let(:dump2) { to_dump(%w(a9 80 85 01 00)) }
	let(:dump3) { to_dump(%w(a9 01 8d 00 00 a2 03 ca ec 00 00 d0 fa ac 00)) }

	context 'initialize' do
		it 'PROGRAM COUNTER' do
			expect(CPU.reg.pc).to eq 0x0200
		end

		it 'STACK POINTER' do
			expect(CPU.reg.sp).to eq 0x01ff
		end
	end

	context 'assemble' do
		let(:code1) { ['LDA #$01', 'TAX'] }
		let(:label) { ['LDA #$01', 'lbl:', 'TAX', 'BNE lbl'] }


		it 'check code1' do
			memory_dump = CPU.assemble(code1).map { |e| e.to_hex }.join(' ')
			expect(memory_dump).to eq 'A9 01 AA'
		end

		it 'check with label' do
			memory_dump = CPU.assemble(label).map { |e| e.to_hex }.join(' ')
			expect(memory_dump).to eq 'A9 01 AA D0 FD'			
		end
	end

	context 'loading dump to memory' do
		let(:memory) { CPU.memory }
		let(:reg_pc) { CPU.reg.pc }

		it 'check memory for dump1' do
			memory_dump = []
			CPU.load(dump1)
			3.times { |i| memory_dump << memory.fetch(reg_pc + i) }
			expect(memory_dump).to eq [0xa9, 0x01, 0xaa]
		end
	end

	context 'disassemble' do
		it 'check disasm for dump1' do
			CPU.load(dump1)
			expect(CPU.disassemble.first).to match(/^\$0200\tA9 01/)
		end
	end

	context 'running processor' do
		let(:reg) { CPU.reg }
		let(:memory) { CPU.memory }

		it 'check dump1' do
			CPU.load(dump1)
			CPU.execute

			expect(reg.a).to eq 1
			expect(reg.x).to eq 1
		end

		it 'check dumo2' do
			CPU.load(dump2)
			CPU.execute

			expect(reg.a).to eq 0x80
			expect(memory.fetch(0x01)).to eq 0x80
			expect(reg.pc).to eq 0x0
		end

		it 'check dump3' do
			CPU.load(dump3)
			CPU.execute

			expect(reg.a).to eq 0x01
			expect(reg.x).to eq 0x01
			expect(reg.y).to eq 0x01
			expect(reg.c).to eq 1
		end
	end
end
