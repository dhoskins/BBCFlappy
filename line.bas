REM Sprite layers
REM BG with scrolling base
REM Then static scenery
REM Then scrolling pipes
REM Then flappy

DIM BLAH% &200
OSWRCH=&FFEE:OSBYTE=&FFF4

seed=TIME

scrollOffset=&70:REM and &71
XCOORD=&72:YCOORD=&73:REM     -- parameters to calcaddress
STORE=&74:REM and &75         -- temporary variable for calcaddress
LOC=&76:REM and &77           -- return value for calcaddress
scrollActual=&78:REM and &79
baseTable=&7B: REM and &7C
baseCurCol=&7D

baseStart=255-8
baseW=&8
baseOffset=&80


FOR PASS=0 TO 3 STEP 3
P% = BLAH%
RESTORE
[
OPT PASS
.BEGIN
  \ Mode 5, errrk
 \ LDA #22
 \ JSR OSWRCH
 \ LDA #5
 \ JSR OSWRCH

  \ initialise the scroll offset to 0xB00 (for mode 5)
  LDA #0
  STA scrollOffset
  STA baseCurCol

  LDA #&B
  STA scrollOffset+1

  LDA #(baseData MOD 256)
  STA baseTable
  LDA #(baseData DIV 256)
  STA baseTable+1

.loop
  JSR calcScrollActual
  JSR paintScrolling
  JSR paintNonScrolling

  LDA #&13
  JSR OSBYTE

  JSR bumpBaseCurCol
  JSR bumpScroll

JMP loop

\ Paint the rightmost strip
.paintScrolling
  LDA #39
  STA XCOORD
  LDA #0
  STA YCOORD

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

  STA (LOC),Y  \ Indirect addressing, see chapter 5 of Creative Assembler

  INC YCOORD
  LDA YCOORD
  CMP #0
  BEQ done

  INY
  TYA  \ compare Y to #8, need to do it via accumulator
  CMP #8
  BEQ paintNext8
  JMP paintInner
RTS

.calcColor
  LDA #baseStart
  CMP YCOORD
  BCS loadBG

  \ ok we need to paint the base
  \ store Y in tempY, because we need it to offset the base
  TYA         
  STA STORE

  LDA baseOffset  
  TAY

  CLC
  ADC #baseW
  STA baseOffset


  LDA (baseTable),Y
  TAX       \ Got the colour, put it in X
  LDA STORE \ And restore Y
  TAY
RTS

.loadBG
  LDX #&F
RTS

.bumpBaseCurCol
  INC baseCurCol
  LDA baseCurCol
  CMP #baseW
  BCC done
  LDA #0
  STA baseCurCol
RTS

.paintNonScrolling
  LDA #20
  STA XCOORD
  LDA #40
  STA YCOORD
  JSR CALCADDRESS

  LDA #0
  TAY

  LDA #&1D
  STA (LOC),Y

  LDA #19
  STA XCOORD
  LDA #40
  STA YCOORD
  JSR CALCADDRESS
  LDA #0
  TAY
  LDA #&F
  STA (LOC),Y
RTS

.resetX
  LDA #0
  STA XCOORD
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

  LDA #&B
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

\ &3000 + 8X + 16Y1 + 64Y1 + (Y % 8) where Y1=8(Y/8) for mode 2
\ &5800 + 8X +  8Y1 + 32Y1 + (Y % 8) where Y1=8(Y/8) for mode 5
\ (39,255) = &7FFF, y1=248
\ &3000 + 632 + 19840
\ &5800 + 312 + 9920 + 7
\ This thing takes XCOORD, YCOORD and translates it to the byte in memory which
\ corresponds to that screen location.
\ Screen location is "returned" in LOC, LOC+1
\ 248 * 32 = 7936
.CALCADDRESS
  \reset vars to 0
  LDA #0
  STA STORE+1
  STA LOC

  LDA XCOORD    \ calc 8x
  \ Don't need to ROL for first two bits as 39 is the max, 
  \ and first two bits will be 0 anyway
  ASL A
  ASL A
  ASL A
  ROL STORE+1
  STA STORE

  LDA YCOORD      \ calc Y1=8(Y DIV 8) (i.e. round to a multiple of 8)
  AND #&F8

  LSR A           \ calc 32Y1, by shifting right three times and storing it as the high bit, nifty
  LSR A
  LSR A
  STA LOC+1

  LSR A           \ calc 8Y1 (same as 16Y1 in Mode 2 because we only multiplied by 32 not 64 in the last step)
  ROR LOC     \ rotate the carry in
  LSR A
  ROR LOC     \ rotate the carry in
  ADC LOC+1       \ calc 80Y1
  TAY

  LDA YCOORD      \ calc Y%8
  AND #7      

  ADC LOC            \ tot it all up
  ADC STORE          \ 8X low byte
  ADC scrollActual
  STA LOC            \ low byte in loc
  TYA                \ 
  ADC STORE+1        \ 
  ADC scrollActual+1 \ 
  STA LOC+1     \ 

  \ Figure out if we've gone over &7FFF
  CMP #&80
  BCS scrollModulus
RTS

.scrollModulus
  SEC
  \ Wrap back round to &5800
  SBC #&28
  STA LOC+1
RTS

.baseData
  OPT FNdatatable((&8*&8))
RTS

]
NEXT PASS

P. ~BLAH%
P. ~P%
P. ~(P%-BLAH%)


REM SETUP
REM This will need to go in a loader or something
MODE 5

VDU 19,0,0,0,0,0  : REM Colour 0 is black
VDU 19,1,6,0,0,0  : REM Colour 1 is cyan
VDU 19,2,3,0,0,0  : REM Colour 2 is yellow
VDU 19,3,2,0,0,0  : REM Colour 3 is green

CALL BLAH%
END

DEF FNdatatable(N)
FOR item=1 TO N
READ D$
D=EVAL("&"+D$)
?P%=D:P%=P%+1
NEXT item
=PASS

REM Here's the base!
REM DATA  8, C
REM 100 (0x60) in total
DATA 55,55,55,55,55,55,55,55
DATA F0,F1,FF,FF,FF,FE,F0,F0
DATA F0,FC,FF,FF,FF,FE,F0,F0
DATA F0,FC,FF,FF,F1,FE,F0,F0
DATA F0,FC,FF,F1,FF,FE,F0,F0
DATA F0,FC,FF,FF,FF,FE,F0,F0
DATA F0,FC,FF,FF,FF,FE,F0,F0
DATA 55,55,55,55,55,55,55,55

REM Here are the background widgets
