ipxnemBuffer	EQU     $FFFFC000

objSlots        EQU     $FFFFE300

hscrollTable    EQU     $FFFFF400

titleTimer      EQU     $FFFFFA42


; -------------------------------------------------------------------------
; MD Title Screen
; -------------------------------------------------------------------------
TitleScreen:
	
	move.l	#0,	d0
	move.w	d0,Title_PadProg
	move.l	d0,	d1
	move.w	#$E0,	d0
	lea		hscroll,	a0
.clrRAM:
	move.l	d1,	(a0)+
	dbf		d0,	.clrRAM
	
	move.w	#$100,	d0
	lea		objSlots,	a0
.clrRAM2:
	move.l	d1,	(a0)+
	dbf		d0,	.clrRAM2

	move.b	#1,(timeZone).l			; (ADDED) Set time zone to present
	move.w	#0,zone					; (ADDED) Set time zone to present

	jsr		InitVDP
	move.w	#$8700,VDPCTRL

	move.l  #$70000001,VDPCTRL   ; Load vocal credit text
	lea     ArtNoSell(pc),a0
	jsr   NemDec
	lea     MapNoSell(pc),a1  ; Load BG mappings
	move.l  #$45880003,d0
	move.w  #31-1,d1
	move.w  #5-1,d2
	jsr   DrawTileMap
	move.b  #4,vintRoutine.w		; VSync
	jsr		VSync	

	moveq	#3,d0				; Load Sonic's palette into both palette buffers
	jsr		LoadFadePal			; Fade from black
	move.w	#$003F,palFadeInfo.w
	jsr		FadeFromBlack

	move.l  #$40000000,VDPCTRL   ; Load main titlescreen art
	lea     Art_TitleMain(pc),a0
	jsr   NemDec

	move.l  #$40000002,VDPCTRL   ; Load menu art text
	lea     Art_TitleText(pc),a0
	jsr   NemDec

	move.l  #$50000002,VDPCTRL   ; Load vocal credit text
	lea     Art_TitleCredit(pc),a0
	jsr   NemDec
	
	jsr		FadeToBlack

	lea     Map_TitleBackground(pc),a1  ; Load BG mappings
	move.l  #$60000003,d0
	move.w  #40-1,d1
	move.w  #28-1,d2
	jsr   DrawTileMap

	lea     Map_TitleClouds(pc),a1 ; Load cloud mappings
	move.l  #$60500003,d0
	move.w  #24-1,d1
	move.w  #8-1,d2
	jsr   DrawTileMap

	lea     Map_TitleWater(pc),a1  ; Load water mappings
	move.l  #$6A500003,d0
	move.w  #24-1,d1
	move.w  #8-1,d2
	jsr   DrawTileMap

	lea     Map_TitleEmblem(pc),a1 ; Load title emblem mappings
	move.l  #$40000003,d0
	move.w  #40-1,d1
	move.w  #28-1,d2
	jsr   DrawTileMap
	
	move.w  #5,objSlots+oSize*0.w     ;
	move.w  #1,objSlots+oSize*1.w     ; Load Vocal Credit
	move.w  #2,objSlots+oSize*2.w     ;
	move.w  #3,objSlots+oSize*3.w     ;
	move.w  #4,objSlots+oSize*4.w     ;
	
	bsr.w   Tit_RunObjects
	
	moveq	#1,d0				; Load Sonic's palette into both palette buffers
	jsr		LoadFadePal			; Fade from black
	move.w	#$003F,palFadeInfo.w
	
	jsr		FadeFromBlack
	
	move.w  #bgm_Title,d0
	jsr     PlayFMSound
	
.loop:
	move.b  #4,vintRoutine.w		; VSync
	jsr		VSync
	btst  	#bitStart,	p1CtrlData
	bne.s	.start
	
	tst.b	debugCheat
	beq.w	.ChkCheat

