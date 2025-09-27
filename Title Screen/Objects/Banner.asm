; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023
; -------------------------------------------------------------------------
; Title Screen program - Banner object
; -------------------------------------------------------------------------

Obj_Banner:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	add.w   d0,d0
	move.w  .Index(pc,d0.w),d0
	jmp     .Index(pc,d0.w)
	
; -------------------------------------------------------------------------

.Index:
	dc.w Banner_Init-.Index
	dc.w Banner_Exit-.Index

; -------------------------------------------------------------------------

Banner_Init:
	bset    #1,oFlags(a0)           ; Set sprite flags
	move.w  #$E000,oTile(a0)        ; Set initial display tile
	move.l  #MapSpr_Banner,oMap(a0)  ; Set object mappings

	move.w  #$120,oX(a0)            ; Object position on screen
	move.w  #$150,oY(a0)

	moveq   #0,d0

	jsr     Tit_DrawObject(pc)          ; Display it

	addq.b  #1,oRoutine(a0)         ; Exit the routine and kill

Banner_Exit:
	rts

; -------------------------------------------------------------------------

MapSpr_Banner:
        include  "Title Screen/Objects/Banner Mappings.asm"
        even