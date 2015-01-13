\ Accepts xcoord, ycoord and sprite (+1)
.paintSprite
	LDX #2
	LDY #1
	LDA (sprite),Y
	STA spriteH

\ Paints a row at a time
	.newRow
		LDA #0
		STA spriteY

		\ Load the width value again
		LDY #0
		LDA (sprite),Y
		STA spriteW
		TXA
		PHA
		JSR CALCADDRESS
		PLA
		TAX
		\ loc now holds the address of the leftmost pixel in the row
	.newCol
		\ Move X to Y
		TXA
		TAY
		\ Y is now the offset into sprite that we are currently on
		LDA (sprite),Y

		\ spriteY is the index into the row
		LDY spriteY
		STA (loc),Y

		\ bump the index by 8
		TYA 
		ADC #8   \ because there's 8 pixels in a "character"
		STA spriteY

		\ Increase the offset into sprite
		INX
		\ Decrease the sprite width.  If it's not 0 yet, do another column
		DEC spriteW
		BNE newCol

		\ We finished a row.  Now bump the Y coord
		INC ycoord
		\ Decrease the sprite height.  If it's not 0 yet, do another row
		DEC spriteH
		BNE newRow
RTS