.conti:
	bsr.w   DoParallax
	bsr.w   Tit_RunObjects
	bra.w	.loop
.start:
	tst.b	debugCheat
	beq.s	.nodbug
	btst  	#bitA,	p1CtrlData
	bne.s	LevelSelect
.nodbug:
	move.b	#GM_LEVEL,gameMode.w			; Set game mode to "level"
	rts
	
.ChkCheat:
	lea		.LevSelCode,a0
	move.w	Title_PadProg,d0
	adda.w	d0,a0
	move.b	p1CtrlData,d0
;	andi.b	#btnDir,d0
	cmp.b	(a0),d0
	bne.s	.ret
	add.w	#1,Title_PadProg
	cmpi.w	#7,Title_PadProg
	beq.s	.enableCheat
.ret
	bra.w	.conti
.enableCheat:
	move.w  #sfxUnused,d0
	jsr     PlayFMSound
	move.b  #1,debugCheat
	bra.w	.conti
.LevSelCode:
;	dc.b btnR,btnA,btnDn,btnL,btnA,btnB,0,$FF
;	dc.b btnB,btnA,btnDn,btnL,btnA,btnDn,0,$FF
	dc.b btnL,btnR,btnL,btnR,btnL,btnR,0,$FF
	even
	
;	---LEVEL SELECT CODE STARTS HERE------------------------------------------------
LevelSelect:
	moveq	#2,d0				; Load Sonic's palette into both palette buffers
	jsr		LoadPalette
	jsr		ClearScreen
	lea     Map_TitleEmblemSel(pc),a1 ; Load title emblem mappings
	move.l  #$40000003,d0
	move.w  #40-1,d1
	move.w  #28-1,d2
	jsr   DrawTileMap
	lea     MapSel(pc),a1 ; Load title emblem mappings
	move.l  #$60240003,d0
	move.w  #4-1,d1
	tst.b	lockOnFlag
	bne.s	.lockedMap
	move.w  #16-1,d2
	bra.s	.conti
.lockedMap:
	move.w  #18-1,d2
.conti:
	jsr   DrawTileMap
	lea     MapSelAr(pc),a1 ; Load title emblem mappings
	move.l  #$46200003,d0
	move.w  #8-1,d1
	move.w  #2-1,d2
	jsr   DrawTileMap
	move.w  #0,objSlots+oSize*3.w     ; erase sonic
	move.w  #0,objSlots+oSize*4.w     ; erase little planet
	move.w  #0,objSlots+oSize*1.w     ; erase press start
;	move.w	#$2000,objSlots+oSize*3+oTile
	move.w	#$6000,objSlots+oSize*2+oTile
	jsr		Tit_RunObjects
	move.w	#-6*16,vscrollScreen+2
	move.b	#0,	Title_PadProg
.loop:
	move.b  #4,vintRoutine.w		; VSync
	jsr		VSync
	btst  	#bitStart,	p1CtrlTap
	bne.s	.start
	btst  	#bitDn,	p1CtrlTap
	bne.s	.down
	btst  	#bitUp,	p1CtrlTap
	bne.s	.up
	bra.s	.loop
.start:
	lea		LevSelTbl,a0
	move.b	Title_PadProg,d0
	add.b	d0,d0	;	1+1=2
	add.b	d0,d0	;	2+2=4
	add.w	d0,a0
	move.l	(a0),d0
	move.w	d0,zone
	swap	d0
	move.b	d0,timeZone
	move.b	#GM_LEVEL,gameMode.w			; Set game mode to "level"
	btst  	#bitA,	p1CtrlData
	bne.s	.nodbug
	move.b	#0,debugCheat
.nodbug:
	rts
	
.down:
	add.b	#1,	Title_PadProg
	add.w	#16,vscrollScreen+2
	tst.b	lockOnFlag
	bne.s	.lockedDn
	cmpi.b	#8,Title_PadProg
	bne.s	.loop
	bra.s	.contiD
