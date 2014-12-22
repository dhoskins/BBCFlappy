  \ &3000 + 8X + 16Y1 + 64Y1 + (Y MOD 8)
  \ This thing takes xcoord, ycoord and translates it to the byte in memory which
  \ corresponds to that screen location.
  \ Screen location is "returned" in loc, loc+1
  .CALCADDRESS
    \reset vars to 0
    LDA #0
    STA store+1
    STA loc

    CLC
    LDA xcoord    \ calc 8x
    ASL A
    ASL A
    ROL store+1
    ASL A
    ROL store+1
    STA store       \ store,store+1 is now 8x

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
    STA loc            \ low byte in loc
    TAX

    TYA                \ 
    ADC store+1        \ 
    STA loc+1     \ 
    TAY

    CLC
    TXA
    ADC scrollActual
    STA loc

    TYA
    ADC scrollActual+1
    STA loc+1


    \ Figure out if we've gone over &7FFF
    CMP #&80
    BCS scrollModulus
  RTS

  .scrollModulus
    SEC
    SBC #&50
    STA loc+1
  RTS