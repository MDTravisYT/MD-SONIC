;+=!!!IMPORTANT!!!!!!IMPORTANT!!!!!!IMPORTANT!!!!!!IMPORTANT!!!!!!IMPORTANT!!!!!!IMPORTANT!!!!!!IMPORTANT!!!!!!IMPORTANT!!!=+
;	Various disassemblies have different labels depending on what and when you use them.
;	For convenience, a compiler flag has been provided below. 
;	Change the number to the following number that matches your disassembly.
;		1 = Define your own
;		2 = Sonic 1 (GitHub, AS) > https://github.com/sonicretro/s1disasm
;		3 = Sonic 1 (GitHub, ASM68K) > https://github.com/sonicretro/s1disasm/tree/asm68k
;		4 = Sonic 1 (Hivebrain 2005) > https://info.sonicretro.org/images/a/a9/Sonic_1_%28Split_and_Text_by_Hivebrain%29.zip
;		5 = Sonic 2 (GitHub) > https://github.com/sonicretro/s2disasm
;		6 = Sonic 2 (Xenowhirl 2007) > https://info.sonicretro.org/images/a/af/Sonic_2_%28Split_and_Text_by_Xenowhirl%29.zip
;		7 = Sonic 3 & Knuckles (GitHub) > https://github.com/sonicretro/skdisasm
SHC_Disassembly	=	0
;+==========================================================================================================================+
SHC_FadeTo		=	FadeToBlack		;	Routine to fade the screen to black
SHC_FadeFrom	=	FadeFromBlack	;	Routine to fade in from black to a palette in the palette buffer
SHC_FadePal		=	FadePalette		;	Palette buffer for the FadeFrom command
SHC_VDPCTRL		=	VDPCTRL			;	VDP control port
SHC_Sprites		=	sprites			;	Sprite table. Gets DMA'd to VRAM in VInt
SHC_VInt		=	vintRoutine		;	VInt routine
SHC_VSync		=	VSync			;	VInt Jump
SHC_Ctrl		=	p1CtrlData		;	Controller data
;SHC_FadeTo		=	PaletteFadeOut
;SHC_FadeFrom	=	PaletteFadeIn
;SHC_FadePal	=	v_palette_fading
;SHC_VDPCTRL	=	vdp_control_port
;SHC_Sprites	=	v_spritetablebuffer
;SHC_VInt		=	v_vbla_routine
;SHC_VSync		=	WaitForVBla
;SHC_Ctrl		=	v_jpadpress1

SHC:
	jsr		SHC_FadeTo
	move.w	#$8218,SHC_VDPCTRL	;	Set initial frame
	move.w	#$8C81,SHC_VDPCTRL	;	Make sure we're in H40 mode
	move.w	#$9001,SHC_VDPCTRL	;	Set plane size to 64x32
	move.l	#$A0,d1				;	v
	lea		SHC_Sprites,a0		;	v
SHC_ClearSprites:         		;	Clear sprites
	move.l	d0,(a0)+      		;	^
	dbf		d1,SHC_ClearSprites	;	^
	
	lea		SHC_Pal,	a0		;	Palette pointer
	lea		SHC_FadePal,a1		;	Palette destination (fade buffer, will be used later)
	move.l	#7,			d0		;	Set up how long loop will take (32/8)-1
SHC_LoadPal:	
	move.l	(a0)+,(a1)+			;	Move what's located in a0 (source) to a1 (destination)
	dbf		d0,	SHC_LoadPal		;	Loop until complete (d0 is 0)
	
	lea		SHC_ART1,a0
	lea		LOGO_VRAMDec,a1
	jsr		KosPlusDec
	LVLDMA	LOGO_VRAMDec,$0000,$2000,VRAM	
	lea		SHC_ART2,a0
	lea		LOGO_VRAMDec,a1
	jsr		KosPlusDec
	LVLDMA	LOGO_VRAMDec,$2000,$2000,VRAM
	lea		SHC_ART3,a0
	lea		LOGO_VRAMDec,a1
	jsr		KosPlusDec
	LVLDMA	LOGO_VRAMDec,$4000,$2000,VRAM
	lea		SHC_MAP0,a0
	lea		LOGO_VRAMDec,a1
	jsr		KosPlusDec
	LVLDMA	LOGO_VRAMDec,$6000,$1000,VRAM
	lea		SHC_MAP1,a0
	lea		LOGO_VRAMDec,a1
	jsr		KosPlusDec
	LVLDMA	LOGO_VRAMDec,$8000,$1000,VRAM
	lea		SHC_MAP2,a0
	lea		LOGO_VRAMDec,a1
	jsr		KosPlusDec
	LVLDMA	LOGO_VRAMDec,$A000,$1000,VRAM
	
	jsr		SHC_FadeFrom	;	Fade in palette we just copied above
	
	lea		SHC_FlickerTable,a0	;	Move the flicker table to a0, referenced by the loop
	moveq	#0,	d0				;	Clear d0
	
