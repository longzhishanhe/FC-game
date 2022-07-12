;显示背景
	.inesprg 1
	.ineschr 1
	.inesmap 0
	.inesmir 1
	

	.bank 0
	.org $c000
	RESET:
		sei
		cld
		ldx #$40
		stx $4017
		ldx #$FF
		txs
		inx
		stx $2000
		stx $2001
		stx $4010
	
	vblankWait1:
		bit $2002
		bpl vblankWait1
		
	clrmem:
		lda #$00
		sta $0000,x
		sta $0100,x
		sta $0300,x
		sta $0400,x
		sta $0500,x
		sta $0600,x
		sta $0700,x
		lda #$FE
		sta $0200,x
		inx
		bne clrmem
		
	vblankWait2:
		bit $2002
		bpl vblankWait2
	
	;初始化调色板
	loadPalettes:
		lda $2002
		lda #$3F
		sta $2006
		lda #$00
		sta $2006
		
		ldx #$00
	loadPalettesLoop:
		lda palette,x
		sta $2007
		inx
		cpx #$20
		bne loadPalettesLoop
		
	;初始化精灵(此处放入cpu内存$0200)
	loadSprites:
		ldx #$00
	loadSpritesLoop:
		lda sprites,x
		sta $0200,x
		inx
		cpx #20
		bne loadSpritesLoop
	
	;初始化背景
	loadBackground:
		lda $2002
		lda #$20
		sta $2006
		lda #$00
		sta $2006
		
		;分4次复制数据
		ldx #$00
	loadBackgroundLoop1:
		lda background,x
		sta $2007
		inx
		bne loadBackgroundLoop1
		
	loadBackgroundLoop2:
		lda background+$100,x
		sta $2007
		inx
		bne loadBackgroundLoop2
		
	loadBackgroundLoop3:
		lda background+$200,x
		sta $2007
		inx
		bne loadBackgroundLoop3
	
	loadBackgroundLoop4:
		lda background+$300,x
		sta $2007
		inx
		bne loadBackgroundLoop4
		
		;------------------
		
		lda #%10010000
		sta $2000
		
		lda #%00011110
		sta $2001
		
	forever:
		jmp forever
		
	NMI:
		lda #$00
		sta $2003
		lda #$02
		sta $4014
		
	;手柄
LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons
  
ReadK:
	LDA $4016
ReadJ:
	LDA $4016
ReadB:
	LDA $4016
ReadV:
	LDA $4016
	
	;读按钮上
ReadW:
	LDA $4016
	AND #%00000001
	BEQ ReadWDone
	
	LDA $0200
	BEQ ReadWDone
	
	SEC
	SBC #$01
	STA $0200
  
	LDA $0204
	SEC
	SBC #$01
	STA $0204
  
	LDA $0208
	SEC
	SBC #$01
	STA $0208
  
	LDA $020C 
	SEC             
	SBC #$01        
	STA $020C
ReadWDone:

	;读按钮下
ReadS:
	LDA $4016
	AND #%00000001
	BEQ ReadSDone
	
	LDA $0200
	cmp #$E4
	bcs ReadSDone
	
	CLC
	ADC #$01
	STA $0200
  
	LDA $0204
	CLC
	ADC #$01
	STA $0204
  
	LDA $0208
	CLC
	ADC #$01
	STA $0208
  
	LDA $020C 
	CLC             
	ADC #$01        
	STA $020C
ReadSDone:

	;读按钮左
ReadA:
	LDA $4016
	AND #%00000001
	BEQ ReadADone
	
	LDA $0203
	BEQ ReadADone
	
	SEC
	SBC #$01
	STA $0203
  
	LDA $0207
	SEC
	SBC #$01
	STA $0207
  
	LDA $020B
	SEC
	SBC #$01
	STA $020B
  
	LDA $020F 
	SEC             
	SBC #$01        
	STA $020F 
ReadADone:

	;读按钮右
ReadD:
	LDA $4016
	AND #%00000001
	BEQ ReadDDone
	
	LDA $0203
	cmp #$F4
	bcs ReadDDone
	
	CLC
	ADC #$01
	STA $0203
  
	LDA $0207
	CLC
	ADC #$01
	STA $0207
  
	LDA $020B
	CLC
	ADC #$01
	STA $020B
  
	LDA $020F 
	CLC             
	ADC #$01        
	STA $020F	
ReadDDone:	

		
	;-------------
		lda #%10010000
		sta $2000
		
		lda #%00011110
		sta $2001
		
		lda #$00
		sta $2005
		sta $2005
		
		rti
		
	
	
	.bank 1
	.org $E000
	palette:
		;背景调色板
		.incbin "minesweeper.pal"
		;精灵调色板
		.db $0F,$30,$27,$30,$0F,$31,$30,$27,$0F,$33,$30,$27,$0F,$22,$35,$33
		
		;精灵数据
	sprites:
		.db $80,$00,$00,$30	;精灵H
		.db	$80,$01,$00,$38	;精灵E
		.db $88,$10,$00,$30	;精灵L
		.db $88,$11,$00,$38	;精灵L
		
	background:	
		;包含属性表和命名表
		.incbin "minesweeper.nam"
		
		
		.org $FFFA
		;nmi中断
		.dw NMI
		;开机启动地址
		.dw RESET
		;irq中断,未使用
		.dw 0
	
	.bank 2
	.org $0000
	.incbin "source.chr"
	