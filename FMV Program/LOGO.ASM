oddF	=	$42000003
evenF	=	$52000003
LOGO_VRAMDec	=	$FF0000
LOGO_VRAMArt	=	$FF0540
LOGO_FrameNum	=	$FFE000
LOGO_Parity		=	$FFE006
;-------------------------------------------------------
LOGO:
	move.b	#$80,v_snddriver_ram+f_pausemusic
	move.w  #$E4,d0
	jsr     PlayFMSound

	jsr		InitVDP
	move.w	#$8C70,VDPCTRL
	move.w	#$9011,VDPCTRL
	
	move.l	#0,	d0
	move.l	d0,	hscroll
	move.l	d0,	LOGO_VRAMDec
	move.l	d0,	LOGO_VRAMArt
	move.l	d0,	LOGO_FrameNum
	move.l	d0,	LOGO_Parity
	
	move.w	#$E0,	d1
	lea		hscroll,	a0
.clrRAM:
	move.l	d0,	(a0)+
	dbf		d1,	.clrRAM
	
	move.l	#$10,d1
	lea		palette,a0
.clrPal:
	move.l	d0,(a0)+
	dbf		d1,.clrPal
	
	move.l	#$A0,d1
	lea		sprites,a0
.clrSpr:
	move.l	d0,(a0)+
	dbf		d1,.clrSpr
	
	moveq	#0,d0				; Load palette into both palette buffers
	jsr		LoadPalette
	
	move.b  #4,vintRoutine.w		; VSync
	jsr		VSync
	move.l	#LOGOTable,LOGO_FrameNum

;-------------------------------------------------------

LOOPLOGO:
;ODDSET
	move.b  #4,vintRoutine.w
	jsr		VSync
	btst  	#bitStart,	p1CtrlData
	bne.w	.skip
	lea		LOGO_FrameNum,a2	;	grab the art & map
	move.l	(a2),a2
	move.l	(a2),a0
	cmpi.w	#-1,a0		;	skip at end
	beq.w	.scream		;	^
	lea		LOGO_VRAMDec,a1
	jsr		KosPlusDec
	addi.w	#4,	LOGO_FrameNum+2
	tst.b	LOGO_Parity
	bne.s	.even
	LVLDMA	LOGO_VRAMArt,$0000,$1B20,VRAM	;	copy it to VRAM
	lea     LOGO_VRAMDec,a1 ; Load mappings
	move.l  #oddF,d0
	move.w  #32-1,d1
	move.w  #21-1,d2
	jsr   DrawTileMap
	move.w	#$0000,vscrollScreen
	move.b	#1,LOGO_Parity
	bra.w	LOOPLOGO
.even:
	LVLDMA	LOGO_VRAMArt,$8000,$1B20,VRAM	;	copy it to VRAM
	lea     LOGO_VRAMDec,a1 ; Load mappings
	move.l  #evenF,d0
	move.w  #32-1,d1
	move.w  #21-1,d2
	jsr   DrawTileMap
	move.w	#$0100,vscrollScreen
	move.b	#0,LOGO_Parity
	bra.w	LOOPLOGO
.scream:
	move.w	#120,vintTimer
	move.w  #$E1,d0
	jsr     PlayFMSound
.loop
	move.b  #4,vintRoutine.w
	jsr		VSync
	btst  	#bitStart,	p1CtrlData
	bne.w	.skip
	tst.w	vintTimer
	bne.s	.loop
.skip:
	move.w  #$E0,d0
	jsr     PlayFMSound
	moveq	#0,	d1
	move.w	#$800,	d0
	lea		$FF0000,	a0
.clrRAM:
	move.l	d1,	(a0)+
	dbf		d0,	.clrRAM
	jsr		FadeToBlack
	jsr		SHC
	move.b	#GM_TITLE,gameMode.w	;	set game mode to title screen
	rts
	