.lockedDn:
	cmpi.b	#9,Title_PadProg
	bne.w	.loop
.contiD:
	move.b	#0,	Title_PadProg
	move.w	#-6*16,vscrollScreen+2
	bra.w	.loop
	
.up:
	sub.b	#1,	Title_PadProg
	sub.w	#16,vscrollScreen+2
	cmpi.b	#-1,	Title_PadProg
	bne.w	.loop
	tst.b	lockOnFlag
	bne.s	.lockedUp
	move.b	#7,	Title_PadProg
	move.w	#1*16,vscrollScreen+2
	bra.w	.loop
.lockedUp:
	move.b	#8,	Title_PadProg
	move.w	#2*16,vscrollScreen+2
	bra.w	.loop
	
LevSelTbl:
SELLVL	macro	ZONE_,ACT_,TIME_
	dc.w	TIME_
	dc.b	ZONE_
	dc.b	ACT_-1
	endm
R1 = 0
R2 = 1
R3 = 2
A_TZ = 1
B_TZ = 0
D_TZ = 2

	SELLVL	R1,1,A_TZ
	SELLVL	R1,1,B_TZ
	SELLVL	R1,1,D_TZ
	SELLVL	R1,2,A_TZ
	SELLVL	R1,2,B_TZ
	SELLVL	R1,2,D_TZ
	SELLVL	R1,3,D_TZ
	SELLVL	R3,1,A_TZ
	SELLVL	R2,1,A_TZ

;	---OBJECT RELATED CODE STARTS HERE----------------------------------------------
	
Tit_RunObjects:
	lea     objSlots.w,a0
	moveq   #7,d7

.LoadObjectList:
	bsr.s   LoadObject
	adda.w  #$40,a0
	dbf     d7,.LoadObjectList

	move.b  #0,($FFFFFA00).w
	move.l  #$FFF800,($FFFFFAA0).w
	lea     ObjRAMLocs(pc),a1
	moveq   #7,d7

.Loop:
	movea.w (a1)+,a0

	move.w  (a0),d0
	beq.s   .SlotEmpty
	move.l  d7,-(sp)
	bsr.s   AnimateSprites
	move.l  (sp)+,d7

.SlotEmpty:
	dbf     d7,.Loop
	movea.l ($FFFFFAA0).w,a0
	move.l  #0,(a0)
	rts

; -------------------------------------------------------------------------

LoadObject:
	move.w  (a0),d0
	beq.s   LocalReturnAddr
	lea     ObjectsList-4(pc),a1
	add.w   d0,d0
	add.w   d0,d0
	movea.l (a1,d0.w),a1
	move.w  d7,-(sp)
	jsr     (a1)
	move.w  (sp)+,d7
	btst    #0,2(a0)
	beq.s   LocalReturnAddr
	movea.l a0,a1
	moveq   #0,d1
	bra.w   ClearObjSlot

; -------------------------------------------------------------------------
; used as a return address for the functions above and below it
; -------------------------------------------------------------------------

LocalReturnAddr:
	rts


; -------------------------------------------------------------------------

AnimateSprites:
	movea.l oMap(a0),a2
	moveq   #0,d0
	move.b  oAnim(a0),d0
	add.w   d0,d0
	add.w   d0,d0
	movea.l (a2,d0.w),a2
	move.b  (a2)+,d1
	move.b  (a2)+,d2
	btst    #1,oFlags(a0)
	bne.s   loc_FF22A8
	subq.b  #1,oAnimTime(a0)
	bpl.s   loc_FF22A8
	move.b  d2,oAnimTime(a0)
	addq.b  #1,oAnimFrame(a0)
	cmp.b   oAnimFrame(a0),d1
	bhi.s   loc_FF22A8
	move.b  #0,oAnimFrame(a0)

