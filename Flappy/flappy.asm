OSWRCH=&FFEE:OSBYTE=&FFF4
seed=1
baseStart=&F7
baseW=&10

shiftKey=&81

scrollOffset=&70
xcoord=&72
ycoord=&73
store=&74
loc=&76
scrollActual=&78
zeroPageBitmap=&7B
baseCurCol=&7D
baseOffset=&7E
shiftDown=&7F
sprite=&80
spriteW=&82
spriteH=&83
spriteY=&84
spriteCount=&85

flappyW=&10
flappyH=&C

GUARD &3000
ORG &1900

.start
.baseTable
  NOP:NOP
.flappyIndex
  NOP:NOP

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

  LDA #(flappySprite MOD 256)
  STA flappyIndex
  LDA #(flappySprite DIV 256)
  STA flappyIndex+1 

.loop
  JSR calcScrollActual
  JSR paintScrolling
  \JSR paintNonScrolling

  JSR checkKey
  JSR paintSprites

  \ wait for scrolling flag
  LDA #&13
  JSR OSBYTE

  JSR unpaintSprites
  JSR bumpBaseCurCol
  JSR bumpScroll
JMP loop

.checkKey
  \ Detect if the shift key is pressed
  LDA #(shiftKey)
  LDX #&FF
  LDY #&FF
  JSR OSBYTE

  \ Set shiftDown to 0 if not pressed, 1 if pressed
  LDA #0
  STA shiftDown
  TXA
  CMP #&FF
  BNE checkKeyDone
  LDA #1
  STA shiftDown
RTS

.checkKeyDone
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

.scrollMod2
  SEC
  SBC #&50
  STA loc+1
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
  INC baseOffset
  INC baseOffset

\  JSR CALCADDRESS
\  JMP paintNext8
.bumpLoc
\ add 0x280 to loc
\  CLC
\  LDA loc
\  ADC #&80
\  STA loc
\  LDA loc+1
\  ADC #2
\  STA loc+1 

\ modulo &8000
\  CMP #&80
\  BCS scrollMod2

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
  BEQ bumpLoc
  JMP paintInner
RTS

.calcColor
  LDA #(baseStart)
  CMP ycoord
  BCS loadBG

  JSR loadBase
RTS

.loadBG
  LDX #&3C
RTS

.loadBase
  \ ok we need to paint the base
  \ store Y in store, because we need it to offset the base
  TYA         
  STA store

  LDA baseOffset  
  TAY

  CLC
  ADC #(baseW)
  STA baseOffset

  LDA baseTable
  STA zeroPageBitmap

  LDA baseTable+1
  STA zeroPageBitmap+1

  LDA (zeroPageBitmap),Y
  TAX       \ Got the colour, put it in X
  LDA store \ And restore Y
  TAY
RTS

\ Gets called on every iteration to make the base column pointer bump then wrap
.bumpBaseCurCol
  INC baseCurCol
  LDA baseCurCol
  CMP #(baseW)
  BCC done
  LDA #0
  STA baseCurCol
RTS

.paintNonScrolling
  LDA #30
  STA xcoord
  LDA #24
  STA ycoord
  JSR CALCADDRESS

  LDA #0
  TAY

  LDA #&15
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

INCLUDE "paintSprite.asm"
INCLUDE "paintSprites.asm"
INCLUDE "unpaintSprites.asm"
INCLUDE "calcscrollactual.asm"
INCLUDE "calcaddress.asm"
INCLUDE "base.asm"
INCLUDE "flappySprite.asm"

.end

SAVE "F",start,end