SHC_Loop:
	move.b  #4,(SHC_VInt).w		;	VSync
	jsr		VSync				;	^
	btst  	#7,SHC_Ctrl			;	Check if start is pressed
	bne.s	SHC_End				;	End execution if so
	move.b	(a0)+,d0			;	Copy the data within a0 to d0, and increase the pointer by 1 for next frame
	btst	#7,d0				;	Check if we're at the end ($FF byte, aka -1)
	bne.s	SHC_End				;	Branch if so (bit 7 is set)
	btst	#0,d0				;	Check if bit 0 is set (value is 1)
	bne.s	SHC_MidFrm			;	Branch if so (makes plane A point to A000, the middle frame)
	btst	#1,d0				;	Check if bit 1 is set (value is 2)
	bne.s	SHC_BriFrm			;	Branch if so (makes plane A point to C000, the bright frame)
	move.w	#$8218,SHC_VDPCTRL	;	If all of the above fails, set plane A to point to 8000 (dark frame)
	bra.s	SHC_Loop
	
SHC_MidFrm:
	move.w	#$8220,SHC_VDPCTRL	;	Middle frame pointer, plane A = A000
	bra.s	SHC_Loop
SHC_BriFrm:
	move.w	#$8228,SHC_VDPCTRL	;	Bright frame pointer, plane A = C000
	bra.s	SHC_Loop
SHC_End:
	move.l	#0,d1
	move.w	#$800,	d0
	lea		$FF0000,	a0
.clrRAM:
	move.l	d1,	(a0)+
	dbf		d0,	.clrRAM
	jmp		SHC_FadeTo			;	End of execution, jump to fade and return from this subroutine

SHC_FlickerTable:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	2,1,2,2,2,1,2,2,0,2,2,1,1,2,2,1,2,2,1,2,1,2,2,2,2,1,2,2,2,1,1,2
	dc.b	1,0,1,1,2,1,2,2,0,2,2,1,2,1,1,2,0,2,2,0,1,1,2,2,1,1,2,2,0,2,2,2
	dc.b	0,1,1,1,1,2,2,2,1,1,0,2,2,0,1,1,2,2,2,0,2,2,0,2,2,2,2,2,2,0,2,1
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b	2,0,2,0,2,2,2,2,0,2,2,2,1,2,0,2,2,0,2,1,2,1,0,0,0,2,2,2,0,1,2,1
	dc.b	2,2,0,1,0,1,2,0,2,1,1,2,1,1,0,1,2,1,2,1,0,2,2,1,0,1,2,2,0,2,2,2
	dc.b	0,1,2,2,1,1,2,2,1,2,1,2,2,2,2,2,2,2,2,2,2,1,2,2,2,0,1,2,1,0,0,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b	0,2,2,0,2,2,2,1,2,1,2,0,2,2,2,1,2,2,2,2,1,2,0,0,2,2,2,2,0,2,0,1
	dc.b	2,2,0,2,0,2,2,0,2,1,2,0,2,0,2,2,2,1,0,0,0,1,0,2,1,2,0,2,1,2,1,0
	dc.b	1,2,1,2,2,1,2,1,2,0,0,2,2,2,2,1,2,2,2,0,2,2,2,2,2,0,1,0,0,1,0,2
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,-1,-1
	
SHC_Pal:
	dc.w	$0000,$0000,$0444,$0888,$0AAA,$0EEE,$000E,$0EC8
	dc.w	$0E80,$0E00,$0C00,$0A00,$0800,$0600,$0400,$0200
	
SHC_ART1:	incbin	"SHC Splash/ART1.KOSP"
SHC_ART2:	incbin	"SHC Splash/ART2.KOSP"
SHC_ART3:	incbin	"SHC Splash/ART3.KOSP"
SHC_MAP0:	incbin	"SHC Splash/0.KOSP"
SHC_MAP1:	incbin	"SHC Splash/1.KOSP"
SHC_MAP2:	incbin	"SHC Splash/2.KOSP"