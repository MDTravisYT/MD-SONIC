; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023
; -------------------------------------------------------------------------
; Salad Plain Past palette cycle
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Handle palette cycling
; -------------------------------------------------------------------------

PaletteCycle:
	tst.b	zone
	bne.w	.end
	move.b	(timeZone).l,d0
	btst	#7,d0
	bne.w	.End
	cmp.b	#TIME_PAST,d0	;	hacky bs i need to redo
	beq.s	.past
	cmp.b	#TIME_PRESENT,d0
	beq.s	.present
	cmp.b	#TIME_FUTURE,d0
	beq.s	.future
.cont:
	subq.b	#1,palCycleTimers.w		; Decrement timer
	bpl.s	.SkipCycle1			; If this cycle's timer isn't done, branch
	move.b	#7,palCycleTimers.w		; Reset the timer

	moveq	#0,d0				; Get the current palette cycle frame
	move.b	palCycleSteps.w,d0
	cmpi.b	#2,d0				; Should we wrap it back to 0?
	bne.s	.IncCycle1			; If not, don't worry about it
	moveq	#0,d0				; If so, then do it
	bra.s	.ApplyCycle1
.present:
	lea		PresentPalCycData1,a0
	bra.s	.cont
.past:
	lea		PastPalCycData1,a0
	bra.s	.cont
.future:
	lea		FuturePalCycData1,a0
	bra.s	.cont

.IncCycle1:
	addq.b	#1,d0				; Increment the palette cycle frame

.ApplyCycle1:
	move.b	d0,palCycleSteps.w

	lsl.w	#3,d0				; Store the currnent palette cycle data in palette RAM
	lea	palette+$6A.w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)

.SkipCycle1:
						; Prepare second palette data set
	adda.w	#PastPalCycData2-PastPalCycData1,a0
	subq.b	#1,palCycleTimers+1.w		; Decrement timer
	bpl.s	.End				; If this cycle's timer isn't done, branch
	move.b	#5,palCycleTimers+1.w		; Reset the timer

	moveq	#0,d0				; Get the current palette cycle frame
	move.b	palCycleSteps+1.w,d0
	cmpi.b	#2,d0				; Should we wrap it back to 0?
	bne.s	.IncCycle2			; If not, don't worry about it
	moveq	#0,d0				; If so, then do it
	bra.s	.ApplyCycle2

.IncCycle2:
	addq.b	#1,d0				; Increment the palette cycle frame

.ApplyCycle2:
	move.b	d0,palCycleSteps+1.w

	andi.w	#3,d0				; Store the currnent palette cycle data in palette RAM
	lsl.w	#3,d0
	lea	palette+$58.w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)

.End:
	rts

; -------------------------------------------------------------------------
; Prototype palette cycle data
; -------------------------------------------------------------------------

PastPalCycData1:
	dc.w	$EEA, $CE6, $EEE, $8C4
	dc.w	$8C4, $EEA, $EEA, $CE6
	dc.w	$CE6, $8C4, $CE6, $EEA

PastPalCycData2:
	dc.w	$EEC, $CE6, $AA0, $8C4
	dc.w	$CE6, $8C4, $AA0, $EEC
	dc.w	$8C4, $EEC, $AA0, $CE6
	
PresentPalCycData1:
	dc.w 	$0ECC,$0ECA,$0EEE,$0EA8
	dc.w	$0EA8,$0ECC,$0ECC,$0ECA
	dc.w	$0ECA,$0EA8,$0ECA,$0ECC
PresentPalCycData2:
	dc.w	$0ECA,$0EA8,$0C60,$0E86
	dc.w 	$0EA8,$0E86,$0C60,$0ECA
	dc.w	$0E86,$0ECA,$0C60,$0EA8
FuturePalCycData1:
	dc.w	$0888,$0666,$0888,$0444
	dc.w	$0444,$0888,$0666,$0666
	dc.w	$0666,$0444,$0444,$0888
FuturePalCycData2:
	dc.w	$0CAE,$0C8C,$0A44,$0C6A
	dc.w	$0C8C,$0C6A,$0A44,$0CAE
	dc.w	$0C6A,$0CAE,$0A44,$0C8C