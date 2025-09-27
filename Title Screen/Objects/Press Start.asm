; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023
; -------------------------------------------------------------------------
; Title Screen program - Unused flashing press start text
; -------------------------------------------------------------------------

Obj_PressStart:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	add.w   d0,d0
	move.w  .Index(pc,d0.w),d0
	jmp     .Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:     
            dc.w PressStart_Init-.Index
	    dc.w PressStart_Flash-.Index

; -------------------------------------------------------------------------

PressStart_Init:
	bset    #1,oFlags(a0)              ; Set flags
	move.w  #$C000,oTile(a0)           ; Set tile offset
	move.l  #MapSpr_PressStart,oMap(a0); Set mappings
	move.w  #288,oX(a0)                ; Set position
	move.w  #260,oY(a0)
	moveq   #0,d0
	jsr     Tit_DrawObject(pc)             ; Draw object
	addq.b  #1,oRoutine(a0)            ; Set to execute next routine

PressStart_Flash:
	andi.w  #$1F,($FFFFFA44).w   ; Are we set to display(?)
	bne.s   .NoChange            ; If not, kill
	bchg    #2,oFlags(a0)        ; Otherwise, change display flag bits

.NoChange:
	rts

; -------------------------------------------------------------------------

MapSpr_PressStart:
        include  "Title Screen/Objects/Press Start Mappings.asm"
        even