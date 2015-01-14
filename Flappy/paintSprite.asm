\ Accepts xcoord, ycoord, sprite (+1) and spriteStash (+1)
\ shouldRestoreStash is a flag to show whether we want to restore the stash
.shouldRestoreStash
	NOP
.paintSprite
	\ Initialise X (offset into sprite) to 2, skip past width and height bytes
	LDX #2

	\ Load height value into spriteH
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

		\ X contains offset into the sprite, let's stash it in the
		\ stack while we calculate address
		TXA
		PHA
		JSR CALCADDRESS
		PLA
		TAX
		\ loc now holds the address of the leftmost pixel in the row
	.newCol

		LDA shouldRestoreStash
		CMP #1
		BEQ restoreStash

		\ Move X to Y
		TXA
		TAY

		\ Y is now the offset into sprite that we are currently on
		LDA (sprite),Y

		\ A now contains the pixel we want to write to screen. Stick it
		\ on the stack while we stash the current pixel val
		PHA

		\ spriteY is the index into the row
		LDY spriteY

		\ Grab current pixel value
		LDA (loc),Y

		\ Stick it in to spriteStash
		PHA

		TXA
		TAY

		DEY
		DEY

		PLA

		STA (spriteStash),Y

		\ Now get the pixel back out of the stack and draw to screen
		PLA
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

	.restoreStash
		\ Move X to Y
		TXA
		TAY
		DEY
		DEY
		\ Y is now the offset into sprite that we are currently on
		LDA (spriteStash),Y
		
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