MODE 2
PRINT "Blah blah blah"
PROCASSEMBLE 
START=HIMEM/8
X=0
Y=0
REM *******************
REPEAT
IF INKEY(-42)  THEN Y=(Y+31) MOD 32 : REM DOWN
IF INKEY(-58)  THEN Y=(Y+1)  MOD 32 : REM UP
IF INKEY(-26)  THEN X=(X+1)  MOD 80 : REM LEFT
IF INKEY(-122) THEN X=(X+79) MOD 80 : REM RIGHT
S=START+X+Y*80
?&D00=S DIV 256
?&D01=S MOD 256
CALL &D10
UNTIL FALSE
REM *******************
REM Machine code routine to load 
REM register 12 with the contents 
REM of &D00 and 13 with that of
REM &D01. Has to be in MC for
REM high speed.
DEF PROCASSEMBLE
P%=&D10
[OPT 0
LDA #12:STA &FE00
LDA &D00:STA &FE01 
LDA #13:STA &FE00 
LDA &D01:STA &FE01 
RTS:]
ENDPROC