loc_FF22A8:
	btst    #2,oFlags(a0)
	bne.s   LocalReturnAddr
	move.w  oX(a0),d4
	move.w  oY(a0),d3
	moveq   #0,d0
	move.b  oAnimFrame(a0),d0
	add.w   d0,d0
	add.w   d0,d0
	movea.l (a2,d0.w),a3
	moveq   #0,d7
	move.b  (a3)+,d7
	bmi.s   LocalReturnAddr
	movea.l ($FFFFFAA0).w,a4
	move.w  oTile(a0),d5

loc_FF22D4:
	cmpi.b  #$50,($FFFFFA00).w
	bcc.s   loc_FF2324
	move.b  (a3)+,d0
	ext.w   d0
	add.w   d3,d0
	cmpi.w  #$60,d0 ; '`'
	ble.s   loc_FF232A
	cmpi.w  #$180,d0
	bge.s   loc_FF232A
	move.w  d0,(a4)+
	move.b  (a3)+,(a4)+
	addq.b  #1,($FFFFFA00).w
	move.b  ($FFFFFA00).w,(a4)+
	move.b  (a3)+,d0
	lsl.w   #8,d0
	move.b  (a3)+,d0
	add.w   d5,d0
	move.w  d0,(a4)+
	move.b  (a3)+,d0
	ext.w   d0
	add.w   d4,d0
	cmpi.w  #$60,d0 ; '`'
	ble.s   loc_FF232E
	cmpi.w  #$1C0,d0
	bge.s   loc_FF232E
	andi.w  #$1FF,d0
	bne.s   loc_FF231E
	addq.w  #1,d0

loc_FF231E:
	move.w  d0,(a4)+

loc_FF2320:
	dbf     d7,loc_FF22D4

loc_FF2324:
	move.l  a4,($FFFFFAA0).w
	rts

loc_FF232A:
	addq.w  #4,a3
	bra.s   loc_FF2320

loc_FF232E:
	subq.w  #6,a4
	subq.b  #1,($FFFFFA00).w
	bra.s   loc_FF2320

; -------------------------------------------------------------------------


Tit_DrawObject:
	move.b  d0,oAnim(a0)
	moveq   #0,d0
	move.b  d0,oAnimFrame(a0)
	movea.l oMap(a0),a6
	move.b  oAnim(a0),d0
	add.w   d0,d0
	add.w   d0,d0
	movea.l (a6,d0.w),a6
	move.b  (a6)+,d0
	move.b  (a6),oAnimTime(a0)
	move.b  (a6)+,oAnimTime2(a0)
	rts

; -------------------------------------------------------------------------

ObjRAMLocs:     
	dc.w objSlots+oSize*0
	dc.w objSlots+oSize*1
	dc.w objSlots+oSize*2
	dc.w objSlots+oSize*3
	dc.w objSlots+oSize*4
	dc.w objSlots+oSize*5
	dc.w objSlots+oSize*6
	dc.w objSlots+oSize*7
	
ObjectsList:
	dc.l Obj_PressStart       ; Unused flashing press start text
	dc.l Obj_Banner           ; CD SONIC THE HEDGEHOG Banner
	dc.l Obj_Sonic            ; Static Sonic object
	dc.l Obj_LittlePlanet     ; Hovering Little Planet
	dc.l Obj_Credits        ; Black behind sonic to hide the BG
	dc.l Obj_Null          ; NEW GAME menu option
	dc.l Obj_Null       ; TIME ATTACK menu option
	dc.l Obj_Null      ; VOCAL:UTOKU (Mi-Ke) static text

        include  "Title Screen/Objects/Banner.asm"
        include  "Title Screen/Objects/Little Planet.asm"
        include  "Title Screen/Objects/Sonic.asm"
        include  "Title Screen/Objects/Press Start.asm"
        include  "Title Screen/Objects/Credits.asm"
	
Obj_Null:
	rts
	
ClearObjSlots:
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+

ClearObjSlot:
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	move.l  d1,(a1)+
	rts
	
