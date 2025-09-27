; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023
; -------------------------------------------------------------------------
; Title Screen program - Static Sonic object
; -------------------------------------------------------------------------

Obj_Sonic:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	add.w   d0,d0
	move.w  .Index(pc,d0.w),d0
	jmp     .Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
        dc.w Sonic_Init-.Index
	dc.w Sonic_Exit-.Index

; -------------------------------------------------------------------------

Sonic_Init:
	bset    #1,oFlags(a0)         ; Set object flags
	move.w  #$A000,oTile(a0)      ; Set tile offset
	move.l  #MapSpr_TSonic,oMap(a0); Set mappings
	move.w  #292,oX(a0)           ; Set position
	move.w  #264,oY(a0)
	moveq   #0,d0
	jsr     Tit_DrawObject(pc)        ; Draw object
	addq.b  #1,oRoutine(a0)       ; Kill execution

Sonic_Exit:
	rts

; -------------------------------------------------------------------------
MapSpr_TSonic:
        include  "Title Screen/Objects/Sonic Mappings.asm"
        even