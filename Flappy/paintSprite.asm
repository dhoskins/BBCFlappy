; Accepts xcoord, ycoord, sprite (+1) and spriteStash (+1)
; shouldRestoreStash is a flag to show whether we want to restore the stash
.shouldRestoreStash
	NOP
.paintSprite
	; Initialise X (offset into sprite) to 2, skip past width and height bytes
	LDX #2

	; Load height value into spriteH
	LDY #1
	LDA (sprite),Y
	STA spriteH

; Paints a row at a time
;  
;  X 0 1 2 3 4 5 6  Each pixel in the row is +8 from the previous
;  X 7 8 9 A B C D  Run calcaddress for each new row to find the leftmost address
;  X . . . . . . .

	.newRow ; 1A56
		LDA #0
		STA spriteX

		; Load the width value (again)
		LDY #0
		LDA (sprite),Y
		STA spriteW

		; X contains offset into the sprite, let's stash it in the
		; stack while we calculate address
		TXA
		PHA
		JSR CALCADDRESS  ; returns loc
		PLA
		TAX
		; loc now holds the address of the leftmost pixel in the row
	.newCol ; 1A67

		; Move X to Y
		TXA
		TAY

		LDA shouldRestoreStash
		CMP #1
		BEQ restoreStash



		; Y is now the offset into sprite that we are currently on
		LDA (sprite),Y

		; A now contains the pixel we want to write to screen. Stick it
		; on the stack while we stash the current pixel val
		PHA

		; spriteX is the index into the row
		LDY spriteX

		; Grab current pixel value (i.e. what's currently on screen)
		LDA (loc),Y

		; Stick it in to spriteStash
		PHA

		; Restore the original Y
		TXA
		TAY

		DEY
		DEY

		PLA

		STA (spriteStash),Y

		; Now get the pixel back out of the stack and draw to screen
		PLA
		LDY spriteX
		STA (loc),Y

		; bump the index by 8
		TYA 
		ADC #8   ; because there's 8 pixels in a "character"
		STA spriteX

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

	.restoreStash  ; 1A95
		CLC
		DEY
		DEY
		; Y is now the offset into sprite that we are currently on
		LDA (spriteStash),Y
		;LDA #1
		LDY spriteX
		STA (loc),Y

		; bump the index by 8
		TYA 
		ADC #8   ; because there's 8 pixels in a "character"
		STA spriteX

		; Increase the offset into sprite
		INX
		; Decrease the sprite width.  If it's not 0 yet, do another column
		DEC spriteW
		BNE newCol

		; We finished a row.  Now bump the Y coord
		INC ycoord
		; Decrease the sprite height.  If it's not 0 yet, do another row
		DEC spriteH
		BNE newRow
RTS
