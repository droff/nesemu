require './lib/ext'
require './lib/nes/asm'
require './lib/nes/cpu'
require './lib/nes/memory'

Fixnum.include(Ext)
NilClass.include(Ext)

module NES
end
