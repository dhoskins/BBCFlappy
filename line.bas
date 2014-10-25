DIM BLAH 500
OSWRCH=&FFEE:OSBYTE=&FFF4

seed=TIME

scrollOffset=&70:REM and &71
XCOORD=&72:YCOORD=&73
STORE=&74:REM and &75
LOC=&76:REM and &77
scrollActual=&78:REM and &79
MAGIC_Y=&7A
CTR=&7B
COLOUR 129
FOR PASS=0 TO 3 STEP 3
P% = BLAH
RESTORE
[
OPT PASS
.BEGIN
  \ Mode 2
  LDA #22
  JSR OSWRCH
  LDA #2
  JSR OSWRCH

  LDA #128
  STA MAGIC_Y

  \ initialise the scroll offset to 0x600
  LDA #0
  STA scrollOffset
  LDA #6
  STA scrollOffset+1

  LDA #79
  STA XCOORD

  LDA #0
  STA CTR
  
.loop
  JSR calcScrollActual
  JSR paint
  JSR move

  LDA #&13
  JSR OSBYTE  

  JSR bumpScroll    



JMP loop

.paint
  LDA #0
  STA YCOORD

.paintLoop
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
  TYA
  CMP #8
  BEQ paintLoop
  JMP paintInner
RTS

.calcColor
  LDA YCOORD
  CMP MAGIC_Y
  BEQ loadWhiteX
  LDX #3
RTS

.loadWhiteX
  LDX #&3F
RTS

.move
  \ Now adjust the pixel Y
 \ JSR rnd
  
  \CMP #&7F
  \BPL increment
  \JSR decrement
RTS

.resetX
  LDA #0
  STA XCOORD
RTS

.increment
  INC YCOORD
RTS

.decrement
  DEC YCOORD
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

.done
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
  STA STORE+1
  STA LOC


  LDA XCOORD    \ calc 8x
  ASL A
  ASL A
  ROL STORE+1
  ASL A
  ROL STORE+1
  STA STORE

  LDA YCOORD      \ calc Y1=8(Y DIV 8) (i.e. round to a multiple of 8)
  AND #&F8

  LSR A           \ calc 64Y1, by shifting right twice and storing it as the high bit, nifty
  LSR A
  STA LOC+1

  LSR A           \ calc 16Y1
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
  BMI done

  SEC
  SBC #&50
  STA LOC+1
RTS

.baseData
  OPT FNdatatable((&8*&C) + 2)
RTS

]
NEXT PASS

P. P%-BLAH
CALL BLAH
END

DEF FNdatatable(N)
FOR item=1 TO N
READ D$
D=EVAL("&"+D$)
?P%=D:P%=P%+1
NEXT item
=PASS

REM Here's the base!
DATA  8, C
REM 100 (0x60) in total
DATA  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
DATA  F, F, F, C, C, C, C, C, C, F, F, F
DATA  F, F, E, C, C, C, C, C, D, F, F, F
DATA  F, F, C, C, C, C, C, C, F, F, F, F
DATA  F, E, C, C, C, C, C, D, F, F, F, F
DATA  F, C, C, C, C, C, C, F, F, F, F, F
DATA  E, C, C, C, C, C, D, F, F, F, F, F
DATA  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3

