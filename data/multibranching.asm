LDA #$01
sety:
LDY #$03
BNE setx
LDA #$02
BNE sety
setx:
LDX #$03
