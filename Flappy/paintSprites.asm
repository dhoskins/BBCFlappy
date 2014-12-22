.paintSprites
	\LDA #(shiftDown)
	\CMP #1
	LDA #50
	STA xcoord
	LDA #160
	STA ycoord

	LDA flappyIndex
	STA sprite

	LDA flappyIndex+1
	STA sprite+1
	JSR paintSprite
RTS