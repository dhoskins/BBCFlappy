OSWRCH=&FFEE:OSBYTE=&FFF4
seed=1
baseStart=&F7
baseW=&10

scrollOffset=&70
xcoord=&72
ycoord=&73
store=&74
loc=&76
scrollActual=&78
baseTable=&7B
baseCurCol=&7D
baseOffset=&7E

GUARD &3000
ORG &1900

.start
	LDA #22
	JSR OSWRCH
	LDA #2
	JSR OSWRCH

	LDA #6
	STA scrollOffset+1
  LDA #0
  STA scrollOffset
	LDA #(base MOD 256)
	STA baseTable
	LDA #(base DIV 256)
	STA baseTable+1

.loop
  JSR calcScrollActual
  JSR paintScrolling
  JSR paintNonScrolling

  \JSR checkKey

  LDA #&13
  JSR OSBYTE

  JSR bumpBaseCurCol
  JSR bumpScroll
JMP loop

.checkKey
  LDA #19
  STA xcoord
  LDA #20
  STA ycoord
  JSR CALCADDRESS
  LDA #0
  TAY
  LDA #&3C
  STA (loc),Y
  
  LDA #&81
  LDX #&FF
  LDY #&FF
  JSR OSBYTE

  TXA
  CMP #&FF
  BEQ drawPixel
RTS

.drawPixel
  LDA #20
  STA xcoord
  LDA #20
  STA ycoord
  JSR CALCADDRESS

  LDA #0
  TAY

  LDA #&0
  STA (loc),Y
RTS


\ Paint the rightmost strip
.paintScrolling
  LDA #79
  STA xcoord
  LDA #0
  STA ycoord

\ Initialise baseOffset to be the baseCurCol
  LDA baseCurCol
  STA baseOffset

\ We only calculate address every 8 pixels
\ Y is the count to the next 8
.paintNext8
  JSR CALCADDRESS
  LDY #0

.paintInner
  JSR calcColor
  TXA

  STA (loc),Y  \ Indirect addressing, see chapter 5 of Creative Assembler

  INC ycoord
  LDA ycoord
  CMP #0
  BEQ done

  INY
  TYA  \ compare Y to #8, need to do it via accumulator
  CMP #8
  BEQ paintNext8
  JMP paintInner
RTS

.calcColor
  LDA #(baseStart)
  CMP ycoord
  BCS loadBG

  \ ok we need to paint the base
  \ store Y in tempY, because we need it to offset the base
  TYA         
  STA store

  LDA baseOffset  
  TAY

  CLC
  ADC #(baseW)
  STA baseOffset


  LDA (baseTable),Y
  TAX       \ Got the colour, put it in X
  LDA store \ And restore Y
  TAY
RTS

.loadBG
  LDX #&3C
RTS

.bumpBaseCurCol
  INC baseCurCol
  LDA baseCurCol
  CMP baseW
  BCC done
  LDA #0
  STA baseCurCol
RTS

.paintNonScrolling
  LDA #20
  STA xcoord
  LDA #40
  STA ycoord
  JSR CALCADDRESS

  LDA #0
  TAY

  LDA #&1D
  STA (loc),Y

  LDA #19
  STA xcoord
  LDA #40
  STA ycoord
  JSR CALCADDRESS
  LDA #0
  TAY
  LDA #&3C
  STA (loc),Y
RTS

.resetX
  LDA #0
  STA xcoord
RTS

.done
RTS

.bumpScroll
  INC scrollOffset
  LDA scrollOffset

  LDA #&D            : STA &FE00
  LDA scrollOffset   : STA &FE01

  CMP #0
  BNE done

  INC scrollOffset+1
  LDA scrollOffset+1
  CMP #&10
  BNE setHighScroll

  LDA #6
  STA scrollOffset+1
  JSR setHighScroll
RTS

.setHighScroll
  LDA #&C            : STA &FE00
  LDA scrollOffset+1 : STA &FE01
RTS

.rnd
  LDA seed
  AND #&48
  ADC #&38
  ASL A
  ASL A
  ROL seed + 2
  ROL seed + 1
  ROL seed
  LDA seed 
RTS

.calcScrollActual
  LDA scrollOffset
  STA scrollActual

  LDA scrollOffset+1
  STA scrollActual+1

  ASL scrollActual+1
  ASL scrollActual+1
  ASL scrollActual+1

  ROL scrollActual
  ROL scrollActual
  ROL scrollActual
  ROL scrollActual
  LDA scrollActual
  AND #7 
  ORA scrollActual+1
  STA scrollActual+1

  LDA scrollOffset
  STA scrollActual
  ASL scrollActual
  ASL scrollActual
  ASL scrollActual
RTS

\ &3000 + 8X + 16Y1 + 64Y1 + (Y MOD 8)
\ This thing takes XCOORD, YCOORD and translates it to the byte in memory which
\ corresponds to that screen location.
\ Screen location is "returned" in LOC, LOC+1
.CALCADDRESS
  \reset vars to 0
  LDA #0
  STA store+1
  STA loc

  LDA xcoord    \ calc 8x
  ASL A
  ASL A
  ROL store+1
  ASL A
  ROL store+1
  STA store

  LDA ycoord      \ calc Y1=8(Y DIV 8) (i.e. round to a multiple of 8)
  AND #&F8

  LSR A           \ calc 64Y1, by shifting right twice and storing it as the high bit, nifty
  LSR A
  STA loc+1

  LSR A           \ calc 16Y1
  LSR A
  ROR loc     \ rotate the carry in
  ADC loc+1       \ calc 80Y1
  TAY

  LDA ycoord      \ calc Y%8
  AND #7      

  ADC loc            \ tot it all up
  ADC store          \ 8X low byte
  ADC scrollActual
  STA loc            \ low byte in loc
  TYA                \ 
  ADC store+1        \ 
  ADC scrollActual+1 \ 
  STA loc+1     \ 

  \ Figure out if we've gone over &7FFF
  CMP #&80
  BCS scrollModulus
RTS

.scrollModulus
  SEC
  SBC #&50
  STA loc+1
RTS

INCLUDE "base.asm"

.end

SAVE "FLAPPY",start,end
