Obj_Credits:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	add.w   d0,d0
	move.w  off_FF2766(pc,d0.w),d0
	jmp     off_FF2766(pc,d0.w)
; -------------------------------------------------------------------------
off_FF2766:     dc.w loc_FF276A-*       ; CODE XREF: ROM:00FF2762↑j
		        ; DATA XREF: ROM:00FF275E↑r ...
	dc.w locret_FF2794-off_FF2766
; -------------------------------------------------------------------------

loc_FF276A:	             ; DATA XREF: ROM:off_FF2766↑o
	bset    #1,oFlags(a0)
	move.w  #$E480,oTile(a0)
	move.l  #off_FF2796,oMap(a0)
	move.w  #$168,oX(a0)
	move.w  #$158,oY(a0)
	moveq   #0,d0
	jsr     Tit_DrawObject(pc)
	addq.b  #1,oRoutine(a0)

locret_FF2794:	          ; DATA XREF: ROM:00FF2768↑o
	rts
; -------------------------------------------------------------------------
off_FF2796:     dc.l unk_FF279A
unk_FF279A:            dc.b   1,0
	dc.l   .Frame1
.Frame1:
	dc.b   4
	dc.b $F0
	dc.b  $D
	dc.b   0
	dc.b   0
	dc.b $B8
	dc.b $F0
	dc.b  $D
	dc.b   0
	dc.b   8
	dc.b $D8
	dc.b $F0
	dc.b  $D
	dc.b   0
	dc.b $10
	dc.b $F8
	dc.b $F0
	dc.b  $D
	dc.b   0
	dc.b $18
	dc.b $18
	dc.b $F0
	dc.b   5
	dc.b   0
	dc.b $20
	dc.b $38 ; 8
	even