DoParallax:
	lea     hscroll+2.w,a0
	move.l  #$10000,d0  ; Set scroll speed
	move.w  #$17,d7     ; Set block size

.Clouds1:
	add.l   d0,(a0)+
	dbf     d7,.Clouds1

	move.l  #$C000,d0   ; Set scroll speed
	move.w  #7,d7       ; Set block size

.Clouds2:
	add.l   d0,(a0)+
	dbf     d7,.Clouds2

	move.l  #$8000,d0   ; Set scroll speed
	move.w  #$17,d7     ; Set block size

.Clouds3:
	add.l   d0,(a0)+
	dbf     d7,.Clouds3

	move.l  #$4000,d0   ; Set scroll speed
	move.w  #7,d7       ; Set block size

.Clouds4:
	add.l   d0,(a0)+
	dbf     d7,.Clouds4

	moveq   #0,d0    ; Set scroll speed
	move.w  #$5F,d7      ; Set block size

.MountainAndBrush:
	add.l   d0,(a0)+
	dbf     d7,.MountainAndBrush
	moveq   #0,d0     ; Clear scroll speed
	move.l  #$800,d1 ; Set skew speed
	move.w  #$3F,d7   ; Set block size

.Water:
	add.l   d0,(a0)+  ; Apply scroll
	add.l   d1,d0     ; Apply skew value to speed each line
	dbf     d7,.Water
	rts

ApplyScrollTable:
	move.w  #$8F04,VDPCTRL        ; Set auto increment to 4
	move.l  #$74020003,VDPCTRL    ; Set to write to address
	lea     hscroll+2.w,a0
	lea     VDPDATA,a1
	move.w  #$E0-1,d7

.Loop:
	move.w  (a0)+,(a1)            ; Write to table
	tst.w   (a0)+
	dbf     d7,.Loop
	move.w  #$8F02,VDPCTRL        ; Reset auto increment to 2
	rts
	
Pal_TitleScreen:
	incbin	"Title Screen/pal.bin"
