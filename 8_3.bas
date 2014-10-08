REM MULTICOLOUR ANIMATION BY 
REM ADDRESSING DIRECT SCREEN 
REM LOCATIONS IN MODE2
OSWRCH=&FFEE:OSBYTE=&FFF4 
LOC=&70
DIM START 500
FOR PASS=0 TO 2 STEP 2 
P%=START
RESTORE 
[
OPT PASS 
LDA #&16 				\ Mode 2
JSR OSWRCH 
LDA #2
JSR OSWRCH 
LDA #&0					\ Set LOC to screen
STA LOC 				\ start address
LDA #&30 				\ &3000
STA LOC+1 				\

.BEGIN
LDY #31					\ There are this number of bytes in the data sequence
.LOOP2
LDA data, Y             \ Load the entire data 
STA (LOC), Y            \ array into the screen
DEY                     \ address
BPL LOOP2               \
LDA #&13                \ Wait for screen sync
JSR OSBYTE
LDA #0                  \ Put blackness into the whole character
LDY #31                 \
.LOOP1                  \
STA (LOC),Y             \
DEY                     \
BPL LOOP1               \
CLC
LDA LOC                 \
ADC #8                  \ Bump the screen location by 8 (low byte
STA LOC                 \
BCC SKIP                \ If we haven't carried over 
INC LOC+1 				\ bump the high byte
.SKIP
LDA LOC					\ If low byte is not zero loop
BNE BEGIN               \
LDA LOC+1          
CMP #&80                \ If high byte is not &80, loop
BNE BEGIN
BEQ FINISH

.data                   \ Populate .data
]
PROCdatatable(32)
DATA 0,0,0,1,3,3,3,0,&40,1,3,3,9,3,3,2,&80,2,3,3,6,3,3,1,0,0,0,2,3,3,3,0 

[
OPT PASS 
.FINISH 
RTS:
]
NEXT PASS 
CALL START
END

DEFPROCdatatable(N) 
FOR item=1 TO N
READ D$
D=EVAL(D$)
?P%=D:P%=P%+1 
NEXT item
ENDPROC