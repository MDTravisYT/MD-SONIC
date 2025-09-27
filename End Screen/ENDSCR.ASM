ENDSCR:
	move.w	#$8B00,VDPCTRL
	move.w	#$8C70,VDPCTRL
	jsr		ClearScreen
	move.l  #$40000000,VDPCTRL   ; Load main titlescreen art
	lea     ENDART(pc),a0
	jsr   	NemDec
	lea     ENDMAP(pc),a1
	move.l  #$43C40003,d0
	move.w  #30-1,d1
	move.w  #15-1,d2
	jsr   DrawTileMap
	moveq	#7,d0				
	jsr		LoadPalette
	move.w  #$87,d0
	jsr     PlayFMSound
	
.loop:
	move.b  #4,vintRoutine.w
	jsr		VSync
	sub.w	#1,hscroll
	btst  	#bitStart,	p1CtrlTap
	bne.w	.creditsfade
	cmpi.w	#-250,hscroll
	beq.s	.map2
	cmpi.w	#-520,hscroll
	beq.s	.map3
	cmpi.w	#-760,hscroll
	beq.w	.credits
	bra.s	.loop
	
.map2:
	lea     ENDMAP2(pc),a1
	move.l  #$43800003,d0
	move.w  #30-1,d1
	move.w  #15-1,d2
	jsr   DrawTileMap
	bra.s	.loop
	
.map3:
	lea     ENDMAP3(pc),a1
	move.l  #$43C40003,d0
	move.w  #30-1,d1
	move.w  #15-1,d2
	jsr   DrawTileMap
	bra.s	.loop
.creditsfade:
	jsr		FadeToBlack
	moveq	#7,d0				
	jsr		LoadPalette

.credits:
	move.l  #$40000003,VDPCTRL
	lea     .zero,a0
	lea     VDPDATA,a1
	move.l	#$D00,d0
.clrVRAM:
	move.l	(a0),(a1)
	dbf		d0,.clrVRAM
	move.w	#$8C81,VDPCTRL
	move.w	#$9011,VDPCTRL
	jsr		ClearScreen
	
	lea     ENDMAP4(pc),a1
	move.l  #$4E040003,d0
	move.w  #36-1,d1
	move.w  #35-1,d2
	jsr   DrawTileMap
	
.zero:
	dc.l	0
	
.loopb:
	btst  	#bitStart,	p1CtrlTap
	bne.w	.end
	cmpi.w	#$200,vscrollScreen
	beq.s	.end
	move.b  #4,vintRoutine.w
	jsr		VSync
	tst.b	LOGO_Parity
	bne.s	.even
	add.w	#1,	vscrollScreen
	move.b	#1,LOGO_Parity
	bra.s	.loopb
.even
	move.b	#0,LOGO_Parity
	bra.s	.loopb
.end:
	move.w  #$E0,d0
	jsr     PlayFMSound
	move.b	#GM_TITLE,gameMode.w			; Set game mode to "title"
	jmp		FadeToBlack
	
ENDART:		INCBIN	"End Screen\ART.BIN"
ENDMAP:		INCBIN	"End Screen\MAP.BIN"
ENDMAP2:	INCBIN	"End Screen\MAP2.BIN"
ENDMAP3:	INCBIN	"End Screen\MAP3.BIN"
ENDMAP4:	INCBIN	"End Screen\MAP4.BIN"
ENDPAL:		INCBIN	"End Screen\PAL.PAL"