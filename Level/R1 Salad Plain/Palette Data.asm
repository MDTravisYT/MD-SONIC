; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023
; -------------------------------------------------------------------------
; Salad Plain Act 1 Past palette data
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Palette table
; -------------------------------------------------------------------------

PaletteTable:
	dc.l	LOGOPAL				; Sonic 1 SEGA screen background (leftover)
	dc.w	palette
	dc.w	$07
	dc.l	Pal_TitleScreen			; Sonic 1 title screen (leftover)
	dc.w	palette
	dc.w	$1F
	dc.l	Pal_S1LevSel			; Sonic 1 level select screen (leftover)
	dc.w	palette
	dc.w	$1F
	dc.l	Pal_Sonic			; Sonic
	dc.w	palette
	dc.w	7
	dc.l	Pal_LevelProto			; Level
	dc.w	palette+$20
	dc.w	$17
	dc.l	Pal_LevelPresent			; Level
	dc.w	palette+$20
	dc.w	$17
	dc.l	Pal_LevelFuture			; Level
	dc.w	palette+$20
	dc.w	$17
	dc.l	ENDPAL				; End Screen
	dc.w	palette
	dc.w	$07
	dc.l	Pal_R3
	dc.w	palette+$20
	dc.w	$17
	dc.l	LOCK_PAL
	dc.w	palette+$20
	dc.w	$17
	dc.l	Pal_Boss
	dc.w	palette+$20
	dc.w	7

; -------------------------------------------------------------------------

; Sonic 1 SEGA screen background (leftover, data completely removed)
Pal_S1SegaBG:

; Sonic 1 level select screen (leftover)
Pal_S1LevSel:
	incbin	"Title Screen/palsel.bin"
	even

; Sonic palette
Pal_Sonic:
	incbin	"Level/_Objects/Sonic/Data/Palette.bin"
	even

; Level palette
Pal_LevelProto:
	incbin	"Level/R1 Salad Plain/Past Palette.bin"
	even
Pal_LevelPresent:
	dc.w $0000,$0000,$0800,$0E40,$0E64,$0006,$0EEE,$008E,$0888,$0444,$0E8E,$0A4E,$00EE,$0088,$0044,$002E
	dc.w $0A00,$08EE,$0E0E,$0002,$00AE,$0000,$004A,$0026,$02E8,$00A0,$0060,$0040,$0ECA,$0EA8,$0C60,$0E86
	dc.w $0A22,$0E66,$0E88,$0ECC,$0EEE,$0ECC,$0ECA,$0EEE,$0EA8,$0060,$00A4,$00E8,$0402,$0226,$006A,$00AE
	even
Pal_LevelFuture:
	dc.w $0000,$0000,$0800,$0E40,$0E64,$0006,$0EEE,$008E,$0888,$0444,$0E8E,$0A4E,$00EE,$0088,$0044,$002E
	dc.w $0646,$0EAC,$0084,$0200,$0A66,$004C,$0644,$0422,$028E,$0028,$0024,$0022,$0CAE,$0C8C,$0846,$0C64
	dc.w $0246,$0448,$066A,$0A8C,$0AAE,$0888,$0666,$0888,$0444,$0644,$0868,$0EAE,$0000,$0226,$006A,$00AE
	even
Pal_R3:
	dc.w $0000,$0000,$0444,$0888,$0060,$00A0,$0EEE,$0C20,$0E42,$0E86,$0006,$006E,$00EE,$0088,$0044,$000E
	dc.w $0804,$08EE,$0A8E,$086E,$084C,$0406,$0204,$00E0,$0080,$0040,$0000,$0EEE,$0EA4,$0C24,$0428,$00AE
	dc.w $0804,$00EE,$008C,$006A,$0048,$0002,$006E,$080C,$0808,$000E,$0000,$0880,$00EE,$0E0E,$0200,$00E0
	even
Pal_Boss:       dc.w   0,  0,$444,$666,$888,$AAA,$EEE,$8AA
                dc.w $688,$466,$244,$22,$EE,$88,$44,$EE
; -------------------------------------------------------------------------