Map_TitleBackground:dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b $80, 1,$80, 2,$80, 3,$80, 4,$80, 5,$80, 6,$80, 5,$80, 6
	dc.b $80, 7,$80, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0,$80, 1,$80, 2,$80, 3,$80, 4,$80, 5,$80, 6
	dc.b $80, 7,$80, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$80, 9,$80,$A
	dc.b $80,$B,$80,$C,$80,$D,$80,$E,$80,$F,$80,$10,$80,$F,$80,$10
	dc.b $80,$11,$80,$12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b $80, 9,$80,$A,$80,$B,$80,$C,$80,$D,$80,$E,$80,$F,$80,$10
	dc.b $80,$11,$80,$12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$80,$13,$80,$14
	dc.b $80,$15,$80,$16,$80,$17,$80,$18,$80,$19,$80,$1A,$80,$19,$80,$1A
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b $80,$13,$80,$14,$80,$15,$80,$16,$80,$17,$80,$18,$80,$19,$80,$1A
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0,$80,$1B,$80,$1C,$80,$1D,$80,$1E, 0, 0,$80,$1B
	dc.b $80,$1E, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0,$80,$1B,$80,$1C,$80,$1D,$80,$1E, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$80, 1,$80, 2,$80, 7
	dc.b $80, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$80, 1,$80, 2
	dc.b $80, 3,$80, 4,$80, 5,$80, 6,$80, 7,$80, 8, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0,$80, 1,$80, 2,$80, 7,$80, 8
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0,$80, 9,$80,$A,$80,$B,$80,$C,$80,$11
	dc.b $80,$12, 0, 0, 0, 0, 0, 0,$80, 9,$80,$A,$80,$B,$80,$C
	dc.b $80,$D,$80,$E,$80,$F,$80,$10,$80,$11,$80,$12, 0, 0, 0, 0
	dc.b  0, 0, 0, 0,$80, 9,$80,$A,$80,$B,$80,$C,$80,$11,$80,$12
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0,$80,$13,$80,$14,$80,$15,$80,$16, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0,$80,$13,$80,$14,$80,$15,$80,$16
	dc.b $80,$17,$80,$18,$80,$19,$80,$1A, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0,$80,$13,$80,$14,$80,$15,$80,$16, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b $80,$1B,$80,$1C,$80,$1D,$80,$1E, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$80,$1B,$80,$1C,$80,$1D
	dc.b $80,$1E, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0,$80,$1F,$80,$20, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0,$80,$21,$80,$22, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0,$80,$23,$80,$24, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0,$80,$25,$80,$26,$80,$27, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0,$80,$28,$80,$29,$80,$2A,$80,$2B,$80,$2C, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0,$80,$2D,$80,$2E,$80,$2F,$80,$30,$80,$31,$80,$32,$80,$33
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0,$80,$34, 0, 0, 0, 0, 0, 0
	dc.b $80,$35,$80,$36,$80,$37,$80,$38,$80,$39,$80,$3A,$80,$3B,$80,$3C
	dc.b $80,$3D,$80,$3E,$80,$3F,$80,$40,$80,$41, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$80,$42,$80,$43,$80,$44
	dc.b $80,$45,$80,$46,$80,$47,$80,$48,$80,$49,$80,$4A,$80,$4B,$80,$4C
	dc.b $80,$4D,$80,$4E,$80,$4F,$80,$50,$80,$51,$80,$52,$80,$53,$80,$54
	dc.b $80,$52,$80,$55,$80,$56,$80,$57,$80,$58,$80,$59,$80,$5A, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b $80,$5B,$80,$5C,$80,$5D,$80,$5E,$80,$5F,$80,$60,$80,$61,$80,$62
	dc.b $88,$4D,$80,$63,$80,$64,$80,$65,$80,$66,$80,$67,$80,$68,$80,$69
	dc.b $80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B
	dc.b $80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B
	dc.b $80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B
	dc.b $80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B
	dc.b $80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B
	dc.b $80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D
	dc.b $80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D
	dc.b $80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D
	dc.b $80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D
	dc.b $80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D
	dc.b $80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F
	dc.b $80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F
	dc.b $80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F
	dc.b $80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F
	dc.b $80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F
	dc.b $80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71
	dc.b $80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71
	dc.b $80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71
	dc.b $80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71
	dc.b $80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71
	dc.b $80,$72,$80,$73,$80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73
	dc.b $80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73,$80,$74,$80,$75
	dc.b $80,$76,$80,$77,$80,$72,$80,$73,$80,$74,$80,$75,$80,$76,$80,$77
	dc.b $80,$72,$80,$73,$80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73
	dc.b $80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73,$80,$74,$80,$75
	dc.b $80,$78,$80,$79,$80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79
	dc.b $80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79,$80,$7A,$80,$7B
	dc.b $80,$7C,$80,$7D,$80,$78,$80,$79,$80,$7A,$80,$7B,$80,$7C,$80,$7D
	dc.b $80,$78,$80,$79,$80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79
	dc.b $80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79,$80,$7A,$80,$7B
	dc.b $80,$72,$80,$73,$80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73
	dc.b $80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73,$80,$74,$80,$75
	dc.b $80,$76,$80,$77,$80,$72,$80,$73,$80,$74,$80,$75,$80,$76,$80,$77
	dc.b $80,$72,$80,$73,$80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73
	dc.b $80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73,$80,$74,$80,$75
	dc.b $80,$78,$80,$79,$80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79
	dc.b $80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79,$80,$7A,$80,$7B
	dc.b $80,$7C,$80,$7D,$80,$78,$80,$79,$80,$7A,$80,$7B,$80,$7C,$80,$7D
	dc.b $80,$78,$80,$79,$80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79
	dc.b $80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79,$80,$7A,$80,$7B
	even