LOGOTable:
	dc.l	FRM_01,FRM_02,FRM_03,FRM_04,FRM_05,FRM_06,FRM_07,FRM_08
	dc.l	FRM_09,FRM_10,FRM_11,FRM_12,FRM_13,FRM_14,FRM_15,FRM_16
	dc.l	FRM_17,FRM_18,FRM_19,FRM_20,FRM_21,FRM_22,FRM_23,FRM_24
	dc.l	FRM_25,FRM_26,FRM_27,FRM_28,FRM_29,FRM_30,FRM_31,FRM_32
	dc.l	FRM_33,FRM_34,FRM_35,FRM_36,FRM_37,FRM_38,FRM_39,FRM_40
	dc.l	FRM_41,FRM_42,FRM_43,FRM_44,FRM_45,FRM_46,FRM_47,FRM_48
	dc.l	FRM_49,FRM_50,FRM_51,FRM_52,FRM_53,FRM_54,FRM_55,FRM_56
	dc.l	FRM_57,FRM_58,FRM_59,FRM_60,FRM_61,FRM_62,FRM_63,FRM_64
	dc.l	FRM_65,FRM_66,FRM_67,FRM_68,FRM_69,FRM_70,FRM_71,FRM_72
	dc.l	FRM_73,FRM_74,FRM_75,FRM_76,FRM_77,FRM_78,FRM_79,FRM_80
	dc.l	FRM_81,FRM_82,FRM_83,FRM_84,FRM_85,FRM_86,FRM_87,FRM_88
	dc.l	FRM_89,FRM_90,$FFFFFFFF
