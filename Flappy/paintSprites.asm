.paintSprites
	LDA #50
	STA xcoord
	LDA #160
	STA ycoord

	LDA #(flappySprite MOD 256)
	STA sprite

	LDA #(flappySprite DIV 256)
	STA sprite+1
	JSR paintSprite
RTS