Map_TitleEmblem:
	incbin	"Title Screen\map.bin"
	even
Map_TitleEmblemSel:
	incbin	"Title Screen\mapselb.bin"
	even
Map_TitleClouds:
        dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$80, 1,$80, 2,$80, 3
	dc.b $80, 4,$80, 5,$80, 6,$80, 5,$80, 6,$80, 7,$80, 8, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0,$80, 9,$80,$A,$80,$B,$80,$C,$80,$D
	dc.b $80,$E,$80,$F,$80,$10,$80,$F,$80,$10,$80,$11,$80,$12, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0,$80,$13,$80,$14,$80,$15,$80,$16,$80,$17
	dc.b $80,$18,$80,$19,$80,$1A,$80,$19,$80,$1A, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$80,$1B,$80,$1E
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$80,$1B
	dc.b $80,$1C,$80,$1D,$80,$1E, 0, 0,$80,$1B,$80,$1E, 0, 0, 0, 0
	dc.b  0, 0, 0, 0,$80, 1,$80, 2,$80, 7,$80, 8, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0,$80, 1,$80, 2,$80, 7,$80, 8, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b $80, 9,$80,$A,$80,$B,$80,$C,$80,$11,$80,$12, 0, 0, 0, 0
	dc.b  0, 0,$80, 9,$80,$A,$80,$B,$80,$C,$80,$11,$80,$12, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b $80,$13,$80,$14,$80,$15,$80,$16, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0,$80,$13,$80,$14,$80,$15,$80,$16, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,$80,$1B,$80,$1E, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0,$80,$1B,$80,$1C,$80,$1D,$80,$1E
	dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	even
Map_TitleWater: 
        dc.b $80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B
	dc.b $80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B
	dc.b $80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B,$80,$6A,$80,$6B
	dc.b $80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D
	dc.b $80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D
	dc.b $80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D,$80,$6C,$80,$6D
	dc.b $80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F
	dc.b $80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F
	dc.b $80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F,$80,$6E,$80,$6F
	dc.b $80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71
	dc.b $80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71
	dc.b $80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71,$80,$70,$80,$71
	dc.b $80,$72,$80,$73,$80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73
	dc.b $80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73,$80,$74,$80,$75
	dc.b $80,$76,$80,$77,$80,$72,$80,$73,$80,$74,$80,$75,$80,$76,$80,$77
	dc.b $80,$78,$80,$79,$80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79
	dc.b $80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79,$80,$7A,$80,$7B
	dc.b $80,$7C,$80,$7D,$80,$78,$80,$79,$80,$7A,$80,$7B,$80,$7C,$80,$7D
	dc.b $80,$72,$80,$73,$80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73
	dc.b $80,$74,$80,$75,$80,$76,$80,$77,$80,$72,$80,$73,$80,$74,$80,$75
	dc.b $80,$76,$80,$77,$80,$72,$80,$73,$80,$74,$80,$75,$80,$76,$80,$77
	dc.b $80,$78,$80,$79,$80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79
	dc.b $80,$7A,$80,$7B,$80,$7C,$80,$7D,$80,$78,$80,$79,$80,$7A,$80,$7B
	dc.b $80,$7C,$80,$7D,$80,$78,$80,$79,$80,$7A,$80,$7B,$80,$7C,$80,$7D
Art_TitleText:  
	incbin	"Title Screen/textart.bin"
	even
MapSel:  
	incbin	"Title Screen/mapsel.bin"
	even
MapSelAr:  
	incbin	"Title Screen/mapselar.bin"
	even
Art_TitleMain:  
	incbin	"Title Screen/art.bin"
	even
Art_TitleCredit:
	incbin	"Title Screen/vocal.bin"
	even

MapNoSell:  
	incbin	"Title Screen/nosell.map"
	even
ArtNoSell:  
	incbin	"Title Screen/nosell.bin"
	even