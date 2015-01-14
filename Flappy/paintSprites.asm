.paintSpritesOn
	LDA #0
	STA shouldRestoreStash
	JMP paintSprites

.paintSpritesOff
	LDA #1
	STA shouldRestoreStash

.paintSprites
	LDA #50
	STA xcoord
	LDA #160
	STA ycoord

	LDA #(flappySprite MOD 256)
	STA sprite
	LDA #(flappySprite DIV 256)
	STA sprite+1

	LDA #(flappySpriteEnd MOD 256)
	STA spriteStash
	LDA #(flappySpriteEnd DIV 256)
	STA spriteStash+1

	JSR paintSprite
RTS