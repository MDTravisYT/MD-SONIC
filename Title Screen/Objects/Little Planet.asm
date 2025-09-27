; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023
; -------------------------------------------------------------------------
; Title Screen program - Hovering Little Planet object
; -------------------------------------------------------------------------

Obj_LittlePlanet:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	add.w   d0,d0
	move.w  .Index(pc,d0.w),d0
	jmp     .Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
        dc.w LittlePlanet_Init-.Index
	dc.w LittlePlanet_MoveDown-.Index
	dc.w LittlePlanet_MoveUp-.Index

; -------------------------------------------------------------------------

LittlePlanet_Init:
	bset    #1,oFlags(a0)       ; Set object flags
	move.w  #0,oTile(a0)        ; Set tile offset
	move.l  #MapSpr_LittlePlanet,oMap(a0)    ; Set mappings
	move.w  #$180,oX(a0)        ; Set initial location
	move.w  #$C0,oY(a0)
	moveq   #0,d0
	jsr     Tit_DrawObject(pc)      ; Draw the object

	move.w  #$40,oTimer(a0)     ; Set a timer for how long to hover
	addq.b  #1,oRoutine(a0)     ; Set to executing next routine

LittlePlanet_MoveDown:
	addi.l  #$2000,oY(a0)       ; Add to the object's Y position
	subq.w  #1,oTimer(a0)       ; Decrement the timer
	
	bne.s   .DoneMovingDown     ; Has the timer depleted?

	addq.b  #1,oRoutine(a0)     ; If so, set to move up next routine
	move.w  #$40,oTimer(a0)     ; ...and reset the timer

.DoneMovingDown:
	rts

; -------------------------------------------------------------------------


LittlePlanet_MoveUp:
	subi.l  #$2000,oY(a0)       ; Subtract from object's Y position
	subq.w  #1,oTimer(a0)       ; Decrement the timer

	bne.s   .DoneMovingUp       ; Has the timer depleted?

	subq.b  #1,oRoutine(a0)     ; If so, set to move down next time
	move.w  #$40,oTimer(a0)     ; ...and reset the timer

.DoneMovingUp:
	rts

; -------------------------------------------------------------------------

MapSpr_LittlePlanet:
        include  "Title Screen/Objects/Little Planet Mappings.asm"
        even