LOGOPAL:	INCBIN	"FMV Program/LOGOPAL.PAL"
FRM_01:		INCBIN	"FMV Program/FRAME01.KOSP"
FRM_02:		INCBIN	"FMV Program/FRAME02.KOSP"
FRM_03:		INCBIN	"FMV Program/FRAME03.KOSP"
FRM_04:		INCBIN	"FMV Program/FRAME04.KOSP"
FRM_05:		INCBIN	"FMV Program/FRAME05.KOSP"
FRM_06:		INCBIN	"FMV Program/FRAME06.KOSP"
FRM_07:		INCBIN	"FMV Program/FRAME07.KOSP"
FRM_08:		INCBIN	"FMV Program/FRAME08.KOSP"
FRM_09:		INCBIN	"FMV Program/FRAME09.KOSP"
FRM_10:		INCBIN	"FMV Program/FRAME10.KOSP"
FRM_11:		INCBIN	"FMV Program/FRAME11.KOSP"
FRM_12:		INCBIN	"FMV Program/FRAME12.KOSP"
FRM_13:		INCBIN	"FMV Program/FRAME13.KOSP"
FRM_14:		INCBIN	"FMV Program/FRAME14.KOSP"
FRM_15:		INCBIN	"FMV Program/FRAME15.KOSP"
FRM_16:		INCBIN	"FMV Program/FRAME16.KOSP"
FRM_17:		INCBIN	"FMV Program/FRAME17.KOSP"
FRM_18:		INCBIN	"FMV Program/FRAME18.KOSP"
FRM_19:		INCBIN	"FMV Program/FRAME19.KOSP"
FRM_20:		INCBIN	"FMV Program/FRAME20.KOSP"
FRM_21:		INCBIN	"FMV Program/FRAME21.KOSP"
FRM_22:		INCBIN	"FMV Program/FRAME22.KOSP"
FRM_23:		INCBIN	"FMV Program/FRAME23.KOSP"
FRM_24:		INCBIN	"FMV Program/FRAME24.KOSP"
FRM_25:		INCBIN	"FMV Program/FRAME25.KOSP"
FRM_26:		INCBIN	"FMV Program/FRAME26.KOSP"
FRM_27:		INCBIN	"FMV Program/FRAME27.KOSP"
FRM_28:		INCBIN	"FMV Program/FRAME28.KOSP"
FRM_29:		INCBIN	"FMV Program/FRAME29.KOSP"
FRM_30:		INCBIN	"FMV Program/FRAME30.KOSP"
FRM_31:		INCBIN	"FMV Program/FRAME31.KOSP"
FRM_32:		INCBIN	"FMV Program/FRAME32.KOSP"
FRM_33:		INCBIN	"FMV Program/FRAME33.KOSP"
FRM_34:		INCBIN	"FMV Program/FRAME34.KOSP"
FRM_35:		INCBIN	"FMV Program/FRAME35.KOSP"
FRM_36:		INCBIN	"FMV Program/FRAME36.KOSP"
FRM_37:		INCBIN	"FMV Program/FRAME37.KOSP"
FRM_38:		INCBIN	"FMV Program/FRAME38.KOSP"
FRM_39:		INCBIN	"FMV Program/FRAME39.KOSP"
FRM_40:		INCBIN	"FMV Program/FRAME40.KOSP"
FRM_41:		INCBIN	"FMV Program/FRAME41.KOSP"
FRM_42:		INCBIN	"FMV Program/FRAME42.KOSP"
FRM_43:		INCBIN	"FMV Program/FRAME43.KOSP"
FRM_44:		INCBIN	"FMV Program/FRAME44.KOSP"
FRM_45:		INCBIN	"FMV Program/FRAME45.KOSP"
FRM_46:		INCBIN	"FMV Program/FRAME46.KOSP"
FRM_47:		INCBIN	"FMV Program/FRAME47.KOSP"
FRM_48:		INCBIN	"FMV Program/FRAME48.KOSP"
FRM_49:		INCBIN	"FMV Program/FRAME49.KOSP"
FRM_50:		INCBIN	"FMV Program/FRAME50.KOSP"
FRM_51:		INCBIN	"FMV Program/FRAME51.KOSP"
FRM_52:		INCBIN	"FMV Program/FRAME52.KOSP"
FRM_53:		INCBIN	"FMV Program/FRAME53.KOSP"
FRM_54:		INCBIN	"FMV Program/FRAME54.KOSP"
FRM_55:		INCBIN	"FMV Program/FRAME55.KOSP"
FRM_56:		INCBIN	"FMV Program/FRAME56.KOSP"
FRM_57:		INCBIN	"FMV Program/FRAME57.KOSP"
FRM_58:		INCBIN	"FMV Program/FRAME58.KOSP"
FRM_59:		INCBIN	"FMV Program/FRAME59.KOSP"
FRM_60:		INCBIN	"FMV Program/FRAME60.KOSP"
FRM_61:		INCBIN	"FMV Program/FRAME61.KOSP"
FRM_62:		INCBIN	"FMV Program/FRAME62.KOSP"
FRM_63:		INCBIN	"FMV Program/FRAME63.KOSP"
FRM_64:		INCBIN	"FMV Program/FRAME64.KOSP"
FRM_65:		INCBIN	"FMV Program/FRAME65.KOSP"
FRM_66:		INCBIN	"FMV Program/FRAME66.KOSP"
FRM_67:		INCBIN	"FMV Program/FRAME67.KOSP"
FRM_68:		INCBIN	"FMV Program/FRAME68.KOSP"
FRM_69:		INCBIN	"FMV Program/FRAME69.KOSP"
FRM_70:		INCBIN	"FMV Program/FRAME70.KOSP"
FRM_71:		INCBIN	"FMV Program/FRAME71.KOSP"
FRM_72:		INCBIN	"FMV Program/FRAME72.KOSP"
FRM_73:		INCBIN	"FMV Program/FRAME73.KOSP"
FRM_74:		INCBIN	"FMV Program/FRAME74.KOSP"
FRM_75:		INCBIN	"FMV Program/FRAME75.KOSP"
FRM_76:		INCBIN	"FMV Program/FRAME76.KOSP"
FRM_77:		INCBIN	"FMV Program/FRAME77.KOSP"
FRM_78:		INCBIN	"FMV Program/FRAME78.KOSP"
FRM_79:		INCBIN	"FMV Program/FRAME79.KOSP"
FRM_80:		INCBIN	"FMV Program/FRAME80.KOSP"
FRM_81:		INCBIN	"FMV Program/FRAME81.KOSP"
FRM_82:		INCBIN	"FMV Program/FRAME82.KOSP"
FRM_83:		INCBIN	"FMV Program/FRAME83.KOSP"
FRM_84:		INCBIN	"FMV Program/FRAME84.KOSP"
FRM_85:		INCBIN	"FMV Program/FRAME85.KOSP"
FRM_86:		INCBIN	"FMV Program/FRAME86.KOSP"
FRM_87:		INCBIN	"FMV Program/FRAME87.KOSP"
FRM_88:		INCBIN	"FMV Program/FRAME88.KOSP"
FRM_89:		INCBIN	"FMV Program/FRAME89.KOSP"
FRM_90:		INCBIN	"FMV Program/FRAME90.KOSP"