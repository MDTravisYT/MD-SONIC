; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023
; -------------------------------------------------------------------------
; Salad Plain Act 1 Past
; -------------------------------------------------------------------------
	include	"_Include/Debugger.asm"
	include	"_Include/Common.i"				; Common macros and constants
	include	"_Include/Main CPU.i"			; MainCPU macros and constants
    include	"_Include/Main CPU Variables.i" ; MainCPU IPX variables
	include	"_Include/System.i"				; Sonic CD system organization
	include	"_Include/Sound.i"				; Sound driver vars/constants
	include	"_Include/MMD.i"				; MMD Specification

    include	"Level/Universal/_Definitions.i"
    include	"Level/Universal/_Sonic 1 Definitions Leftovers.i"

; -------------------------------------------------------------------------
ROM_START:
    include "Level/Universal/Initialization.asm"                ; Basic Initialization 
    include "Level/R1 Salad Plain/Palette Cycle.asm"       ; Palette Cycle Info         
    include "Level/Universal/Palette Functions.asm"             ; Palette Fading/Load  
    include "Level/R1 Salad Plain/Palette Data.asm"  ; Palette Index Table     
    include "Level/Universal/Functions (Misc).asm"              ; Vsync, CalcSine, CalcAngle, and their associated data
    include "Level/Universal/Collision Floor.asm"               ; Floor/wall/block find/collide, loop handling, ConvColArray

; -------------------------------------------------------------------------
; Main function
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Leftover music ID list from Sonic 1
; -------------------------------------------------------------------------

LevelMusicIDs_S1:
	dc.b S1bgm_GHZ
	dc.b S1bgm_LZ
	dc.b S1bgm_MZ
	dc.b S1bgm_SLZ
	dc.b S1bgm_SYZ
	dc.b S1bgm_SBZ
	dc.b S1bgm_FZ
	even

; -------------------------------------------------------------------------
; Level "game mode" (system remnant from Sonic 1)
; -------------------------------------------------------------------------

LevelStart:
	bset	#0,plcLoadFlags			; Mark PLCs as loaded
	bne.s	.NoReset			; If they were loaded before, branch
	move.b	#3,lives			; Reset life count to 3
	tst.b	timeAttackMode			; Are we in time attack mode?
	beq.s	.NoReset			; If not, branch
	move.b	#1,lives			; Reset life count to 1

.NoReset:
	bset	#7,gameMode.w			; Mark level as initializing
	bsr.w	ClearPLCs			; Clear PLCs
	btst	#7,timeZone			; Were we time warping before?
	beq.s	.FadeToBlack			; If not, branch
	move.w  #SFXTravel,d0
	jsr     PlayFMSound2
	bsr.w	FadeToWhite			    ; Fade to white
	clr.b	timeWarpDir.w			; Reset time warp direction
	tst.w	levelRestart			; Was the level restart flag set?
	beq.s	.MainLoad		        ; If not, branch
	move.w	#0,levelRestart			; Clear level restart flag
	rts

; -------------------------------------------------------------------------

.FadeToBlack:
	bsr.w	FadeToBlack			; Fade to black
	cmpi.w	#2,levelRestart			; Were we going to the next level?
	bne.s	.CheckNoLives			; If not, branch
	move.w	#0,levelRestart			; Clear level restart flag
	rts

.CheckNoLives:
	tst.b	lives				; Do we have any lives?
	bne.s	.MainLoad		    ; If so, branch
	bclr    #0,plcLoadFlags			; Mark PLCs as not loaded
	move.b	#GM_TITLE,gameMode
	move.w  #$E0,d0
	jsr     PlayFMSound
	jmp		FadeToBlack

.MainLoad:	
	move.b	#$80,v_snddriver_ram+f_pausemusic
	moveq	#0,d0
	move.b	timeZone,d0
	bclr	#7,d0
;	lea		(LevelMusicIDs_S1).l,a1
;	move.b	(a1,d0.w),d0
	moveq   #0,d0
	move.b	(timeZone).l,d0
	bclr	#7,d0
	add.w	d0,d0
	add.w	d0,d0
	lea		LevelDataIndexes,a2
	add.w	d0,a2
	move.b	act,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a2
	move.b	zone,d0
	add.w	d0,d0	;	1+1=2
	add.w	d0,d0	;	2+2=4
	move.w	d0,d1
	add.w	d0,d0	;	4+4=8
	add.w	d0,d0	;	8+8=10
	add.w	d0,d0	;	10+10=20
	add.w	d1,d0	;	10+4=24
	add.w	d0,a2
	move.l	(a2),a2
	add.w	#$C,a2
	move.b	(a2),d0
	jsr     PlayFMSound

	moveq	#0,d0				; Get level PLCs
	move.b	act,d0	;	1
	add.w	d0,d0	;	1+1 = 2
	add.w	d0,d0	;	2+2 = 4
	add.w	d0,d0	;	4+4 = 8
	add.w	d0,d0	;	8+8 = 10
	lea	    Past_LevelDataIndex,a2
	add.w	d0,a2
	moveq	#0,d0
	move.b	(a2),d0
	beq.s	.LoadStdPLCs
	bsr.w	LoadPLC				; Load it immediately

.LoadStdPLCs:
	moveq	#1,d0				; Load standard PLCs immediately
	bsr.w	LoadPLC

	clr.b	powerup				; Reset powerup ID
	clr.l	flowerCount			; Clear flower count

	lea	    objects.w,a1			; Clear object RAM
	moveq	#0,d0
	move.w	#$2000/4-1,d1

.ClearObjects:
	move.l	d0,(a1)+
	dbf	d1,.ClearObjects

	lea	miscVariables.w,a1		; Clear misc. variables
	moveq	#0,d0
	move.w	#$58/4-1,d1

.ClearMiscVars:
	move.l	d0,(a1)+
	dbf	d1,.ClearMiscVars

	lea	cameraX.w,a1			; Clear camera RAM
	moveq	#0,d0
	move.w	#$100/4-1,d1

.ClearCamera:
	move.l	d0,(a1)+
	dbf	d1,.ClearCamera

	move	#$2700,sr			; Disable interrupts
	bsr.w	ClearScreen			; Clear the screen
	lea	    VDPCTRL,a6
	move.w	#$8B03,(a6)			; HScroll by line, VScroll by screen
	move.w	#$8230,(a6)			; Plane A at $C000
	move.w	#$8407,(a6)			; Plane B at $E000
	move.w	#$8300,(a6)			; Window loc
	move.w	#$857C,(a6)			; Sprite table at $F800
	move.w	#$9001,(a6)			; Plane size 64x32
	move.w	#$8004,(a6)			; Disable H-INT
	move.w	#$8720,(a6)			; Background color at line 2, color 0
	move.w	#$8ADF,vdpReg0A.w		; Set H-INT counter to 233
	move.w	vdpReg0A.w,(a6)

	move.w	#30,drownTimer			; Set drown timer

	move	#$2300,sr			; Enable interrupts
	moveq	#3,d0				; Load Sonic's palette into both palette buffers
	bsr.w	LoadPalette
	moveq	#3,d0
	bsr.w	LoadFadePal

    move.w  vdpReg01.w,d0
	ori.b   #$40,d0
	move.w  d0,VDPCTRL

.WaitPLC:
	move.b	#$C,vintRoutine.w		; VSync
	bsr.w	VSync
	bsr.w	ProcessPLCs			; Process PLCs
	bne.s	.WaitPLC			; If the queue isn't empty, wait
	tst.l	plcBuffer.w			; Is the queue empty?
	bne.s	.WaitPLC			; If not, wait

	bsr.w	LevelSizeLoad			; Get level size and start position
	bsr.w	LevelScroll			; Initialize level scrolling
	bset	#2,scrollFlags.w		; Force draw a block column on the left side of the screen
	bsr.w	LoadLevelData			; Load level data
	bsr.w	InitLevelDraw			; Begin level drawing
	jsr	    ConvColArray			; Convert collision data (dummied out)
	bsr.w	LoadLevelCollision		; Load collision block IDs


.WaitPLC2:
	move.b  #$C,vintRoutine.w		; VSync again
	bsr.w   VSync
	bsr.w   ProcessPLCs				; Process PLC queue until empty again
	bne.s   .WaitPLC2
	tst.l   plcBuffer.w
	bne.s   .WaitPLC2
	
	bsr.w	LoadPlayer					; Load the player
	move.b	#$1C,objHUDScoreSlot.w		; Load HUD score object
	move.b	#$1C,objHUDLivesSlot.w		; Load HUD lives object
	move.b	#1,objHUDLivesSlot+oSubtype.w

	bsr.w	LoadLifeIcon

	move.w	#0,playerCtrl.w			; Clear controller data
	move.w	#0,p1CtrlData.w
	move.w	#0,p2CtrlData.w
	move.w	#0,boredTimer.w			; Reset boredom timers
	move.w	#0,boredTimerP2.w

	moveq	#0,d0
	tst.b	spawnMode			; Is the player being spawned at the beginning?
	bne.s	.SkipClear			; If not, branch
	move.w	d0,rings			; Reset ring count
	move.l	d0,time				; Reset time
	move.b	d0,livesFlags		; Reset 1UP flag

.SkipClear:
	move.b	d0,timeOver			    ; Clear time over flag
	move.b	d0,shield			    ; Clear shield flag
	move.b	d0,invincible			; Clear invincible  flag
	move.b	d0,speedShoes			; Clear speed shoes flag
	move.b	d0,timeWarp			    ; Clear time warp flag
	move.w	d0,debugMode			; Clear debug mode flag
	move.w	d0,levelRestart			; Clear level restart flag
	move.w	d0,levelFrames			; Reset frame counter
	move.b	d0,spawnMode
	move.b	#$80,updateHUDRings		; Update the ring count in the HUD
	move.b	#1,updateHUDScore		; Update the score in the HUD
	move.b	#1,updateHUDTime		; Update the time in the HUD
	move.b	#1,updateHUDLives		; Update the life counter in the HUD

;	move.w	#0,demoS1Index.w		; Clear demo data index (Sonic 1 leftover)
	move.w	#$202F,palFadeInfo.w		; Set to fade palette lines 1-3
	bclr	#7,timeZone			; Stop time warp
	beq.s	.ChkPalFade			; If we weren't to begin with, branch
	bsr.w	FadeFromWhite			; Fade from white
	bra.s	.BeginLevel

.ChkPalFade:
	bsr.w	FadeFromBlack			; Fade from black

.BeginLevel:
	if def(DebugBuild)
	move.b  #1,debugCheat			; Enable debug mode flag
	endif
	bclr	#7,gameMode.w			; Mark level as initialized
	move.w  #$E3,d0
	jsr     PlayFMSound

; -------------------------------------------------------------------------
; Main Level program loop
; -------------------------------------------------------------------------
Level_MainLoop:
	if def(DebugBuild)
	move.w	#$9100,VDPCTRL			; Window disable
	move.b  #8,vintRoutine.w		; VSync
	bsr.w   VSync
	move.w	#$9192,VDPCTRL			; Window enable
	else
	move.w	#$9100,VDPCTRL			; Window disable
	move.b  #8,vintRoutine.w		; VSync
	bsr.w   VSync
	endif
	
	btst  	#bitStart,	p1CtrlTap
	bne.w	DoPause
	addq.w  #1,levelFrames			; Increment level frame counter

	jsr     SpawnObjects			; Spawn objects
	jsr     RunObjects				; Run objects

	tst.w   levelRestart			; Are we restarting?
	bne.w   LevelStart				; If so, re-initialize and restart

	tst.w   debugMode				; Are we in debug mode?
	bne.s   .DebugEnabled			; If so, skip processing

	cmpi.b  #6,objPlayerSlot+oRoutine.w		; Is the player dead?
	bcc.s   .NoScroll						; If so, skip scrolling

.DebugEnabled:
	bsr.w   LevelScroll				; Handle level scrolling and parallax

.NoScroll:
	jsr     DrawObjects				; Draw objects
	tst.w	timeStopTimer			; Is the time stop timer active?
	bne.s	.SkipPalCycle			; If so, branch
	bsr.w	PaletteCycle			; Handle palette cycling

.SkipPalCycle:
	jsr     UpdateSectionArt
	bsr.w   ProcessPLCs
	bsr.w   UpdateGlobalAnims
	bra.w   Level_MainLoop

DoPause:
	tst.b	DebugMode
	beq.s	.pausin
	move.w  #$E0,d0
	jsr     PlayFMSound
	move.b	#GM_TITLE,gameMode.w			; Set game mode to "title"
	jmp		FadeToBlack
.pausin
	move.b  #4,vintRoutine.w		; VSync
	bsr.w   VSync
	move.b	#1,v_snddriver_ram+f_pausemusic
	btst  	#bitStart,	p1CtrlTap
	bne.w	.unpause
	bra.s	.pausin
	
.unpause:
	tst.w	timeStopTimer
	bne.s	.skip
	move.b	#$80,v_snddriver_ram+f_pausemusic
.skip:
	bra.w	Level_MainLoop

; -------------------------------------------------------------------------
; Subroutine to load the player objects (players 1 and 2)
; -------------------------------------------------------------------------

LoadPlayer:
	lea     objPlayerSlot.w,a1
	moveq   #1,d0
	tst.b   usePlayer2
	beq.s   .NotP2
	lea     objPlayerSlot2.w,a1
	moveq   #2,d0

.NotP2:
	move.b  d0,0(a1)
	rts

; -------------------------------------------------------------------------
; Dead code to restore zone flowers from previous timezone
; -------------------------------------------------------------------------

RestoreZoneFlowers:
	lea	flowerCount,a1			; Get flower count bsaed on time zone
	moveq	#0,d0
	move.b	timeZone,d0
	bclr	#7,d0
	move.b	(a1,d0.w),d0
	beq.s	.End				; There are no flowers, exit

	subq.b	#1,d0				; Fix flower count for DBF
	lea		dynObjects.w,a2		; Dynamic object RAM
	moveq	#0,d1				; Flower ID

.Loop:
	move.b	#$1F,oID(a2)		; Load a flower
	move.w	d1,d2				; Get flower position buffer index based on time zone
	add.w	d2,d2
	add.w	d2,d2
	moveq	#0,d3
	move.b	timeZone,d3
	bclr	#7,d3
	lsl.w	#8,d3
	add.w	d3,d2
	lea		flowerPosBuf,a3		; Get flower position
	move.w	(a3,d2.w),oX(a2)
	move.w	2(a3,d2.w),oY(a2)

	adda.w	#oSize,a2		; Next object
	addq.b	#1,d1			; Next flower
	dbf	d0,.Loop			; Loop until finished

.End:
	rts


; -------------------------------------------------------------------------
; A routine to load collision based on the current zone ID...
; which is completely useless, as each MMD is compiled with its own data
;
; Regardless, this is labelled as it would be.
; -------------------------------------------------------------------------

LoadLevelCollision:
	moveq   #0,d0
	moveq   #0,d1
	move.b	timeZone,d0		; Get current timezone ID...
	bclr	#7,d0
	lsl.w   #2,d0		and use it to index the table
	move.b	act,d1	;1
	add.w	d1,d1	;2
	add.w	d1,d1	;4
	move.w	d1,d2
	add.w	d1,d1	;8
	add.w	d2,d1	;C
	add.w	d1,d0
	move.b	zone,d1
	add.w	d1,d1	;2
	add.w	d1,d1	;4
	move.w	d1,d2
	add.w	d1,d1	;8
	add.w	d1,d1	;10
	add.w	d1,d1	;20
	add.w	d2,d1	;24
	add.w	d1,d0
	move.l  LevelColIndex(pc,d0.w),collisionPtr.w
	rts

; -------------------------------------------------------------------------

LevelColIndex:  
	dc.l LevelCollision_Past
	dc.l LevelCollision_Present
	dc.l LevelCollision_Future
	dc.l LevelCollision_Past2
	dc.l LevelCollision_Present2
	dc.l LevelCollision_Future2
	dc.l LevelCollision_Past
	dc.l LevelCollision_Past
	dc.l LevelCollision_Future3
;	R2
	dc.l 0	;	4
	dc.l LOCK_COLLISION	;	8
	dc.l 0	;	C
	dc.l 0	;	10
	dc.l 0	;	14
	dc.l 0	;	18
	dc.l 0	;	1C
	dc.l 0	;	20
	dc.l 0	;	24
;	R3
	dc.l 0
	dc.l LevelCollision_R3
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l 0

; -------------------------------------------------------------------------
; Handle global animations
; -------------------------------------------------------------------------

UpdateGlobalAnims:
	subq.b	#1,logSpikeAnimTimer		; Decrement Sonic 1 spiked log animation timer
	bpl.s	.Rings				; If it hasn't run out, branch
	move.b	#$B,logSpikeAnimTimer		; Reset animation timer
	subq.b	#1,logSpikeAnimFrame		; Decrement frame
	andi.b	#7,logSpikeAnimFrame		; Keep the frame in range

.Rings:
	subq.b	#1,ringAnimTimer		; Decrement ring animation timer
	bpl.s	.Unknown			; If it hasn't run out, branch
	move.b	#7,ringAnimTimer		; Reset animation timer
	addq.b	#1,ringAnimFrame		; Increment frame
	andi.b	#3,ringAnimFrame		; Keep the frame in range

.Unknown:
	subq.b	#1,unkAnimTimer			; Decrement Sonic 1 unused animation timer
	bpl.s	.RingSpill			; If it hasn't run out, branch
	move.b	#7,unkAnimTimer			; Reset animation timer
	addq.b	#1,unkAnimFrame			; Increment frame
	cmpi.b	#6,unkAnimFrame			; Keep the frame in range
	bcs.s	.RingSpill
	move.b	#0,unkAnimFrame

.RingSpill:
	tst.b	ringLossAnimTimer		; Has the ring spill timer run out?
	beq.s	.End				; If so, branch
	moveq	#0,d0				; Increment frame accumulator
	move.b	ringLossAnimTimer,d0
	add.w	ringLossAnimAccum,d0
	move.w	d0,ringLossAnimAccum
	rol.w	#7,d0				; Set ring spill frame
	andi.w	#3,d0
	move.b	d0,ringLossAnimFrame
	subq.b	#1,ringLossAnimTimer		; Decrement ring spill timer

.End:
	rts

; -------------------------------------------------------------------------
; Function to play the level's music based on the current time-zone
; -------------------------------------------------------------------------

PlayLevelMusic:
	moveq   #0,d0
	move.b  timeZone,d0			; Get time zone
	bclr    #7,d0
	cmpi.b	#2,d0				; Are we in the good future?
	bne.s	.NotGoodFuture		; If not, branch
	add.b	goodFuture,d0		; Apply good future flag

.NotGoodFuture:
	move.b  PlaylistCmds(pc,d0.w),d0 ; Use calculations to index the table
	ext.w   d0
	jmp     SendSubCommand			 ; Send SubCMD to SubCPU system

; -------------------------------------------------------------------------

PlaylistCmds:   
	dc.b	SCMD_R1BMUS, SCMD_R1AMUS, SCMD_R1DMUS, SCMD_R1CMUS

; -------------------------------------------------------------------------
; Dead function to play CDDA Track 2. Falls into LoadLifeIcon
; -------------------------------------------------------------------------

PlayLevelMusic2:
	move.w  #SCMD_R1AMUS,d0
	jsr     SendSubCommand

; -------------------------------------------------------------------------
; Life icon manual load
; -------------------------------------------------------------------------

LoadLifeIcon:
	move.l  #$73E00002,d0

	moveq	#0,d2				; Get pointer to life icon
	move.b	timeZone,d2
	bclr	#7,d2
	lsl.w	#7,d2
	move.l	d0,4(a6)
	lea		ArtUnc_LivesIcon,a1
	lea		(a1,d2.w),a3

	rept	32
		move.l	(a3)+,(a6)		; Load life icon
	endr
	rts

; -------------------------------------------------------------------------
; Vertical Interrupt
; -------------------------------------------------------------------------

VInterrupt:

	bset	#0,GAIRQ2			; Send Sub CPU IRQ2 request
	movem.l	d0-a6,-(sp)			; Save registers

	tst.b	vintRoutine.w		; Are we lagging?
	beq.w	VInt_Lag			; If so, branch

	move.w  VDPCTRL,d0					
	move.l  #$40000010,VDPCTRL	; Apply VScroll
	move.l  vscrollScreen.w,VDPDATA

	btst    #6,versionCache		; Are we on a PAL/SECAM Megadrive?
	beq.s   .NotPAL				; If not, skip

	move.w  #$700,d0			; Delay processing for PAL to fix timings
	dbf     d0,*

.NotPAL:
	move.b  vintRoutine.w,d0	; Put our current V-Int routine into d0
	move.b  #0,vintRoutine.w	; Clear the routine

	move.w  #1,hintFlag.w		; Set the horizontal interrupt flag

	andi.w  #$3E,d0 			; Use d0 as an index into the table
	move.w  VInt_Index(pc,d0.w),d0
	jsr     VInt_Index(pc,d0.w)

VInt_Finish:
	JSR 	UpdateMusic

VInt_Finish_SkipFM:

	addq.l  #1,levelVIntCounter	; Increment frame/V-INT counter

	movem.l (sp)+,d0-d7/a0-a6	; Restore registers from stack
	rte							; Return to main execution

; -------------------------------------------------------------------------
; V-Int Routines 
; !!!!!!!! WIP
; Specifically: 		OK. a lot of this is fine actually. just stupid.
; -------------------------------------------------------------------------

VInt_Index:     
	dc.w VInt_Lag-VInt_Index				; Invalid
	dc.w VInt_General-VInt_Index			; Undoc.
	dc.w VInt_S1Title_Leftover-VInt_Index	; Sonic 1's Title Screen
	dc.w VInt_Unk6-VInt_Index				; Undoc.
	dc.w VInt_Level-VInt_Index				; Level
	dc.w VInt_Return-VInt_Index				; Null/Empty
	dc.w sub_20192C-VInt_Index				; Undoc.
	dc.w sub_201A3C-VInt_Index				; Undoc.
	dc.w VInt_Pause-VInt_Index				; Unused Pause function
	dc.w sub_201A4C-VInt_Index				; Undoc.
	dc.w VInt_S1SegaScr_Leftover-VInt_Index ; Sonic 1's SEGA Screen
	dc.w sub_201A58-VInt_Index				; Undoc.
	dc.w sub_20192C-VInt_Index				; Undoc.

; -------------------------------------------------------------------------

VInt_Lag:
	cmpi.b  #$8C,gameMode.w
	beq.s   loc_2016EA
	cmpi.b  #$C,gameMode.w
	bne.w   VInt_Finish

loc_2016EA:
	cmpi.b  #1,zone
	bne.w   VInt_Finish
	move.w  VDPCTRL,d0
	btst    #6,versionCache
	beq.s   .NotPAL

	move.w  #$700,d0

	dbf     d0,*

.NotPAL:
	move.w  #1,hintFlag.w
	jsr     L_stopZ80
	tst.b   waterFullscreen.w
	bne.s   .WaterPal
	LVLDMA	palette,$0000,$80,CRAM		; DMA palette
	bra.s   .Done

; -------------------------------------------------------------------------

.WaterPal:
	LVLDMA	waterPalette,$0000,$80,CRAM		; DMA palette

.Done: 
	move.w  vdpReg0A.w,(a5)
	jsr     L_startZ80
	bra.w   VInt_Finish

; -------------------------------------------------------------------------

VInt_General:
	bsr.w   DoVIntUpdates

VInt_S1SegaScr_Leftover:
	tst.w   vintTimer.w
	beq.w   .End
	subq.w  #1,vintTimer.w

.End:
	rts

; -------------------------------------------------------------------------
; Unused, Sonic 1's Title Screen V-Int routine
; -------------------------------------------------------------------------

VInt_S1Title_Leftover:
	bsr.w   DoVIntUpdates
	tst.w   titleTimer.w
	beq.s   loc_FF286A
	subq.w  #1,titleTimer.w

loc_FF286A:
	addq.w  #1,($FFFFFA44).w

	tst.w   vintTimer.w
	beq.w   .End
	subq.w  #1,vintTimer.w

.End:
	rts

; -------------------------------------------------------------------------
; Unused/Dead
; -------------------------------------------------------------------------

VInt_Unk6:
	bsr.w   DoVIntUpdates
	rts

; -------------------------------------------------------------------------
; Unused remnant pause routine(?) from Sonic 1
; Uses VInt_Return
; -------------------------------------------------------------------------

VInt_Pause:
	cmpi.b  #$10,gameMode.w			; Are we paused?
	beq.w   VInt_Return				; If so, end

; -------------------------------------------------------------------------
; Level Vsync
; -------------------------------------------------------------------------

VInt_Level:
	bsr.w   RunBoredTimer
	bsr.w   RunTimeWarp
	jsr     L_stopZ80
	bsr.w   ReadControllers
	tst.b   waterFullscreen.w
	bne.s   DMA_WaterPalette
	LVLDMA	palette,$0000,$80,CRAM		; DMA palette
	bra.s   NotUnderwater

DMA_WaterPalette:
	LVLDMA	waterPalette,$0000,$80,CRAM	; DMA palette

NotUnderwater:
	move.w  vdpReg0A.w,(a5)
	LVLDMA	hscroll,$FC00,$380,VRAM		; DMA horizontal scroll data
	LVLDMA	sprites,$F800,$280,VRAM		; DMA sprites

Load_PlayerSprites:
	lea     objPlayerSlot.w,a0
	bsr.w   LoadSonicDynPLC
	tst.b   updateSonicArt.w
	beq.s   .NoArtLoad
	LVLDMA	sonicArtBuf,$F000,$2E0,VRAM
	move.b  #0,updateSonicArt.w

.NoArtLoad:
	lea     objPlayerSlot2.w,a0
	bsr.w   LoadSonicDynPLC
	tst.b   updateSonicArt.w
	beq.s   loc_2018CA
	lea     VDPCTRL,a5
	move.l  #$94019370,(a5)
	move.l  #$96E49500,(a5)
	move.w  #$977F,(a5)
	move.w  #$72E0,(a5)
	move.w  #$83,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	move.b  #0,updateSonicArt.w

loc_2018CA:
	jsr     JmpTo_LoadShieldArt

loc_2018D8:
	jsr     L_startZ80
	movem.l cameraX.w,d0-d7
	movem.l d0-d7,camXCopy
	movem.l scrollFlags.w,d0-d1
	movem.l d0-d1,scrollFlagsCopy
	cmpi.b  #$60,vdpReg0A+1.w ; '`'
	bcc.s   sub_20190E
	move.b  #1,hintUpdates.w
	addq.l  #4,sp
	bra.w   VInt_Finish_SkipFM


; -------------------------------------------------------------------------
; Function that processes screen data for a frame(?)
; -------------------------------------------------------------------------

sub_20190E:
	bsr.w   DrawLevel
	bsr.w   DecompPLCSlow
	jsr     sub_20984A
	tst.w   vintTimer.w
	beq.w   .SkipDec
	subq.w  #1,vintTimer.w

.SkipDec:
	rts

; -------------------------------------------------------------------------
; Unused/Null
; -------------------------------------------------------------------------

VInt_Return:
	rts

; -------------------------------------------------------------------------


sub_20192C:
	jsr     L_stopZ80
	bsr.w   ReadControllers
	tst.b   waterFullscreen.w
	bne.s   loc_201962
	lea     VDPCTRL,a5
	move.l  #$94009340,(a5)
	move.l  #$96FD9580,(a5)
	move.w  #$977F,(a5)
	move.w  #$C000,(a5)
	move.w  #$80,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	bra.s   loc_201986
; -------------------------------------------------------------------------

loc_201962:	 ; CODE XREF: sub_20192C+E?j
	lea     VDPCTRL,a5
	move.l  #$94009340,(a5)
	move.l  #$96FD9540,(a5)
	move.w  #$977F,(a5)
	move.w  #$C000,(a5)
	move.w  #$80,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)

loc_201986:	 ; CODE XREF: sub_20192C+34?j
	move.w  vdpReg0A.w,(a5)
	lea     VDPCTRL,a5
	move.l  #$940193C0,(a5)
	move.l  #$96E69500,(a5)
	move.w  #$977F,(a5)
	move.w  #$7C00,(a5)
	move.w  #$83,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	lea     VDPCTRL,a5
	move.l  #$94019340,(a5)
	move.l  #$96FC9500,(a5)
	move.w  #$977F,(a5)
	move.w  #$7800,(a5)
	move.w  #$83,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	lea     objPlayerSlot.w,a0
	bsr.w   LoadSonicDynPLC
	tst.b   updateSonicArt.w
	beq.s   loc_201A0A
	lea     VDPCTRL,a5
	move.l  #$94019370,(a5)
	move.l  #$96E49500,(a5)
	move.w  #$977F,(a5)
	move.w  #$7000,(a5)
	move.w  #$83,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	move.b  #0,updateSonicArt.w

loc_201A0A:	 ; CODE XREF: sub_20192C+B2?j
	jsr     L_startZ80
	movem.l cameraX.w,d0-d7
	movem.l d0-d7,camXCopy
	movem.l scrollFlags.w,d0-d1
	movem.l d0-d1,scrollFlagsCopy
	bsr.w   DrawLevel
	bsr.w   DecompPLCFast
	jsr     sub_20984A
	rts
; End of function sub_20192C


sub_201A3C:	 ; DATA XREF: ROM:002016CC?o
	bsr.w   DoVIntUpdates
	addq.b  #1,miscVariables.w

; -------------------------------------------------------------------------


sub_201A44:
	move.b  #$E,vintRoutine.w
	rts
; End of function sub_201A44


; -------------------------------------------------------------------------


sub_201A4C:	 ; DATA XREF: ROM:002016D0?o
	bsr.w   DoVIntUpdates
	move.w  vdpReg0A.w,(a5)
	bra.w   DecompPLCFast
; End of function sub_201A4C


; -------------------------------------------------------------------------


sub_201A58:	 ; DATA XREF: ROM:002016D4?o
	jsr     L_stopZ80
; End of function sub_201A58


; -------------------------------------------------------------------------


sub_201A5E:
	bsr.w   ReadControllers
	lea     VDPCTRL,a5
	move.l  #$94009340,(a5)
	move.l  #$96FD9580,(a5)
	move.w  #$977F,(a5)
	move.w  #$C000,(a5)
	move.w  #$80,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	lea     VDPCTRL,a5
	move.l  #$94019340,(a5)
	move.l  #$96FC9500,(a5)
	move.w  #$977F,(a5)
	move.w  #$7800,(a5)
	move.w  #$83,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	lea     VDPCTRL,a5
	move.l  #$940193C0,(a5)
	move.l  #$96E69500,(a5)
	move.w  #$977F,(a5)
	move.w  #$7C00,(a5)
	move.w  #$83,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	jsr     L_startZ80
	lea     objPlayerSlot.w,a0
	bsr.w   LoadSonicDynPLC
	tst.b   updateSonicArt.w
	beq.s   loc_201B0C
	lea     VDPCTRL,a5
	move.l  #$94019370,(a5)
	move.l  #$96E49500,(a5)
	move.w  #$977F,(a5)
	move.w  #$7000,(a5)
	move.w  #$83,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	move.b  #0,updateSonicArt.w

loc_201B0C:	 ; CODE XREF: sub_201A5E+82?j
	tst.w   vintTimer.w
	beq.w   locret_201B18
	subq.w  #1,vintTimer.w

locret_201B18:	          ; CODE XREF: sub_201A5E+B2?j
	rts
; End of function sub_201A5E


; -------------------------------------------------------------------------
; General V-Int function that updates essentials like controller reads.
; -------------------------------------------------------------------------

DoVIntUpdates:
	jsr     L_stopZ80
	bsr.w   ReadControllers
	tst.b   waterFullscreen.w
	bne.s   loc_201B50
	lea     VDPCTRL,a5
	move.l  #$94009340,(a5)
	move.l  #$96FD9580,(a5)
	move.w  #$977F,(a5)
	move.w  #$C000,(a5)
	move.w  #$80,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	bra.s   loc_201B74

; -------------------------------------------------------------------------

loc_201B50:	 ; CODE XREF: DoVIntUpdates+E?j
	lea     VDPCTRL,a5
	move.l  #$94009340,(a5)
	move.l  #$96FD9540,(a5)
	move.w  #$977F,(a5)
	move.w  #$C000,(a5)
	move.w  #$80,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)

loc_201B74:	 ; CODE XREF: DoVIntUpdates+34?j
	lea     VDPCTRL,a5
	move.l  #$94019340,(a5)
	move.l  #$96FC9500,(a5)
	move.w  #$977F,(a5)
	move.w  #$7800,(a5)
	move.w  #$83,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	lea     VDPCTRL,a5
	move.l  #$940193C0,(a5)
	move.l  #$96E69500,(a5)
	move.w  #$977F,(a5)
	move.w  #$7C00,(a5)
	move.w  #$83,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)
	jmp     L_startZ80
; End of function DoVIntUpdates


; -------------------------------------------------------------------------
; Horizontal Interrupt (Unused, Sonic 1 leftover.)
; -------------------------------------------------------------------------

HInterrupt:
	move    #$2700,sr
	tst.w   hintFlag.w
	beq.s   .NoTransfer
	move.w  #0,hintFlag.w
	movem.l a0-a1,-(sp)
	lea     VDPDATA,a1
	lea     waterPalette.w,a0
	move.l  #$C0000000,4(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.l  (a0)+,(a1)
	move.w  #$8ADF,4(a1)
	movem.l (sp)+,a0-a1
	tst.b   hintUpdates.w
	bne.s   loc_201C3A

.NoTransfer:
	rte

; -------------------------------------------------------------------------

loc_201C3A:
	clr.b   hintUpdates.w
	movem.l d0-d7/a0-a6,-(sp)
	bsr.w   sub_20190E
	movem.l (sp)+,d0-d7/a0-a6
	rte

; -------------------------------------------------------------------------
; Run the Time Warp timer
; -------------------------------------------------------------------------

RunTimeWarp:
	tst.w   timeWarpTimer.w
	beq.s   loc_201C56
	addq.w  #1,timeWarpTimer.w

loc_201C56:
	tst.w   timeStopTimer
	beq.s   .End
	subq.w  #1,timeStopTimer
	cmpi.w	#1,timeStopTimer
	beq.s	.unpauseMus

.End:
	rts
.unpauseMus
	move.b	#$80,v_snddriver_ram+f_pausemusic
	rts

; -------------------------------------------------------------------------
; Run the Sonic "boredom" timer
; -------------------------------------------------------------------------

RunBoredTimer:
	tst.w   boredTimer.w
	beq.s   loc_201C70
	addq.w  #1,boredTimer.w

loc_201C70:
	tst.w   boredTimerP2.w
	beq.s   locret_201C7A
	addq.w  #1,boredTimerP2.w

locret_201C7A:
	rts

; -------------------------------------------------------------------------
    include "Level/Universal/Functions (General).asm"
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Routine to set the current level boundries for camera locks and events
; -------------------------------------------------------------------------

LevelSizeLoad:
	bsr.s   GetPlayerObject
	moveq   #0,d0
	move.b  d0,unusedF740.w
	move.b  d0,unusedF741.w
	move.b  d0,unusedF746.w
	move.b  d0,unusedF748.w
	move.b  d0,eventRoutine.w

	lea     CamBounds,a0
	move.w  (a0)+,d0
	move.w  d0,unusedF730.w
	move.l  (a0)+,d0
	move.l  d0,leftBound.w
	move.l  d0,destLeftBound.w
	move.l  (a0)+,d0
	move.l  d0,topBound.w
	move.l  d0,destTopBound.w
	move.w  leftBound.w,d0
	addi.w  #$240,d0
	move.w  d0,leftBound3.w
	move.w  #$1010,horizBlkCrossed.w
	move.w  (a0)+,d0
	move.w  d0,camYCenter.w
	bra.w   loc_20247C

; -------------------------------------------------------------------------
; Initial camera/level boundries
; -------------------------------------------------------------------------

CamBounds:
	dc.w 4, 0, $2697, 0, $310, $60

; -------------------------------------------------------------------------
; Leftover starting locations from Sonic 1's ending credits
; -------------------------------------------------------------------------

EndingStLocsS1_Leftover:
	dc.w $50  , $3B0
	dc.w $EA0 , $46C
	dc.w $1750, $BD
	dc.w $A00 , $62C
	dc.w $BB0 , $4C
	dc.w $1570, $16C
	dc.w $1B0 , $72C
	dc.w $1400, $2AC

; -------------------------------------------------------------------------

loc_20247C:	 ; CODE XREF: LevelSizeLoad+50?j
	tst.b   spawnMode
	beq.s   loc_202498
	jsr     sub_205F2E
	moveq   #0,d0
	moveq   #0,d1
	move.w  8(a6),d1
	move.w  $C(a6),d0
	bra.s   loc_2024D4
; -------------------------------------------------------------------------

loc_202498:	 ; CODE XREF: LevelSizeLoad+86?j
	moveq	#0,d0
	move.b	act,d0
	add.b	d0,d0
	add.b	d0,d0
	move.b	zone,d1
	add.b	d1,d1;2
	add.b	d1,d1;4
	move.b	d1,d2
	add.b	d1,d1;8
	add.b	d2,d1
	add.b	d1,d0
	lea     LevelStartLoc(pc,d0.w),a1
	tst.w   demoMode
	bpl.s   loc_2024BA
	move.w  s1CreditsIndex,d0
	subq.w  #1,d0
	lsl.w   #2,d0
	lea     EndingStLocsS1_Leftover,a1
	adda.w  d0,a1
	bra.s   loc_2024C4
; -------------------------------------------------------------------------

loc_2024BA:	 ; CODE XREF: LevelSizeLoad+A8?j
	move.w  demoMode,d0
	lsl.w   #2,d0
	adda.w  d0,a1

loc_2024C4:	 ; CODE XREF: LevelSizeLoad+BC?j
	moveq   #0,d1
	move.w  (a1)+,d1
	move.w  d1,8(a6)
	moveq   #0,d0
	move.w  (a1),d0
	move.w  d0,$C(a6)

loc_2024D4:	 ; CODE XREF: LevelSizeLoad+9A?j
	subi.w  #$A0,d1
	bcc.s   loc_2024DC
	moveq   #0,d1

loc_2024DC:	 ; CODE XREF: LevelSizeLoad+DC?j
	move.w  rightBound.w,d2
	cmp.w   d2,d1
	bcs.s   loc_2024E6
	move.w  d2,d1

loc_2024E6:	 ; CODE XREF: LevelSizeLoad+E6?j
	move.w  d1,cameraX.w
	subi.w  #$60,d0 ; '`'
	bcc.s   loc_2024F2
	moveq   #0,d0

loc_2024F2:	 ; CODE XREF: LevelSizeLoad+F2?j
	cmp.w   bottomBound.w,d0
	blt.s   loc_2024FC
	move.w  bottomBound.w,d0

loc_2024FC:	 ; CODE XREF: LevelSizeLoad+FA?j
	move.w  d0,cameraY.w
	bsr.w   InitLevelScroll
	lea     SpecChunks,a1
	move.l  (a1),specialChunks.w
	rts

; -------------------------------------------------------------------------

LevelStartLoc:  
		dc.w $50, $1E8	;	R11
		dc.w $50, $185	;	R12
		dc.w $50, $2A0	;	R13
		dc.w $50,0		;	R21	4
		dc.w 0,0		;	R22	8
		dc.w 0,0		;	R23	C
		dc.w $50, $3F0	;	R31
		dc.w 0,0		;	R32
		dc.w 0,0		;	R33

SpecChunks:     dc.b $8C, $8E, $1E, $1E

; -------------------------------------------------------------------------
; Level scrolling initialization (Past)
; -------------------------------------------------------------------------

InitLevelScroll:
	swap    d0
	asr.l   #4,d0
	move.l  d0,d2
	add.l   d2,d2
	add.l   d2,d0
	move.l  d0,cameraBgY.w
	swap    d0
	move.w  d0,cameraBg2Y.w
	move.w  d0,cameraBg3Y.w

	lsr.w   #1,d1
	move.w  d1,cameraBgX.w
	lsr.w   #2,d1
	move.w  d1,d2
	add.w   d2,d2
	add.w   d1,d2
	move.w  d2,cameraBg3X.w
	lsr.w   #1,d1
	move.w  d1,d2
	add.w   d2,d2
	add.w   d1,d2
	move.w  d2,cameraBg2X.w
	lea     deformBuffer.w,a2
	clr.l   (a2)+
	clr.l   (a2)+
	clr.l   (a2)+
	clr.l   (a2)+
	clr.l   (a2)+
	clr.l   (a2)+
	rts

; -------------------------------------------------------------------------
; Main Level screen scrolling handler
; -------------------------------------------------------------------------

LevelScroll:
	bsr.w   GetPlayerObject		; Get player slot
	
	tst.b   scrollLock.w			; Is scrolling locked?
	beq.s   .DoScroll			; If not, branch
	rts

.DoScroll:
	clr.w   scrollFlags.w			; Clear scroll flags
	clr.w   scrollFlagsBg.w
	clr.w   scrollFlagsBg2.w
	clr.w   scrollFlagsBg3.w
	bsr.w   ScrollCamX		; Scroll camera horizontally
	bsr.w   ScrollCamY		; Scroll camera vertically
	bsr.w   RunLevelEvents	; Run level events

	move.w  cameraY.w,vscrollScreen.w	; Update VScroll values
	move.w  cameraBgY.w,vscrollScreen+2.w

; -------------------------------------------------------------------------

	move.w  scrollXDiff.w,d4		; Set scroll offset and flags for the clouds and mountains
	ext.l   d4
	asl.l   #5,d4
	moveq   #6,d6
	bsr.w   SetHorizScrollFlagsBG3
	
	move.w  scrollXDiff.w,d4		; Set scroll offset and flags for the waterfalls
	ext.l   d4
	asl.l   #4,d4
	move.l  d4,d3
	add.l   d3,d3
	add.l   d3,d4
	moveq   #4,d6
	bsr.w   SetHorizScrollFlagsBG2
	
	lea     deformBuffer+$18.w,a1		; Prepare deformation buffer
	
	move.w  scrollXDiff.w,d4		; Set scroll offset and flags for the rest + vertical scrolling
	ext.l   d4
	asl.l   #7,d4
	move.w  scrollYDiff.w,d5
	ext.l   d5
	asl.l   #4,d5
	move.l  d5,d3
	add.l   d5,d5
	add.l   d3,d5
	bsr.w   SetScrollFlagsBG
	
	move.w  cameraBgY.w,vscrollScreen+2.w	; Update background Y positions
	move.w  cameraBgY.w,cameraBg2Y.w
	move.w  cameraBgY.w,cameraBg3Y.w
	
	move.b  scrollFlagsBg3.w,d0		; Combine background scroll flags for the level drawing routine
	or.b    scrollFlagsBg2.w,d0
	or.b    d0,scrollFlagsBg.w
	clr.b   scrollFlagsBg3.w
	clr.b   scrollFlagsBg2.w
	
	lea     deformBuffer.w,a2		; Set speeds for the clouds
	addi.l  #$10000,(a2)+
	addi.l  #$C000,(a2)+
	addi.l  #$8000,(a2)+
	addi.l  #$4000,(a2)+
	addi.l  #$2000,(a2)+
	addi.l  #$1000,(a2)+
	
	move.w  cameraX.w,d0			; Prepare scroll buffer entry
	neg.w   d0
	swap    d0
	
	move.b	(timeZone).l,d2
	bclr	#7,d2
	add.w	d2,d2
	add.w	d2,d2
	lea		ScrollIndex,a2
	add.w	d2,a2
	move.l	(a2),a2
	jmp		(a2)
	
ContScroll:
	lea     hscroll.w,a1			; Prepare horizontal scroll buffer
	lea     deformBuffer+$18.w,a2		; Prepare deformation buffer
	move.w  cameraBgY.w,d0
	move.w  d0,d2
	andi.w  #$1F8,d0
	lsr.w   #2,d0
	move.w  d0,d3
	lsr.w   #1,d3
	moveq   #$19,d1
	moveq   #$1C,d5
	sub.w   d3,d1
	bcs.s   loc_2026EC
	sub.w   d1,d5
	lea     (a2,d0.w),a2
	bsr.w   sub_20271E

loc_2026EC:	 ; CODE XREF: LevelScroll+180?j
	move.w  cameraBg2X.w,d0
	move.w  cameraX.w,d2
	sub.w   d0,d2
	ext.l   d2
	asl.l   #8,d2
	divs.w  #$100,d2
	ext.l   d2
	asl.l   #8,d2
	moveq   #0,d3
	move.w  d0,d3
	move.w  d5,d1
	lsl.w   #3,d1
	subq.w  #1,d1

loc_20270C:	 ; CODE XREF: LevelScroll+1B8?j
	move.w  d3,d0
	neg.w   d0
	move.l  d0,(a1)+
	swap    d3
	add.l   d2,d3
	swap    d3
	dbf     d1,loc_20270C
	rts
; End of function LevelScroll

ScrollIndex:
	dc.l	PastScroll
	dc.l	PresentScroll
	dc.l	FutureScroll

FutureScroll:	;	fuck you, fuck you, fuck you, fuck you, fuck you, and fuck you
	lea     deformBuffer+$10.w,a1
	move.w  deformBuffer.w,d0		; Scroll top clouds
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #3,d1

FutureScrollClouds1:	 ; CODE XREF: LevelScroll+DA?j
	move.w  d0,(a1)+
	dbf     d1,FutureScrollClouds1
	
	move.w  deformBuffer+4.w,d0		; Scroll top middle clouds
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #4,d1

FutureScrollClouds2:	 ; CODE XREF: LevelScroll+EE?j
	move.w  d0,(a1)+
	dbf     d1,FutureScrollClouds2
	
	move.w  deformBuffer+8.w,d0		; Scroll bottom middle clouds
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #4,d1

FutureScrollMountains:	 ; CODE XREF: LevelScroll+13E?j
	move.w  d0,(a1)+
	dbf     d1,FutureScrollMountains
	move.w  #7,d1
	move.w  cameraBg3X.w,d0
	neg.w   d0

FutureScrollMountains2:	 ; CODE XREF: LevelScroll+14E?j
	move.w  d0,(a1)+
	dbf     d1,FutureScrollMountains2
	move.w  #7,d1
	move.w  cameraBg2X.w,d0
	neg.w   d0

FutureScrollWater:	 ; CODE XREF: LevelScroll+15E?j
	move.w  d0,(a1)+
	dbf     d1,FutureScrollWater
	lea	hscroll.w,a1			; Prepare horizontal scroll buffer
	lea	deformBuffer+$10.w,a2		; Prepare deformation buffer

	move.w	cameraBgY.w,d0			; Get background Y position
	move.w	d0,d2
	andi.w	#$1F8,d0
	lsr.w	#2,d0
	
	moveq	#(232/8)-1,d1			; Max number of blocks to scroll
	lea	(a2,d0.w),a2			; Get starting scroll block
	andi.w	#7,d2				; Get the number of lines to scroll for the first block of lines
	add.w	d2,d2
	move.w	(a2)+,d0			; Start scrolling
	jmp	ScrollBlockStart(pc,d2.w)

ScrollBlockLoop:
	move.w	(a2)+,d0			; Scroll another block of lines

ScrollBlockStart:
	rept	8				; Scroll a block of 8 lines
		move.l	d0,(a1)+
	endr
	dbf	d1,ScrollBlockLoop		; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------

PresentScroll:
	move.w  deformBuffer.w,d0		; Scroll top clouds
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #3,d1

PresentScrollClouds1:	 ; CODE XREF: LevelScroll+DA?j
	move.w  d0,(a1)+
	dbf     d1,PresentScrollClouds1
	
	move.w  deformBuffer+4.w,d0		; Scroll top middle clouds
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #3,d1

PresentScrollClouds2:	 ; CODE XREF: LevelScroll+EE?j
	move.w  d0,(a1)+
	dbf     d1,PresentScrollClouds2
	
	move.w  deformBuffer+8.w,d0		; Scroll bottom middle clouds
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #3,d1

;ScrollClouds3:	 ; CODE XREF: LevelScroll+102?j
;	move.w  d0,(a1)+
;	dbf     d1,ScrollClouds3
;	
;	move.w  deformBuffer+$C.w,d0		; Scroll bottom clouds
;	add.w   cameraBg3X.w,d0
;	neg.w   d0
;	move.w  #1,d1
;
;ScrollClouds4:	 ; CODE XREF: LevelScroll+116?j
;	move.w  d0,(a1)+
;	dbf     d1,ScrollClouds4
;	move.w  deformBuffer+$10.w,d0
;	add.w   cameraBg3X.w,d0
;	neg.w   d0
;	move.w  #1,d1
;
;ScrollClouds5:	 ; CODE XREF: LevelScroll+12A?j
;	move.w  d0,(a1)+
;	dbf     d1,ScrollClouds5
;	move.w  deformBuffer+$14.w,d0
;	add.w   cameraBg3X.w,d0
;	neg.w   d0
;	move.w  #1,d1

PresentScrollMountains:	 ; CODE XREF: LevelScroll+13E?j
	move.w  d0,(a1)+
	dbf     d1,PresentScrollMountains
	move.w  #5,d1
	move.w  cameraBg3X.w,d0
	neg.w   d0

PresentScrollMountains2:	 ; CODE XREF: LevelScroll+14E?j
	move.w  d0,(a1)+
	dbf     d1,PresentScrollMountains2
	move.w  #7,d1
	move.w  cameraBg2X.w,d0
	neg.w   d0

PresentScrollWater:	 ; CODE XREF: LevelScroll+15E?j
	move.w  d0,(a1)+
	dbf     d1,PresentScrollWater
	bra.w	ContScroll

; -------------------------------------------------------------------------

PastScroll:
	move.w  deformBuffer.w,d0		; Scroll top clouds
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #1,d1

PastScrollClouds1:	 ; CODE XREF: LevelScroll+DA?j
	move.w  d0,(a1)+
	dbf     d1,PastScrollClouds1
	
	move.w  deformBuffer+4.w,d0		; Scroll top middle clouds
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #1,d1

PastScrollClouds2:	 ; CODE XREF: LevelScroll+EE?j
	move.w  d0,(a1)+
	dbf     d1,PastScrollClouds2
	
	move.w  deformBuffer+8.w,d0		; Scroll bottom middle clouds
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #1,d1

ScrollClouds3:	 ; CODE XREF: LevelScroll+102?j
	move.w  d0,(a1)+
	dbf     d1,ScrollClouds3
	
	move.w  deformBuffer+$C.w,d0		; Scroll bottom clouds
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #1,d1

ScrollClouds4:	 ; CODE XREF: LevelScroll+116?j
	move.w  d0,(a1)+
	dbf     d1,ScrollClouds4
	move.w  deformBuffer+$10.w,d0
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #1,d1

ScrollClouds5:	 ; CODE XREF: LevelScroll+12A?j
	move.w  d0,(a1)+
	dbf     d1,ScrollClouds5
	move.w  deformBuffer+$14.w,d0
	add.w   cameraBg3X.w,d0
	neg.w   d0
	move.w  #1,d1

PastScrollMountains:	 ; CODE XREF: LevelScroll+13E?j
	move.w  d0,(a1)+
	dbf     d1,PastScrollMountains
	move.w  #7,d1
	move.w  cameraBg3X.w,d0
	neg.w   d0

PastScrollMountains2:	 ; CODE XREF: LevelScroll+14E?j
	move.w  d0,(a1)+
	dbf     d1,PastScrollMountains2
	move.w  #5,d1
	move.w  cameraBg2X.w,d0
	neg.w   d0

PastScrollWater:	 ; CODE XREF: LevelScroll+15E?j
	move.w  d0,(a1)+
	dbf     d1,PastScrollWater
	bra.w	ContScroll

; -------------------------------------------------------------------------


sub_20271E:	 ; CODE XREF: LevelScroll+188?p
	andi.w  #7,d2
	add.w   d2,d2
	move.w  (a2)+,d0
	jmp     loc_20272C(pc,d2.w)
; End of function sub_20271E

; -------------------------------------------------------------------------

loc_20272A:	 ; CODE XREF: ROM:0020273C?j
		        ; ROM:0020275A?j
	move.w  (a2)+,d0

loc_20272C:	 ; CODE XREF: sub_20271E+8?j
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	dbf     d1,loc_20272A
	rts
; -------------------------------------------------------------------------
	neg.w   d0
	jmp     loc_20274A(pc,d2.w)
; -------------------------------------------------------------------------
	neg.w   d0

loc_20274A:	 ; CODE XREF: ROM:00202744?j
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	move.l  d0,(a1)+
	dbf     d1,loc_20272A
	rts

; -------------------------------------------------------------------------


ScrollCamX:	 ; CODE XREF: LevelScroll+1C?p
	move.w  cameraX.w,d4
	bsr.s   MoveScreenHoriz
	move.w  cameraX.w,d0
	andi.w  #$10,d0
	move.b  horizBlkCrossed.w,d1
	eor.b   d1,d0
	bne.s   locret_202792
	eori.b  #$10,horizBlkCrossed.w
	move.w  cameraX.w,d0
	sub.w   d4,d0
	bpl.s   loc_20278C
	bset    #2,scrollFlags.w
	rts
; -------------------------------------------------------------------------

loc_20278C:
	bset    #3,scrollFlags.w

locret_202792:
	rts

; -------------------------------------------------------------------------

MoveScreenHoriz:
	move.w  8(a6),d0
	sub.w   cameraX.w,d0
	subi.w  #$90,d0
	blt.s   loc_2027D8
	subi.w  #$10,d0
	bge.s   loc_2027AE
	clr.w   scrollXDiff.w
	rts

loc_2027AE:
	cmpi.w  #$10,d0
	blt.s   loc_2027B8
	move.w  #$10,d0

loc_2027B8:
	add.w   cameraX.w,d0
	cmp.w   rightBound.w,d0
	blt.s   loc_2027C6
	move.w  rightBound.w,d0

loc_2027C6:
	move.w  d0,d1
	sub.w   cameraX.w,d1
	asl.w   #8,d1
	move.w  d0,cameraX.w
	move.w  d1,scrollXDiff.w
	rts

loc_2027D8:
	cmpi.w  #$FFF0,d0
	bge.s   loc_2027E2
	move.w  #$FFF0,d0

loc_2027E2:
	add.w   cameraX.w,d0
	cmp.w   leftBound.w,d0
	bgt.s   loc_2027C6
	move.w  leftBound.w,d0
	bra.s   loc_2027C6

; -------------------------------------------------------------------------

ShiftCameraHoriz:
	tst.w   d0
	bpl.s   loc_2027FC
	move.w  #$FFFE,d0
	bra.s   loc_2027D8

; -------------------------------------------------------------------------

loc_2027FC:
	move.w  #2,d0
	bra.s   loc_2027AE

; -------------------------------------------------------------------------


ScrollCamY:
	moveq   #0,d1
	move.w  $C(a6),d0
	sub.w   cameraY.w,d0
	btst    #2,$22(a6)
	beq.s   loc_202816
	subq.w  #5,d0

loc_202816:
	btst    #1,$22(a6)
	beq.s   loc_202836
	addi.w  #$20,d0 ; ' '
	sub.w   camYCenter.w,d0
	bcs.s   loc_202882
	subi.w  #$40,d0 ; '.'
	bcc.s   loc_202882
	tst.b   btmBoundShift.w
	bne.s   loc_202894
	bra.s   loc_202842
; -------------------------------------------------------------------------

loc_202836:	 ; CODE XREF: ScrollCamY+1A?j
	sub.w   camYCenter.w,d0
	bne.s   loc_202848
	tst.b   btmBoundShift.w
	bne.s   loc_202894

loc_202842:	 ; CODE XREF: ScrollCamY+32?j
	clr.w   scrollYDiff.w
	rts
; -------------------------------------------------------------------------

loc_202848:	 ; CODE XREF: ScrollCamY+38?j
	cmpi.w  #$60,camYCenter.w ; '`'
	bne.s   loc_202870
	move.w  $14(a6),d1
	bpl.s   loc_202858
	neg.w   d1

loc_202858:	 ; CODE XREF: ScrollCamY+52?j
	cmpi.w  #$800,d1
	bcc.s   loc_202882
	move.w  #$600,d1
	cmpi.w  #6,d0
	bgt.s   loc_2028E2
	cmpi.w  #$FFFA,d0
	blt.s   loc_2028AC
	bra.s   loc_20289A
; -------------------------------------------------------------------------

loc_202870:	 ; CODE XREF: ScrollCamY+4C?j
	move.w  #$200,d1
	cmpi.w  #2,d0
	bgt.s   loc_2028E2
	cmpi.w  #$FFFE,d0
	blt.s   loc_2028AC
	bra.s   loc_20289A
; -------------------------------------------------------------------------

loc_202882:	 ; CODE XREF: ScrollCamY+24?j
		        ; ScrollCamY+2A?j ...
	move.w  #$1000,d1
	cmpi.w  #$10,d0
	bgt.s   loc_2028E2
	cmpi.w  #$FFF0,d0
	blt.s   loc_2028AC
	bra.s   loc_20289A
; -------------------------------------------------------------------------

loc_202894:	 ; CODE XREF: ScrollCamY+30?j
		        ; ScrollCamY+3E?j
	moveq   #0,d0
	move.b  d0,btmBoundShift.w

loc_20289A:	 ; CODE XREF: ScrollCamY+6C?j
		        ; ScrollCamY+7E?j ...
	moveq   #0,d1
	move.w  d0,d1
	add.w   cameraY.w,d1
	tst.w   d0
	bpl.w   loc_2028EC
	bra.w   loc_2028B8
; -------------------------------------------------------------------------

loc_2028AC:	 ; CODE XREF: ScrollCamY+6A?j
		        ; ScrollCamY+7C?j ...
	neg.w   d1
	ext.l   d1
	asl.l   #8,d1
	add.l   cameraY.w,d1
	swap    d1

loc_2028B8:	 ; CODE XREF: ScrollCamY+A6?j
	cmp.w   topBound.w,d1
	bgt.s   loc_202910
	cmpi.w  #$FF00,d1
	bgt.s   loc_2028DC
	andi.w  #$7FF,d1
	andi.w  #$7FF,$C(a6)
	andi.w  #$7FF,cameraY.w
	andi.w  #$3FF,cameraBgY.w
	bra.s   loc_202910
; -------------------------------------------------------------------------

loc_2028DC:	 ; CODE XREF: ScrollCamY+C0?j
	move.w  topBound.w,d1
	bra.s   loc_202910
; -------------------------------------------------------------------------

loc_2028E2:	 ; CODE XREF: ScrollCamY+64?j
		        ; ScrollCamY+76?j ...
	ext.l   d1
	asl.l   #8,d1
	add.l   cameraY.w,d1
	swap    d1

loc_2028EC:	 ; CODE XREF: ScrollCamY+A2?j
	cmp.w   bottomBound.w,d1
	blt.s   loc_202910
	subi.w  #$800,d1
	bcs.s   loc_20290C
	andi.w  #$7FF,$C(a6)
	subi.w  #$800,cameraY.w
	andi.w  #$3FF,cameraBgY.w
	bra.s   loc_202910
; -------------------------------------------------------------------------

loc_20290C:	 ; CODE XREF: ScrollCamY+F4?j
	move.w  bottomBound.w,d1

loc_202910:	 ; CODE XREF: ScrollCamY+BA?j
		        ; ScrollCamY+D8?j ...
	move.w  cameraY.w,d4
	swap    d1
	move.l  d1,d3
	sub.l   cameraY.w,d3
	ror.l   #8,d3
	move.w  d3,scrollYDiff.w
	move.l  d1,cameraY.w
	move.w  cameraY.w,d0
	andi.w  #$10,d0
	move.b  vertiBlkCrossed.w,d1
	eor.b   d1,d0
	bne.s   locret_202952
	eori.b  #$10,vertiBlkCrossed.w
	move.w  cameraY.w,d0
	sub.w   d4,d0
	bpl.s   loc_20294C
	bset    #0,scrollFlags.w
	rts
; -------------------------------------------------------------------------

loc_20294C:	 ; CODE XREF: ScrollCamY+140?j
	bset    #1,scrollFlags.w

locret_202952:	          ; CODE XREF: ScrollCamY+132?j
	rts
; End of function ScrollCamY	    


; -------------------------------------------------------------------------

SetScrollFlagsBG:
	move.l  cameraBgX.w,d2
	move.l  d2,d0
	add.l   d4,d0
	move.l  d0,cameraBgX.w
	move.l  d0,d1
	swap    d1
	andi.w  #$10,d1
	move.b  horizBlkCrossedBg.w,d3
	eor.b   d3,d1
	bne.s   loc_202988
	eori.b  #$10,horizBlkCrossedBg.w
	sub.l   d2,d0
	bpl.s   loc_202982
	bset    #2,scrollFlagsBg.w
	bra.s   loc_202988

loc_202982:
	bset    #3,scrollFlagsBg.w

loc_202988:
	move.l  cameraBgY.w,d3
	move.l  d3,d0
	add.l   d5,d0
	move.l  d0,cameraBgY.w
	move.l  d0,d1
	swap    d1
	andi.w  #$10,d1
	move.b  vertiBlkCrossedBg.w,d2
	eor.b   d2,d1
	bne.s   locret_2029BC
	eori.b  #$10,vertiBlkCrossedBg.w
	sub.l   d3,d0
	bpl.s   loc_2029B6
	bset    #0,scrollFlagsBg.w
	rts

loc_2029B6:
	bset    #1,scrollFlagsBg.w

locret_2029BC:
	rts

; -------------------------------------------------------------------------

SetVertiScrollFlagsBG:
	move.l  cameraBgY.w,d3
	move.l  d3,d0
	add.l   d5,d0
	move.l  d0,cameraBgY.w
	move.l  d0,d1
	swap    d1
	andi.w  #$10,d1
	move.b  vertiBlkCrossedBg.w,d2
	eor.b   d2,d1
	bne.s   locret_2029F2
	eori.b  #$10,vertiBlkCrossedBg.w
	sub.l   d3,d0
	bpl.s   loc_2029EC
	bset    #4,scrollFlagsBg.w
	rts

; -------------------------------------------------------------------------

loc_2029EC:
	bset    #5,scrollFlagsBg.w

locret_2029F2:
	rts

; -------------------------------------------------------------------------

SetVertiScrollFlagsBG2:
	move.w  cameraBgY.w,d3
	move.w  d0,cameraBgY.w
	move.w  d0,d1
	andi.w  #$10,d1
	move.b  vertiBlkCrossedBg.w,d2
	eor.b   d2,d1
	bne.s   locret_202A22
	eori.b  #$10,vertiBlkCrossedBg.w
	sub.w   d3,d0
	bpl.s   loc_202A1C
	bset    #0,scrollFlagsBg.w
	rts

loc_202A1C:
	bset    #1,scrollFlagsBg.w

locret_202A22:
	rts

; -------------------------------------------------------------------------

SetHorizScrollFlagsBG:
	move.l  cameraBgX.w,d2
	move.l  d2,d0
	add.l   d4,d0
	move.l  d0,cameraBgX.w
	move.l  d0,d1
	swap    d1
	andi.w  #$10,d1
	move.b  horizBlkCrossedBg.w,d3
	eor.b   d3,d1
	bne.s   locret_202A56
	eori.b  #$10,horizBlkCrossedBg.w
	sub.l   d2,d0
	bpl.s   loc_202A50
	bset    d6,scrollFlagsBg.w
	bra.s   locret_202A56

loc_202A50:
	addq.b  #1,d6
	bset    d6,scrollFlagsBg.w

locret_202A56:
	rts

; -------------------------------------------------------------------------

SetHorizScrollFlagsBG2:
	move.l  cameraBg2X.w,d2
	move.l  d2,d0
	add.l   d4,d0
	move.l  d0,cameraBg2X.w
	move.l  d0,d1
	swap    d1
	andi.w  #$10,d1
	move.b  horizBlkCrossedBg2.w,d3
	eor.b   d3,d1
	bne.s   locret_202A8A
	eori.b  #$10,horizBlkCrossedBg2.w
	sub.l   d2,d0
	bpl.s   loc_202A84
	bset    d6,scrollFlagsBg2.w
	bra.s   locret_202A8A

loc_202A84:
	addq.b  #1,d6
	bset    d6,scrollFlagsBg2.w

locret_202A8A:
	rts

; -------------------------------------------------------------------------


SetHorizScrollFlagsBG3:
	move.l  cameraBg3X.w,d2
	move.l  d2,d0
	add.l   d4,d0
	move.l  d0,cameraBg3X.w

	move.l  d0,d1
	swap    d1
	andi.w  #$10,d1
	move.b  horizBlkCrossedBg3.w,d3
	eor.b   d3,d1
	bne.s   locret_202ABE
	eori.b  #$10,horizBlkCrossedBg3.w
	sub.l   d2,d0
	bpl.s   loc_202AB8
	bset    d6,scrollFlagsBg3.w
	bra.s   locret_202ABE

loc_202AB8:	
	addq.b  #1,d6
	bset    d6,scrollFlagsBg3.w

locret_202ABE:	          
	rts
; -------------------------------------------------------------------------

DrawLevelBG:
	lea     VDPCTRL,a5
	lea     VDPDATA,a6
	lea     scrollFlagsBg.w,a2
	lea     cameraBgX.w,a3
	lea     levelLayout+$40.w,a4
	move.w  #$6000,d2
	bsr.w   DrawLevelBG1
	lea     scrollFlagsBg2.w,a2
	lea     cameraBg2X.w,a3
	bra.w   sub_202C8E

; -------------------------------------------------------------------------


DrawLevel:
	lea     VDPCTRL,a5
	lea     VDPDATA,a6
	lea     scrollFlagsBgCopy,a2
	lea     camXBgCopy,a3
	lea     levelLayout+$40.w,a4
	move.w  #$6000,d2
	bsr.w   DrawLevelBG1
	lea     scrollFlagsBg2Copy,a2
	lea     camXBg2Copy,a3
	bsr.w   sub_202C8E
	lea     scrollFlagsBg3Copy,a2
	lea     camXBg3Copy,a3
	bsr.w   locret_202C90
	lea     scrollFlagsCopy,a2
	lea     camXCopy,a3
	lea     levelLayout.w,a4
	move.w  #$4000,d2


	tst.b   (a2)
	beq.s   locret_202BA8
	bclr    #0,(a2)
	beq.s   loc_202B5E
	moveq   #$FFFFFFF0,d4
	moveq   #$FFFFFFF0,d5
	bsr.w   sub_202EB8
	moveq   #$FFFFFFF0,d4
	moveq   #$FFFFFFF0,d5
	bsr.w   sub_202C92

loc_202B5E:	 ; CODE XREF: DrawLevel+60?j
	bclr    #1,(a2)
	beq.s   loc_202B78
	move.w  #$E0,d4
	moveq   #$FFFFFFF0,d5
	bsr.w   sub_202EB8
	move.w  #$E0,d4
	moveq   #$FFFFFFF0,d5
	bsr.w   sub_202C92

loc_202B78:	 ; CODE XREF: DrawLevel+76?j
	bclr    #2,(a2)
	beq.s   loc_202B8E
	moveq   #$FFFFFFF0,d4
	moveq   #$FFFFFFF0,d5
	bsr.w   sub_202EB8
	moveq   #$FFFFFFF0,d4
	moveq   #$FFFFFFF0,d5
	bsr.w   sub_202CE8

loc_202B8E:	 ; CODE XREF: DrawLevel+90?j
	bclr    #3,(a2)
	beq.s   locret_202BA8
	moveq   #$FFFFFFF0,d4
	move.w  #$140,d5
	bsr.w   sub_202EB8
	moveq   #$FFFFFFF0,d4
	move.w  #$140,d5
	bsr.w   sub_202CE8

locret_202BA8:	          ; CODE XREF: DrawLevel+5A?j
		        ; DrawLevel+A6?j
	rts
; End of function DrawLevel


; -------------------------------------------------------------------------


DrawLevelBG1:
	moveq   #0,d0
	move.b	(timeZone).l,d0
	bclr	#7,d0
	add.w	d0,d0
	add.w	d0,d0
	lea		ScrollSectIDs,a0
	add.w	d0,a0
	move.l	(a0),a0
	
	adda.w  #1,a0
	moveq   #$FFFFFFF0,d4
	bclr    #0,(a2)
	bne.s   .loc_202BC6
	bclr    #1,(a2)
	beq.s   loc_202C10
	move.w  #$E0,d4

.loc_202BC6:
	move.w  cameraBgY.w,d0
	add.w   d4,d0
	andi.w  #$FFF0,d0
	asr.w   #4,d0
	move.b  (a0,d0.w),d0
	ext.w   d0
	add.w   d0,d0
	movea.l dword_202C40(pc,d0.w),a3
	beq.s   loc_202BF8
	moveq   #$FFFFFFF0,d5
	move.l  a0,-(sp)
	movem.l d4-d5,-(sp)
	bsr.w   sub_202EB8
	movem.l (sp)+,d4-d5
	bsr.w   sub_202C92
	movea.l (sp)+,a0
	bra.s   loc_202C10
ScrollSectIDs:
	dc.l	PastBGCameraSectIDs
	dc.l	PresentBGCameraSectIDs
	dc.l	FutureBGCameraSectIDs
; -------------------------------------------------------------------------

loc_202BF8:	 ; CODE XREF: DrawLevelBG1+34?j
	moveq   #0,d5
	move.l  a0,-(sp)
	movem.l d4-d5,-(sp)
	bsr.w   sub_202EBA
	movem.l (sp)+,d4-d5
	moveq   #$1F,d6
	bsr.w   sub_202CBE
	movea.l (sp)+,a0

loc_202C10:	 ; CODE XREF: DrawLevelBG1+16?j
		        ; DrawLevelBG1+4C?j
	tst.b   (a2)
	bne.s   loc_202C16
	rts
; -------------------------------------------------------------------------

loc_202C16:	 ; CODE XREF: DrawLevelBG1+68?j
	moveq   #$FFFFFFF0,d4
	moveq   #$FFFFFFF0,d5
	move.b  (a2),d0
	andi.b  #$A8,d0
	beq.s   loc_202C2A
	lsr.b   #1,d0
	move.b  d0,(a2)
	move.w  #$140,d5

loc_202C2A:	 ; CODE XREF: DrawLevelBG1+76?j
	move.w  cameraBgY.w,d0
	andi.w  #$FFF0,d0
	asr.w   #4,d0
	suba.w  #1,a0
	lea     (a0,d0.w),a0
	bra.w   loc_202C50
; -------------------------------------------------------------------------
dword_202C40:   dc.l $FF1318; DATA XREF: DrawLevelBG1+30?r
		        ; DrawLevelBG1+B8?r
	dc.l $FF1318
	dc.l $FF1320
	dc.l $FF1328
; -------------------------------------------------------------------------

loc_202C50:	 ; CODE XREF: DrawLevelBG1+92?j
	moveq   #$F,d6
	move.l  #$800000,d7

loc_202C58:	 ; CODE XREF: DrawLevelBG1+DC?j
	moveq   #0,d0
	move.b  (a0)+,d0
	btst    d0,(a2)
	beq.s   loc_202C82
	add.w   d0,d0
	movea.l dword_202C40(pc,d0.w),a3
	movem.l d4-d5/a0,-(sp)
	movem.l d4-d5,-(sp)
	bsr.w   sub_202D94
	movem.l (sp)+,d4-d5
	bsr.w   sub_202EB8
	bsr.w   sub_202D16
	movem.l (sp)+,d4-d5/a0

loc_202C82:	 ; CODE XREF: DrawLevelBG1+B4?j
	addi.w  #$10,d4
	dbf     d6,loc_202C58
	clr.b   (a2)
	rts
; End of function DrawLevelBG1


; -------------------------------------------------------------------------


sub_202C8E:	 ; CODE XREF: DrawLevelBG+28?j
		        ; DrawLevel+30?p
	rts
; End of function sub_202C8E

; -------------------------------------------------------------------------

locret_202C90:	          ; CODE XREF: DrawLevel+40?p
	rts

; -------------------------------------------------------------------------


sub_202C92:	 ; CODE XREF: DrawLevel+6E?p
		        ; DrawLevel+88?p ...
	moveq   #$15,d6

loc_202C94:	 ; CODE XREF: sub_202F1A+16?p
	move.l  #$800000,d7
	move.l  d0,d1

loc_202C9C:	 ; CODE XREF: sub_202C92+26?j
	movem.l d4-d5,-(sp)
	bsr.w   sub_202D94
	move.l  d1,d0
	bsr.w   sub_202D16
	addq.b  #4,d1
	andi.b  #$7F,d1
	movem.l (sp)+,d4-d5
	addi.w  #$10,d5
	dbf     d6,loc_202C9C
	rts
; End of function sub_202C92


; -------------------------------------------------------------------------


sub_202CBE:	 ; CODE XREF: DrawLevelBG1+60?p
		        ; DrawBGBlockRow+32?p
	move.l  #$800000,d7
	move.l  d0,d1

loc_202CC6:	 ; CODE XREF: sub_202CBE+24?j
	movem.l d4-d5,-(sp)
	bsr.w   sub_202D96
	move.l  d1,d0
	bsr.w   sub_202D16
	addq.b  #4,d1
	andi.b  #$7F,d1
	movem.l (sp)+,d4-d5
	addi.w  #$10,d5
	dbf     d6,loc_202CC6
	rts
; End of function sub_202CBE


; -------------------------------------------------------------------------


sub_202CE8:	 ; CODE XREF: DrawLevel+9E?p
		        ; DrawLevel+B8?p
	moveq   #$F,d6
	move.l  #$800000,d7
	move.l  d0,d1

loc_202CF2:	 ; CODE XREF: sub_202CE8+28?j
	movem.l d4-d5,-(sp)
	bsr.w   sub_202D94
	move.l  d1,d0
	bsr.w   sub_202D16
	addi.w  #$100,d1
	andi.w  #$FFF,d1
	movem.l (sp)+,d4-d5
	addi.w  #$10,d4
	dbf     d6,loc_202CF2
	rts
; End of function sub_202CE8


; -------------------------------------------------------------------------


sub_202D16:	 ; CODE XREF: DrawLevelBG1+D0?p
		        ; sub_202C92+14?p ...
	or.w    d2,d0
	swap    d0
	btst    #4,(a0)
	bne.s   loc_202D52
	btst    #3,(a0)
	bne.s   loc_202D32
	move.l  d0,(a5)
	move.l  (a1)+,(a6)
	add.l   d7,d0
	move.l  d0,(a5)
	move.l  (a1)+,(a6)
	rts
; -------------------------------------------------------------------------

loc_202D32:	 ; CODE XREF: sub_202D16+E?j
	move.l  d0,(a5)
	move.l  (a1)+,d4
	eori.l  #$8000800,d4
	swap    d4
	move.l  d4,(a6)
	add.l   d7,d0
	move.l  d0,(a5)
	move.l  (a1)+,d4
	eori.l  #$8000800,d4
	swap    d4
	move.l  d4,(a6)
	rts
; -------------------------------------------------------------------------

loc_202D52:	 ; CODE XREF: sub_202D16+8?j
	btst    #3,(a0)
	bne.s   loc_202D74
	move.l  d0,(a5)
	move.l  (a1)+,d5
	move.l  (a1)+,d4
	eori.l  #$10001000,d4
	move.l  d4,(a6)
	add.l   d7,d0
	move.l  d0,(a5)
	eori.l  #$10001000,d5
	move.l  d5,(a6)
	rts
; -------------------------------------------------------------------------

loc_202D74:	 ; CODE XREF: sub_202D16+40?j
	move.l  d0,(a5)
	move.l  (a1)+,d5
	move.l  (a1)+,d4
	eori.l  #$18001800,d4
	swap    d4
	move.l  d4,(a6)
	add.l   d7,d0
	move.l  d0,(a5)
	eori.l  #$18001800,d5
	swap    d5
	move.l  d5,(a6)
	rts
; End of function sub_202D16


; -------------------------------------------------------------------------


sub_202D94:	 ; CODE XREF: DrawLevelBG1+C4?p
		        ; sub_202C92+E?p ...
	add.w   (a3),d5
; End of function sub_202D94


; -------------------------------------------------------------------------


sub_202D96:	 ; CODE XREF: sub_202CBE+C?p
	add.w   4(a3),d4

loc_202D9A:	 ; CODE XREF: DrawBlockAtPos+20?p
		        ; ROM:0020694E?p
	lea     blockBuffer.w,a1
	move.w  d4,d3
	lsr.w   #1,d3
	andi.w  #$380,d3
	lsr.w   #3,d5
	move.w  d5,d0
	lsr.w   #5,d0
	andi.w  #$7F,d0
	add.w   d3,d0
	moveq	#0,d3
	move.b  (a4,d0.w),d3
	beq.s   locret_202DE2
	subq.b  #1,d3
	andi.w  #$7F,d3
	ror.w   #7,d3
	add.w   d4,d4
	andi.w  #$1E0,d4
	andi.w  #$1E,d5
	add.w   d4,d3
	add.w   d5,d3
	lea		LevelChunks,a0	;	(pointer's now RAM)
	add.l  (a0),d3			;	(pointer's now RAM)
	movea.l d3,a0
	move.w  (a0),d3
	andi.w  #$3FF,d3
	lsl.w   #3,d3
	adda.w  d3,a1
	moveq   #1,d0

locret_202DE2:	          ; CODE XREF: sub_202D96+26?j
	rts
; End of function sub_202D96

; -------------------------------------------------------------------------
	move.w  d4,d3
	lsr.w   #1,d3
	andi.w  #$380,d3
	lsr.w   #3,d5
	move.w  d5,d0
	lsr.w   #5,d0
	andi.w  #$7F,d0
	add.w   d3,d0
	moveq	#0,d3
	move.b  (a4,d0.w),d3
	subq.b  #1,d3
	andi.w  #$7F,d3
	ror.w   #7,d3
	add.w   d4,d4
	andi.w  #$1E0,d4
	andi.w  #$1E,d5
	add.w   d4,d3
	add.w   d5,d3
	lea		LevelChunks,a0	;	(pointer's now RAM)
	add.l  (a0),d3			;	(pointer's now RAM)
	movea.l d3,a0
	rts

; -------------------------------------------------------------------------

DrawBlockAtPos:
	move.l  a0,-(sp)
	lea     levelLayout.w,a4
	lea     VDPCTRL,a5
	lea     VDPDATA,a6
	move.w  #$4000,d2
	move.l  #$800000,d7
	movem.l d3-d5,-(sp)
	bsr.w   loc_202D9A
	bne.s   loc_202E48
	movem.l (sp)+,d3-d5
	bra.s   loc_202E70

loc_202E48:
	movem.l (sp)+,d3-d5
	move.w  d3,(a0)
	bsr.w   sub_202E74
	bne.s   loc_202E70
	movem.l d3-d5,-(sp)
	lea     blockBuffer.w,a1
	andi.w  #$3FF,d3
	lsl.w   #3,d3
	adda.w  d3,a1
	bsr.w   loc_202EBE
	bsr.w   sub_202D16
	movem.l (sp)+,d3-d5

loc_202E70:
	movea.l (sp)+,a0
	rts

sub_202E74:
	move.w  cameraY.w,d0
	move.w  d0,d1
	andi.w  #$FFF0,d0
	subi.w  #$10,d0
	cmp.w   d0,d4
	bcs.s   loc_202EB4
	addi.w  #$F0,d1
	andi.w  #$FFF0,d1
	cmp.w   d1,d4
	bgt.s   loc_202EB4
	move.w  cameraX.w,d0
	move.w  d0,d1
	andi.w  #$FFF0,d0
	subi.w  #$10,d0
	cmp.w   d0,d5
	bcs.s   loc_202EB4
	addi.w  #$150,d1
	andi.w  #$FFF0,d1
	cmp.w   d1,d5
	bgt.s   loc_202EB4
	moveq   #0,d0
	rts

loc_202EB4:
	moveq   #1,d0
	rts

; -------------------------------------------------------------------------


sub_202EB8:
	add.w   (a3),d5

sub_202EBA:
	add.w   4(a3),d4

loc_202EBE:
	andi.w  #$F0,d4
	andi.w  #$1F0,d5
	lsl.w   #4,d4
	lsr.w   #2,d5
	add.w   d5,d4
	moveq   #3,d0
	swap    d0
	move.w  d4,d0
	rts

; -------------------------------------------------------------------------
; dead code

	add.w   4(a3),d4
	add.w   (a3),d5
	andi.w  #$F0,d4
	andi.w  #$1F0,d5
	lsl.w   #4,d4
	lsr.w   #2,d5
	add.w   d5,d4
	moveq   #2,d0
	swap    d0
	move.w  d4,d0
	rts

; -------------------------------------------------------------------------


InitLevelDraw:	  
	lea     VDPCTRL,a5
	lea     VDPDATA,a6
	lea     cameraX.w,a3
	lea     levelLayout.w,a4
	move.w  #$4000,d2
	bsr.s   sub_202F1A
	lea     cameraBgX.w,a3
	lea     levelLayout+$40.w,a4
	move.w  #$6000,d2
	bra.w   loc_202F42

sub_202F1A:
	moveq   #$FFFFFFF0,d4
	moveq   #$F,d6

loc_202F1E:
	movem.l d4-d6,-(sp)
	moveq   #0,d5
	move.w  d4,d1
	bsr.w   sub_202EB8
	move.w  d1,d4
	moveq   #0,d5
	moveq   #$1F,d6
	bsr.w   loc_202C94
	movem.l (sp)+,d4-d6
	addi.w  #$10,d4
	dbf     d6,loc_202F1E
	rts

loc_202F42:
	moveq   #$FFFFFFF0,d4
	moveq   #$F,d6

loc_202F46:
    movem.l d4-d6/a0,-(sp)
	moveq   #0,d0
	move.b	(timeZone).l,d0
	bclr	#7,d0
	add.w	d0,d0
	add.w	d0,d0
	lea		ScrollSectIDs,a0
	add.w	d0,a0
	move.l	(a0),a0
    adda.w  #1,a0
	move.w  cameraBgY.w,d0
	add.w   d4,d0
	andi.w  #$1F0,d0
	bsr.w   DrawBGBlockRow
	movem.l (sp)+,d4-d6/a0
	addi.w  #$10,d4
	dbf     d6,loc_202F46
	rts
; -------------------------------------------------------------------------
BGSTATIC	EQU	0
BGDYNAMIC1	EQU	2
BGDYNAMIC2	EQU	4
BGDYNAMIC3	EQU	6
BGSECT macro size, id
	dcb.b	(\size)/16, \id
	endm
	
PresentBGCameraSectIDs:    
	BGSECT	16,  BGSTATIC			; Offscreen top row, required to be here
	BGSECT	96,  BGSTATIC			; Clouds
	BGSECT	48,  BGDYNAMIC3			; Mountains
	BGSECT	64,  BGDYNAMIC2			; Waterfalls
	BGSECT	256, BGSTATIC			; Water
PastBGCameraSectIDs:    
	BGSECT	16,  BGSTATIC			; Offscreen top row, required to be here
	BGSECT	96,  BGSTATIC			; Clouds
	BGSECT	64,  BGDYNAMIC3			; Mountains
	BGSECT	48,  BGDYNAMIC2			; Waterfalls
	BGSECT	256, BGSTATIC			; Water
FutureBGCameraSectIDs:    
	BGSECT	16,  BGSTATIC			; Offscreen top row, required to be here
	BGSECT	112,  BGSTATIC			; Clouds
	BGSECT	64,  BGDYNAMIC3			; Mountains
	BGSECT	64,  BGDYNAMIC2			; Waterfalls
	BGSECT	256, BGSTATIC			; Water

BGCameraSects:   
    dc.l $FFF708 
	dc.l $FFF708
	dc.l $FFF710
	dc.l $FFF718

; -------------------------------------------------------------------------

DrawBGBlockRow:
	lsr.w   #4,d0
	move.b  (a0,d0.w),d0
	add.w   d0,d0
	movea.l BGCameraSects(pc,d0.w),a3
	beq.s   loc_202FC4
	moveq   #$FFFFFFF0,d5
	movem.l d4-d5,-(sp)
	bsr.w   sub_202EB8
	movem.l (sp)+,d4-d5
	bsr.w   sub_202C92
	bra.s   locret_202FD8

loc_202FC4:
	moveq   #0,d5
	movem.l d4-d5,-(sp)
	bsr.w   sub_202EBA
	movem.l (sp)+,d4-d5
	moveq   #$1F,d6
	bsr.w   sub_202CBE

locret_202FD8:
	rts

; -------------------------------------------------------------------------

LoadLevelData:
	moveq   #0,d0
	move.b	(timeZone).l,d0
	bclr	#7,d0
	add.w	d0,d0
	add.w	d0,d0
	lea		LevelDataIndexes,a2
	add.w	d0,a2
	move.b	act,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a2
	move.b	zone,d0
	add.w	d0,d0	;	1+1=2
	add.w	d0,d0	;	2+2=4
	move.w	d0,d1
	add.w	d0,d0	;	4+4=8
	add.w	d0,d0	;	8+8=10
	add.w	d0,d0	;	10+10=20
	add.w	d1,d0	;	10+4=24
	add.w	d0,a2
	move.l	(a2),a2

	move.l  a2,-(sp)
	movea.l (a2)+,a0	;	04, art
	move.l  #$40000000,VDPCTRL
	jsr   NemDec
	movea.l (a2)+,a0	;	08, block
	lea     blockBuffer.w,a4
	bsr.w   NemDecToRAM
	movea.l (a2)+,a0	;	0C, chunk
	move.l  a0,LevelChunks
	bsr.w   LoadLevelLayout
	move.w  (a2)+,d0
	move.w  (a2),d0
	andi.w  #$FF,d0
	bsr.w   LoadFadePal
	movea.l (sp)+,a2
	addq.w  #4,a2
	btst    #7,timeZone
	beq.s   loc_203020
	jmp     LoadSectionArt
	
LevelDataIndexes:
	dc.l	Past_LevelDataIndex
	dc.l	Present_LevelDataIndex
	dc.l	Future_LevelDataIndex
	dc.l	Past_LevelDataIndex2
	dc.l	Present_LevelDataIndex2
	dc.l	Future_LevelDataIndex2
	dc.l	Past_LevelDataIndex
	dc.l	Past_LevelDataIndex
	dc.l	LevelDataIndex3
	;R2
	dc.l	Null_LevelDataIndex		;	4
	dc.l	LevelData_LockOn	    ;	8
	dc.l	Null_LevelDataIndex     ;	C
	dc.l	Null_LevelDataIndex     ;	10
	dc.l	Null_LevelDataIndex     ;	14
	dc.l	Null_LevelDataIndex     ;	18
	dc.l	Null_LevelDataIndex     ;	1C
	dc.l	Null_LevelDataIndex     ;	20
	dc.l	Null_LevelDataIndex     ;	24
	;R3
	dc.l	Null_LevelDataIndex
	dc.l	LevelDataIndex_R3
	dc.l	Null_LevelDataIndex
	dc.l	Null_LevelDataIndex
	dc.l	Null_LevelDataIndex
	dc.l	Null_LevelDataIndex
	dc.l	Null_LevelDataIndex
	dc.l	Null_LevelDataIndex
	dc.l	Null_LevelDataIndex
; -------------------------------------------------------------------------

loc_203020:
	moveq   #0,d0
	move.b  (a2),d0
	beq.s   locret_20302A
	bsr.w   LoadPLC

locret_20302A:
	rts

; -------------------------------------------------------------------------

LoadLevelLayout:
	lea     levelLayout.w,a3
	move.w  #$1FF,d1
	moveq   #0,d0

loc_203036:
	move.l  d0,(a3)+
	dbf     d1,loc_203036
	lea     levelLayout.w,a3
	moveq   #0,d1
	bsr.w   sub_20304C
	lea     levelLayout+$40.w,a3
	moveq   #2,d1

sub_20304C:
	moveq   #0,d0
	move.b	timeZone,d0
	lsl.b	#6,d0
	lsr.w	#5,d0
	move.w	d0,d2
	add.w	d0,d0
	add.w	d2,d0
	add.w   d1,d0
	
	moveq   #0,d1
	move.b	act,d1
	lsl.b	#6,d1
	lsr.w	#5,d1
	move.w	d1,d2
	add.w	d1,d1
	add.w	d2,d1
	;add.w   d3,d1
	move.w	d1,d2
	add.w	d2,d1
	add.w	d2,d1
	add.w	d2,d1
	add.w	d1,d0
	moveq   #0,d1
	move.b	zone,d1
	add.b	d1,d1	;	1+1=2
	add.b	d1,d1	;	2+2=4
	add.b	d1,d1	;	4+4=8
	move.b	d1,d2
	add.b	d1,d1	;	8+8=10
	add.b	d1,d1	;	10+10=20
	add.b	d1,d1	;	20+20=40
	add.b	d2,d1	;	40+8=48
	add.w	d1,d0
	lea     (LevelLayoutData).l,a1
	move.w  (a1,d0.w),d0
	lea     (a1,d0.w),a1
	moveq   #0,d1
	move.w  d1,d2
	move.b  (a1)+,d1
	move.b  (a1)+,d2

loc_203066:
	move.w  d1,d0
	movea.l a3,a0

loc_20306A:
	move.b  (a1)+,(a0)+
	dbf     d0,loc_20306A
	lea     $80(a3),a3
	dbf     d2,loc_203066
	rts

; -------------------------------------------------------------------------
; Level events
; -------------------------------------------------------------------------

RunLevelEvents:
	bsr.w   GetPlayerObject     ; Get the player object

	moveq   #0,d0               
	move.b  zone,d0      ; Use zone ID to index into the event table
	add.w   d0,d0
	move.w  .EventIndex(pc,d0.w),d0 ; Run level events
	jsr     .EventIndex(pc,d0.w)

	moveq	#4,d1				; Bottom boundary shift speed
	move.w	destBottomBound.w,d0		; Is the bottom boundary shifting?
	sub.w	bottomBound.w,d0
	beq.s	.End				; If not, branch
	bcc.s	.MoveDown			; If it's scrolling down, branch

	neg.w	d1				; Set the speed to go up
	move.w	cameraY.w,d0			; Is the camera past the target bottom boundary?
	cmp.w	destBottomBound.w,d0
	bls.s	.ShiftUp			; If not, branch
	move.w	d0,bottomBound.w		; Set the bottom boundary to be where the camera id
	andi.w	#$FFFE,bottomBound.w

.ShiftUp:
	add.w	d1,bottomBound.w		; Shift the boundary up
	move.b	#1,btmBoundShift.w		; Mark as shifting

.End:
	rts

.MoveDown:
	move.w	cameraY.w,d0			; Is the camera near the bottom boundary?
	addq.w	#8,d0
	cmp.w	bottomBound.w,d0
	bcs.s	.ShiftDown			; If not, branch
	btst	#1,oFlags(a6)       ; Is the player in the air?
	beq.s	.ShiftDown			; If not, branch
	add.w	d1,d1				; If so, quadruple the shift speed
	add.w	d1,d1

.ShiftDown:
	add.w	d1,bottomBound.w		; Shift the boundary down
	move.b	#1,btmBoundShift.w		; Mark as shifting
	rts

; -------------------------------------------------------------------------

.EventIndex:     
    dc.w LevEvents_R1-.EventIndex       ; Round 1
	dc.w LevEvents_R2-.EventIndex       ; Round 2
	dc.w LevEvents_R3-.EventIndex       ; Round 3
	dc.w LevEvents_Basic-.EventIndex    ; Round 4
	dc.w LevEvents_Basic-.EventIndex    ; Round 5
	dc.w LevEvents_Basic-.EventIndex    ; Round 6
	dc.w LevEvents_Basic-.EventIndex    ; Round 7
	dc.w LevEvents_Basic-.EventIndex    ; Round 8

; -------------------------------------------------------------------------
; Main Level Events for R1 (Salad Plain/Palmtree Panic)  
; -------------------------------------------------------------------------

LevEvents_R1:
	moveq   #0,d0
	move.b  act.l,d0    ; Use act ID as index into table
	add.w   d0,d0
	move.w  .R1Acts(pc,d0.w),d0
	jmp     .R1Acts(pc,d0.w)

.R1Acts:     
    dc.w R1Placeholder-.R1Acts ; Act 1
	dc.w R1Placeholder-.R1Acts ; Act 2
	dc.w R13_DLE-.R1Acts ; Act 3

R1Placeholder:
	move.w  #$310,destBottomBound.w     ; Set bottom boundry
	rts
	
R13_DLE:
	tst.b   bossFlags.w
	bne.s   .SetBossBound
	move.w  #$310,bottomBound.w
	move.w  #$310,destBottomBound.w
	rts

.SetBossBound:
	move.w  #$100,bottomBound.w
	move.w  #$100,destBottomBound.w
	rts

LevEvents_R2:
	move.w  #$4000,destBottomBound.w
	move.w  #$7FFF,rightBound.w   	  ; Set right boundry
	rts

; -------------------------------------------------------------------------
; Main Level Events for R3 (Collision Chaos)  
; -------------------------------------------------------------------------

LevEvents_R3:
	moveq   #0,d0
	move.b  act.l,d0    ; Use act ID as index into table
	add.w   d0,d0
	move.w  .R3Acts(pc,d0.w),d0
	jmp     .R3Acts(pc,d0.w)

.R3Acts:     
    dc.w R3Placeholder-.R3Acts ; Act 1       
	dc.w R3Placeholder-.R3Acts ; Act 2
	dc.w R3Placeholder-.R3Acts ; Act 3

R3Placeholder:
	move.w  #$510,destBottomBound.w     ; Set bottom boundry
	rts

; -------------------------------------------------------------------------
; Very basic, barebones level events for R4 onward
; -------------------------------------------------------------------------

LevEvents_Basic:
	move.w  #$710,destBottomBound.w
	rts

; -------------------------------------------------------------------------
; Process object code
; -------------------------------------------------------------------------

RunObjects:
	lea     objects.w,a0
	moveq   #$7F,d7
	moveq   #0,d0

loc_203144:
	move.b  (a0),d0
	beq.s   loc_20315A
	add.w   d0,d0
	add.w   d0,d0
    lea     ObjectIndex,a1
    movea.l -4(a1,d0.w),a1
	jsr     (a1)
	moveq   #0,d0

loc_20315A:
	lea     $40(a0),a0
	dbf     d7,loc_203144
	rts

; -------------------------------------------------------------------------
; dead code
	moveq   #$1F,d7
	bsr.s   loc_203144
	moveq   #$5F,d7

loc_20316A:
	moveq   #0,d0
	move.b  (a0),d0
	beq.s   loc_20317A
	tst.b   1(a0)
	bpl.s   loc_20317A
	bsr.w   DrawObject

loc_20317A:
	lea     $40(a0),a0
	dbf     d7,loc_20316A
	rts

; -------------------------------------------------------------------------

ObjMoveGrv:
	move.l  oX(a0),d2
	move.l  oY(a0),d3
	move.w  oXVel(a0),d0
	ext.l   d0
	asl.l   #8,d0
	add.l   d0,d2
	move.w  oYVel(a0),d0
	addi.w  #$38,oYVel(a0) ; '8'
	ext.l   d0
	asl.l   #8,d0
	add.l   d0,d3
	move.l  d2,oX(a0)
	move.l  d3,oY(a0)
	rts

; -------------------------------------------------------------------------


ObjMove:
	move.l  oX(a0),d2
	move.l  oY(a0),d3
	move.w  oXVel(a0),d0
	btst    #3,oFlags(a0)
	beq.s   loc_2031EC
	moveq   #0,d1
	move.b  oPlayerStandObj(a0),d1
	lsl.w   #6,d1
	addi.l  #$FFD000,d1
	movea.l d1,a1
	cmpi.b  #$1E,0(a1)
	bne.s   loc_2031EC
	move.w  #$FF00,d1
	btst    #0,$22(a1)
	beq.s   loc_2031EA
	neg.w   d1

loc_2031EA:	 ; CODE XREF: ObjMove+36?j
	add.w   d1,d0

loc_2031EC:	 ; CODE XREF: ObjMove+12?j
		        ; ObjMove+2A?j
	ext.l   d0
	asl.l   #8,d0
	add.l   d0,d2
	move.w  oYVel(a0),d0
	ext.l   d0
	asl.l   #8,d0
	add.l   d0,d3
	move.l  d2,oX(a0)
	move.l  d3,oY(a0)
	rts
; End of function ObjMove


; -------------------------------------------------------------------------


DrawObject:	 

	bclr    #7,oSprFlags(a0)
	move.b  1(a0),d0
	andi.w  #$C,d0
	beq.s   loc_20324E
	move.b  $19(a0),d0
	move.w  oX(a0),d3
	sub.w   cameraX.w,d3
	move.w  d3,d1
	add.w   d0,d1
	bmi.s   locret_20326A
	move.w  d3,d1
	sub.w   d0,d1
	cmpi.w  #$140,d1
	bge.s   locret_20326A
	move.b  oYRadius(a0),d0
	move.w  oY(a0),d3
	sub.w   cameraY.w,d3
	move.w  d3,d1
	add.w   d0,d1
	bmi.s   locret_20326A
	move.w  d3,d1
	sub.w   d0,d1
	cmpi.w  #$E0,d1
	bge.s   locret_20326A

loc_20324E:	 ; CODE XREF: DrawObject+E?j
	lea     objDrawQueue.w,a1
	move.w  $18(a0),d0
	lsr.w   #1,d0
	andi.w  #$380,d0
	adda.w  d0,a1
	cmpi.w  #$7E,(a1) ; '~'
	bcc.s   locret_20326A
	addq.w  #2,(a1)
	adda.w  (a1),a1
	move.w  a0,(a1)

locret_20326A:
	rts

; -------------------------------------------------------------------------

	lea     objDrawQueue.w,a2
	move.w  $18(a1),d0
	lsr.w   #1,d0
	andi.w  #$380,d0
	adda.w  d0,a2
	cmpi.w  #$7E,(a2) ; '~'
	bcc.s   locret_203288
	addq.w  #2,(a2)
	adda.w  (a2),a2
	move.w  a1,(a2)

locret_203288:
	rts

; -------------------------------------------------------------------------


DeleteObject:
	movea.l a0,a1
	moveq   #0,d1
	moveq   #$F,d0

loc_203290:
	move.l  d1,(a1)+
	dbf     d0,loc_203290
	rts

; -------------------------------------------------------------------------

ObjDrawCameras: 
    dc.l 0	  
	dc.l $FFF700
	dc.l $FFF708
	dc.l $FFF718

; -------------------------------------------------------------------------


DrawObjects:	
	lea     sprites.w,a2
	moveq   #0,d5
	lea     objDrawQueue.w,a4
	moveq   #7,d7

LevelLoop:	 
	tst.w   (a4)
	beq.w   NextLevel
	moveq   #2,d6

ObjLoop:	   
	movea.w (a4,d6.w),a0
	tst.b   (a0)
	beq.w   loc_203344
	move.b  1(a0),d0
	move.b  d0,d4
	andi.w  #$C,d0
	beq.s   .ScreenPos
	movea.l ObjDrawCameras(pc,d0.w),a1
	moveq   #0,d0
	move.b  $19(a0),d0
	move.w  oX(a0),d3
	sub.w   (a1),d3
	addi.w  #$80,d3
	moveq   #0,d0
	move.b  oYRadius(a0),d0
	move.w  oY(a0),d2
	sub.w   4(a1),d2
	addi.w  #$80,d2
	bra.s   .DrawSprite
; -------------------------------------------------------------------------

.ScreenPos:
	move.w  $A(a0),d2
	move.w  oX(a0),d3
	bra.s   .DrawSprite

; -------------------------------------------------------------------------
; dead code

	move.w  oY(a0),d2
	sub.w   4(a1),d2
	addi.w  #$80,d2
	cmpi.w  #$60,d2
	bcs.s   loc_203344
	cmpi.w  #$180,d2
	bcc.s   loc_203344

.DrawSprite:
	movea.l 4(a0),a1
	moveq   #0,d1
	btst    #5,d4
	bne.s   loc_20333A
	move.b  oMapFrame(a0),d1
	add.w   d1,d1
	adda.w  (a1,d1.w),a1
	moveq   #0,d1
	move.b  (a1)+,d1
	subq.b  #1,d1
	bmi.s   loc_20333E

loc_20333A:	 ; CODE XREF: DrawObjects+7E?j
	bsr.w   sub_20336E

loc_20333E:	 ; CODE XREF: DrawObjects+90?j
	bset    #7,oSprFlags(a0)

loc_203344:	 ; CODE XREF: DrawObjects+1A?j
		        ; DrawObjects+6C?j ...
	addq.w  #2,d6
	subq.w  #2,(a4)
	bne.w   ObjLoop

NextLevel:	 ; CODE XREF: DrawObjects+E?j
	lea     $80(a4),a4
	dbf     d7,LevelLoop
	move.b  d5,spriteCount.w
	cmpi.b  #$50,d5 ; 'P'
	beq.s   loc_203366
	move.l  #0,(a2)
	rts

loc_203366:
	move.b  #0,-5(a2)
	rts


sub_20336E:
	movea.w 2(a0),a3
	btst    #0,d4
	bne.s   loc_2033B4
	btst    #1,d4
	bne.w   loc_203402

loc_203380:	 ; CODE XREF: sub_20336E+40?j
	cmpi.b  #$50,d5 ; 'P'
	beq.s   locret_2033B2
	move.b  (a1)+,d0
	ext.w   d0
	add.w   d2,d0
	move.w  d0,(a2)+
	move.b  (a1)+,(a2)+
	addq.b  #1,d5
	move.b  d5,(a2)+
	move.b  (a1)+,d0
	lsl.w   #8,d0
	move.b  (a1)+,d0
	add.w   a3,d0
	move.w  d0,(a2)+
	move.b  (a1)+,d0
	ext.w   d0
	add.w   d3,d0
	andi.w  #$1FF,d0
	bne.s   loc_2033AC
	addq.w  #1,d0

loc_2033AC:	 ; CODE XREF: sub_20336E+3A?j
	move.w  d0,(a2)+
	dbf     d1,loc_203380

locret_2033B2:	          ; CODE XREF: sub_20336E+16?j
	rts

loc_2033B4:	 ; CODE XREF: sub_20336E+8?j
	btst    #1,d4
	bne.w   loc_203448

loc_2033BC:	 ; CODE XREF: sub_20336E+8E?j
	cmpi.b  #$50,d5 ; 'P'
	beq.s   locret_203400
	move.b  (a1)+,d0
	ext.w   d0
	add.w   d2,d0
	move.w  d0,(a2)+
	move.b  (a1)+,d4
	move.b  d4,(a2)+
	addq.b  #1,d5
	move.b  d5,(a2)+
	move.b  (a1)+,d0
	lsl.w   #8,d0
	move.b  (a1)+,d0
	add.w   a3,d0
	eori.w  #$800,d0
	move.w  d0,(a2)+
	move.b  (a1)+,d0
	ext.w   d0
	neg.w   d0
	add.b   d4,d4
	andi.w  #$18,d4
	addq.w  #8,d4
	sub.w   d4,d0
	add.w   d3,d0
	andi.w  #$1FF,d0
	bne.s   loc_2033FA
	addq.w  #1,d0

loc_2033FA:	 ; CODE XREF: sub_20336E+88?j
	move.w  d0,(a2)+
	dbf     d1,loc_2033BC

locret_203400:	          ; CODE XREF: sub_20336E+52?j
	rts

loc_203402:	 ; CODE XREF: sub_20336E+E?j
		        ; sub_20336E+D4?j
	cmpi.b  #$50,d5 ; 'P'
	beq.s   locret_203446
	move.b  (a1)+,d0
	move.b  (a1),d4
	ext.w   d0
	neg.w   d0
	lsl.b   #3,d4
	andi.w  #$18,d4
	addq.w  #8,d4
	sub.w   d4,d0
	add.w   d2,d0
	move.w  d0,(a2)+
	move.b  (a1)+,(a2)+
	addq.b  #1,d5
	move.b  d5,(a2)+
	move.b  (a1)+,d0
	lsl.w   #8,d0
	move.b  (a1)+,d0
	add.w   a3,d0
	eori.w  #$1000,d0
	move.w  d0,(a2)+
	move.b  (a1)+,d0
	ext.w   d0
	add.w   d3,d0
	andi.w  #$1FF,d0
	bne.s   loc_203440
	addq.w  #1,d0

loc_203440:	 ; CODE XREF: sub_20336E+CE?j
	move.w  d0,(a2)+
	dbf     d1,loc_203402

locret_203446:	          ; CODE XREF: sub_20336E+98?j
	rts
; -------------------------------------------------------------------------

loc_203448:	 ; CODE XREF: sub_20336E+4A?j
		        ; sub_20336E+128?j
	cmpi.b  #$50,d5 ; 'P'
	beq.s   locret_20349A
	move.b  (a1)+,d0
	move.b  (a1),d4
	ext.w   d0
	neg.w   d0
	lsl.b   #3,d4
	andi.w  #$18,d4
	addq.w  #8,d4
	sub.w   d4,d0
	add.w   d2,d0
	move.w  d0,(a2)+
	move.b  (a1)+,d4
	move.b  d4,(a2)+
	addq.b  #1,d5
	move.b  d5,(a2)+
	move.b  (a1)+,d0
	lsl.w   #8,d0
	move.b  (a1)+,d0
	add.w   a3,d0
	eori.w  #$1800,d0
	move.w  d0,(a2)+
	move.b  (a1)+,d0
	ext.w   d0
	neg.w   d0
	add.b   d4,d4
	andi.w  #$18,d4
	addq.w  #8,d4
	sub.w   d4,d0
	add.w   d3,d0
	andi.w  #$1FF,d0
	bne.s   loc_203494
	addq.w  #1,d0

loc_203494:	 ; CODE XREF: sub_20336E+122?j
	move.w  d0,(a2)+
	dbf     d1,loc_203448

locret_20349A:	          ; CODE XREF: sub_20336E+DE?j
	rts
; End of function sub_20336E

; -------------------------------------------------------------------------
; dead code
	move.w  oX(a0),d0
	sub.w   cameraX.w,d0
	bmi.s   loc_2034C0
	cmpi.w  #$140,d0
	bge.s   loc_2034C0
	move.w  oY(a0),d1
	sub.w   cameraY.w,d1
	bmi.s   loc_2034C0
	cmpi.w  #$E0,d1
	bge.s   loc_2034C0
	moveq   #0,d0
	rts
; -------------------------------------------------------------------------

loc_2034C0:	 ; CODE XREF: ROM:002034A4?j
		        ; ROM:002034AA?j ...
	moveq   #1,d0
	rts
; -------------------------------------------------------------------------
	moveq   #0,d1
	move.b  $19(a0),d1
	move.w  oX(a0),d0
	sub.w   cameraX.w,d0
	add.w   d1,d0
	bmi.s   .Offscreen
	add.w   d1,d1
	sub.w   d1,d0
	cmpi.w  #$140,d0
	bge.s   .Offscreen
	move.w  oY(a0),d1
	sub.w   cameraY.w,d1
	bmi.s   .Offscreen
	cmpi.w  #$E0,d1
	bge.s   .Offscreen
	moveq   #0,d0
	rts
; -------------------------------------------------------------------------

.Offscreen:
	moveq   #1,d0
	rts

; -------------------------------------------------------------------------
; Main Object Index list
; Uses the current object "ID" as an index into this pointer table to grab
; each object's specific code.
; -------------------------------------------------------------------------

ObjectIndex:    
	dc.l ObjSonic           ; 01 - Sonic Player 1
	dc.l ObjSonic           ; 02 - Sonic Player 2
	dc.l ObjPowerup         ; 03 - Powerup
	dc.l ObjWaterfall       ; 04 - Unused (broken?) Waterfall Generator
	dc.l ObjUnkDemolishSwitch ; 05 - Unknown switch, spawns the layout demolition object
	dc.l ObjTestBadnik      ; 06 - Unused (test?) Badnik
	dc.l ObjSpinTunnel      ; 07 - Spin Tunnel (seems preliminary)
	dc.l ObjLayoutDemolish  ; 08 - Unused Layout Demolition Object
	dc.l ObjRotPlatform     ; 09 - Rotating Platform
	dc.l ObjSpring          ; 0A - Spring
	dc.l ObjWaterSplash     ; 0B - Water splash
	dc.l ObjFlapDoor_ChkCollision ; 0C - Unknown, seems like a broken address pointer or something.
	dc.l ObjFlapDoorH       ; 0D - Horizontal Trapdoor
	dc.l ObjWaterfallSplash ; 0E - Waterfall Splash
	dc.l ObjMovingSpring    ; 0F - Moving Spring
	dc.l ObjRing			; 10 - Rings
	dc.l ObjLostRing        ; 11 - Ring loss
	dc.l ObjSmallPlatform   ; 12 - Small Platform
	dc.l ObjMosqui          ; 13 - Moqui
	dc.l ObjPataBata        ; 14 - PataBata
	dc.l ObjAnton           ; 15  - Anton
	dc.l ObjTagaTaga        ; 16 - Tagataga
	dc.l ObjYouSay          ; 17  - Signpost (You Say!)
	dc.l ObjExplosion       ; 16 - Explosions
	dc.l ObjMonitor         ; 19 - Monitor
	dc.l ObjMonitorContents ; 1A - Monitor content
	dc.l ObjGrayRock        ; 1B - Gray solid rock
	dc.l ObjHUD 			; 1C - Heads up display
	dc.l ObjNull			; 1D - Null
	dc.l ObjNull			; 1E - Null, but lines up with the R3 pinball flipper object
	dc.l ObjFlower          ; 1F - Flower object
	dc.l ObjCollapsingPlatform ; 20 - Collapsing platforms
	dc.l ObjFloatingPlatform   ; 21 - Floating platforms
	dc.l ObjTamabboh        ; 22 - Tamabboh
	dc.l ObjUnkMissile      ; 23 - Unknown, but said to be a missile handler?
	dc.l ObjAnimal          ; 24 - Animals/Flickies
	dc.l ObjNull			; 25 - Null, but would point to the unreferenced bridge object
	dc.l ObjSpikes          ; 26 - Spikes that hurt you because they're spikes you fucking idiot
	dc.l ObjUnusedFlipPlatform ; 27 - Unused flipping platform
	dc.l ObjSpringBoard     ; 28 - Springboard
	dc.l ObjUnusedMovingPForm ; 29 - Unused Tidal Tempest-esque moving platform
	dc.l objBossMain
	dc.l objBossBody
	dc.l objBossThighs
	dc.l objBossLeg
	dc.l objBossFeet
	dc.l objBossShoulders
	dc.l objBossUpperArm
	dc.l objBossLowerArm
	dc.l objBossHands
	dc.l objBossPincers
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull
	dc.l ObjNull

; -------------------------------------------------------------------------
; Default "nulled" object program
; Used in the place of unimplemented, removed, or empty slots in the table
; -------------------------------------------------------------------------

ObjNull:
	move.b  #0,(a0)
	rts

; -------------------------------------------------------------------------
; Check Sonic's bored timer and 
; -------------------------------------------------------------------------

ObjSonic_ChkBoredom:
	lea     boredTimer.w,a1
	cmpi.b  #1,0(a0)
	beq.s   loc_2035B2
	lea     boredTimerP2.w,a1

loc_2035B2:
	cmpi.b  #5,oAnim(a0)
	beq.s   loc_2035C0
	move.w  #0,(a1)
	rts
; -------------------------------------------------------------------------

loc_2035C0:	 ; CODE XREF: ObjSonic_ChkBoredom+16?j
	tst.w   (a1)
	bne.s   loc_2035CA
	move.b  #1,1(a1)

loc_2035CA:	 ; CODE XREF: ObjSonic_ChkBoredom+20?j
	cmpi.w  #$2A30,(a1)
	bcs.s   locret_2035F8
	move.w  #0,(a1)
	move.b  #$2B,oAnim(a0) ; '+'
	move.w  #$FB00,oYVel(a0)
	move.w  #$100,oXVel(a0)
	btst    #0,oFlags(a0)
	beq.s   loc_2035F2
	neg.w   oXVel(a0)

loc_2035F2:	 ; CODE XREF: ObjSonic_ChkBoredom+4A?j
	move.w  #0,$14(a0)

locret_2035F8:	          ; CODE XREF: ObjSonic_ChkBoredom+2C?j
	rts
; End of function ObjSonic_ChkBoredom


; -------------------------------------------------------------------------


sub_2035FA:	 ; CODE XREF: ObjSonic:loc_203676?p
	move.w  p2CtrlData.w,d0
	moveq   #2,d1
	lea     boredTimerP2.w,a4
	lea     objPlayerSlot.w,a5
	lea     objPlayerSlot2.w,a6
	tst.b   usePlayer2
	beq.s   loc_203626
	move.w  p1CtrlData.w,d0
	moveq   #1,d1
	lea     boredTimer.w,a4
	lea     objPlayerSlot2.w,a5
	lea     objPlayerSlot.w,a6

loc_203626:	 ; CODE XREF: sub_2035FA+18?j
	tst.b   0(a6)
	bne.s   locret_20365E
	andi.b  #$F0,d0
	beq.s   locret_20365E
	move.b  d1,0(a6)
	move.b  $22(a5),$22(a6)
	move.l  $C(a5),$C(a6)
	move.l  8(a5),8(a6)
	move.w  $12(a5),$12(a6)
	move.w  $10(a5),$10(a6)
	move.w  $14(a5),$14(a6)
	move.w  #0,(a4)

locret_20365E:	          ; CODE XREF: sub_2035FA+30?j
		        ; sub_2035FA+36?j
	rts
; End of function sub_2035FA


; -------------------------------------------------------------------------
; The beginning of Sonic's main object code, which controls all gameplay
; -------------------------------------------------------------------------

ObjSonic:
	move.b  $2A(a0),d0
	beq.s   loc_203676
	addq.b  #1,d0
	cmpi.b  #$3C,d0
	bcs.s   loc_203672
	move.b  #$3C,d0 

loc_203672:	 ; CODE XREF: ObjSonic+C?j
	move.b  d0,$2A(a0)

loc_203676:	 ; CODE XREF: ObjSonic+4?j
	bsr.s   sub_2035FA
	clr.b   $29(a0)
	moveq   #0,d0
	move.b  0(a0),d0
	subq.b  #1,d0
	cmp.b   usePlayer2,d0
	bne.s   .RunRoutines
	move.b  #1,$29(a0)

.RunRoutines:	           ; CODE XREF: ObjSonic+2A?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  .Index(pc,d0.w),d1
	jmp     .Index(pc,d1.w)

; -------------------------------------------------------------------------

.Index:         
	dc.w ObjSonic_Init-.Index
	dc.w ObjSonic_Main-.Index
	dc.w ObjSonic_Hurt-.Index
	dc.w ObjSonic_Dead-.Index
	dc.w ObjSonic_Restart-.Index

; -------------------------------------------------------------------------
; Unusual, dead routine that just gives sonic a shield.
; Its position relative to ObjSonic_MakeTimeWarpStars might imply it's
; an earlier version of that subroutine
; -------------------------------------------------------------------------

	tst.b   $29(a0)
	beq.s   .End
	move.b  #1,shield
	move.b  #3,objShieldSlot.w

.End:
	rts

; -------------------------------------------------------------------------
; Create time warp animation stars
; -------------------------------------------------------------------------

ObjSonic_MakeTimeWarpStars:
	tst.b   objTimeStar1Slot.w
	bne.s   .End
	tst.b   $29(a0)
	beq.s   .End
	move.b  #1,timeWarp
	move.b  #3,objTimeStar1Slot.w
	move.b  #5,objTimeStar1Slot+oAnim.w
	move.b  #3,objTimeStar2Slot.w
	move.b  #6,objTimeStar2Slot+oAnim.w
	move.b  #3,objTimeStar3Slot.w
	move.b  #7,objTimeStar3Slot+oAnim.w
	move.b  #3,objTimeStar4Slot.w
	move.b  #8,objTimeStar4Slot+oAnim.w

.End:    
	rts

; -------------------------------------------------------------------------
; ???
	rts

; -------------------------------------------------------------------------

ObjSonic_Init:
	addq.b  #2,oRoutine(a0)
	move.b  #$13,oYRadius(a0)
	move.b  #9,oXRadius(a0)
	tst.b   miniSonic.w
	beq.s   .NotMini
	move.b  #$A,oYRadius(a0)
	move.b  #5,oXRadius(a0)

.NotMini:
	move.l  #MapSpr_Sonic,4(a0)
	move.w  #$780,2(a0)
	cmpi.b  #1,0(a0)
	beq.s   .IsPlayer1
	move.w  #$797,2(a0)

.IsPlayer1:
	move.b  #2,$18(a0)
	move.b  #$18,$19(a0)
	move.b  #4,oSprFlags(a0)
	move.w  #$600,sonicTopSpeed.w
	move.w  #$C,sonicAcceleration.w
	move.w  #$80,sonicDeceleration.w

; -------------------------------------------------------------------------


sub_20376A:
	tst.b   zone
	bne.s   locret_weird

	move.b  levelFrames+1,d0
	andi.b  #3,d0
	bne.s   locret_weird

	move.b  oYRadius(a0),d2
	ext.w   d2
	add.w   oY(a0),d2
	move.w  oX(a0),d3
	bsr.w   ObjSonic_GetChunkAtPos
	cmpi.b  #$2F,d1
	bne.s   contsub_20376A
	cmpi.w  #$15C0,oX(a0)
	bcc.s   locret_weird

	tst.b   $2C(a0)
	beq.s   locret_weird
	jsr     FindObjSlot
	bne.s   locret_weird

	move.b  #$E,0(a1)
	move.w  oX(a0),8(a1)
	move.w  oY(a0),$C(a1)
	moveq   #1,d0
	tst.w   oXVel(a0)
	bmi.s   loc_2037C8
	moveq   #0,d0

loc_2037C8:
	move.b  d0,1(a1)
	move.b  d0,$22(a1)

locret_weird:
	rts

contsub_20376A:
	rts	     
	; dead code
	move.b  oYRadius(a0),d2
	ext.w   d2
	add.w   oY(a0),d2
	cmpi.b  #$10,d1
	bne.s   loc_2037F2
	cmpi.w  #$210,d2
	bcc.s   locret_weird
	cmpi.w  #$208,d2
	bcs.s   locret_weird
	bra.s   loc_203804

loc_2037F2:
	cmpi.b  #$21,d1
	bne.s   locret_weird
	cmpi.w  #$2A0,d2
	bcc.s   locret_weird
	cmpi.w  #$298,d2
	bcs.s   locret_weird

loc_203804:
	tst.w   $14(a0)
	beq.s   locret_weird
	jsr     FindObjSlot
	bne.s   locret_weird
	move.b  #$B,0(a1)
	move.w  oX(a0),8(a1)
	andi.w  #$FFF8,d2
	move.w  d2,$C(a1)
	move.b  #1,$28(a1)
	move.w  $14(a0),d0
	bpl.s   loc_203834
	neg.w   d0

loc_203834:
	cmpi.w  #$600,d0
	bcc.s   loc_203840
	move.b  #2,$28(a1)

loc_203840:
;	move.w  #$A1,d0
;	jmp     PlayFMSound		;	dead, ignore

; -------------------------------------------------------------------------

ObjSonic_GetChunkAtPos:
	move.w  d2,d0
	lsr.w   #1,d0
	andi.w  #$380,d0
	move.w  d3,d1
	lsr.w   #8,d1
	andi.w  #$7F,d1
	add.w   d1,d0
	lea		LevelChunks,a1	;	(pointer's now RAM)
	move.l  (a1),d1			;	(pointer's now RAM)
	lea     levelLayout.w,a1
	move.b  (a1,d0.w),d1
	andi.b  #$7F,d1
	rts
; End of function ObjSonic_GetChunkAtPos


; -------------------------------------------------------------------------

ObjSonic_Null:
	cmpi.b  #2,zone
	beq.s   Player_LevelColInAir
	rts

; -------------------------------------------------------------------------

Player_LevelColInAir:	   ; CODE XREF: ObjSonic_Null+8?j
	move.w  oXVel(a0),d1
	move.w  oYVel(a0),d2
	jsr     CalcAngle
	subi.b  #$20,d0 ; ' '
	andi.b  #$C0,d0
	cmpi.b  #$40,d0 ; '.'
	beq.w   loc_203960
	cmpi.b  #$80,d0
	beq.w   loc_2038E6
	cmpi.b  #$C0,d0
	beq.w   loc_203922
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	move.b  oYRadius(a0),d0
	ext.w   d0
	add.w   d0,d2
	move.b  oXRadius(a0),d0
	ext.w   d0
	sub.w   d0,d3
	bsr.w   ObjSonic_CheckCCZBlock
	bne.s   locret_2038E4
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	move.b  oYRadius(a0),d0
	ext.w   d0
	add.w   d0,d2
	move.b  oXRadius(a0),d0
	ext.w   d0
	add.w   d0,d3
	bra.w   ObjSonic_CheckCCZBlock
; -------------------------------------------------------------------------

locret_2038E4:	          ; CODE XREF: ObjSonic_Null+56?j
	rts
; -------------------------------------------------------------------------

loc_2038E6:	 ; CODE XREF: ObjSonic_Null+2E?j
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	move.b  oYRadius(a0),d0
	ext.w   d0
	sub.w   d0,d2
	move.b  oXRadius(a0),d0
	ext.w   d0
	sub.w   d0,d3
	bsr.w   ObjSonic_CheckCCZBlock
	bne.s   locret_203920
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	move.b  oYRadius(a0),d0
	ext.w   d0
	sub.w   d0,d2
	move.b  oXRadius(a0),d0
	ext.w   d0
	add.w   d0,d3
	bra.w   ObjSonic_CheckCCZBlock
; -------------------------------------------------------------------------

locret_203920:	          ; CODE XREF: ObjSonic_Null+92?j
	rts
; -------------------------------------------------------------------------

loc_203922:	 ; CODE XREF: ObjSonic_Null+36?j
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	move.b  oXRadius(a0),d0
	ext.w   d0
	add.w   d0,d3
	move.b  oYRadius(a0),d0
	subq.b  #6,d0
	ext.w   d0
	sub.w   d0,d2
	bsr.w   ObjSonic_CheckCCZBlock
	bne.s   locret_20395E
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	move.b  oXRadius(a0),d0
	ext.w   d0
	add.w   d0,d3
	move.b  oYRadius(a0),d0
	ext.w   d0
	add.w   d0,d2
	bra.w   ObjSonic_CheckCCZBlock
; -------------------------------------------------------------------------

locret_20395E:
	rts
; -------------------------------------------------------------------------

loc_203960:
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	move.b  oXRadius(a0),d0
	ext.w   d0
	sub.w   d0,d3
	move.b  oYRadius(a0),d0
	subq.b  #6,d0
	ext.w   d0
	sub.w   d0,d2
	bsr.w   ObjSonic_CheckCCZBlock
	bne.s   locret_20399C
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	move.b  oXRadius(a0),d0
	ext.w   d0
	sub.w   d0,d3
	move.b  oYRadius(a0),d0
	ext.w   d0
	add.w   d0,d2
	bra.w   ObjSonic_CheckCCZBlock

locret_20399C:
	rts

ObjSonic_CheckCCZBlock:
	jsr     GetLevelBlock
	move.w  (a1),d0
	move.w  d0,d4
	andi.w  #$7FF,d0
	beq.s   loc_2039DE
	moveq   #0,d1
	move.b  timeZone,d1
	cmpi.b  #2,d1
	bne.s   loc_2039C2
	add.b   goodFuture,d1

loc_2039C2:
	add.w   d1,d1
	move.w  CCZGlassBlockIDs(pc,d1.w),d1
	lea     CCZGlassBlockIDs(pc,d1.w),a1
	moveq   #0,d6
	move.w  (a1)+,d6
	moveq   #0,d1

loc_2039D2:
	cmp.w   (a1,d1.w),d0
	beq.s   loc_203A56
	addq.w  #2,d1
	dbf     d6,loc_2039D2

loc_2039DE:
	moveq   #0,d0
	rts
; -------------------------------------------------------------------------

CCZGlassBlockIDs:     
	dc.w word_2039C2-CCZGlassBlockIDs
	dc.w word_2039A0-CCZGlassBlockIDs
	dc.w word_2039EA-CCZGlassBlockIDs
	dc.w word_2039C8-CCZGlassBlockIDs
word_2039A0:    dc.w $F		  
	dc.w $13C
	dc.w $146
	dc.w $19B
	dc.w $1AE
	dc.w $83
	dc.w $84
	dc.w $89
	dc.w $8A
	dc.w $77
	dc.w $76
	dc.w $80
	dc.w $7F
	dc.w $7E
	dc.w $7D
	dc.w $7C
	dc.w $82
word_2039C2:    dc.w 1			
	dc.w $145
	dc.w $146
word_2039C8:    dc.w $F		   
	dc.w $13C
	dc.w $146
	dc.w 0
	dc.w 0
	dc.w $83
	dc.w $84
	dc.w $89
	dc.w $8A
	dc.w $77
	dc.w $76
	dc.w $80
	dc.w $7F
	dc.w $7E
	dc.w $7D
	dc.w $7C
	dc.w $82
word_2039EA:    dc.w $F		   
	dc.w $13C
	dc.w $146
	dc.w $165
	dc.w 0
	dc.w $83
	dc.w $84
	dc.w $89
	dc.w $8A
	dc.w $77
	dc.w $76
	dc.w $80
	dc.w $7F
	dc.w $7E
	dc.w $7D
	dc.w $7C
	dc.w $82

; -------------------------------------------------------------------------

loc_203A56:                             ; CODE XREF: sub_20399E+38↑j
    move.b  #0,cczNoBumper
    move.w  off_203A76(pc,d1.w),d0
    jsr     off_203A76(pc,d0.w)
    tst.b   cczNoBumper
    beq.s   loc_203A72
    moveq   #0,d0
    rts

loc_203A72:

	moveq   #1,d0
	rts


; -------------------------------------------------------------------------
off_203A76:     
	dc.w loc_203A96-off_203A76
	dc.w loc_203A96-off_203A76
	dc.w loc_203B24-off_203A76
	dc.w loc_203B24-off_203A76
	dc.w loc_203CBA-off_203A76
	dc.w loc_203B76-off_203A76
	dc.w loc_203B88-off_203A76
	dc.w loc_203B88-off_203A76
	dc.w loc_203C96-off_203A76
	dc.w loc_203BEE-off_203A76
	dc.w loc_203BEE-off_203A76
	dc.w loc_203BEE-off_203A76
	dc.w loc_203BD2-off_203A76
	dc.w loc_203B76-off_203A76
	dc.w loc_203B76-off_203A76
	dc.w loc_203B9A-off_203A76
; -------------------------------------------------------------------------

loc_203A96:	 ; DATA XREF: ROM:off_203A76?o
		        ; ROM:00203A78?o
	andi.w  #$FFF0,d2
	tst.b   d1
	bne.s   loc_203AA2
	addi.w  #$10,d2

loc_203AA2:	 ; CODE XREF: ROM:00203A9C?j
	andi.w  #$FFF0,d3
	btst    #$B,d4
	bne.s   loc_203AB0
	addi.w  #$10,d3

loc_203AB0:	 ; CODE XREF: ROM:00203AAA?j
	move.w  d3,d1
	movem.l d1-d2,-(sp)
	sub.w   oX(a0),d1
	sub.w   oY(a0),d2
	jsr     CalcAngle
	jsr     CalcSine
	muls.w  #$F900,d1
	asr.l   #8,d1
	move.w  d1,oXVel(a0)
	muls.w  #$F900,d0
	asr.l   #8,d0
	move.w  d0,oYVel(a0)
	bset    #1,oFlags(a0)
	bclr    #4,oFlags(a0)
	bclr    #5,oFlags(a0)
	clr.b   $3C(a0)
	movem.l (sp)+,d1-d2
	move.w  d2,d4
	move.w  d1,d5
	move.w  #0,d3
	jsr     DrawBlockAtPos
	subi.w  #$10,d5
	jsr     DrawBlockAtPos
	subi.w  #$10,d4
	jsr     DrawBlockAtPos
	addi.w  #$10,d5
	jmp     DrawBlockAtPos
; -------------------------------------------------------------------------

loc_203B24:	 ; DATA XREF: ROM:00203A7A?o
		        ; ROM:00203A7C?o
	andi.w  #$FFF0,d2
	addq.w  #8,d2
	andi.w  #$FFF0,d3
	addq.w  #8,d3
	move.w  d3,d1
	sub.w   oX(a0),d1
	sub.w   oY(a0),d2
	jsr     CalcAngle
	jsr     CalcSine
	muls.w  #$F900,d1
	asr.l   #8,d1
	asr.l   #1,d1
	move.w  d1,oXVel(a0)
	muls.w  #$F900,d0
	asr.l   #8,d0
	asr.l   #1,d0
	move.w  d0,oYVel(a0)

loc_203B5E:	 ; CODE XREF: ROM:00203B86?j
		        ; ROM:00203B98?j ...
	bset    #1,oFlags(a0)
	bclr    #4,oFlags(a0)
	bclr    #5,oFlags(a0)
	clr.b   $3C(a0)
	rts
; -------------------------------------------------------------------------

loc_203B76:	 ; CODE XREF: ROM:00203BE4?j
		        ; ROM:00203BEA?j ...
	move.w  #$700,d0
	tst.w   oYVel(a0)
	bmi.s   loc_203B82
	neg.w   d0

loc_203B82:	 ; CODE XREF: ROM:00203B7E?j
	move.w  d0,oYVel(a0)
	bra.s   loc_203B5E
; -------------------------------------------------------------------------

loc_203B88:	 ; CODE XREF: ROM:00203BE2?j
		        ; ROM:00203BEC?j ...
	move.w  #$700,d0
	tst.w   oXVel(a0)
	bmi.s   loc_203B94
	neg.w   d0

loc_203B94:	 ; CODE XREF: ROM:00203B90?j
	move.w  d0,oXVel(a0)
	bra.s   loc_203B5E
; -------------------------------------------------------------------------

loc_203B9A:	 ; CODE XREF: ROM:00203CCE?j
		        ; ROM:00203CD6?j ...
	andi.w  #$FFF0,d2
	addq.w  #8,d2
	andi.w  #$FFF0,d3
	addq.w  #8,d3
	move.w  d3,d1
	sub.w   oX(a0),d1
	sub.w   oY(a0),d2
	jsr     CalcAngle
	jsr     CalcSine
	muls.w  #$F900,d1
	asr.l   #8,d1
	move.w  d1,oXVel(a0)
	muls.w  #$F900,d0
	asr.l   #8,d0
	move.w  d0,oYVel(a0)
	bra.s   loc_203B5E
; -------------------------------------------------------------------------

loc_203BD2:	 ; DATA XREF: ROM:00203A8E?o
	move.w  d3,d1
	andi.w  #$F,d1
	cmpi.b  #8,d1
	bcc.s   loc_203BE6
	btst    #$B,d4
	bne.s   loc_203B88
	bra.s   loc_203B76
; -------------------------------------------------------------------------

loc_203BE6:	 ; CODE XREF: ROM:00203BDC?j
	btst    #$B,d4
	bne.s   loc_203B76
	bra.s   loc_203B88
; -------------------------------------------------------------------------

loc_203BEE:	 ; CODE XREF: ROM:00203CAA?j
		        ; ROM:00203CB6?j
		        ; DATA XREF: ...
	subi.w  #$12,d1
	bmi.s   loc_203C20
	move.w  byte_203C60(pc,d1.w),d0
	lea     byte_203C60(pc,d0.w),a1
	andi.w  #$F,d2
	andi.w  #$F,d3
	btst    #$B,d4
	bne.s   loc_203C10
	neg.b   d3
	addi.b  #$F,d3

loc_203C10:	 ; CODE XREF: ROM:00203C08?j
	cmp.b   (a1,d3.w),d2
	bcc.s   loc_203C20
	move.b  #1,cczNoBumper.l
	rts
; -------------------------------------------------------------------------

loc_203C20:	 ; CODE XREF: ROM:00203BF2?j
		        ; ROM:00203C14?j
	move.w  oXVel(a0),d1
	move.w  oYVel(a0),d2
	jsr     CalcAngle
	addi.b  #-$80,d0
	neg.b   d0
	subi.b  #$20,d0 ; ' '
	btst    #$B,d4
	beq.s   loc_203C42
	addi.b  #$40,d0 ; '.'

loc_203C42:	 ; CODE XREF: ROM:00203C3C?j
	jsr     CalcSine
	muls.w  #$F900,d1
	asr.l   #8,d1
	move.w  d1,oXVel(a0)
	muls.w  #$F900,d0
	asr.l   #8,d0
	move.w  d0,oYVel(a0)
	bra.w   loc_203B5E
; -------------------------------------------------------------------------
byte_203C60:    dc.b    0,   6,   0, $16,   0, $26,   1,   1
		        ; DATA XREF: ROM:00203BF4?r
		        ; ROM:00203BF8?o
	dc.b    1,   2,   2,   2,   3,   3,   3,   4
	dc.b    4,   4,   5,   5,   5,   6,   6,   6
	dc.b    7,   7,   7,   8,   8,   8,   9,   9
	dc.b    9,  $A,  $A,  $A,  $B,  $B,  $B,  $C
	dc.b   $C,  $C,  $D,  $D,  $D,  $E,  $E,  $E
	dc.b   $F,  $F,  $F, $10, $10, $10
; -------------------------------------------------------------------------

loc_203C96:	 ; DATA XREF: ROM:00203A86?o
	move.w  d3,d1
	andi.w  #$F,d1
	cmpi.b  #8,d1
	bcc.s   loc_203CAE
	btst    #$B,d4
	bne.w   loc_203B88
	bra.w   loc_203BEE
; -------------------------------------------------------------------------

loc_203CAE:	 ; CODE XREF: ROM:00203CA0?j
	btst    #$B,d4
	bne.w   loc_203B76
	bra.w   loc_203BEE
; -------------------------------------------------------------------------

loc_203CBA:	 ; DATA XREF: ROM:00203A7E?o
	move.w  d3,d1
	andi.w  #$F,d1
	cmpi.b  #8,d1
	bcc.s   loc_203CD2
	btst    #$B,d4
	bne.w   loc_203B76
	bra.w   loc_203B9A
; -------------------------------------------------------------------------

loc_203CD2:	 ; CODE XREF: ROM:00203CC4?j
	btst    #$B,d4
	bne.w   loc_203B9A
	bra.w   loc_203B76
; -------------------------------------------------------------------------
	move.w  d2,d1
	andi.w  #$F,d1
	cmpi.b  #8,d1
	bcc.s   loc_203CF6
	btst    #$C,d4
	bne.w   loc_203B88
	bra.w   loc_203B9A
; -------------------------------------------------------------------------

loc_203CF6:	 ; CODE XREF: ROM:00203CE8?j
	btst    #$C,d4
	bne.w   loc_203B9A
	bra.w   loc_203B88
; -------------------------------------------------------------------------

ObjSonic_Main:	          ; DATA XREF: ROM:002036A2?o
	bsr.w   sub_20376A
	tst.w   debugCheat
	beq.s   .DebugEnabled
	tst.w   debugMode
	bne.w   DebugObjectPlacement
	btst    #4,p1CtrlTap.w
	beq.s   .DebugEnabled
	move.b  #1,debugMode
	rts
; -------------------------------------------------------------------------

.DebugEnabled:	   ; CODE XREF: ROM:00203D0C?j
		        ; ROM:00203D14?j
	tst.b   ctrlLocked.w
	bne.s   .CtrlLock
	move.w  p1CtrlData.w,playerCtrl.w
	cmpi.b  #1,0(a0)
	beq.s   .CtrlLock
	move.w  p2CtrlData.w,playerCtrl.w

.CtrlLock:	  ; CODE XREF: ROM:00203D24?j
		        ; ROM:00203D32?j
	btst    #0,$2C(a0)
	bne.s   loc_203D58
	moveq   #0,d0
	move.b  oFlags(a0),d0
	andi.w  #6,d0
	move.w  ObjSonic_ModeIndex(pc,d0.w),d1
	jsr     ObjSonic_ModeIndex(pc,d1.w)
	bsr.w   ObjSonic_Null

loc_203D58:	 ; CODE XREF: ROM:00203D40?j
	bsr.s   ObjSonic_Display
	tst.b   $29(a0)
	beq.s   loc_203D64
	bsr.w   ObjSonic_RecordPos

loc_203D64:	 ; CODE XREF: ROM:00203D5E?j
	move.b  primaryAngle.w,$36(a0)
	move.b  secondaryAngle.w,$37(a0)
	tst.b   unkAnimFlag.w
	beq.s   loc_203D82
	tst.b   oAnim(a0)
	bne.s   loc_203D82
	move.b  $1D(a0),oAnim(a0)

loc_203D82:	 ; CODE XREF: ROM:00203D74?j
		        ; ROM:00203D7A?j
	bsr.w   ObjSonic_Animate
	tst.b   $2C(a0)
	bmi.s   loc_203D92
	jsr     Player_ObjCollide

loc_203D92:	 ; CODE XREF: ROM:00203D8A?j
	bsr.w   sub_204E62
	bsr.w   sub_203E60
	rts
; -------------------------------------------------------------------------

ObjSonic_ModeIndex:
	dc.w ObjSonic_MdGround-ObjSonic_ModeIndex
	dc.w ObjSonic_MdAir-ObjSonic_ModeIndex
	dc.w ObjSonic_MdRoll-ObjSonic_ModeIndex
	dc.w ObjSonic_MdJump-ObjSonic_ModeIndex

; -------------------------------------------------------------------------


ObjSonic_Display:	       ; CODE XREF: ROM:loc_203D58?p
	cmpi.w  #$D2,timeWarpTimer.w
	bcc.s   .SkipDisplay
	move.w  $30(a0),d0
	beq.s   .NotFlashing
	subq.w  #1,$30(a0)
	lsr.w   #3,d0
	bcc.s   .SkipDisplay

.NotFlashing:	           ; CODE XREF: ObjSonic_Display+C?j
	tst.b   $29(a0)
	bne.s   .Display
	btst    #0,levelVIntCounter+3
	beq.s   .SkipDisplay

.Display:	   ; CODE XREF: ObjSonic_Display+1A?j
	jsr     DrawObject

.SkipDisplay:

	tst.b   invincible
	beq.s   NotInvincible
	tst.w   $32(a0)
	beq.s   NotInvincible
	subq.w  #1,$32(a0)
	bne.s   NotInvincible
	tst.b   bossActive.w
	bne.s   StopInvinc
	cmpi.w  #$C,drownTimer
	bcs.s   StopInvinc
	moveq   #0,d0
	move.b  timeZone,d0
;	cmpi.w  #$103,zone 	; This check is a leftover from Sonic 1, to check if the level is Labyrinth 
		   				; Zone act 4 and to play Scrap Brain's music.
;	bne.s   loc_203E0E
;	moveq   #5,d0

loc_203E0E:
	lea     (LevelMusicIDs_S1).l,a1
	move.b  (a1,d0.w),d0
	jsr     PlayFMSound

StopInvinc:
	move.b  #0,invincible

NotInvincible:
	tst.b   speedShoes
	beq.s   locret_203E5E
	tst.w   $34(a0)
	beq.s   locret_203E5E
	subq.w  #1,$34(a0)
	bne.s   locret_203E5E
	move.w  #$600,sonicTopSpeed.w
	move.w  #$C,sonicAcceleration.w
	move.w  #$80,sonicDeceleration.w
	move.b  #0,speedShoes
	move.w  #$E3,d0
	jmp     PlayFMSound

locret_203E5E:	         
	rts


sub_203E60:
	tst.b   $29(a0)
	bne.s   locret_203EA2
	move.w  cameraX.w,d0
	subi.w  #$80,d0
	bcs.s   loc_203E78
	cmp.w   oX(a0),d0
	bhi.w   DeleteObject

loc_203E78:
	addi.w  #$240,d0
	cmp.w   oX(a0),d0
	blt.w   DeleteObject
	move.w  cameraY.w,d0
	subi.w  #$60,d0 ; '`'
	bcs.s   loc_203E96
	cmp.w   oY(a0),d0
	bhi.w   DeleteObject

loc_203E96:
	addi.w  #$180,d0
	cmp.w   oY(a0),d0
	blt.w   DeleteObject

locret_203EA2: 
	rts

; -------------------------------------------------------------------------

ObjSonic_RecordPos:	
	move.w  sonicRecordIndex.w,d0
	lea     sonicRecordBuf.w,a1
	lea     (a1,d0.w),a1
	move.w  oX(a0),(a1)+
	move.w  oY(a0),(a1)+
	addq.b  #4,sonicRecordIndex+1.w
	rts

; -------------------------------------------------------------------------

TimeTravel_SaveData:
	move.b  spawnMode,warpSpawnMode
	move.w  oX(a0),warpX
	move.w  oY(a0),warpY
	move.b  eventRoutine.w,warpEventRoutine
	move.b  waterRoutine.w,warpWaterRoutine
	move.w  bottomBound.w,warpBtmBound
	move.w  cameraX.w,warpCamX
	move.w  cameraY.w,warpCamY
	move.w  cameraBgX.w,warpCamBgX
	move.w  cameraBgY.w,warpCamBgY
	move.w  cameraBg2X.w,warpCamBg2X
	move.w  cameraBg2Y.w,warpCamBg2Y
	move.w  cameraBg3X.w,warpCamBg3X
	move.w  cameraBg3Y.w,warpCamBg3Y
	move.w  waterHeight2.w,warpWaterHeight
	move.b  waterRoutine.w,warpWaterRoutine
	move.b  waterFullscreen.w,warpWaterFull
	move.w  rings,savedRings
	move.b  livesFlags,savedLivesFlags
	rts
; -------------------------------------------------------------------------

ObjSonic_TimeWarp:	      

	tst.b   $2A(a0)
	bne.w   locret_203FFA
	tst.b   timeWarpDir
	beq.w   locret_203FFA
	move.w  sonicTopSpeed.w,d2
	moveq   #0,d0
	move.w  $14(a0),d0
	bpl.s   loc_203F68
	neg.w   d0

loc_203F68:	 ; CODE XREF: ObjSonic_TimeWarp+1A?j
	tst.w   timeWarpTimer.w
	bne.s   loc_203F74
	move.w  #1,timeWarpTimer.w

loc_203F74:	 ; CODE XREF: ObjSonic_TimeWarp+22?j
	move.w  timeWarpTimer.w,d1
	cmpi.w  #$E6,d1
	bcs.s   loc_203F8A
	move.b  #1,levelRestart
	move.w  #$E0,d0
	jsr     PlayFMSound
; -------------------------------------------------------------------------

loc_203F8A:	 ; CODE XREF: ObjSonic_TimeWarp+32?j
	cmpi.w  #$D2,d1
	bcs.s   loc_203FD0
	cmpi.b  #2,spawnMode
	beq.s   locret_203FCE
	move.b  #1,scrollLock.w
	move.b  timeZone,d0
	add.b   timeWarpDir,d0
	bpl.s   loc_203FB0
	moveq   #0,d0
	bra.s   loc_203FB8
; -------------------------------------------------------------------------

loc_203FB0:	 ; CODE XREF: ObjSonic_TimeWarp+60?j
	cmpi.b  #3,d0
	bcs.s   loc_203FB8
	moveq   #2,d0

loc_203FB8:	 ; CODE XREF: ObjSonic_TimeWarp+64?j
		        ; ObjSonic_TimeWarp+6A?j
	bset    #7,d0
	move.b  d0,timeZone
	bsr.w   TimeTravel_SaveData
	move.b  #2,spawnMode

locret_203FCE:	          ; CODE XREF: ObjSonic_TimeWarp+4E?j
	rts
; -------------------------------------------------------------------------

loc_203FD0:	 ; CODE XREF: ObjSonic_TimeWarp+44?j
	cmpi.w  #$5A,d1 ; 'Z'
	bcc.s   loc_203FE8
	cmp.w   d2,d0
	bcc.w   ObjSonic_MakeTimeWarpStars
	clr.w   timeWarpTimer.w
	clr.b   timeWarp
	rts
; -------------------------------------------------------------------------

loc_203FE8:	 ; CODE XREF: ObjSonic_TimeWarp+8A?j
	cmp.w   d2,d0
	bcc.s   locret_203FFA
	clr.w   timeWarpTimer.w
	clr.b   timeWarpDir
	clr.b   timeWarp

locret_203FFA:	          
	rts
; End of function ObjSonic_TimeWarp

; -------------------------------------------------------------------------

ObjSonic_MdGround:	     
	tst.b   miniSonic+1.w
	beq.s   .NotMini_MdGround
	cmpi.b  #5,oAnim(a0)
	bne.s   ObjSonic_MdGround_EndLocalR
	clr.b   miniSonic+1.w

.NotMini_MdGround:	      
	bsr.w   ObjSonic_ChkBoredom
	cmpi.b  #$2B,oAnim(a0) 
	bne.s   loc_20403C
	tst.b   miniSonic.w
	beq.s   .NotMini_2
	cmpi.b  #$79,oMapFrame(a0) 
	bne.s   ObjSonic_MdGround_EndLocalR
	bra.s   .GivingUp
; -------------------------------------------------------------------------

.NotMini_2:	 ; CODE XREF: ROM:0020401E?j
	cmpi.b  #$17,oMapFrame(a0)
	bne.s   ObjSonic_MdGround_EndLocalR

.GivingUp:	  ; CODE XREF: ROM:00204028?j
	bsr.w   ObjSonic_LevelBound
	jmp     ObjMoveGrv
; -------------------------------------------------------------------------

loc_20403C:	 ; CODE XREF: ROM:00204018?j
	bsr.w   ObjSonic_TimeWarp
	bsr.w   ObjSonic_CheckJump
	bsr.w   ObjSonic_SlopeResist
	bsr.w   ObjSonic_MoveGround
	bsr.w   ObjSonic_CheckRoll
	bsr.w   ObjSonic_LevelBound
	jsr     ObjMove
	bsr.w   Player_GroundCol
	bsr.w   ObjSonic_CheckFallOff

ObjSonic_MdGround_EndLocalR:		; CODE XREF: ROM:00204008?j
		        ; ROM:00204026?j ...
	rts
; -------------------------------------------------------------------------

ObjSonic_MdAir:	         ; DATA XREF: ROM:00203D9E?t
	bsr.w   ObjSonic_TimeWarp
	bsr.w   ObjSonic_JumpHeight
	bsr.w   ObjSonic_MoveAir
	bsr.w   ObjSonic_LevelBound
	jsr     ObjMoveGrv
	btst    #6,oFlags(a0)
	beq.s   .NoWater_1
	subi.w  #$28,oYVel(a0) ; '('

.NoWater_1:	 ; CODE XREF: ROM:00204080?j
	bsr.w   ObjSonic_JumpAngle
	bsr.w   Player_LevelColInAir2
	rts
; -------------------------------------------------------------------------

ObjSonic_MdRoll:	        ; DATA XREF: ROM:00203DA0?t
	bsr.w   ObjSonic_TimeWarp
	bsr.w   ObjSonic_CheckJump
	bsr.w   ObjSonic_SlopeResistRoll
	bsr.w   ObjSonic_MoveRoll
	bsr.w   ObjSonic_LevelBound
	jsr     ObjMove
	bsr.w   Player_GroundCol
	bsr.w   ObjSonic_CheckFallOff
	rts
; -------------------------------------------------------------------------

ObjSonic_MdJump:	        ; DATA XREF: ROM:00203DA2?t
	bsr.w   ObjSonic_TimeWarp
	bsr.w   ObjSonic_JumpHeight
	bsr.w   ObjSonic_MoveAir
	bsr.w   ObjSonic_LevelBound
	jsr     ObjMoveGrv
	btst    #6,oFlags(a0)
	beq.s   .NoWater_2
	subi.w  #$28,oYVel(a0) ; '('

.NoWater_2:	 ; CODE XREF: ROM:002040D2?j
	bsr.w   ObjSonic_JumpAngle
	bsr.w   Player_LevelColInAir2
	rts

; -------------------------------------------------------------------------


ObjSonic_MoveGround:	    ; CODE XREF: ROM:00204048?p
	move.w  sonicTopSpeed.w,d6
	move.w  sonicAcceleration.w,d5
	move.w  sonicDeceleration.w,d4
	tst.b   waterSlideFlag.w
	bne.w   loc_2043CA
	tst.w   oPlayerMoveLock(a0)
	bne.w   loc_20437A
	btst    #2,playerCtrl.w
	beq.s   loc_20410C
	bsr.w   sub_20445A

loc_20410C:	 ; CODE XREF: ObjSonic_MoveGround+22?j
	btst    #3,playerCtrl.w
	beq.s   loc_204118
	bsr.w   sub_2044E2

loc_204118:	 ; CODE XREF: ObjSonic_MoveGround+2E?j
	move.b  oAngle(a0),d0
	addi.b  #$20,d0 ; ' '
	andi.b  #$C0,d0
	bne.w   loc_20437A
	tst.w   $14(a0)
	beq.s   loc_204136
	tst.b   $2A(a0)
	beq.w   loc_20437A

loc_204136:	 ; CODE XREF: ObjSonic_MoveGround+48?j
	bclr    #5,oFlags(a0)
	move.b  #5,oAnim(a0)
	btst    #3,oFlags(a0)
	beq.s   loc_204192
	moveq   #0,d0
	move.b  oPlayerStandObj(a0),d0
	lsl.w   #6,d0
	lea     objPlayerSlot.w,a1
	lea     (a1,d0.w),a1
	tst.b   $22(a1)
	bmi.s   loc_2041C6
	cmpi.b  #$1E,0(a1)
	bne.s   loc_204172
	move.b  #0,oAnim(a0)
	bra.w   loc_20437A
; -------------------------------------------------------------------------

loc_204172:	 ; CODE XREF: ObjSonic_MoveGround+82?j
	moveq   #0,d1
	move.b  $19(a1),d1
	move.w  d1,d2
	add.w   d2,d2
	subq.w  #4,d2
	add.w   oX(a0),d1
	sub.w   8(a1),d1
	cmpi.w  #4,d1
	blt.s   loc_2041B6
	cmp.w   d2,d1
	bge.s   loc_2041A6
	bra.s   loc_2041C6
; -------------------------------------------------------------------------

loc_204192:	 ; CODE XREF: ObjSonic_MoveGround+64?j
	jsr     CheckFloorEdge
	cmpi.w  #$C,d1
	blt.s   loc_2041C6
	cmpi.b  #3,$36(a0)
	bne.s   loc_2041AE

loc_2041A6:	 ; CODE XREF: ObjSonic_MoveGround+AA?j
	bclr    #0,oFlags(a0)
	bra.s   loc_2041BC
; -------------------------------------------------------------------------

loc_2041AE:	 ; CODE XREF: ObjSonic_MoveGround+C0?j
	cmpi.b  #3,$37(a0)
	bne.s   loc_2041C6

loc_2041B6:	 ; CODE XREF: ObjSonic_MoveGround+A6?j
	bset    #0,oFlags(a0)

loc_2041BC:	 ; CODE XREF: ObjSonic_MoveGround+C8?j
	move.b  #6,oAnim(a0)
	bra.w   loc_20437A
; -------------------------------------------------------------------------

loc_2041C6:	 ; CODE XREF: ObjSonic_MoveGround+7A?j
		        ; ObjSonic_MoveGround+AC?j ...
	tst.b   $29(a0)
	beq.w   loc_20422E
	move.b  lookMode.w,d0
	andi.b  #$F,d0
	beq.s   loc_2041E2
	addq.b  #1,lookMode.w
	andi.b  #$CF,lookMode.w

loc_2041E2:	 ; CODE XREF: ObjSonic_MoveGround+F2?j
	btst    #7,lookMode.w
	bne.w   loc_2042AE
	btst    #6,lookMode.w
	bne.w   loc_2042D6
	btst    #1,playerCtrl.w
	bne.w   loc_2042D6
	andi.b  #$F,lookMode.w
	beq.s   loc_20421A
	btst    #0,playerCtrlTap.w
	beq.s   loc_20422E
	bset    #7,lookMode.w
	bra.w   loc_20439E
; -------------------------------------------------------------------------

loc_20421A:	 ; CODE XREF: ObjSonic_MoveGround+122?j
	btst    #0,playerCtrlTap.w
	beq.w   loc_20422E
	move.b  #1,lookMode.w
	bra.w   loc_20439E
; -------------------------------------------------------------------------

loc_20422E:	 ; CODE XREF: ObjSonic_MoveGround+E6?j
		        ; ObjSonic_MoveGround+12A?j ...
	btst    #0,playerCtrl.w
	beq.s   loc_20426E
	move.b  #7,oAnim(a0)
	tst.b   $2A(a0)
	beq.s   loc_20425A
	move.b  #0,oAnim(a0)
	moveq   #$19,d0
	btst    #0,oFlags(a0)
	beq.s   loc_204254
	neg.w   d0

loc_204254:	 ; CODE XREF: ObjSonic_MoveGround+16C?j
	add.w   d0,$14(a0)
	rts
; -------------------------------------------------------------------------

loc_20425A:	 ; CODE XREF: ObjSonic_MoveGround+15C?j
	move.b  playerCtrlTap.w,d0
	andi.b  #$70,d0 ; 'p'
	beq.s   loc_20426A
	move.b  #1,$2A(a0)

loc_20426A:	 ; CODE XREF: ObjSonic_MoveGround+17E?j
	bra.w   loc_20439E
; -------------------------------------------------------------------------

loc_20426E:	 ; CODE XREF: ObjSonic_MoveGround+150?j
	cmpi.b  #$3C,$2A(a0) ; '<'
	beq.s   loc_204284
	move.b  #0,$2A(a0)
	move.w  #0,$14(a0)
	bra.s   loc_2042D6
; -------------------------------------------------------------------------

loc_204284:	 ; CODE XREF: ObjSonic_MoveGround+190?j
	move.b  #$3D,$2A(a0) ; '='
	move.w  sonicTopSpeed.w,d6
	move.w  sonicAcceleration.w,d5
	move.w  sonicDeceleration.w,d4
	btst    #0,oFlags(a0)
	bne.s   loc_2042A6
	bsr.w   sub_2044E2
	bra.w   loc_20437A
; -------------------------------------------------------------------------
; syntax and comments get cleaned up following this line
; fuck ida's default outputs it's annoying
; finish this later

loc_2042A6:
	bsr.w   sub_20445A
	bra.w   loc_20437A

loc_2042AE:
	btst    #0,playerCtrl.w
	beq.s   loc_2042D6
	move.b  #7,oAnim(a0)
	tst.b   $29(a0)
	beq.w   loc_204358
	cmpi.w  #$C8,camYCenter.w
	beq.w   loc_20439E
	addq.w  #2,camYCenter.w
	bra.w   loc_20439E

loc_2042D6:
	tst.b   $29(a0)
	beq.s   loc_204312
	btst    #6,lookMode.w
	bne.w   loc_204358
	andi.b  #$F,lookMode.w
	beq.s   loc_204300
	btst    #1,playerCtrlTap.w
	beq.s   loc_204312
	bset    #6,lookMode.w
	bra.w   loc_20439E

loc_204300:
	btst    #1,playerCtrlTap.w
	beq.s   loc_204312
	move.b  #1,lookMode.w
	bra.w   loc_20439E

loc_204312:
	btst    #1,playerCtrl.w
	beq.s   loc_20437A
	move.b  #8,oAnim(a0)
	tst.b   $2A(a0)
	bne.s   loc_204356
	move.b  playerCtrlTap.w,d0
	andi.b  #$70,d0 ; 'p'
	beq.s   loc_204356
	move.b  #1,$2A(a0)
	move.w  #$16,$14(a0)
	btst    #0,oFlags(a0)
	beq.s   loc_204348
	neg.w   $14(a0)

loc_204348:
	move.w  #SFXRollCont,d0
	jsr     PlayFMSound
	bsr.w   ObjSonic_StartRoll

loc_204356:

	bra.s   loc_20439E

loc_204358:
	btst    #1,playerCtrl.w
	beq.s   loc_20437A
	move.b  #8,oAnim(a0)
	tst.b   $29(a0)
	beq.s   loc_20439E
	cmpi.w  #8,camYCenter.w
	beq.s   loc_20439E
	subq.w  #2,camYCenter.w
	bra.s   loc_20439E

; -------------------------------------------------------------------------

loc_20437A:
	cmpi.w  #$60,camYCenter.w
	bne.s   loc_204394
	move.b  lookMode.w,d0
	andi.b  #$F,d0
	bne.s   loc_20439E
	move.b  #0,lookMode.w
	bra.s   loc_20439E

; -------------------------------------------------------------------------

loc_204394:
	bcc.s   loc_20439A
	addq.w  #4,camYCenter.w

loc_20439A:
	subq.w  #2,camYCenter.w

loc_20439E:
	move.b  playerCtrl.w,d0
	andi.b  #$C,d0
	bne.s   loc_2043CA
	move.w  $14(a0),d0
	beq.s   loc_2043CA
	bmi.s   loc_2043BE
	sub.w   d5,d0
	bcc.s   loc_2043B8
	move.w  #0,d0

loc_2043B8:
	move.w  d0,$14(a0)
	bra.s   loc_2043CA

loc_2043BE:
	add.w   d5,d0
	bcc.s   loc_2043C6
	move.w  #0,d0

loc_2043C6:
	move.w  d0,$14(a0)

loc_2043CA:
	move.b  oAngle(a0),d0
	jsr     CalcSine
	muls.w  $14(a0),d1
	asr.l   #8,d1
	move.w  d1,oXVel(a0)
	muls.w  $14(a0),d0
	asr.l   #8,d0
	move.w  d0,oYVel(a0)

loc_2043E8:
	move.b  oAngle(a0),d0
	addi.b  #$40,d0 ; '.'
	bmi.s   locret_204458
	move.b  #$40,d1 ; '.'
	tst.w   $14(a0)
	beq.s   locret_204458
	bmi.s   loc_204400
	neg.w   d1

loc_204400:
	move.b  oAngle(a0),d0
	add.b   d1,d0
	move.w  d0,-(sp)
	bsr.w   sub_206026
	move.w  (sp)+,d0
	tst.w   d1
	bpl.s   locret_204458
	asl.w   #8,d1
	addi.b  #$20,d0 ; ' '
	andi.b  #$C0,d0
	beq.s   loc_204454
	cmpi.b  #$40,d0 ; '.'
	beq.s   loc_204442
	cmpi.b  #$80,d0
	beq.s   loc_20443C
	add.w   d1,oXVel(a0)
	bset    #5,oFlags(a0)
	move.w  #0,$14(a0)
	rts

loc_20443C:
	sub.w   d1,oYVel(a0)
	rts

loc_204442:
	sub.w   d1,oXVel(a0)
	bset    #5,oFlags(a0)
	move.w  #0,$14(a0)
	rts

loc_204454:
	add.w   d1,oYVel(a0)

locret_204458:
	rts

sub_20445A:
	move.w  $14(a0),d0
	beq.s   loc_204462
	bpl.s   loc_2044AA

loc_204462:	
	tst.b   $2A(a0)
	beq.s   loc_20447E
	cmpi.b  #$3D,$2A(a0)
	bne.s   locret_2044E0
	bset    #2,playerCtrl.w
	lsl.w   #7,d5
	move.b  #0,$2A(a0)

loc_20447E:
	bset    #0,oFlags(a0)
	bne.s   loc_204492
	bclr    #5,oFlags(a0)
	move.b  #1,$1D(a0)

loc_204492:
	sub.w   d5,d0
	move.w  d6,d1
	neg.w   d1
	cmp.w   d1,d0
	bgt.s   loc_20449E
	move.w  d1,d0

loc_20449E:
	move.w  d0,$14(a0)
	move.b  #0,oAnim(a0)
	rts

; -------------------------------------------------------------------------

loc_2044AA:
	sub.w   d4,d0
	bcc.s   loc_2044B2
	move.w  #$FF80,d0

loc_2044B2:
	move.w  d0,$14(a0)
	move.b  oAngle(a0),d0
	addi.b  #$20,d0 ; ' '
	andi.b  #$C0,d0
	bne.s   locret_2044E0
	cmpi.w  #$400,d0
	blt.s   locret_2044E0
	move.b  #$D,oAnim(a0)
	bclr    #0,oFlags(a0)
	move.w  #SFXSkid,d0
	jsr     PlayFMSound

locret_2044E0:
	rts

; -------------------------------------------------------------------------


sub_2044E2:
	move.w  $14(a0),d0
	bmi.s   loc_20452C
	tst.b   $2A(a0)
	beq.s   loc_204504
	cmpi.b  #$3D,$2A(a0)
	bne.s   locret_204562
	bset    #3,playerCtrl.w
	lsl.w   #7,d5
	move.b  #0,$2A(a0)

loc_204504:
	bclr    #0,oFlags(a0)
	beq.s   loc_204518
	bclr    #5,oFlags(a0)
	move.b  #1,$1D(a0)

loc_204518:
	add.w   d5,d0
	cmp.w   d6,d0
	blt.s   loc_204520
	move.w  d6,d0

loc_204520:
	move.w  d0,$14(a0)
	move.b  #0,oAnim(a0)
	rts
; -------------------------------------------------------------------------

loc_20452C:
	add.w   d4,d0
	bcc.s   loc_204534
	move.w  #$80,d0

loc_204534:
	move.w  d0,$14(a0)
	move.b  oAngle(a0),d0
	addi.b  #$20,d0
	andi.b  #$C0,d0
	bne.s   locret_204562
	cmpi.w  #$FC00,d0
	bgt.s   locret_204562
	move.b  #$D,oAnim(a0)
	bset    #0,oFlags(a0)
	move.w  #SFXSkid,d0
	jsr     PlayFMSound

locret_204562:
	rts

; -------------------------------------------------------------------------

ObjSonic_MoveRoll:
	move.w  sonicTopSpeed.w,d6
	asl.w   #1,d6
	move.w  sonicAcceleration.w,d5
	asr.w   #1,d5
	move.w  sonicDeceleration.w,d4
	asr.w   #2,d4
	tst.b   waterSlideFlag.w
	bne.w   loc_20468A
	tst.w   oPlayerMoveLock(a0)
	bne.s   loc_20459C
	btst    #2,playerCtrl.w
	beq.s   loc_204590
	bsr.w   sub_2046C0

loc_204590:	
	btst    #3,playerCtrl.w
	beq.s   loc_20459C
	bsr.w   sub_2046E4

loc_20459C:	 
	tst.b   $2A(a0)
	beq.w   loc_204632
	move.w  #$19,d0
	move.w  sonicTopSpeed.w,d1
	asl.w   #1,d1
	btst    #0,oFlags(a0)
	beq.s   loc_2045BA
	neg.w   d0
	neg.w   d1

loc_2045BA:	
	add.w   d0,$14(a0)
	move.w  $14(a0),d0
	cmp.w   d1,d0
	bgt.s   loc_2045C8
	move.w  d1,d0

loc_2045C8:	
	move.w  d0,$14(a0)
	btst    #1,playerCtrl.w
	beq.s   loc_204604
	move.b  playerCtrlTap.w,d0
	andi.b  #$70,d0 ; 'p'
	beq.s   locret_204630

loc_2045DE:	
	move.w  #SFXStop,d0
	jsr     PlayFMSound
	move.b  #0,$2A(a0)
	move.w  #0,$14(a0)
	move.w  #0,oXVel(a0)
	move.w  #0,oYVel(a0)
	bra.w   loc_20465A
; -------------------------------------------------------------------------

loc_204604:	
	cmpi.b  #$3C,$2A(a0) ; '<'
	bne.s   loc_2045DE
	move.b  #0,$2A(a0)
	move.w  #SFXDash,d0
	jsr     PlayFMSound
	btst    #0,oFlags(a0)
	bne.s   loc_20462A
	bsr.w   sub_2046E4
	bra.s   loc_204632
; -------------------------------------------------------------------------

loc_20462A:	
	bsr.w   sub_2046C0
	bra.s   loc_204632

; -------------------------------------------------------------------------

locret_204630:
	rts

; -------------------------------------------------------------------------

loc_204632:
	move.w  $14(a0),d0
	beq.s   loc_204654
	bmi.s   loc_204648
	sub.w   d5,d0
	bcc.s   loc_204642
	move.w  #0,d0

loc_204642:
	move.w  d0,$14(a0)
	bra.s   loc_204654
; -------------------------------------------------------------------------

loc_204648:
	add.w   d5,d0
	bcc.s   loc_204650
	move.w  #0,d0

loc_204650:
	move.w  d0,$14(a0)

loc_204654:
	tst.w   $14(a0)
	bne.s   loc_20468A

loc_20465A:
	bclr    #2,oFlags(a0)
	tst.b   miniSonic.w
	beq.s   loc_204674
	move.b  #$A,oYRadius(a0)
	move.b  #5,oXRadius(a0)
	bra.s   loc_204684
; -------------------------------------------------------------------------

loc_204674:
	move.b  #$13,oYRadius(a0)
	move.b  #9,oXRadius(a0)
	subq.w  #5,oY(a0)

loc_204684:
	move.b  #5,oAnim(a0)

loc_20468A:
	move.b  oAngle(a0),d0
	jsr     CalcSine
	muls.w  $14(a0),d0
	asr.l   #8,d0
	move.w  d0,oYVel(a0)
	muls.w  $14(a0),d1
	asr.l   #8,d1
	cmpi.w  #$1000,d1
	ble.s   loc_2046AE
	move.w  #$1000,d1

loc_2046AE:
	cmpi.w  #$F000,d1
	bge.s   loc_2046B8
	move.w  #$F000,d1

loc_2046B8:
	move.w  d1,oXVel(a0)
	bra.w   loc_2043E8

; -------------------------------------------------------------------------

sub_2046C0:
	move.w  $14(a0),d0
	beq.s   loc_2046C8
	bpl.s   loc_2046D6

loc_2046C8:
	bset    #0,oFlags(a0)
	move.b  #2,oAnim(a0)
	rts

loc_2046D6:
	sub.w   d4,d0
	bcc.s   loc_2046DE
	move.w  #$FF80,d0

loc_2046DE:
	move.w  d0,$14(a0)
	rts

; -------------------------------------------------------------------------


sub_2046E4:
	move.w  $14(a0),d0
	bmi.s   loc_2046F8
	bclr    #0,oFlags(a0)
	move.b  #2,oAnim(a0)
	rts

loc_2046F8:
	add.w   d4,d0
	bcc.s   loc_204700
	move.w  #$80,d0

loc_204700:
	move.w  d0,$14(a0)
	rts

; -------------------------------------------------------------------------


ObjSonic_MoveAir:
	move.w  sonicTopSpeed.w,d6
	move.w  sonicAcceleration.w,d5
	asl.w   #1,d5
	btst    #4,oFlags(a0)
	bne.s   loc_204750
	move.w  oXVel(a0),d0
	btst    #2,playerCtrl.w
	beq.s   loc_204736
	bset    #0,oFlags(a0)
	sub.w   d5,d0
	move.w  d6,d1
	neg.w   d1
	cmp.w   d1,d0
	bgt.s   loc_204736
	move.w  d1,d0

loc_204736:
	btst    #3,playerCtrl.w
	beq.s   loc_20474C
	bclr    #0,oFlags(a0)
	add.w   d5,d0
	cmp.w   d6,d0
	blt.s   loc_20474C
	move.w  d6,d0

loc_20474C:
	move.w  d0,oXVel(a0)

loc_204750:
	tst.b   $29(a0)
	beq.s   loc_204768
	cmpi.w  #$60,camYCenter.w
	beq.s   loc_204768
	bcc.s   loc_204764
	addq.w  #4,camYCenter.w

loc_204764:
	subq.w  #2,camYCenter.w

loc_204768:
	cmpi.w  #$FC00,oYVel(a0)
	bcs.s   locret_204796
	move.w  oXVel(a0),d0
	move.w  d0,d1
	asr.w   #5,d1
	beq.s   locret_204796
	bmi.s   loc_20478A
	sub.w   d1,d0
	bcc.s   loc_204784
	move.w  #0,d0

loc_204784:
	move.w  d0,oXVel(a0)
	rts

loc_20478A:
	sub.w   d1,d0
	bcs.s   loc_204792
	move.w  #0,d0

loc_204792:
	move.w  d0,oXVel(a0)

locret_204796:
	rts

; -------------------------------------------------------------------------
; unused, dead code

	move.b  oAngle(a0),d0
	addi.b  #$20,d0 ; ' '
	andi.b  #$C0,d0
	bne.s   locret_2047C6
	bsr.w   sub_206260
	tst.w   d1
	bpl.s   locret_2047C6
	move.w  #0,$14(a0)
	move.w  #0,oXVel(a0)
	move.w  #0,oYVel(a0)
	move.b  #$B,oAnim(a0)

locret_2047C6:
	rts

; -------------------------------------------------------------------------


ObjSonic_LevelBound:
	move.l  oX(a0),d1
	move.w  oXVel(a0),d0
	ext.l   d0
	asl.l   #8,d0
	add.l   d0,d1
	swap    d1
	move.w  leftBound.w,d0
	addi.w  #$10,d0
	cmp.w   d1,d0
	bhi.s   loc_20480E
	move.w  rightBound.w,d0
	addi.w  #$130,d0
	tst.b   bossActive.w
	bne.s   loc_2047F6
	addi.w  #$38,d0

loc_2047F6:
	cmp.w   d1,d0
	bls.s   loc_20480E

loc_2047FA:
	move.w  bottomBound.w,d0
	addi.w  #$E0,d0
	cmp.w   oY(a0),d0
	blt.s   loc_20480A
	rts

loc_20480A:
	bra.w   KillPlayer

loc_20480E:
	move.w  d0,oX(a0)
	move.w  #0,oYScr(a0)
	move.w  #0,oXVel(a0)
	move.w  #0,$14(a0)
	bra.s   loc_2047FA

; -------------------------------------------------------------------------

ObjSonic_CheckRoll:
	tst.b   waterSlideFlag.w
	bne.s   .End
	move.w  $14(a0),d0
	bpl.s   .PosInertia
	neg.w   d0

.PosInertia:
	cmpi.w  #$80,d0
	bcs.s   .End
	move.b  playerCtrl.w,d0
	andi.b  #$C,d0
	bne.s   .End
	btst    #1,playerCtrl.w
	bne.s   .startRoll

.End:
	rts

; -------------------------------------------------------------------------
.startRoll:
	move.w  #SFXRollFade,d0
	jsr     PlayFMSound
ObjSonic_StartRoll:
	btst    #2,oFlags(a0)
	beq.s   loc_204858
	rts

loc_204858:	 ; CODE XREF: ObjSonic_StartRoll+6?j

	bset    #2,oFlags(a0)
	tst.b   miniSonic.w
	beq.s   loc_204872
	move.b  #$A,oYRadius(a0)
	move.b  #5,oXRadius(a0)
	bra.s   loc_204882

loc_204872:
	move.b  #$E,oYRadius(a0)
	move.b  #7,oXRadius(a0)
	addq.w  #5,oY(a0)

loc_204882:
	move.b  #2,oAnim(a0)
	tst.w   $14(a0)
	bne.s   locret_204894
	move.w  #$200,$14(a0)

locret_204894:
	rts

; -------------------------------------------------------------------------


ObjSonic_CheckJump:
	tst.b   $2A(a0)
	beq.s   loc_2048C0
	move.b  playerCtrlTap.w,d0
	andi.b  #$70,d0 ; 'p'
	beq.s   loc_2048C0
	move.b  #0,$2A(a0)
	move.w  #0,$14(a0)
	move.w  #0,oXVel(a0)
	move.w  #0,oYVel(a0)
	bra.s   loc_2048D2

loc_2048C0:
	move.b  playerCtrl.w,d0
	andi.b  #3,d0
	beq.s   loc_2048D2
	tst.w   $14(a0)
	beq.w   locret_2049AE

loc_2048D2:
	move.b  playerCtrlTap.w,d0
	andi.b  #$70,d0 ; 'p'
	beq.w   locret_2049AE
	btst    #3,oFlags(a0)
	beq.s   loc_2048EE
	jsr     ObjSonic_ChkFlipper
	beq.s   loc_20491E

loc_2048EE:
	moveq   #0,d0
	move.b  oAngle(a0),d0
	addi.b  #-$80,d0
	bsr.w   sub_206090
	cmpi.w  #6,d1
	blt.w   locret_2049AE
	move.w  #$680,d2
	btst    #6,oFlags(a0)
	beq.s   loc_204914
	move.w  #$380,d2

loc_204914:
	moveq   #0,d0
	move.b  oAngle(a0),d0
	subi.b  #$40,d0

loc_20491E:
	jsr     CalcSine
	muls.w  d2,d1
	asr.l   #8,d1
	add.w   d1,oXVel(a0)
	muls.w  d2,d0
	asr.l   #8,d0
	add.w   d0,oYVel(a0)
	bset    #1,oFlags(a0)
	bclr    #5,oFlags(a0)
	addq.l  #4,sp
	move.b  #1,$3C(a0)
	clr.b   $38(a0)
	move.w  #SFXJump,d0
	jsr     PlayFMSound
	tst.b   miniSonic.w
	beq.s   loc_20496A
	move.b  #$A,oYRadius(a0)
	move.b  #5,oXRadius(a0)
	bra.s   loc_204976

loc_20496A:
	move.b  #$13,oYRadius(a0)
	move.b  #9,oXRadius(a0)

loc_204976:
	btst    #2,oFlags(a0)
	bne.s   loc_2049B0
	tst.b   miniSonic.w
	beq.s   loc_204992
	move.b  #$A,oYRadius(a0)
	move.b  #5,oXRadius(a0)
	bra.s   loc_2049A2

loc_204992:
	move.b  #$E,oYRadius(a0)
	move.b  #7,oXRadius(a0)
	addq.w  #5,oY(a0)

loc_2049A2:
	bset    #2,oFlags(a0)
	move.b  #2,oAnim(a0)

locret_2049AE:
	rts

loc_2049B0:
	bset    #4,oFlags(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_JumpHeight:
	tst.b   $3C(a0)
	beq.s   NotJump
	move.w  #$FC00,d1
	btst    #6,oFlags(a0)
	beq.s   .GotCapVel
	move.w  #$FE00,d1

.GotCapVel:
	cmp.w   oYVel(a0),d1
	ble.s   locret_2049E8
	move.b  playerCtrl.w,d0
	andi.b  #$70,d0 ; 'p'
	bne.s   locret_2049E8
	move.b  #0,$2A(a0)
	move.w  d1,oYVel(a0)

locret_2049E8:
	rts

NotJump:
	cmpi.w  #$F040,oYVel(a0)
	bge.s   locret_2049F8
	move.w  #$F040,oYVel(a0)

locret_2049F8:
	rts

; -------------------------------------------------------------------------

ObjSonic_SlopeResist:
	tst.b   $2A(a0)
	bne.s   locret_204A34
	move.b  oAngle(a0),d0
	addi.b  #$60,d0
	cmpi.b  #$C0,d0
	bcc.s   locret_204A34
	move.b  oAngle(a0),d0
	jsr     CalcSine
	muls.w  #$20,d0
	asr.l   #8,d0
	tst.w   $14(a0)
	beq.s   locret_204A34
	bmi.s   loc_204A30
	tst.w   d0
	beq.s   locret_204A2E
	add.w   d0,$14(a0)

locret_204A2E:
	rts

loc_204A30:
	add.w   d0,$14(a0)

locret_204A34:
	rts

; -------------------------------------------------------------------------


ObjSonic_SlopeResistRoll:
	tst.b   $2A(a0)
	bne.s   locret_204A76
	move.b  oAngle(a0),d0
	addi.b  #$60,d0
	cmpi.b  #$C0,d0
	bcc.s   locret_204A76
	move.b  oAngle(a0),d0
	jsr     CalcSine
	muls.w  #$50,d0
	asr.l   #8,d0
	tst.w   $14(a0)
	bmi.s   loc_204A6C
	tst.w   d0
	bpl.s   loc_204A66
	asr.l   #2,d0

loc_204A66:
	add.w   d0,$14(a0)
	rts
; -------------------------------------------------------------------------

loc_204A6C:
	tst.w   d0
	bmi.s   loc_204A72
	asr.l   #2,d0

loc_204A72:
	add.w   d0,$14(a0)

locret_204A76:
	rts

; -------------------------------------------------------------------------


ObjSonic_CheckFallOff:
	nop
	tst.b   $38(a0)
	bne.s   locret_204AB2
	tst.w   oPlayerMoveLock(a0)
	bne.s   loc_204AB4
	move.b  oAngle(a0),d0
	addi.b  #$20,d0 ; ' '
	andi.b  #$C0,d0
	beq.s   locret_204AB2
	move.w  $14(a0),d0
	bpl.s   loc_204A9C
	neg.w   d0

loc_204A9C:
	cmpi.w  #$280,d0
	bcc.s   locret_204AB2
	clr.w   $14(a0)
	bset    #1,oFlags(a0)
	move.w  #$1E,oPlayerMoveLock(a0)

locret_204AB2:
	rts

loc_204AB4:
	subq.w  #1,oPlayerMoveLock(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_JumpAngle:
	move.b  oAngle(a0),d0
	beq.s   locret_204AD4
	bpl.s   loc_204ACA
	addq.b  #2,d0
	bcc.s   loc_204AC8
	moveq   #0,d0

loc_204AC8:
	bra.s   loc_204AD0

loc_204ACA:
	subq.b  #2,d0
	bcc.s   loc_204AD0
	moveq   #0,d0

loc_204AD0:
	move.b  d0,oAngle(a0)

locret_204AD4:
	rts

; -------------------------------------------------------------------------

Player_LevelColInAir2:
	move.w  oXVel(a0),d1
	move.w  oYVel(a0),d2
	jsr     CalcAngle
	move.b  d0,debugAngle
	subi.b  #$20,d0
	move.b  d0,debugAngleShift
	andi.b  #$C0,d0
	move.b  d0,debugQuadrant
	cmpi.b  #$40,d0
	beq.w   Player_LvlColAir_Left
	cmpi.b  #$80,d0
	beq.w   Player_LvlColAir_Up
	cmpi.b  #$C0,d0
	beq.w   Player_LvlColAir_Right

Player_LvlColAir_Down:
	bsr.w   Player_GetLWallDist
	tst.w   d1
	bpl.s   .NotLeftWall
	sub.w   d1,oX(a0)
	move.w  #0,oXVel(a0)

.NotLeftWall:
	bsr.w   Player_GetRWallDist
	tst.w   d1
	bpl.s   loc_204B3A
	add.w   d1,oX(a0)
	move.w  #0,oXVel(a0)

loc_204B3A:
	bsr.w   sub_2060B8
	move.b  d1,debugFloorDist
	tst.w   d1
	bpl.s   locret_204BB8
	move.b  oYVel(a0),d2
	addq.b  #8,d2
	neg.b   d2
	cmp.b   d2,d1
	bge.s   loc_204B58
	cmp.b   d2,d0
	blt.s   locret_204BB8

loc_204B58:
	add.w   d1,oY(a0)
	move.b  d3,oAngle(a0)
	bsr.w   Player_ResetOnFloor
	move.b  #0,oAnim(a0)
	move.b  d3,d0
	addi.b  #$20,d0
	andi.b  #$40,d0
	bne.s   loc_204B96
	move.b  d3,d0
	addi.b  #$10,d0
	andi.b  #$20,d0
	beq.s   loc_204B88
	asr     oYVel(a0)
	bra.s   loc_204BAA

loc_204B88:
	move.w  #0,oYVel(a0)
	move.w  oXVel(a0),$14(a0)
	rts

loc_204B96:
	move.w  #0,oXVel(a0)
	cmpi.w  #$FC0,oYVel(a0)
	ble.s   loc_204BAA
	move.w  #$FC0,oYVel(a0)

loc_204BAA:
	move.w  oYVel(a0),$14(a0)
	tst.b   d3
	bpl.s   locret_204BB8
	neg.w   $14(a0)

locret_204BB8:
	rts

; -------------------------------------------------------------------------

Player_LvlColAir_Left:
	bsr.w   Player_GetLWallDist
	tst.w   d1
	bpl.s   loc_204BD4
	sub.w   d1,oX(a0)
	move.w  #0,oXVel(a0)
	move.w  oYVel(a0),$14(a0)
	rts
; -------------------------------------------------------------------------

loc_204BD4:
	bsr.w   sub_206260
	tst.w   d1
	bpl.s   loc_204BEE
	sub.w   d1,oY(a0)
	tst.w   oYVel(a0)
	bpl.s   locret_204BEC
	move.w  #0,oYVel(a0)

locret_204BEC:
	rts
; -------------------------------------------------------------------------

loc_204BEE:
	tst.w   oYVel(a0)
	bmi.s   locret_204C1A
	bsr.w   sub_2060B8
	tst.w   d1
	bpl.s   locret_204C1A
	add.w   d1,oY(a0)
	move.b  d3,oAngle(a0)
	bsr.w   Player_ResetOnFloor
	move.b  #0,oAnim(a0)
	move.w  #0,oYVel(a0)
	move.w  oXVel(a0),$14(a0)

locret_204C1A:
	rts

; -------------------------------------------------------------------------

Player_LvlColAir_Up:
	bsr.w   Player_GetLWallDist
	tst.w   d1
	bpl.s   loc_204C2E
	sub.w   d1,oX(a0)
	move.w  #0,oXVel(a0)

loc_204C2E:
	bsr.w   Player_GetRWallDist
	tst.w   d1
	bpl.s   loc_204C40
	add.w   d1,oX(a0)
	move.w  #0,oXVel(a0)

loc_204C40:
	bsr.w   sub_206260
	tst.w   d1
	bpl.s   locret_204C76
	sub.w   d1,oY(a0)
	move.b  d3,d0
	addi.b  #$20,d0
	andi.b  #$40,d0
	bne.s   loc_204C60
	move.w  #0,oYVel(a0)
	rts

loc_204C60:
	move.b  d3,oAngle(a0)
	bsr.w   Player_ResetOnFloor
	move.w  oYVel(a0),$14(a0)
	tst.b   d3
	bpl.s   locret_204C76
	neg.w   $14(a0)

locret_204C76:
	rts

; -------------------------------------------------------------------------

Player_LvlColAir_Right:
	bsr.w   Player_GetRWallDist
	tst.w   d1
	bpl.s   loc_204C92
	add.w   d1,oX(a0)
	move.w  #0,oXVel(a0)
	move.w  oYVel(a0),$14(a0)
	rts

loc_204C92:
	bsr.w   sub_206260
	tst.w   d1
	bpl.s   loc_204CAC
	sub.w   d1,oY(a0)
	tst.w   oYVel(a0)
	bpl.s   locret_204CAA
	move.w  #0,oYVel(a0)

locret_204CAA:
	rts

loc_204CAC:
	tst.w   oYVel(a0)
	bmi.s   locret_204CD8
	bsr.w   sub_2060B8
	tst.w   d1
	bpl.s   locret_204CD8
	add.w   d1,oY(a0)
	move.b  d3,oAngle(a0)
	bsr.w   Player_ResetOnFloor
	move.b  #0,oAnim(a0)
	move.w  #0,oYVel(a0)
	move.w  oXVel(a0),$14(a0)

locret_204CD8:
	rts

; -------------------------------------------------------------------------

Player_ResetOnFloor:
	btst    #4,oFlags(a0)
	beq.s   loc_204CE4
	nop

loc_204CE4:	 
	bclr    #5,oFlags(a0)
	bclr    #1,oFlags(a0)
	bclr    #4,oFlags(a0)
	btst    #2,oFlags(a0)
	beq.s   loc_204D2E
	bclr    #2,oFlags(a0)
	tst.b   miniSonic.w
	beq.s   loc_204D18
	move.b  #$A,oYRadius(a0)
	move.b  #5,oXRadius(a0)
	bra.s   loc_204D28

loc_204D18:	 
	move.b  #$13,oYRadius(a0)
	move.b  #9,oXRadius(a0)
	subq.w  #5,oY(a0)

loc_204D28:	 
	move.b  #0,oAnim(a0)

loc_204D2E:	 
	move.b  #0,$3C(a0)
	move.w  #0,scoreChain.w
	rts

; -------------------------------------------------------------------------

ObjSonic_Hurt:
	jsr     ObjMove
	addi.w  #$30,oYVel(a0)
	btst    #6,oFlags(a0)
	beq.s   .NoWater
	subi.w  #$20,oYVel(a0)

.NoWater:
	bsr.w   ObjSonic_HurtChkLand
	bsr.w   ObjSonic_LevelBound
	bsr.w   ObjSonic_RecordPos
	bsr.w   ObjSonic_Animate
	jmp     DrawObject

; -------------------------------------------------------------------------

ObjSonic_HurtChkLand:
	move.w  bottomBound.w,d0
	addi.w  #$E0,d0
	cmp.w   oY(a0),d0
	bcs.w   KillPlayer
	bsr.w   Player_LevelColInAir2
	btst    #1,oFlags(a0)
	bne.s   locret_204DA6
	moveq   #0,d0
	move.w  d0,oYVel(a0)
	move.w  d0,oXVel(a0)
	move.w  d0,$14(a0)
	move.b  #0,oAnim(a0)
	subq.b  #2,oRoutine(a0)
	move.w  #$78,$30(a0)

locret_204DA6:
	rts

; -------------------------------------------------------------------------

ObjSonic_Dead:
	bsr.w   ObjSonic_DeadChkGone
	jsr     ObjMoveGrv
	bsr.w   ObjSonic_RecordPos
	bsr.w   ObjSonic_Animate
	jmp     DrawObject

; -------------------------------------------------------------------------


ObjSonic_DeadChkGone:
	move.w  bottomBound.w,d0
	addi.w  #$100,d0
	cmp.w   oY(a0),d0
	bcc.w   ObjSonic_DeadChkGone_End
	move.w  #$FFC8,oYVel(a0)
	addq.b  #2,oRoutine(a0)
	clr.b   updateHUDTime
	addq.b  #1,updateHUDLives
	subq.b  #1,lives

loc_204DEC:
	move.w  #$3C,$3A(a0)
	tst.b   timeOver
	beq.s   ObjSonic_DeadChkGone_End
	move.w  #0,$3A(a0)
	bra.s   loc_204DEC

ObjSonic_DeadChkGone_End:
	rts

; -------------------------------------------------------------------------


ObjSonic_Restart:
	tst.w   $3A(a0)
	beq.s   ObjSonic_Restart_End
	subq.w  #1,$3A(a0)
	bne.s   ObjSonic_Restart_End
	move.w  #1,levelRestart
	lea     objPlayerSlot2.w,a5
	cmpi.b  #1,0(a0)
	beq.s   loc_204E28
	lea     objPlayerSlot.w,a5

loc_204E28:	 ; CODE XREF: ObjSonic_Restart+1E?j
	tst.b   0(a5)
	beq.w   loc_204E44
	move.w  #0,levelRestart
	eori.b  #1,usePlayer2
	bra.w   DeleteObject


loc_204E44:
	clr.l   flowerCount
	move.w  #$E,d0
	tst.b   lives
	beq.s   loc_204E5C
	clr.w   sectionID

loc_204E5C:
	bra.w   SendSubCommand

ObjSonic_Restart_End:
	rts

; -------------------------------------------------------------------------

sub_204E62:
	cmpi.b  #3,zone
	beq.s   loc_204E76
	tst.b   zone
	bne.w   locret_204F2C

loc_204E76:
	move.w  oY(a0),d0
	lsr.w   #1,d0
	andi.w  #$380,d0
	move.b  oX(a0),d1
	andi.w  #$7F,d1
	add.w   d1,d0
	lea     levelLayout.w,a1
	move.b  (a1,d0.w),d1
	cmp.b   specialChunks+2.w,d1
	bne.s   loc_204EB4
	tst.b   zone
	bne.w   PlaySpinSound
	move.w  oY(a0),d0
	andi.w  #$FF,d0
	cmpi.w  #$90,d0
	bcc.w   PlaySpinSound
	bra.s   loc_204EBC
; -------------------------------------------------------------------------

loc_204EB4:	 ; CODE XREF: sub_204E62+34?j
	cmp.b   specialChunks+3.w,d1
	beq.w   PlaySpinSound

loc_204EBC:	 ; CODE XREF: sub_204E62+50?j
	cmp.b   specialChunks.w,d1
	beq.s   loc_204EE0
	cmp.b   specialChunks+1.w,d1
	beq.s   loc_204ED0
	bclr    #6,oSprFlags(a0)
	rts
; -------------------------------------------------------------------------

loc_204ED0:	 ; CODE XREF: sub_204E62+64?j
	btst    #1,oFlags(a0)
	beq.s   loc_204EE0
	bclr    #6,oSprFlags(a0)
	rts

loc_204EE0:
	move.w  oX(a0),d2
	cmpi.b  #$2C,d2
	bcc.s   loc_204EF2
	bclr    #6,oSprFlags(a0)
	rts

loc_204EF2:
	cmpi.b  #$E0,d2
	bcs.s   loc_204F00
	bset    #6,oSprFlags(a0)
	rts

loc_204F00:
	btst    #6,oSprFlags(a0)
	bne.s   loc_204F1C
	move.b  oAngle(a0),d1
	beq.s   locret_204F2C
	cmpi.b  #$80,d1
	bhi.s   locret_204F2C
	bset    #6,oSprFlags(a0)
	rts

loc_204F1C:
	move.b  oAngle(a0),d1
	cmpi.b  #$80,d1
	bls.s   locret_204F2C
	bclr    #6,oSprFlags(a0)

locret_204F2C:
	rts
; -------------------------------------------------------------------------

PlaySpinSound:
;	move.w  #SFXRollFade,d0
;	jsr     PlayFMSound
	jmp     ObjSonic_StartRoll


; -------------------------------------------------------------------------


ObjSonic_Animate:
	lea     Ani_Sonic,a1
	moveq   #0,d0
	move.b  oAnim(a0),d0
	cmp.b   $1D(a0),d0
	beq.s   .DoAnim
	move.b  d0,$1D(a0)
	move.b  #0,$1B(a0)
	move.b  #0,$1E(a0)

.DoAnim:
	bsr.w   ObjSonic_GetMiniAnim
	add.w   d0,d0
	adda.w  (a1,d0.w),a1
	move.b  (a1),d0
	bmi.s   loc_204FD8
	move.b  oFlags(a0),d1
	andi.b  #1,d1
	andi.b  #$FC,oSprFlags(a0)
	or.b    d1,oSprFlags(a0)
	subq.b  #1,$1E(a0)
	bpl.s   locret_204FA6
	move.b  d0,$1E(a0)

sub_204F8A:
	moveq   #0,d1
	move.b  $1B(a0),d1
	move.b  1(a1,d1.w),d0
	beq.s   loc_204F9E
	bpl.s   loc_204F9E
	cmpi.b  #$FD,d0
	bge.s   loc_204FA8

loc_204F9E:
	move.b  d0,oMapFrame(a0)
	addq.b  #1,$1B(a0)

locret_204FA6:
	rts

loc_204FA8:
	addq.b  #1,d0
	bne.s   loc_204FB8
	move.b  #0,$1B(a0)
	move.b  1(a1),d0
	bra.s   loc_204F9E

loc_204FB8:
	addq.b  #1,d0
	bne.s   loc_204FCC
	move.b  2(a1,d1.w),d0
	sub.b   d0,$1B(a0)
	sub.b   d0,d1
	move.b  1(a1,d1.w),d0
	bra.s   loc_204F9E

loc_204FCC:
	addq.b  #1,d0
	bne.s   locret_204FD6
	move.b  2(a1,d1.w),oAnim(a0)

locret_204FD6:
	rts

loc_204FD8:
	subq.b  #1,$1E(a0)
	bpl.s   locret_204FA6
	addq.b  #1,d0
	bne.w   loc_205060
	tst.b   miniSonic.w
	bne.w   loc_205106
	moveq   #0,d1
	move.b  oAngle(a0),d0
	move.b  oFlags(a0),d2
	andi.b  #1,d2
	bne.s   loc_204FFE
	not.b   d0

loc_204FFE:
	addi.b  #$10,d0
	bpl.s   loc_205006
	moveq   #3,d1

loc_205006:
	andi.b  #$FC,oSprFlags(a0)
	eor.b   d1,d2
	or.b    d2,oSprFlags(a0)
	btst    #5,oFlags(a0)
	bne.w   loc_2050B4
	lsr.b   #4,d0
	andi.b  #6,d0
	move.w  $14(a0),d2
	bpl.s   loc_20502A
	neg.w   d2

loc_20502A:
	lea     ((Ani_Sonic+$70)).l,a1
	cmpi.w  #$600,d2
	bcc.s   loc_205042
	lea     ((Ani_Sonic+$68)).l,a1
	move.b  d0,d1
	lsr.b   #1,d1
	add.b   d1,d0

loc_205042:
	add.b   d0,d0
	move.b  d0,d3
	neg.w   d2
	addi.w  #$800,d2
	bpl.s   loc_205050
	moveq   #0,d2

loc_205050:
	lsr.w   #8,d2
	move.b  d2,$1E(a0)
	bsr.w   sub_204F8A
	add.b   d3,oMapFrame(a0)
	rts
; -------------------------------------------------------------------------

loc_205060:
	addq.b  #1,d0
	bne.s   loc_2050B0
	move.w  $14(a0),d2
	bpl.s   loc_20506C
	neg.w   d2

loc_20506C:
	lea     ((Ani_Sonic+$146)).l,a1
	tst.b   miniSonic.w
	bne.s   loc_20508A
	lea     ((Ani_Sonic+$80)).l,a1
	cmpi.w  #$600,d2
	bcc.s   loc_20508A
	lea     ((Ani_Sonic+$78)).l,a1

loc_20508A:
	neg.w   d2
	addi.w  #$400,d2
	bpl.s   loc_205094
	moveq   #0,d2

loc_205094
	lsr.w   #8,d2
	move.b  d2,$1E(a0)
	move.b  oFlags(a0),d1
	andi.b  #1,d1
	andi.b  #$FC,oSprFlags(a0)
	or.b    d1,oSprFlags(a0)
	bra.w   sub_204F8A

; -------------------------------------------------------------------------

loc_2050B0:
	addq.b  #1,d0
	bne.s   loc_2050F2

loc_2050B4:
	move.w  $14(a0),d2
	bmi.s   loc_2050BC
	neg.w   d2

loc_2050BC:
	addi.w  #$800,d2
	bpl.s   loc_2050C4
	moveq   #0,d2

loc_2050C4:
	lsr.w   #6,d2
	move.b  d2,$1E(a0)
	lea     ((Ani_Sonic+$158)).l,a1
	tst.b   miniSonic.w
	bne.s   loc_2050DC
	lea     ((Ani_Sonic+$88)).l,a1

loc_2050DC:
	move.b  oFlags(a0),d1
	andi.b  #1,d1
	andi.b  #$FC,oSprFlags(a0)
	or.b    d1,oSprFlags(a0)
	bra.w   sub_204F8A
; -------------------------------------------------------------------------

loc_2050F2:
	moveq   #0,d1
	move.b  $1B(a0),d1
	move.b  1(a1,d1.w),oMapFrame(a0)
	move.b  #0,$1E(a0)
	rts
; -------------------------------------------------------------------------

loc_205106:
	moveq   #0,d1
	move.b  oAngle(a0),d0
	move.b  oFlags(a0),d2
	andi.b  #1,d2
	bne.s   loc_205118
	not.b   d0

loc_205118:
	addi.b  #$10,d0
	bpl.s   loc_205120
	moveq   #0,d1

loc_205120:
	andi.b  #$FC,oSprFlags(a0)
	or.b    d2,oSprFlags(a0)
	addi.b  #$30,d0 ; '0'
	cmpi.b  #$60,d0 ; '`'
	bcs.s   loc_20514E
	bset    #2,oFlags(a0)
	move.b  #$A,oYRadius(a0)
	move.b  #5,oXRadius(a0)
	move.b  #$FF,d0
	bra.w   loc_205060

; -------------------------------------------------------------------------

loc_20514E:
	move.w  $14(a0),d2
	bpl.s   loc_205156
	neg.w   d2

loc_205156:
	lea     ((Ani_Sonic+$140)).l,a1
	cmpi.w  #$600,d2
	bcc.s   loc_205168
	lea     ((Ani_Sonic+$13A)).l,a1

loc_205168:
	neg.w   d2
	addi.w  #$800,d2
	bpl.s   loc_205172
	moveq   #0,d2

loc_205172:
	lsr.w   #8,d2
	move.b  d2,$1E(a0)
	bra.w   sub_204F8A

; -------------------------------------------------------------------------

ObjSonic_GetMiniAnim:
	tst.b   miniSonic.w
	beq.s   .End
	move.b  .MiniAnims(pc,d0.w),d0

.End:
	rts

; -------------------------------------------------------------------------

.MiniAnims:     
    dc.b    $21,   $18
	dcb.b 2,   $23
	dc.b    $27,   $1F,   $26,   $28,   $20,     9
	dc.b     $A,    $B,    $C,   $24,    $E,    $F
	dc.b    $28,   $11,   $12,   $13,   $14,   $15
	dc.b    $16,   $17,   $18,   $19
	dcb.b 2,   $25
	dc.b    $1C,   $1D,   $1E,   $1F,   $20,   $21
	dc.b    $22,   $23,   $24,   $25,   $26,   $27
	dc.b    $28,   $29,   $2A,   $30,   $2C,   $2D
	dc.b    $2E,   $2F

Ani_Sonic:      
    dc.w byte_205220-Ani_Sonic
    dc.w byte_205228-Ani_Sonic
    dc.w byte_205230-Ani_Sonic
    dc.w byte_205238-Ani_Sonic
    dc.w byte_205240-Ani_Sonic
    dc.w byte_205248-Ani_Sonic
    dc.w byte_20525E-Ani_Sonic
    dc.w byte_205262-Ani_Sonic
    dc.w byte_205266-Ani_Sonic
    dc.w byte_20526A-Ani_Sonic
    dc.w byte_20526E-Ani_Sonic
    dc.w byte_205272-Ani_Sonic
    dc.w byte_205276-Ani_Sonic
    dc.w byte_20527A-Ani_Sonic
    dc.w byte_20527E-Ani_Sonic
    dc.w byte_205282-Ani_Sonic
    dc.w byte_20528A-Ani_Sonic
    dc.w byte_20528E-Ani_Sonic
    dc.w byte_205292-Ani_Sonic
    dc.w byte_205298-Ani_Sonic
    dc.w byte_20529E-Ani_Sonic
    dc.w byte_2052A2-Ani_Sonic
    dc.w byte_2052AA-Ani_Sonic
    dc.w byte_2052AE-Ani_Sonic
    dc.w byte_2052B2-Ani_Sonic
    dc.w byte_2052B6-Ani_Sonic
    dc.w byte_2052C0-Ani_Sonic
    dc.w byte_2052C4-Ani_Sonic
    dc.w byte_2052C8-Ani_Sonic
    dc.w byte_2052CC-Ani_Sonic
    dc.w byte_2052D4-Ani_Sonic
    dc.w byte_2052D8-Ani_Sonic
    dc.w byte_2052EE-Ani_Sonic
    dc.w byte_2052F2-Ani_Sonic
    dc.w byte_2052F8-Ani_Sonic
    dc.w byte_2052FE-Ani_Sonic
    dc.w byte_205304-Ani_Sonic
    dc.w byte_205308-Ani_Sonic
    dc.w byte_20530C-Ani_Sonic
    dc.w byte_205310-Ani_Sonic
    dc.w byte_205318-Ani_Sonic
    dc.w byte_20531C-Ani_Sonic
    dc.w byte_205320-Ani_Sonic
    dc.w byte_205330-Ani_Sonic
    dc.w byte_205356-Ani_Sonic
    dc.w byte_20535A-Ani_Sonic
    dc.w byte_205362-Ani_Sonic
    dc.w byte_20536A-Ani_Sonic
    dc.w byte_205370-Ani_Sonic
    dc.w byte_20535A-Ani_Sonic
    dc.w byte_205362-Ani_Sonic
    dc.w byte_20536A-Ani_Sonic
byte_205220:    dc.b  $FF, $35, $36, $37, $38, $33, $34, $FF
byte_205228:    dc.b  $FF, $4B, $4C, $4D, $4E, $FF, $FF, $FF
byte_205230:    dc.b  $FE, $2D, $2E, $2F, $30, $31, $FF, $FF
byte_205238:    dc.b  $FE, $2D, $2E, $31, $2F, $30, $31, $FF
byte_205240:    dc.b  $FD, $64, $65, $66, $67, $FF, $FF, $FF
byte_205248:    dc.b  $17,   1,   1,   1,   1,   1,   1,   1,   1,   1
    			dc.b    1,   1,   1,   3,   2,   2,   2,   3,   4, $FE
    			dc.b    2,   0
byte_20525E:    dc.b  $1F, $6D, $6E, $FF 
byte_205262:    dc.b  $3F,   5, $FF,   0 
byte_205266:    dc.b  $3F, $60, $FF,   0 
byte_20526A:    dc.b  $3F, $33, $FF,   0 
byte_20526E:    dc.b  $3F, $34, $FF,   0 
byte_205272:    dc.b  $3F, $35, $FF,   0 
byte_205276:    dc.b  $3F, $36, $FF,   0 
byte_20527A:    dc.b    7, $5B, $5C, $FF 
byte_20527E:    dc.b    7, $3C, $3F, $FF 
byte_205282:    dc.b    7, $3C, $3D, $53, $3E, $54, $FF,   0
byte_20528A:    dc.b  $2F, $32, $FD,   0 
byte_20528E:    dc.b    4, $6B, $6C, $FF 
byte_205292:    dc.b   $F, $43, $43, $43, $FE,   1
byte_205298:    dc.b   $F, $43, $44, $FE,   1,   0
byte_20529E:    dc.b  $3F, $49, $FF,   0 
byte_2052A2:    dc.b   $B, $5F, $5F, $37, $38, $FD,   0,   0
byte_2052AA:    dc.b  $20, $68, $FF,   0 
byte_2052AE:    dc.b  $2F, $69, $FF,   0 
byte_2052B2:    dc.b    3, $6A, $FF,   0 
byte_2052B6:    dc.b    3, $4E, $4F, $50, $51, $52,   0, $FE,   1,   0
byte_2052C0:    dc.b    3, $5D, $FF,   0 
byte_2052C4:    dc.b    7, $5D, $5E, $FF 
byte_2052C8:    dc.b  $77,   0, $FD,   0 
byte_2052CC:    dc.b    3, $3C, $3D, $53, $3E, $54, $FF,   0
byte_2052D4:    dc.b    3, $3C, $FD,   0 
byte_2052D8:    dc.b  $17, $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F
    			dc.b  $6F, $6F, $6F, $70, $70, $70, $71, $70, $71, $FE
    			dc.b    2,   0
byte_2052EE:    dc.b  $3F, $72, $FF,   0 
byte_2052F2:    dc.b  $FF, $73, $74, $75, $74, $FF
byte_2052F8:    dc.b  $FF, $76, $77, $FF, $FF, $FF
byte_2052FE:    dc.b  $FE, $7C, $7D, $7E, $FF, $FF
byte_205304:    dc.b    7, $78, $78, $FF 
byte_205308:    dc.b    3, $79, $FF,   0 
byte_20530C:    dc.b  $1F, $7A, $7B, $FF 
byte_205310:    dc.b  $FD, $73, $74, $75, $FF, $FF, $FF,   0
byte_205318:    dc.b  $3F, $6F, $FF,   0 
byte_20531C:    dc.b  $3F,   6, $FF,   0 
byte_205320:    dc.b    3,   7,   7,   7,   7,   7,   9,   9,   8,   8
    			dc.b    8,   1,  $A,  $A, $FD,   5
byte_205330:    dc.b    9, $11, $11, $11, $11, $11, $11, $11, $11, $11
    			dc.b  $11, $11, $11, $12, $12, $12, $12, $13, $14, $14
    			dc.b  $14, $14, $14, $14, $14, $14, $15, $15, $15, $15
    			dc.b  $16, $16, $16, $16, $17, $FE,   1,   0
byte_205356:    dc.b    4, $18, $19, $FF 
byte_20535A:    dc.b  $FC, $1A, $1B, $1C, $1F, $1D, $1E, $FF
byte_205362:    dc.b  $FF,  $D,  $E,  $F, $10,  $B,  $C, $FF
byte_20536A:    dc.b  $FF, $61, $62, $63, $FF,   0
byte_205370:    dc.b  $13, $70, $6F, $70, $79, $FE,   1,   0


; -------------------------------------------------------------------------

LoadSonicDynPLC:
	lea     sonicLastFrame.w,a2
	cmpi.b  #1,0(a0)
	beq.s   .UpdateFrame
	lea     sonicLastFrameP2.w,a2

.UpdateFrame:
	moveq   #0,d0
	move.b  oMapFrame(a0),d0
	cmp.b   (a2),d0
	beq.s   .End
	move.b  d0,(a2)
	lea     (DPLC_Sonic).l,a2
	add.w   d0,d0
	adda.w  (a2,d0.w),a2
	moveq   #0,d1
	move.b  (a2)+,d1
	subq.b  #1,d1
	bmi.s   .End
	lea     sonicArtBuf.w,a3
	move.b  #1,updateSonicArt.w

.PieceLoop:
	moveq   #0,d2
	move.b  (a2)+,d2
	move.w  d2,d0
	lsr.b   #4,d0
	lsl.w   #8,d2
	move.b  (a2)+,d2
	lsl.w   #5,d2
	lea     ArtUnc_Sonic,a1
	adda.l  d2,a1

.CopyPieceLoop:
	movem.l (a1)+,d2-d6/a4-a6
	movem.l d2-d6/a4-a6,(a3)
	lea     $20(a3),a3
	dbf     d0,.CopyPieceLoop
	dbf     d1,.PieceLoop

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_ChkFlipper:
	moveq   #0,d0
	move.b  oPlayerStandObj(a0),d0
	lsl.w   #6,d0
	addi.l  #$FFD000,d0
	movea.l d0,a1
	cmpi.b  #$1E,0(a1)      ; Is this Obj1E? (pinball flipper from CCZ)
	bne.s   .End			; If not, terminate
	move.b  #1,$1C(a1)
	move.w  8(a1),d1
	move.w  $C(a1),d2
	addi.w  #$18,d2
	sub.w   oX(a0),d1
	sub.w   oY(a0),d2
	jsr     CalcAngle
	moveq   #0,d2
	move.b  $19(a1),d2
	move.w  oX(a0),d3
	sub.w   8(a1),d3
	add.w   d2,d3
	btst    #0,$22(a1)
	bne.s   .XFlip
	move.w  #$40,d1
	sub.w   d3,d1
	move.w  d1,d3

.XFlip:
	move.w  #$F600,d2
	move.w  d2,d1
	ext.l   d1
	muls.w  d3,d1
	divs.w  #$40,d1
	add.w   d1,d2
	moveq   #0,d1

.End:
	rts

; -------------------------------------------------------------------------


;FadeOutMusic:
	move.w  #$E,d0

SendSubCommand:
	rts
	move.w  d0,GACOMCMD0

loc_205454:
	tst.w   GACOMSTAT0
	beq.s   loc_205454
	move.w  #0,GACOMCMD0

loc_205464:
	tst.w   GACOMSTAT0
	bne.s   loc_205464
	rts

; -------------------------------------------------------------------------

AnimateObject:
	tst.b   1(a0)
	bpl.s   AnimateObject_End
	moveq   #0,d0
	move.b  oAnim(a0),d0
	cmp.b   $1D(a0),d0
	beq.s   .DoAnim
	move.b  d0,$1D(a0)
	move.b  #0,$1B(a0)
	move.b  #0,$1E(a0)

.DoAnim:
	subq.b  #1,$1E(a0)
	bpl.s   AnimateObject_End
	add.w   d0,d0
	adda.w  (a1,d0.w),a1
	move.b  (a1),$1E(a0)
	moveq   #0,d1
	move.b  $1B(a0),d1
	move.b  1(a1,d1.w),d0
	bmi.s   Ani_Loop

AniNext:
	move.b  d0,d1
	andi.b  #$1F,d0
	move.b  d0,oMapFrame(a0)
	move.b  oFlags(a0),d0
	rol.b   #3,d1
	eor.b   d0,d1
	andi.b  #3,d1
	andi.b  #$FC,oSprFlags(a0)
	or.b    d1,oSprFlags(a0)
	addq.b  #1,$1B(a0)

AnimateObject_End:
	rts

Ani_Loop:
	addq.b  #1,d0
	bne.s   Ani_LoopBackToFrame
	move.b  #0,$1B(a0)
	move.b  1(a1),d0
	bra.s   AniNext

Ani_LoopBackToFrame:
	addq.b  #1,d0
	bne.s   Ani_NewAnim
	move.b  2(a1,d1.w),d0
	sub.b   d0,$1B(a0)
	sub.b   d0,d1
	move.b  1(a1,d1.w),d0
	bra.s   AniNext

Ani_NewAnim:
	addq.b  #1,d0
	bne.s   Ani_IncRoutine
	move.b  2(a1,d1.w),oAnim(a0)

Ani_IncRoutine:
	addq.b  #1,d0
	bne.s   Ani_Reset_routine2
	addq.b  #2,oRoutine(a0)

Ani_Reset_routine2:
	addq.b  #1,d0
	bne.s   loc_205516
	move.b  #0,$1B(a0)
	clr.b   $25(a0)

loc_205516:
	addq.b  #1,d0
	bne.s   .End2
	addq.b  #2,$25(a0)

.End2:
	rts

; -------------------------------------------------------------------------
; A basic, unused test badnik
; -------------------------------------------------------------------------

ObjTestBadnik:
	move.b	#0,	debugCheat
	move.b	#0,	debugMode
	lea     objPlayerSlot.w,a1
	move.l	#MapSpr_Sonic,oMap(a1)
	move.w	#$780,oTile(a1)
	move.b	#2,oPriority(a1)
	move.b	#0,oMapFrame(a1)
	move.b	#4,oSprFlags(a1)
	bra.w   DeleteObject

; -------------------------------------------------------------------------
; Object destruction explosion
; -------------------------------------------------------------------------

ObjExplosion:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  Explosion_Index(pc,d0.w),d0
	jmp     Explosion_Index(pc,d0.w)

; -------------------------------------------------------------------------

Explosion_Index:
    dc.w Explosion_Main-Explosion_Index
	dc.w Explosion_Animate-Explosion_Index
	dc.w Explosion_End-Explosion_Index

; -------------------------------------------------------------------------

Explosion_Main:
	addq.b  #2,oRoutine(a0)
	ori.b   #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.w  #$680,2(a0)
	move.l  #MapSpr_Explosion,4(a0)
	move.b  #0,$20(a0)
	move.w  #1,oAnim(a0)

Explosion_Animate:
	lea     (AniSpr_Explosion).l,a1
	bsr.w   AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------

Explosion_End:
	tst.b   $25(a0)
	beq.s   .MakeFlower
	jmp     DeleteObject

; -------------------------------------------------------------------------

.MakeFlower:
	move.b  #$1F,0(a0)      ; Make object a flower seed
	move.b  #0,oRoutine(a0)      ; Clear object routine
	rts

; -------------------------------------------------------------------------

ObjFlower:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjFlower_Index(pc,d0.w),d0
	jsr     ObjFlower_Index(pc,d0.w)
	jmp     DrawObject

; -------------------------------------------------------------------------
ObjFlower_Index:
    dc.w ObjFlower_Init-ObjFlower_Index
	dc.w ObjFlower_Seed-ObjFlower_Index
	dc.w ObjFlower_Animate-ObjFlower_Index
	dc.w ObjFlower_Growing-ObjFlower_Index
	dc.w ObjFlower_Done-ObjFlower_Index
; -------------------------------------------------------------------------

ObjFlower_Init:
	ori.b   #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #0,oYRadius(a0)
	move.w  #$46D6,2(a0)
	move.l  #MapSpr_Flower,4(a0)
	bsr.w   ObjFlower_GetRespawnAddr
	move.b  (a1),d0
	move.b  #4,oRoutine(a0)
	move.b  #3,oAnim(a0)
	btst    #6,d0
	bne.s   ObjFlower_Animate
	move.w  #2,oAnim(a0)
	move.b  #2,oRoutine(a0)
	move.w  #$6D6,2(a0)

ObjFlower_Seed:
	jsr     CheckFloorEdge
	tst.w   d1
	bpl.s   .Fall
	add.w   d1,oY(a0)
	bsr.w   ObjFlower_GetRespawnAddr
	lea     flowerCount,a2
	move.b  (a2,d1.w),d0
	addq.b  #1,(a2,d1.w)
	bsr.w   ObjFlower_GetPosBuffer
	move.w  oX(a0),(a1,d0.w)
	move.w  oY(a0),2(a1,d0.w)
	move.b  #4,oRoutine(a0)
	move.b  #1,oAnim(a0)
	rts

.Fall:
	addq.w  #2,oY(a0)


ObjFlower_Animate:
	lea     (AniSpr_Flower).l,a1
	bra.w   AnimateObject

; -------------------------------------------------------------------------

ObjFlower_GetRespawnAddr:
	moveq   #0,d0
	move.b  $23(a0),d0
	move.w  d0,d1
	add.w   d1,d1
	add.w   d1,d0
	moveq   #0,d1
	move.b  timeZone,d1
	bclr    #7,d1
	add.w   d1,d0
	lea     savedObjFlags,a1
	lea     2(a1,d0.w),a1
	rts

; -------------------------------------------------------------------------

ObjFlower_GetPosBuffer:
	andi.w  #$3F,d0
	add.w   d0,d0
	add.w   d0,d0
	moveq   #0,d1
	move.b  timeZone,d1
	bclr    #7,d1
	lsl.w   #8,d1
	add.w   d1,d0
	lea     flowerPosBuf,a1
	rts

; -------------------------------------------------------------------------


ObjFlower_Growing:
	move.w  #$46D6,2(a0)
	move.b  #2,oAnim(a0)
	bra.s   ObjFlower_Animate

; -------------------------------------------------------------------------


ObjFlower_Done:
	move.b  #3,oAnim(a0)
	move.b  #4,oRoutine(a0)
	bra.s   ObjFlower_Animate

; -------------------------------------------------------------------------

ObjWaterfallSplash:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjWaterfallSplash_Index(pc,d0.w),d0
	jmp     ObjWaterfallSplash_Index(pc,d0.w)

; -------------------------------------------------------------------------

ObjWaterfallSplash_Index:
	dc.w ObjWaterfallSplash_Init-ObjWaterfallSplash_Index
	dc.w ObjWaterfallSplash_Main-ObjWaterfallSplash_Index
	dc.w ObjWaterfallSplash_Delete-ObjWaterfallSplash_Index

; -------------------------------------------------------------------------

ObjWaterfallSplash_Init:
	addq.b  #2,oRoutine(a0)
	ori.b   #4,oSprFlags(a0)
	move.l  #MapSpr_WaterfallSplash,4(a0)
	move.w  #$31E,2(a0)
	move.b  #1,$18(a0)

ObjWaterfallSplash_Main:
	lea     AniSpr_WaterfallSplash,a1
	bsr.w   AnimateObject
	jmp     DrawObject

ObjWaterfallSplash_Delete:
	jmp     DeleteObject

; -------------------------------------------------------------------------

ObjFlapDoorH:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjFlapDoorH_Index(pc,d0.w),d0
	jsr     ObjFlapDoorH_Index(pc,d0.w)
	jsr     DrawObject
	jmp     CheckObjDespawnTime

; -------------------------------------------------------------------------

ObjFlapDoorH_Index:
    dc.w ObjFlapFoorH_Init-ObjFlapDoorH_Index
	dc.w ObjFlapDoorH_Check-ObjFlapDoorH_Index
	dc.w ObjFlapDoorH_Animate-ObjFlapDoorH_Index
	dc.w ObjFlapDoorH_Reset-ObjFlapDoorH_Index

; -------------------------------------------------------------------------


ObjFlapDoorH_CheckPlayer:
	tst.w   $12(a1)
	bpl.s   .Solid
	bsr.w   ObjFlapDoor_ChkCollision
	beq.s   .Solid
	move.b  #4,oRoutine(a0)
	tst.b   $28(a0)
	bne.s   .End
	jsr     FindObjSlot
	bne.s   .End
	move.b  #$B,0(a1)
	move.w  oX(a0),8(a1)
	move.w  oY(a0),$C(a1)
	subq.w  #4,$C(a1)
	move.w  #SFXDoor,d0
	jmp     PlayFMSound

.End:
	rts

.Solid:
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	jmp     SolidObject

; -------------------------------------------------------------------------

ObjFlapFoorH_Init:
	addq.b  #2,oRoutine(a0)
	move.l  #MapSpr_ObjFlapDoor,4(a0)
	move.b  #1,$18(a0)
	ori.b   #4,oSprFlags(a0)
	move.b  #$2C,$19(a0)
	move.b  #8,oYRadius(a0)
	moveq   #$C,d0
	jsr     LevelObj_SetBaseTile

; -------------------------------------------------------------------------

ObjFlapDoorH_Check:
	lea     objPlayerSlot.w,a1
	bsr.w   ObjFlapDoorH_CheckPlayer
	lea     objPlayerSlot2.w,a1
	bra.w   ObjFlapDoorH_CheckPlayer

; -------------------------------------------------------------------------

ObjFlapDoorH_Animate:
	lea     (ani_205D14).l,a1
	bra.w   AnimateObject

; -------------------------------------------------------------------------

ObjFlapDoorH_Reset:
	move.b  #1,$1D(a0)
	move.b  #0,oMapFrame(a0)
	subq.b  #4,oRoutine(a0)
	rts

; -------------------------------------------------------------------------


ObjFlapDoor_ChkCollision:
	move.w  8(a1),d0
	sub.w   oX(a0),d0
	moveq   #0,d1
	move.b  $19(a0),d1
	add.w   d1,d0
	bmi.s   .NoCollision
	add.w   d1,d1
	cmp.w   d1,d0
	bcc.s   .NoCollision
	move.w  $C(a1),d0
	sub.w   oY(a0),d0
	moveq   #0,d1
	move.b  oYRadius(a0),d1
	add.w   d1,d0
	bmi.s   .NoCollision
	add.w   d1,d1
	cmp.w   d1,d0
	bcc.s   .NoCollision
	moveq   #1,d0
	rts
.NoCollision:
	moveq   #0,d0
	rts

; -------------------------------------------------------------------------
; Water splash FX object
; Used in R1 for exiting a trapdoor
; -------------------------------------------------------------------------

ObjWaterSplash:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjWaterSplash_Index(pc,d0.w),d0
	jmp     ObjWaterSplash_Index(pc,d0.w)

; -------------------------------------------------------------------------
ObjWaterSplash_Index:
    dc.w ObjWaterSplash_Init-ObjWaterSplash_Index
	dc.w ObjWaterSplash_Main-ObjWaterSplash_Index
	dc.w ObjWaterSplash_End-ObjWaterSplash_Index
; -------------------------------------------------------------------------

ObjWaterSplash_Init:
	addq.b  #2,oRoutine(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.l  #MapSpr_WaterSplash,4(a0)
	move.b  $28(a0),oAnim(a0)
	moveq   #$D,d0
	jsr     LevelObj_SetBaseTile
	move.w  #SFXWaterSplash,d0
	cmpi.b  #2,$28(a0)
	bcs.s   .PlaySound
	move.w  #SFXWaterSplash,d0

.PlaySound:
	jsr     PlayFMSound

ObjWaterSplash_Main:
	lea     AniSpr_WaterSplash,a1

ObjWaterSplash_End:
	jmp     DeleteObject

; -------------------------------------------------------------------------
; Shield, Invincibility, and TimeWarp object handler
; -------------------------------------------------------------------------

ObjPowerup:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjPowerup_Index(pc,d0.w),d1
	jmp     ObjPowerup_Index(pc,d1.w)
; -------------------------------------------------------------------------
ObjPowerup_Index:
    dc.w ObjPowerup_Init-ObjPowerup_Index       
	dc.w ObjPowerup_Shield-ObjPowerup_Index
	dc.w ObjPowerup_InvStars-ObjPowerup_Index
	dc.w ObjPowerup_TimeStars-ObjPowerup_Index
; -------------------------------------------------------------------------

ObjPowerup_Init:
	addq.b  #2,oRoutine(a0)
	move.l  #MapSpr_Powerup,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	move.w  #$544,2(a0)
	tst.b   oAnim(a0)
	beq.s   .End
	addq.b  #2,oRoutine(a0)
	cmpi.b  #5,oAnim(a0)
	bcs.s   .End
	addq.b  #2,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjPowerup_Shield:
	tst.b   shield
	beq.s   .Delete
	tst.b   timeWarp
	bne.s   .End2
	tst.b   invincible
	bne.s   .End2
	jsr     GetPlayerObject
	move.w  8(a6),oX(a0)
	move.w  $C(a6),oY(a0)
	move.b  $22(a6),oFlags(a0)
	lea     (AniSpr_Powerup).l,a1
	jsr     AnimateObject
	bra.w   ObjPowerup_ChkSaveRout

.End2:
	rts

.Delete:
	jmp     DeleteObject

; -------------------------------------------------------------------------

ObjPowerup_InvStars:
	tst.b   timeWarp
	beq.s   .NoTimeWarp
	rts

.NoTimeWarp:
	tst.b   invincible
	bne.s   ObjPowerup_ShowStars
	jmp     DeleteObject
; -------------------------------------------------------------------------

ObjPowerup_TimeStars:
	tst.b   timeWarp
	bne.s   ObjPowerup_ShowStars
	jmp     DeleteObject

; -------------------------------------------------------------------------

ObjPowerup_ShowStars:
	move.w  sonicRecordIndex.w,d0
	move.b  oAnim(a0),d1
	subq.b  #1,d1
	cmpi.b  #4,d1
	bcs.s   .GotDelta
	subq.b  #4,d1

.GotDelta:
	lsl.b   #3,d1
	move.b  d1,d2
	add.b   d1,d1
	add.b   d2,d1
	addq.b  #4,d1
	sub.b   d1,d0
	move.b  $30(a0),d1
	sub.b   d1,d0
	addq.b  #4,d1
	cmpi.b  #$18,d1
	bcs.s   .NoCap
	moveq   #0,d1

.NoCap:
	move.b  d1,$30(a0)
	lea     sonicRecordBuf.w,a1
	lea     (a1,d0.w),a1
	move.w  (a1)+,oX(a0)
	move.w  (a1)+,oY(a0)
	jsr     GetPlayerObject
	move.b  $22(a6),oFlags(a0)
	lea     (AniSpr_Powerup).l,a1
	jsr     AnimateObject

ObjPowerup_ChkSaveRout:
	move.b  powerup,d0
	andi.b  #7,d0
	cmp.b   oRoutine(a0),d0
	beq.s   .Display
	move.b  oRoutine(a0),powerup
	bset    #7,powerup

.Display:
	jmp     DrawObject

; -------------------------------------------------------------------------

LoadShieldArt:
	bclr    #7,powerup
	beq.s   .End
	moveq   #0,d0
	move.b  powerup,d0
	subq.b  #2,d0
	add.w   d0,d0
	movea.l ShieldArtIndex(pc,d0.w),a1
	lea     aniArtBuffer,a2
	move.w  #$BF,d0

.Loop:
	move.l  (a1)+,(a2)+
	dbf     d0,.Loop
	lea     VDPCTRL,a5
	move.l  #$94029340,(a5)
	move.l  #$968C9580,(a5)
	move.w  #$977F,(a5)
	move.w  #$6880,(a5)
	move.w  #$82,dmaCmdLow.w
	move.w  dmaCmdLow.w,(a5)

.End:
	rts

; -------------------------------------------------------------------------

ShieldArtIndex: 
    dc.l ArtUnc_Shield
	dc.l ArtUnc_Invincibility
	dc.l ArtUnc_TimeTravelSpark

; -------------------------------------------------------------------------

AniSpr_Powerup:	
	include	"Level/_Objects/Powerup/Animation Script.asm"
MapSpr_Powerup: 
	include	"Level/_Objects/Powerup/Mappings.asm"
MapSpr_WaterSplash:
	include	"Level/_Objects/Water Splash/Mappings.asm"
ani_205D14:     dc.w byte_205D16-*      ; DATA XREF: ObjFlapDoorH_Animate?o
byte_205D16:    dc.b  0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1,$FC
		        ; DATA XREF: ROM:ani_205D14?o
MapSpr_ObjFlapDoor:
	incbin	"Level/_Objects/Flap Door/Mappings.bin"	;	??? ~ MDT
AniSpr_WaterfallSplash:
	include	"Level/_Objects/Waterfall Splash/Animation Script.asm"
MapSpr_WaterfallSplash:
	include	"Level/_Objects/Waterfall Splash/Mappings.asm"
AniSpr_Explosion:
	include	"Level/_Objects/Explosion/Animation Script.asm"
MapSpr_Explosion:
	include	"Level/_Objects/Explosion/Mappings.asm"
AniSpr_Flower:	
	include	"Level/_Objects/Flower/Animation Script.asm"
MapSpr_Flower:	
	include	"Level/_Objects/Flower/Mappings.asm"

; -------------------------------------------------------------------------
; Routine that restores saved player timewarp data on timewarp exit
; -------------------------------------------------------------------------

RestoreFromTimeTravel:
;	move.b  warpSpawnMode,spawnMode
	move.w  warpX,8(a6)
	move.w  warpY,$C(a6)
	move.b  warpEventRoutine,eventRoutine.w
	move.b  warpWaterRoutine,waterRoutine.w
	move.w  warpBtmBound,bottomBound.w
	move.w  warpBtmBound,destBottomBound.w
	move.w  warpCamX,cameraX.w
	move.w  warpCamY,cameraY.w
	move.w  warpCamBgX,cameraBgX.w
	move.w  warpCamBgY,cameraBgY.w
	move.w  warpCamBg2X,cameraBg2X.w
	move.w  warpCamBg2Y,cameraBg2Y.w
	move.w  warpCamBg3X,cameraBg3X.w
	move.w  warpCamBg3Y,cameraBg3Y.w
	cmpi.b  #1,zone
	bne.s   loc_205F16
	move.w  warpWaterHeight,waterHeight2.w
	move.b  warpWaterRoutine,waterRoutine.w
	move.b  warpWaterFull,waterFullscreen.w
loc_205F16: 
	tst.b   spawnMode
	bpl.s   locret_205F2C
	move.w  warpX,d0
	subi.w  #$A0,d0
	move.w  d0,leftBound.w

locret_205F2C:
	rts

; -------------------------------------------------------------------------

sub_205F2E:     
	cmpi.b  #2,spawnMode
	beq.w   RestoreFromTimeTravel
	move.b  savedSpawnMode,spawnMode
	move.w  savedX,8(a6)
	move.w  savedY,$C(a6)
	move.w  savedRings,rings
	move.b  savedLivesFlags,livesFlags
;	clr.w   rings
;	clr.b   livesFlags
	move.l  savedTime,time
	move.b  #$3B,timeFrames.l ; ';'
	subq.b  #1,timeSeconds.l
	move.b  savedEventRoutine,eventRoutine.w
	move.b  savedWaterRoutine,waterRoutine.w
	move.w  savedBtmBound,bottomBound.w
	move.w  savedBtmBound,destBottomBound.w
	move.w  savedCamX,cameraX.w
	move.w  savedCamY,cameraY.w
	move.w  savedCamBgX,cameraBgX.w
	move.w  savedCamBgY,cameraBgY.w
	move.w  savedCamBg2X,cameraBg2X.w
	move.w  savedCamBg2Y,cameraBg2Y.w
	move.w  savedCamBg3X,cameraBg3X.w
	move.w  savedCamBg3Y,cameraBg3Y.w
	cmpi.b  #1,zone
	bne.s   loc_20600E
	move.w  savedWaterHeight,waterHeight2.w
	move.b  savedWaterRoutine,waterRoutine.w
	move.b  savedWaterFull,waterFullscreen.w

loc_20600E:
	tst.b   spawnMode
	bpl.s   locret_206024
	move.w  savedX,d0
	subi.w  #$A0,d0
	move.w  d0,leftBound.w

locret_206024:
	rts

; -------------------------------------------------------------------------

sub_206026:
	move.l  oX(a0),d3
	move.l  oY(a0),d2
	move.w  oXVel(a0),d1
	ext.l   d1
	asl.l   #8,d1
	add.l   d1,d3
	move.w  oYVel(a0),d1
	ext.l   d1
	asl.l   #8,d1
	add.l   d1,d2
	swap    d2
	swap    d3
	move.b  d0,primaryAngle.w
	move.b  d0,secondaryAngle.w
	move.b  d0,d1
	addi.b  #$20,d0
	bpl.s   loc_206062
	move.b  d1,d0
	bpl.s   loc_20605C
	subq.b  #1,d0

loc_20605C:
	addi.b  #$20,d0
	bra.s   loc_20606C

loc_206062:
	move.b  d1,d0
	bpl.s   loc_206068
	addq.b  #1,d0

loc_206068:
	addi.b  #$1F,d0

loc_20606C:
	andi.b  #$C0,d0
	beq.w   loc_20613C
	cmpi.b  #$80,d0
	beq.w   Player_GetCeilDist_Part2
	andi.b  #$38,d1
	bne.s   loc_206084
	addq.w  #8,d2

loc_206084:
	cmpi.b  #$40,d0
	beq.w   Player_GetLWallDist_Part2
	bra.w   Player_GetRWallDist_Part2

; -------------------------------------------------------------------------

sub_206090:
	move.b  d0,primaryAngle.w
	move.b  d0,secondaryAngle.w
	addi.b  #$20,d0 ; ' '
	andi.b  #$C0,d0
	cmpi.b  #$40,d0 ; '.'
	beq.w   Player_CheckLCeil
	cmpi.b  #$80,d0
	beq.w   sub_206260
	cmpi.b  #$C0,d0
	beq.w   loc_2061A0

; -------------------------------------------------------------------------

sub_2060B8:
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	moveq   #0,d0
	move.b  oYRadius(a0),d0
	ext.w   d0
	add.w   d0,d2
	move.b  oXRadius(a0),d0
	ext.w   d0
	add.w   d0,d3
	lea     primaryAngle.w,a4
	movea.w #$10,a3
	move.w  #0,d6
	moveq   #$D,d5
	jsr     FindLevelFloor
	move.w  d1,-(sp)
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	moveq   #0,d0
	move.b  oYRadius(a0),d0
	ext.w   d0
	add.w   d0,d2
	move.b  oXRadius(a0),d0
	ext.w   d0
	sub.w   d0,d3
	lea     secondaryAngle.w,a4
	movea.w #$10,a3
	move.w  #0,d6
	moveq   #$D,d5
	jsr     FindLevelFloor
	move.w  (sp)+,d0
	move.b  #0,d2

Player_ChooseAngle:
	move.b  secondaryAngle.w,d3
	cmp.w   d0,d1
	ble.s   loc_20612A
	move.b  primaryAngle.w,d3
	exg     d0,d1

loc_20612A:
	btst    #0,d3
	beq.s   locret_206132
	move.b  d2,d3

locret_206132:
	rts

; -------------------------------------------------------------------------
; Player_Check....   something...

	move.w  oY(a0),d2
	move.w  oX(a0),d3

loc_20613C:
	addi.w  #$A,d2
	lea     primaryAngle.w,a4
	movea.w #$10,a3
	move.w  #0,d6
	moveq   #$E,d5
	jsr     FindLevelFloor
	move.b  #0,d2

loc_206158:
	move.b  primaryAngle.w,d3
	btst    #0,d3
	beq.s   locret_206164
	move.b  d2,d3

locret_206164:
	rts

; -------------------------------------------------------------------------

CheckFloorEdge:
	move.w  oX(a0),d3
	move.w  oY(a0),d2
	moveq   #0,d0
	move.b  oYRadius(a0),d0
	ext.w   d0
	add.w   d0,d2
	lea     primaryAngle.w,a4
	move.b  #0,(a4)
	movea.w #$10,a3
	move.w  #0,d6
	moveq   #$D,d5
	jsr     FindLevelFloor
	move.b  primaryAngle.w,d3
	btst    #0,d3
	beq.s   locret_20619E
	move.b  #0,d3

locret_20619E:
	rts

; -------------------------------------------------------------------------

loc_2061A0:
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	moveq   #0,d0
	move.b  oXRadius(a0),d0
	ext.w   d0
	sub.w   d0,d2
	move.b  oYRadius(a0),d0
	ext.w   d0
	add.w   d0,d3
	lea     primaryAngle.w,a4
	movea.w #$10,a3
	move.w  #0,d6
	moveq   #$E,d5
	jsr     FindLevelWall
	move.w  d1,-(sp)
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	moveq   #0,d0
	move.b  oXRadius(a0),d0
	ext.w   d0
	add.w   d0,d2
	move.b  oYRadius(a0),d0
	ext.w   d0
	add.w   d0,d3
	lea     secondaryAngle.w,a4
	movea.w #$10,a3
	move.w  #0,d6
	moveq   #$E,d5
	jsr     FindLevelWall
	move.w  (sp)+,d0
	move.b  #$C0,d2
	bra.w   Player_ChooseAngle

; -------------------------------------------------------------------------


Player_GetRWallDist:
	move.w  oY(a0),d2
	move.w  oX(a0),d3

Player_GetRWallDist_Part2:
	addi.w  #$A,d3
	lea     primaryAngle.w,a4
	movea.w #$10,a3
	move.w  #0,d6
	moveq   #$E,d5
	jsr     FindLevelWall
	move.b  #$C0,d2
	bra.w   loc_206158


sub_206230:
	add.w   oX(a0),d3
	move.w  oY(a0),d2
	lea     primaryAngle.w,a4
	move.b  #0,(a4)
	movea.w #$10,a3
	move.w  #0,d6
	moveq   #$E,d5
	jsr     FindLevelWall
	move.b  primaryAngle.w,d3
	btst    #0,d3
	beq.s   .End
	move.b  #$C0,d3

.End:
	rts

; -------------------------------------------------------------------------

sub_206260:
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	moveq   #0,d0
	move.b  oYRadius(a0),d0
	ext.w   d0
	sub.w   d0,d2
	eori.w  #$F,d2
	move.b  oXRadius(a0),d0
	ext.w   d0
	add.w   d0,d3
	lea     primaryAngle.w,a4
	movea.w #$FFF0,a3
	move.w  #$1000,d6
	moveq   #$E,d5
	jsr     FindLevelFloor
	move.w  d1,-(sp)
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	moveq   #0,d0
	move.b  oYRadius(a0),d0
	ext.w   d0
	sub.w   d0,d2
	eori.w  #$F,d2
	move.b  oXRadius(a0),d0
	ext.w   d0
	sub.w   d0,d3
	lea     secondaryAngle.w,a4
	movea.w #$FFF0,a3
	move.w  #$1000,d6
	moveq   #$E,d5
	jsr     FindLevelFloor
	move.w  (sp)+,d0
	move.b  #$80,d2
	bra.w   Player_ChooseAngle

; -------------------------------------------------------------------------

Player_GetCeilDist:
	move.w  oY(a0),d2
	move.w  oX(a0),d3

Player_GetCeilDist_Part2:
	subi.w  #$A,d2
	eori.w  #$F,d2
	lea     primaryAngle.w,a4
	movea.w #$FFF0,a3
	move.w  #$1000,d6
	moveq   #$E,d5
	jsr     FindLevelFloor
	move.b  #$80,d2
	bra.w   loc_206158

; -------------------------------------------------------------------------

ObjGetCeilDist:
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	moveq   #0,d0
	move.b  oYRadius(a0),d0
	ext.w   d0
	sub.w   d0,d2
	eori.w  #$F,d2
	lea     primaryAngle.w,a4
	movea.w #$FFF0,a3
	move.w  #$1000,d6
	moveq   #$E,d5
	jsr     FindLevelFloor
	move.b  primaryAngle.w,d3
	btst    #0,d3
	beq.s   locret_206334
	move.b  #$80,d3

locret_206334:
	rts

; -------------------------------------------------------------------------

Player_CheckLCeil:
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	moveq   #0,d0
	move.b  oXRadius(a0),d0
	ext.w   d0
	sub.w   d0,d2
	move.b  oYRadius(a0),d0
	ext.w   d0
	sub.w   d0,d3
	eori.w  #$F,d3
	lea     primaryAngle.w,a4
	movea.w #$FFF0,a3
	move.w  #$800,d6
	moveq   #$E,d5
	jsr     FindLevelWall
	move.w  d1,-(sp)
	move.w  oY(a0),d2
	move.w  oX(a0),d3
	moveq   #0,d0
	move.b  oXRadius(a0),d0
	ext.w   d0
	add.w   d0,d2
	move.b  oYRadius(a0),d0
	ext.w   d0
	sub.w   d0,d3
	eori.w  #$F,d3
	lea     secondaryAngle.w,a4
	movea.w #$FFF0,a3
	move.w  #$800,d6
	moveq   #$E,d5
	jsr     FindLevelWall
	move.w  (sp)+,d0
	move.b  #$40,d2 ; '.'
	bra.w   Player_ChooseAngle

; -------------------------------------------------------------------------


Player_GetLWallDist:

	move.w  oY(a0),d2
	move.w  oX(a0),d3

Player_GetLWallDist_Part2:
	subi.w  #$A,d3
	eori.w  #$F,d3
	lea     primaryAngle.w,a4
	movea.w #$FFF0,a3
	move.w  #$800,d6
	moveq   #$E,d5
	jsr     FindLevelWall
	move.b  #$40,d2 ; '.'
	bra.w   loc_206158


ObjGetLWallDist:
	add.w   oX(a0),d3
	move.w  oY(a0),d2
	lea     primaryAngle.w,a4
	move.b  #0,(a4)
	movea.w #$FFF0,a3
	move.w  #$800,d6
	moveq   #$E,d5
	jsr     FindLevelWall
	move.b  primaryAngle.w,d3
	btst    #0,d3
	beq.s   locret_206400
	move.b  #$40,d3 ; '.'

locret_206400:
	rts
; -------------------------------------------------------------------------

Player_ObjCollide:
	nop
	move.w  oX(a0),d2
	move.w  oY(a0),d3
	subq.w  #8,d2
	moveq   #0,d5
	move.b  oYRadius(a0),d5
	subq.b  #3,d5
	sub.w   d5,d3
	cmpi.b  #$39,oMapFrame(a0)
	bne.s   .NoDuck_
	addi.w  #$C,d3
	moveq   #$A,d5

.NoDuck_:
	move.w  #$10,d4
	add.w   d5,d5
	lea     dynObjects.w,a1
	move.w  #$5F,d6 

loc_206434:
	tst.b   1(a1)
	bpl.s   Player_ObjCollide_Next
	move.b  $20(a1),d0
	bne.w   Player_ObjCollide_CheckWidth

Player_ObjCollide_Next:
	lea     $40(a1),a1
	dbf     d6,loc_206434
	moveq   #0,d0
	rts
; -------------------------------------------------------------------------

ObjColSizes:
				dc.b $14,$14
                dc.b $12, $C
                dc.b $10,$10
                dc.b   4,$10
                dc.b  $C,$12
                dc.b $10,$10
                dc.b   6,  6
                dc.b $18, $C
                dc.b  $C,$10
                dc.b $10, $C
                dc.b   8,  8
                dc.b $14,$10
                dc.b $14,  8
                dc.b  $E, $E
                dc.b $18,$18
                dc.b $28,$10
                dc.b $10,$18
                dc.b   8,$10
                dc.b $20,$70
                dc.b $40,$20
                dc.b -$80,$20
                dc.b $20,$20
                dc.b   8,  8
                dc.b   4,  4
                dc.b $20,  8
                dc.b  $C, $C
                dc.b   8,  4
                dc.b $18,  4
                dc.b $28,  4
                dc.b   4,  8
                dc.b   4,$18
                dc.b   4,$28
                dc.b   4,$20
                dc.b $18,$18
                dc.b  $C,$18
                dc.b $48,  8
                dc.b   8, $C
                dc.b $10,  8
                dc.b $20,$10
                dc.b $20,$10
                dc.b  $C,$10
                dc.b $10,$10
                dc.b  $C, $C
                dc.b $10,$10
                dc.b   4,  4
                dc.b $10,$10
                dc.b   0,  0
                dc.b   0,  0
                dc.b   0,  0
                dc.b   0,  0
                dc.b   0,  0
                dc.b   0,  0
                dc.b   0,  0
                dc.b   0,  0
                dc.b   0,  0
                dc.b   0,  0
                dc.b   0,  0
                dc.b $28,$22
                dc.b $12, $E
                dc.b $20,$18
                dc.b  $C,$14
                dc.b $20, $C
                dc.b  $A,$10

; -------------------------------------------------------------------------

Player_ObjCollide_CheckWidth:
	andi.w  #$3F,d0 ; '?'
	add.w   d0,d0
	lea     ObjColSizes,a2
	lea     -2(a2,d0.w),a2
	moveq   #0,d1
	move.b  (a2)+,d1
	move.w  8(a1),d0
	sub.w   d1,d0
	sub.w   d2,d0
	bcc.s   .TouchRight
	add.w   d1,d1
	add.w   d1,d0
	bcs.s   .CheckHeight
	bra.w   Player_ObjCollide_Next

.TouchRight:
	cmp.w   d4,d0
	bhi.w   Player_ObjCollide_Next

.CheckHeight:
	moveq   #0,d1
	move.b  (a2)+,d1
	move.w  $C(a1),d0
	sub.w   d1,d0
	sub.w   d3,d0
	bcc.s   .TouchBottom
	add.w   d1,d1
	add.w   d0,d1
	bcs.s   .CheckColType
	bra.w   Player_ObjCollide_Next
; -------------------------------------------------------------------------

.TouchBottom:
	cmp.w   d5,d0
	bhi.w   Player_ObjCollide_Next

.CheckColType:
	move.b  $20(a1),d1
	andi.b  #$C0,d1
	beq.w   Player_TouchEnemy
	cmpi.b  #$C0,d1
	beq.w   Player_TouchSpecial
	tst.b   d1
	bmi.w   Player_TouchHazard
	move.b  $20(a1),d0
	andi.b  #$3F,d0
	cmpi.b  #6,d0
	beq.s   Player_TouchMonitor
	cmpi.w  #$5A,$30(a0)
	bcc.w   .End
	addq.b  #2,$24(a1)

.End:
	rts
	
; -------------------------------------------------------------------------

Player_TouchMonitor:
	tst.w   oYVel(a0)
	bpl.s   .GoingDown
	move.w  oY(a0),d0
	subi.w  #$10,d0
	cmp.w   $C(a1),d0
	bcs.s   .End
	neg.w   oYVel(a0)
	move.w  #$FE80,$12(a1)
	tst.b   $25(a1)
	bne.s   .End
	addq.b  #4,$25(a1)
	rts

.GoingDown:
	cmpi.b  #2,oAnim(a0)
	bne.s   .End
	neg.w   oYVel(a0)
	addq.b  #2,$24(a1)

.End:
	rts

; -------------------------------------------------------------------------

Player_TouchEnemy:
	tst.b   invincible
	bne.s   .DamageEnemy
	cmpi.b  #2,oAnim(a0)
	bne.w   Player_TouchHazard

.DamageEnemy:
	tst.b   $21(a1)
	beq.s   .KillEnemy
	neg.w   oXVel(a0)
	neg.w   oYVel(a0)
	asr     oXVel(a0)
	asr     oYVel(a0)
	move.b  #0,$20(a1)
	subq.b  #1,$21(a1)
	bne.s   .End3
	bset    #7,$22(a1)

.End3:
	rts
; -------------------------------------------------------------------------

.KillEnemy:
	bset    #7,$22(a1)
	moveq   #0,d0
	move.w  scoreChain.w,d0
	addq.w  #2,scoreChain.w
	cmpi.w  #6,d0
	bcs.s   .CappedChain
	moveq   #6,d0

.CappedChain:
	move.w  d0,$3E(a1)
	move.w  EnemyPoints(pc,d0.w),d0
	cmpi.w  #$20,scoreChain.w
	bcs.s   .GivePoints
	move.w  #$3E8,d0
	move.w  #$A,$3E(a1)

.GivePoints:
	bsr.w   sub_20982A
	move.w  #SFXExplosion,d0
	jsr     PlayFMSound
	move.b  #$18,0(a1)
	move.b  #0,$24(a1)
	tst.w   oYVel(a0)
	bmi.s   loc_2065EC
	move.w  oY(a0),d0
	cmp.w   $C(a1),d0
	bcc.s   loc_2065F4
	neg.w   oYVel(a0)
	rts

loc_2065EC:
	addi.w  #$100,oYVel(a0)
	rts

loc_2065F4:
	subi.w  #$100,oYVel(a0)
	rts

; -------------------------------------------------------------------------

EnemyPoints:    
	dc.w 10, 20, 50, 100 

; -------------------------------------------------------------------------

Player_TouchHazard2:
	bset    #7,$22(a1)

Player_TouchHazard:
	tst.b   invincible
	beq.s   .ChkHurt

.NoHurt:
	moveq   #$FFFFFFFF,d0
	rts

.ChkHurt:
	nop
	tst.w   $30(a0)
	bne.s   .NoHurt
	movea.l a1,a2

; -------------------------------------------------------------------------

HurtPlayer:
	tst.b   shield
	bne.s   ClearCharge
	tst.w   rings
	beq.w   loc_2066A8
	jsr     FindObjSlot
	bne.s   ClearCharge
	move.b  #$11,0(a1)
	move.w  oX(a0),8(a1)
	move.w  oY(a0),$C(a1)

ClearCharge:
	move.b  #0,shield
	move.b  #4,oRoutine(a0)
	bsr.w   Player_ResetOnFloor
	bset    #1,oFlags(a0)
	move.w  #$FC00,oYVel(a0)
	move.w  #$FE00,oXVel(a0)
	btst    #6,oFlags(a0)
	beq.s   .NotUnderwater
	move.w  #$FE00,oYVel(a0)
	move.w  #$FF00,oXVel(a0)

.NotUnderwater:
	move.w  oX(a0),d0
	cmp.w   8(a2),d0
	bcs.s   .GotXVel
	neg.w   oXVel(a0)

.GotXVel:
	move.w  #0,$14(a0)
	move.b  #$1A,oAnim(a0)
	move.w  #$78,$30(a0)
	moveq   #$FFFFFFFF,d0
	rts

loc_2066A8:
	tst.w   debugCheat
	bne.w   ClearCharge

; -------------------------------------------------------------------------

KillPlayer:	
	tst.w   debugMode
	bne.s   loc_206708
	tst.b   $29(a0)
	beq.w   DeleteObject
	move.b  #0,invincible
	move.b  #6,oRoutine(a0)
	bsr.w   Player_ResetOnFloor
	bset    #1,oFlags(a0)
	move.w  #$F900,oYVel(a0)
	move.w  #0,oXVel(a0)
	move.w  #0,$14(a0)
	move.w  oY(a0),$38(a0)
	move.b  #$18,oAnim(a0)
	bset    #7,2(a0)
	move.w  #SFXDie,d0
	jsr     PlayFMSound

loc_206708:
	moveq   #$FFFFFFFF,d0
	rts

; -------------------------------------------------------------------------

Player_TouchSpecial:
	move.b  oColType(a1),d1
	andi.b  #$3F,d1 ; '?'
	cmpi.b  #$1F,d1
	beq.s   .CheckIfRoll
	cmpi.b  #$B,d1
	beq.s   .TouchHazard
	cmpi.b  #$C,d1
	beq.s   .TouchMechaBlu
	cmpi.b  #$17,d1
	beq.s   .CheckIfRoll
	cmpi.b  #$21,d1 ; '!'
	beq.s   .CheckIfRoll
	tst.b   (bossActive).w
	beq.w   .NoBossHere
	cmpi.b  #$3C,d1
	blt.s   .NoBossHere
	cmpi.b  #$3F,d1 ; '?'
	bgt.s   .NoBossHere
	bsr.w   Player_TouchEnemy
	tst.b   $20(a1)
	bne.s   .BossStatwait
	addq.b  #3,$21(a1)

.BossStatwait:
	clr.b   $20(a1)
	bra.s   .CheckIfRoll

.NoBossHere:
	rts

.TouchHazard:
	bra.w   Player_TouchHazard2

.TouchMechaBlu:
	sub.w   d0,d5
	cmpi.w  #8,d5
	bcc.s   .TouchEnemy
	move.w  8(a1),d0
	subq.w  #4,d0
	btst    #0,$22(a1)
	beq.s   .NotFlipped
	subi.w  #$10,d0

.NotFlipped:
	sub.w   d2,d0
	bcc.s   .CheckIfRight
	addi.w  #$18,d0
	bcs.s   .TouchHazard2
	bra.s   .TouchEnemy

.CheckIfRight:
	cmp.w   d4,d0
	bhi.s   .TouchEnemy

.TouchHazard2:
	bra.w   Player_TouchHazard

.TouchEnemy:
	bra.w   Player_TouchEnemy

.CheckIfRoll:
	addq.b  #1,$21(a1)
	cmpa.w  #$D000,a0
	beq.s   .End
	addq.b  #1,$21(a1)

.End:
	rts

; -------------------------------------------------------------------------
; Unused waterfall generator
; -------------------------------------------------------------------------

ObjWaterfall:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjWaterfall_Index(pc,d0.w),d0
	jsr     ObjWaterfall_Index(pc,d0.w)
	lea     (Ani_Waterfall).l,a1
	jsr     AnimateObject
	jmp     DrawObject

; -------------------------------------------------------------------------

ObjWaterfall_Index:
    dc.w ObjWaterfall_Init-ObjWaterfall_Index
	dc.w ObjWaterfall_Main-ObjWaterfall_Index

; -------------------------------------------------------------------------

ObjWaterfall_Init:
	addq.b  #2,oRoutine(a0)
	move.l  #MapSpr_Waterfall,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	move.w  #$3BA,2(a0)
	andi.w  #$FFF0,oY(a0)
	move.w  oY(a0),$2A(a0)
	addi.w  #$180,$2A(a0)
	rts
; -------------------------------------------------------------------------

ObjWaterfall_Main:
	move.w  oY(a0),d0
	addq.w  #4,d0
	cmp.w   $2A(a0),d0
	bcs.s   .NoDel
	jmp     DeleteObject

; -------------------------------------------------------------------------

.NoDel:
	move.w  d0,oY(a0)
	moveq   #2,d3
	bset    #$D,d3
	move.w  oY(a0),d4
	move.w  oX(a0),d5
	subi.w  #$60,d5
	move.w  d4,d6
	andi.w  #$F,d6
	bne.s   .End
	moveq   #$B,d6

.Loop:
	jsr     DrawBlockAtPos
	addi.w  #$10,d5
	dbf     d6,.Loop
.End:
	rts
; -------------------------------------------------------------------------
; Unused object that "demolishes" the layout above it by moving each block
; down by 1. Activated by a kind of "switch" object (ObjUnkDemolishSwitch)
; -------------------------------------------------------------------------

ObjLayoutDemolish:
	moveq   #0,d0 
	move.b  oRoutine(a0),d0
	move.w  ObjLayoutDemolish_Index(pc,d0.w),d0
	jsr     ObjLayoutDemolish_Index(pc,d0.w)
	lea     (AniSpr_Powerup).l,a1
	bsr.w   AnimateObject
	jsr     DrawObject
	move.w  oX(a0),d0
	andi.w  #$FF80,d0
	move.w  cameraX.w,d1
	subi.w  #$80,d1
	andi.w  #$FF80,d1
	sub.w   d1,d0
	cmpi.w  #$280,d0
	bhi.s   loc_206854
	rts

loc_206854:
	lea     savedObjFlags,a2
	moveq   #0,d0
	move.b  $23(a0),d0
	beq.s   loc_206868
	bclr    #7,2(a2,d0.w)

loc_206868:
	jmp     DeleteObject

; -------------------------------------------------------------------------

ObjLayoutDemolish_Index:
    dc.w ObjLayoutDemolish_Init-ObjLayoutDemolish_Index
	dc.w ObjLayoutDemolish_Main-ObjLayoutDemolish_Index

; -------------------------------------------------------------------------

ObjLayoutDemolish_Init:
	addq.b  #2,oRoutine(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.l  #MapSpr_Powerup,4(a0)
	move.w  #$541,2(a0)

ObjLayoutDemolish_Main:
	lea     objPlayerSlot.w,a1
	bsr.w   sub_2068D0
	bcs.s   loc_2068A4
	lea     objPlayerSlot2.w,a1
	bsr.w   sub_2068D0
	bcc.s   locret_2068CE

loc_2068A4:
	move.b  #0,oRoutine(a0)
	move.b  #5,0(a0)
	move.w  #$1940,oX(a0)
	move.w  #$2D0,oY(a0)
	move.b  #9,$2E(a0)
	move.b  #$17,$2C(a0)
	move.b  #$2B,$2A(a0)

locret_2068CE:
	rts

sub_2068D0:
	moveq   #0,d0
	move.w  8(a1),d0
	sub.w   oX(a0),d0
	addi.w  #$10,d0
	cmpi.w  #$20,d0 ; ' '
	bcc.s   locret_2068F4
	move.w  $C(a1),d0
	sub.w   oY(a0),d0
	addi.w  #$10,d0
	cmpi.w  #$20,d0

locret_2068F4:
	rts

; -------------------------------------------------------------------------
; Unused object that enables and spawns the level demolition object
; -------------------------------------------------------------------------

ObjUnkDemolishSwitch:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjUnk_5_Index(pc,d0.w),d0
	jmp     ObjUnk_5_Index(pc,d0.w)
; -------------------------------------------------------------------------

ObjUnk_5_Index: 
    dc.w ObjUnk_5_Init-ObjUnk_5_Index
	dc.w ObjUnk_5_Main-ObjUnk_5_Index

; -------------------------------------------------------------------------

ObjUnk_5_Init:
	addq.b  #2,oRoutine(a0)
	move.b  #4,oSprFlags(a0)

ObjUnk_5_Main:
	move.b  levelVIntCounter+3,d0
	andi.b  #$F,d0
	bne.s   locret_20697A
	subq.b  #1,$2E(a0)
	bne.s   loc_20692A
	jmp     DeleteObject

; -------------------------------------------------------------------------

loc_20692A:
	lea     levelLayout.w,a4
	move.w  oY(a0),d4
	moveq   #0,d0
	move.b  $2A(a0),d0

loc_206938:
	movem.l d0/a0,-(sp)
	move.w  oX(a0),d5
	moveq   #0,d6
	move.b  $2C(a0),d6

loc_206946:
	movem.l d4-d5,-(sp)
	subi.w  #$10,d4
	jsr     loc_202D9A
	bne.s   loc_20695A
	moveq   #0,d3
	bra.s   loc_20695C
; -------------------------------------------------------------------------

loc_20695A:
	move.w  (a0),d3

loc_20695C:
	movem.l (sp)+,d4-d5
	jsr     DrawBlockAtPos
	addi.w  #$10,d5
	dbf     d6,loc_206946
	movem.l (sp)+,d0/a0
	subi.w  #$10,d4
	dbf     d0,loc_206938

locret_20697A:
	rts
    ; dead code
	movem.l (sp)+,d4-d5
	movem.l (sp)+,d0/a0
	rts
; -------------------------------------------------------------------------

Ani_Waterfall:		include	"Level/_Objects/Waterfall/Animation Script.asm"
MapSpr_Waterfall:	include	"Level/_Objects/Waterfall/Mappings.asm"

; -------------------------------------------------------------------------
; Unused Debug Mode "edit" mode/object placement mode.
; Totally unused and unreferenced. There is no way to activate this at all.
; -------------------------------------------------------------------------

DebugObjectPlacement:
	move.b	p1CtrlData.w,d0
	andi.b	#$F,d0
	bne.s	.Accel
	move.l	#$4000,debugSpeed
	bra.s	.GotSpeed

; -------------------------------------------------------------------------

.Accel:
	addi.l	#$2000,debugSpeed
	cmpi.l	#$80000,debugSpeed
	bls.s	.GotSpeed
	move.l	#$80000,debugSpeed

.GotSpeed:
	move.l	debugSpeed,d0
	btst	#0,p1CtrlData.w
	beq.s	.ChkDown
	sub.l	d0,oY(a0)

.ChkDown:
	btst	#1,p1CtrlData.w
	beq.s	.ChkLeft
	add.l	d0,oY(a0)

.ChkLeft:
	btst	#2,p1CtrlData.w
	beq.s	.ChkRight
	sub.l	d0,oX(a0)

.ChkRight:
	btst	#3,p1CtrlData.w
	beq.s	.SetPos
	add.l	d0,oX(a0)

.SetPos:
	move.w	oY(a0),d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.w	oX(a0),d3
	jsr	GetLevelBlock
	move.w	(a1),debugBlock
	lea	DebugItemIndex,a2
	btst	#6,p1CtrlTap.w
	beq.s	.NoInc
	moveq	#0,d1
	move.b	debugObject,d1
	addq.b	#1,d1
	cmp.b	(a2),d1
	bcs.s	.NoWrap
	move.b	#0,d1

.NoWrap:
	move.b	d1,debugObject

.NoInc:
	btst	#7,p1CtrlTap.w
	beq.s	.NoDec
	moveq	#0,d1
	move.b	debugObject,d1
	subq.b	#1,d1
	cmpi.b	#$FF,d1
	bne.s	.NoWrap2
	add.b	(a2),d1

.NoWrap2:
	move.b	d1,debugObject

.NoDec:
	moveq	#0,d1
	move.b	debugObject,d1
	mulu.w	#$C,d1
	move.l	4(a2,d1.w),oMap(a0)
	move.w	8(a2,d1.w),oTile(a0)
	move.b	3(a2,d1.w),oPriority(a0)
	move.b	$D(a2,d1.w),oMapFrame(a0)
	move.b	$C(a2,d1.w),debugSubtype2
	move.b	$B(a2,d1.w),d0
	ori.b	#4,d0
	move.b	d0,oSprFlags(a0)
	move.b	#0,oAnim(a0)
	btst	#5,p1CtrlTap.w
	beq.s	.NoPlace
	bsr.w	FindObjSlot
	bne.s	.NoPlace
	moveq	#0,d1
	move.b	debugObject,d1
	mulu.w	#$C,d1
	move.b	2(a2,d1.w),oID(a1)
	move.b	$A(a2,d1.w),oSubtype(a1)
	move.b	$C(a2,d1.w),oSubtype2(a1)
	move.b	$D(a2,d1.w),oMapFrame(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	oSprFlags(a0),d0
	andi.b	#3,d0
	move.b	d0,oSprFlags(a1)
	move.b	d0,oFlags(a1)

.NoPlace:
	btst	#4,p1CtrlTap.w
	beq.s	.NoRevert
	move.b	#0,debugMode
	move.l	#MapSpr_Sonic,oMap(a0)
	move.w	#$780,oTile(a0)
	move.b	#2,oPriority(a0)
	move.b	#0,oMapFrame(a0)
	move.b	#4,oSprFlags(a0)

.NoRevert:
	jmp	DrawObject

; -------------------------------------------------------------------------

DBGITEM macro id, priority, mappings, tile, subtype, flip, subtype2, frame
	dc.b	\id, \priority
	dc.l	\mappings
	dc.w	\tile
	dc.b	\subtype, \flip, \subtype2, \frame
	__dbgCount: = __dbgCount+1
	endm

DebugItemIndex: 
    dc.b $34	
	dc.b   0
	DBGITEM	$06, 1, MapSpr_Monitor,            $5A8,  0,   0, 0, $11
	dc.b $26
	dc.b   1
	dc.l MapSpr_Spikes
	dc.w $31E
	dc.b   0
	dc.b   0 
	dc.b   0
	dc.b   0
	dc.b $28
	dc.b   1
	dc.l MapSpr_SpringBoard
	dc.w $32A
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $28
	dc.b   1
	dc.l MapSpr_SpringBoard
	dc.w $32A
	dc.b   1
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b  $D
	dc.b   1
	dc.l MapSpr_ObjFlapDoor
	dc.w $399
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   9
	dc.b   1
	dc.l Map_RotPlatform
	dc.w $3B7
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $1B
	dc.b   1
	dc.l MapSpr_GrayRock
	dc.w $3C6
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $21
	dc.b   1
	dc.l MapSpr_FloatingPlatform1
	dc.w $4000
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring1
	dc.w $520
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring1
	dc.w $520
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b 1
	dc.l MapSpr_Spring2
	dc.b   5
	dc.b $20
	dc.b   4
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring2
	dc.w $520
	dc.b   4
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring3
	dc.w $36B
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring3
	dc.w $36B
	dc.b   8
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring3
	dc.w $36B
	dc.b   8
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring3
	dc.w $36B
	dc.b   8
	dc.b   3
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring1
	dc.w $2520
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring1
	dc.w $2520
	dc.b   2
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring2
	dc.w $2520
	dc.b   6
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring2
	dc.w $2520
	dc.b   6
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring3
	dc.w $236B
	dc.b  $A
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring3
	dc.w $236B
	dc.b  $A
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring3
	dc.w $236B
	dc.b  $A
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.l MapSpr_Spring3
	dc.w $236B
	dc.b  $A
	dc.b   3
	dc.b   0
	dc.b   0
	dc.b $24
	dc.b   1
	dc.l off_20DFC2
	dc.w $3DA
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $24
	dc.b   1
	dc.l map_20E0CE
	dc.w $3DA
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $13
	dc.b   4
	dc.l map_20AFCC
	dc.w $2408
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $14
	dc.b   4
	dc.l off_20B0A4
	dc.w $2452
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $15
	dc.b   4
	dc.l map_20B154
	dc.w $23F2
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $22 ; "
	dc.b   4
	dc.l map_20B462
	dc.w $2486
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $19
	dc.b   4
	dc.l MapSpr_Monitor
	dc.w $5A8
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $19
	dc.b   4
	dc.l MapSpr_Monitor
	dc.w $5A8
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $19
	dc.b   4
	dc.l MapSpr_Monitor
	dc.w $5A8
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b $19
	dc.b   4
	dc.l MapSpr_Monitor
	dc.w $5A8
	dc.b   3
	dc.b   0
	dc.b   0
	dc.b   3
	dc.b $19
	dc.b   4
	dc.l MapSpr_Monitor
	dc.w $5A8
	dc.b   4
	dc.b   0
	dc.b   0
	dc.b   4
	dc.b $19
	dc.b   4
	dc.l MapSpr_Monitor
	dc.w $5A8
	dc.b   5
	dc.b   0
	dc.b   0
	dc.b   5
	dc.b $19
	dc.b   4
	dc.l MapSpr_Monitor
	dc.w $5A8
	dc.b   6
	dc.b   0
	dc.b   0
	dc.b   6
	dc.b $19
	dc.b   4
	dc.l MapSpr_Monitor
	dc.w $5A8
	dc.b   7
	dc.b   0
	dc.b   0
	dc.b   7
	dc.b   4
	dc.b 1
	dc.l MapSpr_Waterfall
	dc.w $3BA
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $E
	dc.b   1
	dc.l MapSpr_WaterfallSplash
	dc.w $31E
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b 3
	dc.l MapSpr_CollapsePlatform1
	dc.w $4000
	dc.b $10
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b   3
	dc.l MapSpr_CollapsePlatform1
	dc.w $4000
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b   3
	dc.l MapSpr_CollapsePlatform1
	dc.w $4000
	dc.b $11
	dc.b   1
	dc.b   0
	dc.b   1
	dc.b $20
	dc.b   3
	dc.l MapSpr_CollapsePlatform1
	dc.w $4000
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $20
	dc.b   3
	dc.l MapSpr_CollapsePlatform2
	dc.w $4000
	dc.b $80
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b   3
	dc.l MapSpr_CollapsePlatform2
	dc.w $4000
	dc.b $81
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $20
	dc.b   3
	dc.l MapSpr_CollapsePlatform2
	dc.w $4000
	dc.b $83
	dc.b   0
	dc.b   0
	dc.b   3
	dc.b $20
	dc.b   3
	dc.l MapSpr_CollapsePlatform2
	dc.w $4000
	dc.b $84
	dc.b   0
	dc.b   0
	dc.b   4
	dc.b $20
	dc.b   3
	dc.l MapSpr_CollapsePlatform2
	dc.w $4000
	dc.b $82
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b $20
	dc.b   3
	dc.l MapSpr_CollapsePlatform2
	dc.w $4000
	dc.b $85
	dc.b   0
	dc.b   0
	dc.b   5
	dc.b $19
	dc.b 4
	dc.l MapSpr_Monitor
	dc.w $5A8
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b $19
	dc.b   4
	dc.l MapSpr_Monitor
	dc.w $5A8
	dc.b   9
	dc.b   0
	dc.b   0
	dc.b  $C

; -------------------------------------------------------------------------
; Initial object processing routine 
; -------------------------------------------------------------------------

SpawnObjects:
	moveq   #0,d0
	move.b  objSpawnRoutine.w,d0
	move.w  LvlObjMan_Index(pc,d0.w),d0
	jmp     LvlObjMan_Index(pc,d0.w)

; -------------------------------------------------------------------------

LvlObjMan_Index:
	dc.w LvlObjMan_Init-LvlObjMan_Index   
	dc.w loc_206E6A-LvlObjMan_Index

; -------------------------------------------------------------------------


LvlObjMan_Init:
	moveq	#0,d0
	addq.b  #2,objSpawnRoutine.w
	move.b	act,d0
	add.b	d0,d0
	add.b	d0,d0
	move.b	zone,d1
	add.b	d1,d1	;2
	add.b	d1,d1	;4
	move.b	d1,d2
	add.b	d1,d1	;8
	add.b	d2,d1	;C
	add.b	d1,d0
	lea     (LevelObjectIndex).l,a0
	movea.l a0,a1
	adda.w	(a0,d0.w),a0
	move.l  a0,objChunkRight.w
	move.l  a0,objChunkLeft.w
	adda.w  2(a1),a1
	move.l  a1,objChunkNullR.w
	move.l  a1,objChunkNullL.w
	lea     savedObjFlags,a2
	move.w  #$101,(a2)+
	move.w  #$5E,d0 ; '^'

loc_206E0C:
	clr.l   (a2)+
	dbf     d0,loc_206E0C
	lea     savedObjFlags,a2
	moveq   #0,d2
	move.w  cameraX.w,d6
	subi.w  #$80,d6
	bcc.s   loc_206E26
	moveq   #0,d6

loc_206E26:
	andi.w  #$FF80,d6
	movea.l objChunkRight.w,a0

loc_206E2E:
	cmp.w   (a0),d6
	bls.s   loc_206E40
	tst.b   4(a0)
	bpl.s   loc_206E3C
	move.b  (a2),d2
	addq.b  #1,(a2)

loc_206E3C:
	addq.w  #8,a0
	bra.s   loc_206E2E

loc_206E40:
	move.l  a0,objChunkRight.w
	movea.l objChunkLeft.w,a0
	subi.w  #$80,d6
	bcs.s   loc_206E60

loc_206E4E:
	cmp.w   (a0),d6
	bls.s   loc_206E60
	tst.b   4(a0)
	bpl.s   loc_206E5C
	addq.b  #1,1(a2)

loc_206E5C:
	addq.w  #8,a0
	bra.s   loc_206E4E

loc_206E60:
	move.l  a0,objChunkLeft.w
	move.w  #$FFFF,objPrevChunk.w

loc_206E6A:
	lea     savedObjFlags,a2
	moveq   #0,d2
	move.w  cameraX.w,d6
	andi.w  #$FF80,d6
	cmp.w   objPrevChunk.w,d6
	beq.w   locret_206F26
	bge.s   loc_206EE2
	move.w  d6,objPrevChunk.w
	movea.l objChunkLeft.w,a0
	subi.w  #$80,d6
	bcs.s   loc_206EBE

loc_206E92:
	cmp.w   -oX(a0),d6
	bge.s   loc_206EBE
	subq.w  #8,a0
	tst.b   4(a0)
	bpl.s   loc_206EA8
	subq.b  #1,1(a2)
	move.b  1(a2),d2

loc_206EA8:
	bsr.w   sub_206F46
	bne.s   loc_206EB2
	subq.w  #8,a0
	bra.s   loc_206E92

loc_206EB2:
	tst.b   4(a0)
	bpl.s   loc_206EBC
	addq.b  #1,1(a2)

loc_206EBC:
	addq.w  #8,a0

loc_206EBE:
	move.l  a0,objChunkLeft.w
	movea.l objChunkRight.w,a0
	addi.w  #$300,d6

loc_206ECA:
	cmp.w   -oX(a0),d6
	bgt.s   loc_206EDC
	tst.b   -4(a0)
	bpl.s   loc_206ED8
	subq.b  #1,(a2)

loc_206ED8:
	subq.w  #8,a0
	bra.s   loc_206ECA

loc_206EDC:
	move.l  a0,objChunkRight.w
	rts

loc_206EE2:
	move.w  d6,objPrevChunk.w
	movea.l objChunkRight.w,a0
	addi.w  #$280,d6

loc_206EEE:
	cmp.w   (a0),d6
	bls.s   loc_206F02
	tst.b   4(a0)
	bpl.s   loc_206EFC
	move.b  (a2),d2
	addq.b  #1,(a2)

loc_206EFC:
	bsr.w   sub_206F46
	beq.s   loc_206EEE

loc_206F02:
	move.l  a0,objChunkRight.w
	movea.l objChunkLeft.w,a0
	subi.w  #$300,d6
	bcs.s   loc_206F22

loc_206F10:
	cmp.w   (a0),d6
	bls.s   loc_206F22
	tst.b   4(a0)
	bpl.s   loc_206F1E
	addq.b  #1,1(a2)

loc_206F1E:
	addq.w  #8,a0
	bra.s   loc_206F10

loc_206F22:
	move.l  a0,objChunkLeft.w

locret_206F26:
	rts

; -------------------------------------------------------------------------


sub_206F28:	 ; CODE XREF: sub_206F46?p
	moveq   #0,d0
	move.b  timeZone,d0
	move.w  d2,d3
	add.w   d3,d3
	add.w   d2,d3
	add.w   d0,d3
	move.b  6(a0),d1
	rol.b   #3,d1
	andi.b  #7,d1
	btst    d0,d1
	rts

sub_206F46:
	bsr.s   sub_206F28
	beq.s   loc_206F58
	tst.b   4(a0)
	bpl.s   loc_206F5E
	bset    #7,2(a2,d3.w)
	beq.s   loc_206F5E

loc_206F58:
	addq.w  #8,a0
	moveq   #0,d0
	rts

loc_206F5E:
	bsr.w   FindObjSlot
	bne.s   locret_206F9E
	move.w  (a0)+,8(a1)
	move.w  (a0)+,d0
	move.w  d0,d1
	andi.w  #$FFF,d0
	move.w  d0,$C(a1)
	rol.w   #2,d1
	andi.b  #3,d1
	move.b  d1,1(a1)
	move.b  d1,$22(a1)
	move.b  (a0)+,d0
	bpl.s   loc_206F8E
	andi.b  #$7F,d0
	move.b  d2,$23(a1)

loc_206F8E:
	move.b  d0,0(a1)
	move.b  (a0)+,$28(a1)
	move.b  (a0)+,d0
	move.b  (a0)+,$29(a1)
	moveq   #0,d0

locret_206F9E:
	rts

; -------------------------------------------------------------------------

FindObjSlot:
	lea     dynObjects.w,a1
	move.w  #$5F,d0 ; '_'

loc_206FA8:
	tst.b   (a1)
	beq.s   locret_206FB4
	lea     $40(a1),a1
	dbf     d0,loc_206FA8

locret_206FB4:
	rts

; -------------------------------------------------------------------------

FindNextObjSlot:
	movea.l a0,a1
	move.w  #$F000,d0
	sub.w   a0,d0
	lsr.w   #6,d0
	subq.w  #1,d0
	bcs.s   locret_206FD0

loc_206FC4:
	tst.b   (a1)
	beq.s   locret_206FD0
	lea     $40(a1),a1
	dbf     d0,loc_206FC4

locret_206FD0:
	rts

; -------------------------------------------------------------------------

CheckObjDespawnTime:
	move.w  oX(a0),d0
	andi.w  #$FF80,d0
	move.w  cameraX.w,d1
	subi.w  #$80,d1
	andi.w  #$FF80,d1
	sub.w   d1,d0
	cmpi.w  #$280,d0
	bls.s   locret_207018
	moveq   #0,d0
	move.b  $23(a0),d0
	beq.s   loc_207012
	lea     savedObjFlags,a1
	move.w  d0,d1
	add.w   d1,d1
	add.w   d1,d0
	moveq   #0,d1
	move.b  timeZone,d1
	add.w   d1,d0
	bclr    #7,2(a1,d0.w)

loc_207012:
	jmp     DeleteObject

locret_207018:
	rts
; -------------------------------------------------------------------------
LevelObjectIndex:
    dc.w Objects_Act1-LevelObjectIndex, Objects_Null-LevelObjectIndex
    dc.w Objects_Act2-LevelObjectIndex, Objects_Null-LevelObjectIndex
    dc.w Objects_Act3-LevelObjectIndex, Objects_Null-LevelObjectIndex
;	R2
    dc.w Objects_Null-LevelObjectIndex, Objects_Null-LevelObjectIndex
    dc.w Objects_Null-LevelObjectIndex, Objects_Null-LevelObjectIndex
    dc.w Objects_Null-LevelObjectIndex, Objects_Null-LevelObjectIndex
;	R3
    dc.w Objects_Null-LevelObjectIndex, Objects_Null-LevelObjectIndex
    dc.w Objects_Null-LevelObjectIndex, Objects_Null-LevelObjectIndex
    dc.w Objects_Null-LevelObjectIndex, Objects_Null-LevelObjectIndex

	dc.w $FFFF
	dc.w 0
	dc.w 0
	dc.w 0

; Object layout list
Objects_Act1:	incbin	"Level/R1 Salad Plain/Act 1 Objects.bin"
    even   
Objects_Act2:	incbin	"Level/R1 Salad Plain/Act 2 Objects.bin"
    even   
Objects_Act3:	incbin	"Level/R1 Salad Plain/Act 3 Objects.bin"
    even   

; Null placeholder list
Objects_Null:   
    dc.w $FFFF
	dc.w 0
	dc.w 0

; -------------------------------------------------------------------------

ObjSpinTunnel:
	bsr.w   GetPlayerObject
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjSpinTunnel_Index(pc,d0.w),d1
	jsr     ObjSpinTunnel_Index(pc,d1.w)
	cmpi.b  #4,oRoutine(a0)
	bcc.s   locret_207B8A
	move.w  oX(a0),d0
	andi.w  #$FF80,d0
	move.w  cameraX.w,d1
	subi.w  #$80,d1
	andi.w  #$FF80,d1
	sub.w   d1,d0
	cmpi.w  #$280,d0
	bhi.s   loc_207B8C

locret_207B8A:
	rts
; -------------------------------------------------------------------------

loc_207B8C:
	jmp     DeleteObject

; -------------------------------------------------------------------------

ObjSpinTunnel_Index:     
    dc.w sub_207B9A-ObjSpinTunnel_Index      
	dc.w loc_207BE0-ObjSpinTunnel_Index
	dc.w ObjSpinTunnel_InitPlayer-ObjSpinTunnel_Index
	dc.w ObjSpinTunnel_CtrlPlayer-ObjSpinTunnel_Index

; -------------------------------------------------------------------------


sub_207B9A:
	move.l  #MapSpr_Powerup,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	move.w  #$541,2(a0)
	addq.b  #2,oRoutine(a0)
	move.b  $28(a0),d0
	add.w   d0,d0
	andi.w  #$1E,d0
	lea     ObjSpinTunnel_TargetPos(pc),a2
	adda.w  (a2,d0.w),a2
	move.w  (a2)+,$3A(a0)
	move.l  a2,$3C(a0)
	move.w  (a2)+,$36(a0)
	move.w  (a2)+,$38(a0)

loc_207BE0:
	move.w  8(a6),d0
	sub.w   oX(a0),d0
	addi.w  #$10,d0
	cmpi.w  #$20,d0 ; ' '
	bcc.s   locret_207C56
	move.w  $C(a6),d1
	sub.w   oY(a0),d1
	addi.w  #$20,d1 ; ' '
	cmpi.w  #$40,d1 ; '.'
	bcc.s   locret_207C56
	tst.b   $2C(a6)
	bne.s   locret_207C56
	addq.b  #2,oRoutine(a0)
	move.b  #$81,$2C(a6)
	move.b  #2,$1C(a6)
	bsr.w   ObjSpinTunnel_SetPlayerGVel
	move.w  #0,$10(a6)
	move.w  #0,$12(a6)
	bclr    #5,oFlags(a0)
	bclr    #5,$22(a6)
	bset    #1,$22(a6)
	move.w  oX(a0),8(a6)
	move.w  oY(a0),$C(a6)
	clr.b   $32(a0)
	move.w  #SFXDash,d0
	jsr     PlayFMSound

locret_207C56:
	rts



; -------------------------------------------------------------------------

ObjSpinTunnel_InitPlayer:
	bsr.w   ObjSpinTunnel_SetPlayerSpeeds
	addq.b  #2,oRoutine(a0)
	move.w  #SFXDash,d0
	jsr     PlayFMSound
	rts

; -------------------------------------------------------------------------


ObjSpinTunnel_CtrlPlayer:
	addq.l  #4,sp
	subq.b  #1,$2E(a0)
	bpl.s   loc_207CAA
	move.w  $36(a0),8(a6)
	move.w  $38(a0),$C(a6)
	moveq   #0,d1
	move.b  $3A(a0),d1
	addq.b  #4,d1
	cmp.b   $3B(a0),d1
	bcs.s   loc_207C92
	moveq   #0,d1
	bra.s   loc_207CD0

loc_207C92:
	move.b  d1,$3A(a0)
	movea.l $3C(a0),a2
	move.w  (a2,d1.w),$36(a0)
	move.w  2(a2,d1.w),$38(a0)
	bra.w   ObjSpinTunnel_SetPlayerSpeeds

loc_207CAA:
	move.l  8(a6),d2
	move.l  $C(a6),d3
	move.w  $10(a6),d0
	ext.l   d0
	asl.l   #8,d0
	add.l   d0,d2
	move.w  $12(a6),d0
	ext.l   d0
	asl.l   #8,d0
	add.l   d0,d3
	move.l  d2,8(a6)
	move.l  d3,$C(a6)
	rts

loc_207CD0:
	andi.w  #$7FF,$C(a6)
	clr.b   oRoutine(a0)
	clr.b   $2C(a6)
	move.w  #2,oRoutine(a0)
	rts

; -------------------------------------------------------------------------


ObjSpinTunnel_SetPlayerSpeeds:
	moveq   #0,d0
	move.w  $14(a6),d2
	move.w  $14(a6),d3
	move.w  $36(a0),d0
	sub.w   8(a6),d0
	bge.s   loc_207CFE
	neg.w   d0
	neg.w   d2

loc_207CFE:
	moveq   #0,d1
	move.w  $38(a0),d1
	sub.w   $C(a6),d1
	bge.s   loc_207D0E
	neg.w   d1
	neg.w   d3

loc_207D0E:
	cmp.w   d0,d1
	bcs.s   loc_207D44

	moveq   #0,d1
	move.w  $38(a0),d1
	sub.w   $C(a6),d1
	swap    d1
	divs.w  d3,d1
	moveq   #0,d0
	move.w  $36(a0),d0
	sub.w   8(a6),d0
	beq.s   loc_207D30
	swap    d0
	divs.w  d1,d0

loc_207D30:
	move.w  d0,$10(a6)
	move.w  d3,$12(a6)
	tst.w   d1
	bpl.s   loc_207D3E
	neg.w   d1

loc_207D3E:
	move.w  d1,$2E(a0)
	rts
; -------------------------------------------------------------------------

loc_207D44:
	moveq   #0,d0
	move.w  $36(a0),d0
	sub.w   8(a6),d0
	swap    d0
	divs.w  d2,d0
	moveq   #0,d1
	move.w  $38(a0),d1
	sub.w   $C(a6),d1
	beq.s   loc_207D62
	swap    d1
	divs.w  d0,d1

loc_207D62:
	move.w  d1,$12(a6)
	move.w  d2,$10(a6)
	tst.w   d0
	bpl.s   loc_207D70
	neg.w   d0

loc_207D70:
	move.w  d0,$2E(a0)
	rts

; -------------------------------------------------------------------------

ObjSpinTunnel_SetPlayerGVel:
	moveq   #0,d0
	move.b  $28(a0),d0
	add.w   d0,d0
	move.w  ObjSpinTunnel_GVels(pc,d0.w),d0
	cmp.w   $14(a6),d0
	ble.s   .End
	move.w  d0,$14(a6)

.End:
	rts

; -------------------------------------------------------------------------
ObjSpinTunnel_GVels:dc.w $1000
	    dc.w $C00
	    dc.w $C00
	    dc.w $800
ObjSpinTunnel_TargetPos:
    ; no idea how to format this
    dc.w  $10, $9A, $E0,$126,$126,$126,$126,$126
	dc.w  $88,$1440, $F0,$1478,$108,$1490,$140,$1490
	dc.w $1E0,$1440,$1F8,$1400,$1E0,$13F0,$1C0,$13F0
	dc.w $180,$1400,$170,$1420,$168,$1440,$170,$1468
	dc.w $1A8,$1660,$218,$16A0,$210,$16C0,$1F8,$16D0
	dc.w $1C8,$16C0,$1A8,$1680,$198,$1658,$1A0,$1640
	dc.w $1C8,$1650,$1F0,$1680,$200,$16C0,$200,$16D0
	dc.w $210,$16D0,$288,$16C0,$2C0,$1680,$2D8,$1650
	dc.w $2C0,$1650,$2A0,$1680,$290,$1700,$290,$1728
	dc.w $2A0,$1728,$2E0,$1700,$2F0, $44,$F08,$1A0
	dc.w $F90,$1A0,$FC8,$1B8,$FE0,$1F0,$FE0,$260
	dc.w $1000,$290,$1030,$2A0,$1068,$288,$1080,$250
	dc.w $1068,$218,$1030,$200,$FF0,$220,$FE0,$260
	dc.w $1000,$290,$1030,$2A0,$1068,$288,$1130,$1C8
	dc.w  $44,$1630,$290,$1630,$318,$1638,$338,$16D0
	dc.w $3D0,$1700,$3E0,$1738,$3C8,$1758,$390,$1738
	dc.w $358,$16F8,$340,$16C0,$360,$16A8,$390,$16D0
	dc.w $3D0,$1700,$3E0,$1738,$3C8,$17B8,$348,$17D0
	dc.w $320,$17D0,$278

; -------------------------------------------------------------------------


ClearObjRide:	           ; CODE XREF: SolidObject:loc_208076?p
		        ; SolidObject:loc_208082?p
	btst    #3,oFlags(a0)
	beq.s   .End
	btst    #3,$22(a1)
	beq.s   .End
	moveq   #0,d0
	move.b  $3D(a1),d0
	lsl.w   #6,d0
	addi.l  #$FFD000,d0
	cmpa.w  d0,a0
	bne.s   .End
	clr.b   $38(a1)
	bset    #1,$22(a1)
	bclr    #3,$22(a1)
	bclr    #3,oFlags(a0)

.End:		   ; CODE XREF: ClearObjRide+6?j
		        ; ClearObjRide+E?j ...
	rts
; End of function ClearObjRide


; -------------------------------------------------------------------------


sub_207EF6:	 ; CODE XREF: SolidObject+FE?p
	clr.b   $25(a0)
	clr.b   $3C(a1)
	bset    #3,oFlags(a0)
	bne.s   loc_207F24
	bclr    #2,$22(a1)
	beq.s   loc_207F24
	move.b  #$13,$16(a1)
	move.b  #9,$17(a1)
	subq.w  #5,$C(a1)
	move.b  #0,$1C(a1)

loc_207F24:	 ; CODE XREF: sub_207EF6+E?j
		        ; sub_207EF6+16?j
	bset    #3,$22(a1)
	beq.s   loc_207F46
	moveq   #0,d0
	move.b  $3D(a1),d0
	lsl.w   #6,d0
	addi.l  #$FFD000,d0
	cmpa.w  d0,a0
	beq.s   locret_207F6E
	movea.l d0,a2
	bclr    #3,$22(a2)

loc_207F46:	 ; CODE XREF: sub_207EF6+34?j
	move.w  a0,d0
	subi.w  #$D000,d0
	lsr.w   #6,d0
	andi.w  #$7F,d0
	move.b  d0,$3D(a1)
	move.b  #0,$26(a1)
	move.w  #0,$12(a1)
	move.w  $10(a1),$14(a1)
	bclr    #1,$22(a1)

locret_207F6E:	          ; CODE XREF: sub_207EF6+46?j
	rts
; End of function sub_207EF6


; -------------------------------------------------------------------------


SolidObject:
	cmpi.b  #4,$24(a1)
	bcc.w   loc_208076
	cmpi.b  #$2B,$1C(a1) ; '+'
	beq.w   loc_208076
	tst.b   0(a1)
	beq.w   loc_208076
	tst.b   1(a0)
	bpl.w   loc_208076
	tst.b   debugMode
	bne.w   loc_208076
	moveq   #0,d1
	moveq   #0,d2
	move.b  oYRadius(a0),d2
	move.b  $19(a0),d1
	moveq   #$10,d5
	add.w   d1,d5
	move.w  8(a1),d0
	sub.w   d3,d0
	add.w   d5,d0
	bmi.w   loc_208076
	move.w  d5,d6
	add.w   d5,d5
	cmp.w   d5,d0
	bcc.w   loc_208076
	move.w  d0,d5
	move.w  8(a1),d0
	sub.w   d3,d0
	add.w   d1,d0
	bmi.w   loc_208082
	add.w   d1,d1
	cmp.w   d1,d0
	bcc.w   loc_208082
	tst.b   $25(a0)
	beq.s   loc_207FEA
	cmpi.b  #2,$1C(a1)
	beq.w   loc_208076

loc_207FEA:	 ; CODE XREF: SolidObject+6E?j
	btst    #1,oSprFlags(a0)
	beq.s   loc_207FFC
	tst.w   $12(a1)
	bpl.w   loc_208076
	bra.s   loc_208004
; -------------------------------------------------------------------------

loc_207FFC:	 ; CODE XREF: SolidObject+80?j
	tst.w   $12(a1)
	bmi.w   loc_208076

loc_208004:	 ; CODE XREF: SolidObject+8A?j
	move.w  $C(a1),d0
	moveq   #0,d1
	move.b  $16(a1),d1
	btst    #1,oSprFlags(a0)
	beq.s   loc_20801A
	sub.w   d1,d0
	bra.s   loc_20801C
; -------------------------------------------------------------------------

loc_20801A:	 ; CODE XREF: SolidObject+A4?j
	add.w   d1,d0

loc_20801C:	 ; CODE XREF: SolidObject+A8?j
	addq.w  #2,d2
	sub.w   d4,d0
	add.w   d2,d0
	bmi.s   loc_208076
	add.w   d2,d2
	cmp.w   d2,d0
	bcc.s   loc_208076
	move.w  d4,$C(a1)
	lsr.w   #1,d2
	add.w   d1,d2
	subq.w  #2,d2
	btst    #1,oSprFlags(a0)
	beq.s   loc_208042
	add.w   d2,$C(a1)
	bra.s   loc_208046
; -------------------------------------------------------------------------

loc_208042:	 ; CODE XREF: SolidObject+CA?j
	sub.w   d2,$C(a1)

loc_208046:	 ; CODE XREF: SolidObject+D0?j
	moveq   #0,d1
	move.w  oXVel(a0),d1
	ext.l   d1
	asl.l   #8,d1
	move.l  8(a1),d0
	add.l   d1,d0
	move.l  d0,8(a1)
	moveq   #0,d1
	move.w  oYVel(a0),d1
	ext.l   d1
	asl.l   #8,d1
	move.l  $C(a1),d0
	add.l   d1,d0
	move.l  d0,$C(a1)
	bsr.w   sub_207EF6
	moveq   #1,d0
	rts
; -------------------------------------------------------------------------

loc_208076:	 ; CODE XREF: SolidObject+6?j
		        ; SolidObject+10?j ...
	bsr.w   ClearObjRide
	clr.b   $25(a0)
	moveq   #0,d0
	rts
; -------------------------------------------------------------------------

loc_208082:	 ; CODE XREF: SolidObject+5E?j
		        ; SolidObject+66?j
	bsr.w   ClearObjRide
	btst    #1,$22(a1)
	bne.s   loc_2080F4
	subq.w  #2,d2
	move.w  $C(a1),d0
	add.b   $16(a1),d0
	sub.w   d4,d0
	add.w   d2,d0
	bmi.s   loc_2080F4
	add.b   $16(a1),d2
	add.w   d2,d2
	cmp.w   d2,d0
	bcc.s   loc_2080F4
	move.w  8(a1),d0
	cmp.w   d3,d0
	bcc.s   loc_2080B8
	tst.w   $10(a1)
	bpl.s   loc_2080CC
	bra.s   loc_2080BE
; -------------------------------------------------------------------------

loc_2080B8:	 ; CODE XREF: SolidObject+13E?j
	tst.w   $10(a1)
	bmi.s   loc_2080CC

loc_2080BE:	 ; CODE XREF: SolidObject+146?j
	bclr    #5,$22(a1)
	bclr    #5,oFlags(a0)
	bra.s   loc_2080D8
; -------------------------------------------------------------------------

loc_2080CC:	 ; CODE XREF: SolidObject+144?j
		        ; SolidObject+14C?j
	bset    #5,$22(a1)
	bset    #5,oFlags(a0)

loc_2080D8:	 ; CODE XREF: SolidObject+15A?j
	cmp.w   d5,d6
	bcc.s   loc_2080E0
	add.w   d6,d6
	sub.w   d6,d5

loc_2080E0:	 ; CODE XREF: SolidObject+16A?j
	sub.w   d5,8(a1)
	move.w  #0,$14(a1)
	move.w  #0,$10(a1)
	moveq   #0,d0
	rts
; -------------------------------------------------------------------------

loc_2080F4:	 ; CODE XREF: SolidObject+11C?j
		        ; SolidObject+12C?j ...
	bclr    #5,$22(a1)
	bclr    #5,oFlags(a0)
	moveq   #0,d0
	rts
; End of function SolidObject


; -------------------------------------------------------------------------

ObjRotPlatform_SolidObj:
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	jmp     SolidObject

; -------------------------------------------------------------------------


ObjRotPlatform:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjRotPlatform_Index(pc,d0.w),d0
	jsr     ObjRotPlatform_Index(pc,d0.w)
	tst.w   timeStopTimer
	bne.s   .SkipAnim
	lea     (Ani_RotPlatform).l,a1
	bsr.w   AnimateObject

.SkipAnim:
	jsr     DrawObject
	jmp     CheckObjDespawnTime

; -------------------------------------------------------------------------

ObjRotPlatform_Index:
    dc.w ObjRotPlatform_Init-ObjRotPlatform_Index
	dc.w ObjRotPlatform_Main-ObjRotPlatform_Index

; -------------------------------------------------------------------------


ObjRotPlatform_Init:
	addq.b  #2,oRoutine(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #4,$18(a0)
	move.l  #Map_RotPlatform,4(a0)
	moveq   #6,d0
	jsr     LevelObj_SetBaseTile(pc)
	move.b  #$10,$19(a0)
	move.b  #8,oYRadius(a0)

ObjRotPlatform_Main:
	tst.b   1(a0)
	bpl.w   locret_2081D6
	lea     objPlayerSlot.w,a1
	bsr.s   ObjRotPlatform_SolidObj
	beq.s   loc_208180
	bsr.s   sub_20818C
	bra.s   loc_208182

loc_208180:
	bsr.s   sub_2081C0

loc_208182:
	lea     objPlayerSlot2.w,a1
	bsr.w   ObjRotPlatform_SolidObj
	beq.s   sub_2081C0

sub_20818C:

	tst.w   timeStopTimer
	bne.s   locret_2081D6
	bset    #0,$2C(a1)
	bne.s   loc_2081BE
	move.b  #$2D,$1C(a1)
	moveq   #0,d0
	move.b  d0,$2B(a1)
	move.w  8(a1),d0
	sub.w   oX(a0),d0
	bcc.s   loc_2081BA
	neg.w   d0
	move.b  #$80,$2B(a1)

loc_2081BA:
	move.b  d0,$39(a1)

loc_2081BE:
	bra.s   loc_2081D8

; -------------------------------------------------------------------------

sub_2081C0:
	moveq   #0,d0
	move.b  $3D(a1),d0
	lsl.w   #6,d0
	addi.l  #$FFD000,d0
	cmpa.w  d0,a0
	bne.s   locret_2081D6
	clr.b   $2C(a1)

locret_2081D6:
	rts

loc_2081D8:
	addq.b  #8,$2B(a1)
	move.b  $2B(a1),d0
	jsr     CalcSine
	moveq   #0,d0
	move.b  $39(a1),d0
	muls.w  d1,d0
	lsr.l   #8,d0
	move.w  oX(a0),8(a1)
	add.w   d0,8(a1)
	moveq   #0,d0
	move.b  $2B(a1),d0
	move.b  d0,d1
	andi.b  #$F0,d0
	lsr.b   #4,d0
	move.b  byte_208236(pc,d0.w),$1B(a1)
	andi.b  #$3F,d1
	bne.s   loc_208218
	addq.b  #1,$39(a1)

loc_208218:
	move.w  p1CtrlData.w,playerCtrl.w
	cmpi.b  #1,0(a1)
	beq.s   loc_20822C
	move.w  p2CtrlData.w,playerCtrl.w

loc_20822C:
	bsr.w   sub_208246
	bra.w   loc_208298
	rts     ; dead
; -------------------------------------------------------------------------

byte_208236:    
    dc.b  0, 0, 0 
	dc.b  1, 1, 2
	dc.b  2, 2, 3
	dc.b  3, 3, 4
	dc.b  4, 5, 5
	dc.b  5

; -------------------------------------------------------------------------


sub_208246:
	move.w  8(a1),d0
	sub.w   oX(a0),d0
	bcc.s   loc_208274
	btst    #2,playerCtrl.w
	beq.s   loc_20825E
	addq.b  #1,$39(a1)
	bra.s   locret_208296


loc_20825E:
	btst    #3,playerCtrl.w
	beq.s   locret_208296
	subq.b  #1,$39(a1)
	bcc.s   locret_208296
	move.b  #0,$39(a1)
	bra.s   locret_208296

loc_208274:
	btst    #3,playerCtrl.w
	beq.s   loc_208282
	addq.b  #1,$39(a1)
	bra.s   locret_208296

loc_208282:
	btst    #2,playerCtrl.w
	beq.s   locret_208296
	subq.b  #1,$39(a1)
	bcc.s   locret_208296
	move.b  #0,$39(a1)

locret_208296:	          
	rts

loc_208298:
	move.b  playerCtrlTap.w,d0
	andi.b  #$70,d0 ; 'p'
	beq.w   locret_20834C
	move.w  #$680,d2
	btst    #6,oFlags(a0)
	beq.s   loc_2082B4
	move.w  #$380,d2

loc_2082B4:
	moveq   #0,d0
	move.b  $26(a1),d0
	subi.b  #$40,d0 ; '.'
	jsr     CalcSine
	muls.w  d2,d1
	asr.l   #8,d1
	add.w   d1,$10(a1)
	muls.w  d2,d0
	asr.l   #8,d0
	add.w   d0,$12(a1)
	bset    #1,$22(a1)
	bclr    #5,$22(a1)
	move.b  #1,$3C(a1)
	clr.b   $38(a1)
	move.w  #SFXNoisePop,d0
	jsr     PlayFMSound
	tst.b   miniSonic.w
	beq.s   loc_208308
	move.b  #$A,$16(a1)
	move.b  #5,$17(a1)
	bra.s   loc_208314

loc_208308:
	move.b  #$13,$16(a1)
	move.b  #9,$17(a1)

loc_208314:
	btst    #2,$22(a1)
	bne.s   loc_20834E
	tst.b   miniSonic.w
	beq.s   loc_208330
	move.b  #$A,$16(a1)
	move.b  #5,$17(a1)
	bra.s   loc_208340

loc_208330:
	move.b  #$E,$16(a1)
	move.b  #7,$17(a1)
	addq.w  #5,$C(a1)

loc_208340:
	bset    #2,$22(a1)
	move.b  #2,$1C(a1)

locret_20834C:
	rts

loc_20834E:	
	bset    #4,$22(a1)
	rts

; -------------------------------------------------------------------------

Ani_RotPlatform:
    dc.w byte_208358-Ani_RotPlatform  
byte_208358:    dc.b  1, 0, 1, 2, $FF 
	even

; -------------------------------------------------------------------------

Map_RotPlatform:
    dc.w byte_208364-Map_RotPlatform      
	dc.w byte_208370-Map_RotPlatform
	dc.w byte_20837C-Map_RotPlatform
byte_208364:    dc.b  2,$F8, 5, 0       
	dc.b  0,$F0,$F8, 5
	dc.b  8, 0, 0, 0
byte_208370:    dc.b  2,$F8, 5, 0       
	dc.b  0,$F0,$F8, 5
	dc.b  8, 0, 0, 0
byte_20837C:    dc.b  1,$F8,$D, 0       
	dc.b  4,$F0
	even

; -------------------------------------------------------------------------


ObjGrayRock:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjGrayRock_Index(pc,d0.w),d0
	jsr     ObjGrayRock_Index(pc,d0.w)
	jsr     DrawObject
	jmp     CheckObjDespawnTime

; -------------------------------------------------------------------------

ObjGrayRock_Index:
    dc.w ObjGrayRock_Init-ObjGrayRock_Index 
	dc.w ObjGrayRock_Main-ObjGrayRock_Index

; -------------------------------------------------------------------------


ObjGrayRock_Init:

	addq.b  #2,oRoutine(a0)
	ori.b   #4,oSprFlags(a0)
	move.b  #4,$18(a0)
	move.l  #MapSpr_GrayRock,4(a0)
	move.b  #$10,$19(a0)
	move.b  #$10,oYRadius(a0)
	move.b  #0,oMapFrame(a0)
	moveq   #$B,d0
	jsr     LevelObj_SetBaseTile

ObjGrayRock_Main:
	tst.b   1(a0)
	bpl.s   .End
	lea     objPlayerSlot.w,a1
	bsr.w   .MakeSolid
	lea     objPlayerSlot2.w,a1

; -------------------------------------------------------------------------


.MakeSolid:
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	jmp     SolidObject


.End:
	rts
; -------------------------------------------------------------------------

MapSpr_GrayRock:
    dc.w byte_2083F6-* 
     
byte_2083F6:    dc.b  2,$F8, 2, 0
	dc.b  0,$EC,$F0,$F
	dc.b  0, 3,$F4, 0

; -------------------------------------------------------------------------


ObjMovingSpring:	        
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjMovingSpring_Index(pc,d0.w),d0
	jsr     ObjMovingSpring_Index(pc,d0.w)
	move.w  $36(a0),d0
	andi.w  #$FF80,d0
	move.w  cameraX.w,d1
	subi.w  #$80,d1
	andi.w  #$FF80,d1
	sub.w   d1,d0
	cmpi.w  #$280,d0
	bhi.w   DeleteObject
	rts

; -------------------------------------------------------------------------

ObjMovingSpring_Index:  ; lmao what
    dc.w ObjMovingSpring_Main-ObjMovingSpring_Index
	dc.w ObjMovingSpring_Check-ObjMovingSpring_Index
	dc.w ObjMovingSpring_Set-ObjMovingSpring_Index

; -------------------------------------------------------------------------

ObjMovingSpring_Main:
	addq.b  #2,oRoutine(a0)
	ori.b   #4,oSprFlags(a0)
	move.b  #4,$18(a0)
	move.l  #MapSpr_MovingSpring,4(a0)
	move.b  #8,$19(a0)
	move.b  #8,oYRadius(a0)
	move.w  oX(a0),$36(a0)
	move.w  #$180,oXVel(a0)
	moveq   #$E,d0
	jsr     LevelObj_SetBaseTile
	jsr     FindObjSlot
	beq.s   loc_20847C
	jmp     DeleteObject

loc_20847C:
	move.b  #$A,0(a1)
	move.w  oX(a0),8(a1)
	move.w  oY(a0),$C(a1)
	subi.w  #$10,$C(a1)
	move.b  #$F0,$39(a1)
	move.w  a0,$34(a1)
	move.b  $28(a0),$28(a1)

ObjMovingSpring_Check:
	jsr     CheckFloorEdge
	tst.w   d1
	bpl.s   loc_2084BE
	add.w   d1,oY(a0)
	move.w  oY(a0),$32(a0)
	addq.b  #2,oRoutine(a0)
	rts

loc_2084BE:
	addq.w  #1,oY(a0)
	rts

ObjMovingSpring_Set:
	tst.w   timeStopTimer
	bne.s   loc_2084FA
	jsr     CheckFloorEdge
	add.w   d1,oY(a0)
	move.w  $32(a0),d0
	sub.w   oY(a0),d0
	cmpi.w  #$C,d0
	bcs.s   loc_2084E8
	neg.w   oXVel(a0)

loc_2084E8:
	jsr     ObjMove
	lea     (AniSpr_MovingSpring).l,a1
	jsr     AnimateObject

loc_2084FA:
	jmp     DrawObject

ObjSpring:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	beq.s   loc_20850E
	tst.b   1(a0)
	bpl.s   loc_208516

loc_20850E:
	move.w  ObjSpring_Index(pc,d0.w),d1
	jsr     ObjSpring_Index(pc,d1.w)

loc_208516:
	bsr.w   DrawObject
	move.l  #$FFFF0000,d1
	move.w  $34(a0),d1
	beq.s   loc_208548
	movea.l d1,a1
	move.w  8(a1),oX(a0)
	move.w  $C(a1),oY(a0)
	move.b  $38(a0),d0
	ext.w   d0
	add.w   d0,oX(a0)
	move.b  $39(a0),d0
	ext.w   d0
	add.w   d0,oY(a0)

loc_208548:
	move.w  $36(a0),d0
	andi.w  #$FF80,d0
	move.w  cameraX.w,d1
	subi.w  #$80,d1
	andi.w  #$FF80,d1
	sub.w   d1,d0
	cmpi.w  #$280,d0
	bhi.w   DeleteObject
	rts

; -------------------------------------------------------------------------
ObjSpring_Index:
    dc.w ObjSpring_Init-ObjSpring_Index
	dc.w sub_20863E-ObjSpring_Index
	dc.w sub_20868A-ObjSpring_Index
	dc.w sub_2086A0-ObjSpring_Index
	dc.w sub_2086C6-ObjSpring_Index
	dc.w sub_20874E-ObjSpring_Index
	dc.w sub_208768-ObjSpring_Index
	dc.w sub_208788-ObjSpring_Index
	dc.w loc_2087D2-ObjSpring_Index
	dc.w sub_2087E8-ObjSpring_Index
	dc.w sub_2087FA-ObjSpring_Index
	dc.w loc_2088B0-ObjSpring_Index
	dc.w sub_2088BA-ObjSpring_Index

; -------------------------------------------------------------------------

ObjSpring_Init:
	addq.b  #2,oRoutine(a0)
	move.l  #MapSpr_Spring1,4(a0)
	move.w  #$520,2(a0)
	ori.b   #4,oSprFlags(a0)
	move.b  #$10,$19(a0)
	move.b  #8,oYRadius(a0)
	move.w  oX(a0),$36(a0)
	move.b  #4,$18(a0)
	move.b  $28(a0),d0
	btst    #2,d0
	beq.s   loc_2085D8
	move.b  #8,oRoutine(a0)
	move.b  #8,$19(a0)
	move.b  #$10,oYRadius(a0)
	move.l  #MapSpr_Spring2,4(a0)
	bra.s   loc_208614

; -------------------------------------------------------------------------

loc_2085D8:
	btst    #3,d0
	beq.s   loc_208600
	move.b  #$14,oRoutine(a0)
	move.b  #$10,oYRadius(a0)
	move.l  #MapSpr_Spring3,4(a0)
	move.l  d0,-(sp)
	moveq   #$F,d0
	jsr     LevelObj_SetBaseTile
	move.l  (sp)+,d0
	bra.s   loc_208614
; -------------------------------------------------------------------------

loc_208600:
	btst    #1,oSprFlags(a0)
	beq.s   loc_208614
	move.b  #$E,oRoutine(a0)
	bset    #1,oFlags(a0)

loc_208614:	
	btst    #1,d0
	beq.s   loc_208620
	bset    #5,2(a0)

loc_208620:
	andi.w  #2,d0
	move.w  Spring_Forces(pc,d0.w),$30(a0)
	rts

; -------------------------------------------------------------------------

Spring_Forces:  dc.w -$1000
	dc.w -$A00

; -------------------------------------------------------------------------

sub_208630:	
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	jmp     SolidObject

sub_20863E:	 ; DATA XREF: ROM:0020856A?o
	tst.b   1(a0)
	bpl.s   locret_208656
	lea     objPlayerSlot.w,a1
	bsr.s   sub_208630
	beq.s   loc_20864E
	bsr.s   sub_208658

loc_20864E:	 ; CODE XREF: sub_20863E+C?j
	lea     objPlayerSlot2.w,a1
	bsr.s   sub_208630
	bne.s   sub_208658

locret_208656:	          ; CODE XREF: sub_20863E+4?j
	rts
; End of function sub_20863E


; -------------------------------------------------------------------------


sub_208658:	 ; CODE XREF: sub_20863E+E?p
		        ; sub_20863E+16?j
	move.b  #4,oRoutine(a0)
	addq.w  #8,$C(a1)
	move.w  $30(a0),$12(a1)
	bset    #1,$22(a1)
	bclr    #3,$22(a1)
	move.b  #$10,$1C(a1)
	bclr    #3,oFlags(a0)
	move.w  #SFXSpring,d0
	jmp     PlayFMSound
; End of function sub_208658


; -------------------------------------------------------------------------


sub_20868A:	 ; DATA XREF: ROM:0020856C?o
	lea     objPlayerSlot.w,a1
	bsr.s   sub_208630
	lea     objPlayerSlot2.w,a1
	bsr.s   sub_208630
	lea     (AniSpr_Spring).l,a1
	bra.w   AnimateObject
; End of function sub_20868A


; -------------------------------------------------------------------------


sub_2086A0:	 ; DATA XREF: ROM:0020856E?o
	bclr    #3,oFlags(a0)
	move.b  #1,$1D(a0)
	subq.b  #4,oRoutine(a0)
	move.b  #0,oMapFrame(a0)
	rts
; End of function sub_2086A0


; -------------------------------------------------------------------------


sub_2086B8:	 ; CODE XREF: sub_2086C6+A?p
		        ; sub_2086C6+1A?p ...
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	jmp     SolidObject
; End of function sub_2086B8


; -------------------------------------------------------------------------


sub_2086C6:	 ; DATA XREF: ROM:00208570?o
	tst.b   1(a0)
	bpl.s   locret_2086EA
	lea     objPlayerSlot.w,a1
	bsr.s   sub_2086B8
	btst    #5,oFlags(a0)
	beq.s   loc_2086DC
	bsr.s   sub_2086EC

loc_2086DC:	 ; CODE XREF: sub_2086C6+12?j
	lea     objPlayerSlot2.w,a1
	bsr.s   sub_2086B8
	btst    #5,oFlags(a0)
	bne.s   sub_2086EC

locret_2086EA:	          ; CODE XREF: sub_2086C6+4?j
	rts
; End of function sub_2086C6


; -------------------------------------------------------------------------


sub_2086EC:	 ; CODE XREF: sub_2086C6+14?p
		        ; sub_2086C6+22?j
	move.b  #$A,oRoutine(a0)
	move.w  $30(a0),$10(a1)
	addq.w  #8,8(a1)
	bset    #0,$22(a1)
	btst    #0,oFlags(a0)
	bne.s   loc_20871A
	subi.w  #$10,8(a1)
	neg.w   $10(a1)
	bclr    #0,$22(a1)

loc_20871A:	 ; CODE XREF: sub_2086EC+1C?j
	move.w  #$F,$3E(a1)
	move.w  $10(a1),$14(a1)
	btst    #2,$22(a1)
	bne.s   loc_208734
	move.b  #0,$1C(a1)

loc_208734:	 ; CODE XREF: sub_2086EC+40?j
	clr.b   $26(a1)
	bclr    #5,oFlags(a0)
	bclr    #5,$22(a1)
	move.w  #SFXSpring,d0
	jmp     PlayFMSound
; End of function sub_2086EC


; -------------------------------------------------------------------------


sub_20874E:	 ; DATA XREF: ROM:00208572?o
	lea     objPlayerSlot.w,a1
	bsr.w   sub_2086B8
	lea     objPlayerSlot2.w,a1
	bsr.w   sub_2086B8
	lea     (AniSpr_Spring).l,a1
	bra.w   AnimateObject
; End of function sub_20874E


; -------------------------------------------------------------------------


sub_208768:	 ; DATA XREF: ROM:00208574?o
	move.b  #1,$1D(a0)
	subq.b  #4,oRoutine(a0)
	move.b  #0,oMapFrame(a0)
	rts
; End of function sub_208768


; -------------------------------------------------------------------------


sub_20877A:	 ; CODE XREF: sub_208788+A?p
		        ; sub_208788+14?p ...
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	jmp     SolidObject
; End of function sub_20877A


; -------------------------------------------------------------------------


sub_208788:	 ; DATA XREF: ROM:00208576?o
	tst.b   1(a0)
	bpl.s   locret_2087A0
	lea     objPlayerSlot.w,a1
	bsr.s   sub_20877A
	beq.s   loc_208798
	bsr.s   sub_2087A2

loc_208798:	 ; CODE XREF: sub_208788+C?j
	lea     objPlayerSlot2.w,a1
	bsr.s   sub_20877A
	bne.s   sub_2087A2

locret_2087A0:	          ; CODE XREF: sub_208788+4?j
	rts
; End of function sub_208788


; -------------------------------------------------------------------------


sub_2087A2:	 ; CODE XREF: sub_208788+E?p
		        ; sub_208788+16?j
	move.b  #$10,oRoutine(a0)
	subq.w  #8,$C(a1)
	move.w  $30(a0),$12(a1)
	neg.w   $12(a1)
	bset    #1,$22(a1)
	bclr    #3,$22(a1)
	bclr    #3,oFlags(a0)
	move.w  #SFXSpring,d0
	jsr     PlayFMSound

loc_2087D2:	 ; DATA XREF: ROM:00208578?o
	lea     objPlayerSlot.w,a1
	bsr.s   sub_20877A
	lea     objPlayerSlot2.w,a1
	bsr.s   sub_20877A
	lea     (AniSpr_Spring).l,a1
	bra.w   AnimateObject

sub_2087E8:
	move.b  #1,$1D(a0)
	subq.b  #4,oRoutine(a0)
	move.b  #0,oMapFrame(a0)
	rts

sub_2087FA:
	tst.b   1(a0)
	bpl.s   locret_208826
	lea     objPlayerSlot.w,a1
	bsr.w   sub_20877A
	bne.s   loc_208812
	btst    #5,oFlags(a0)
	beq.s   loc_208814

loc_208812:
	bsr.s   sub_208828

loc_208814:
	lea     objPlayerSlot2.w,a1
	bsr.w   sub_20877A
	bne.s   sub_208828
	btst    #5,oFlags(a0)
	bne.s   sub_208828

locret_208826:
	rts

sub_208828:
	move.b  #$16,oRoutine(a0)
	moveq   #0,d0
	move.b  #$D0,d0
	jsr     CalcSine
	move.w  $30(a0),d2
	neg.w   d2
	mulu.w  d2,d0
	mulu.w  d2,d1
	lsr.l   #8,d0
	lsr.l   #8,d1
	move.w  d0,$12(a1)
	move.w  d1,$10(a1)
	addq.w  #8,$C(a1)
	btst    #1,oSprFlags(a0)
	beq.s   loc_208866
	subi.w  #$10,$C(a1)
	neg.w   $12(a1)

loc_208866:
	bclr    #0,$22(a1)
	subq.w  #8,8(a1)
	btst    #0,oFlags(a0)
	beq.s   loc_208888
	addi.w  #$10,8(a1)
	bset    #0,$22(a1)
	neg.w   $10(a1)

loc_208888:
	bset    #1,$22(a1)
	bclr    #3,$22(a1)
	bclr    #5,$22(a1)
	bclr    #3,oFlags(a0)
	bclr    #5,oFlags(a0)
	move.w  #SFXSpring,d0
	jsr     PlayFMSound

loc_2088B0:
	lea     (AniSpr_Spring).l,a1
	bra.w   AnimateObject

sub_2088BA:
	move.b  #1,$1D(a0)
	subq.b  #4,oRoutine(a0)
	move.b  #0,oMapFrame(a0)
	rts

; -------------------------------------------------------------------------
AniSpr_S1Spring:	include	"Level/Leftover/Sonic 1 Spring Animation Script.asm"
MapSpr_S1Spring:	include	"Level/Leftover/Sonic 1 Spring Mappings.asm"
AniSpr_Spring:		include	"Level/_Objects/Springs/Animation Script.asm"
;	WARNING! Some data in the prototype points to the
;	middle of the mapping header. To edit the spring map,
;	please redefine where this secondary mapping would be.
;	~ MDT
MapSpr_Spring1:		include	"Level/_Objects/Springs/Mappings 1.asm"
MapSpr_Spring3:		include	"Level/_Objects/Springs/Mappings 3.asm"
AniSpr_MovingSpring:include	"Level/_Objects/Moving Springs/Animation Script.asm"
MapSpr_MovingSpring:include	"Level/_Objects/Moving Springs/Mappings.asm"

; -------------------------------------------------------------------------

ObjRing:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_2089FE(pc,d0.w),d1
	jmp     off_2089FE(pc,d1.w)

; -------------------------------------------------------------------------
off_2089FE:     
    dc.w sub_208A28-off_2089FE       
	dc.w loc_208B18-off_2089FE
	dc.w loc_208B4A-off_2089FE
	dc.w loc_208B84-off_2089FE
	dc.w loc_208B92-off_2089FE
byte_208A08:    
    dc.b  $10,   0, $18,   0, $20,   0,   0, $10
	dc.b    0, $18,   0, $20, $10, $10, $18, $18
	dc.b  $20, $20, $F0, $10, $E8, $18, $E0, $20
	dc.b  $10,   8, $18, $10, $F0,   8, $E8, $10

; -------------------------------------------------------------------------


sub_208A28:
	lea     savedObjFlags,a2
	moveq   #0,d0
	move.b  $23(a0),d0
	move.w  d0,d1
	add.w   d1,d1
	add.w   d1,d0
	moveq   #0,d1
	move.b  timeZone,d1
	add.w   d1,d0
	lea     2(a2,d0.w),a2
	move.b  (a2),d4
	move.b  $28(a0),d1
	moveq   #0,d0
	move.b  d1,d0
	andi.w  #7,d1
	cmpi.w  #7,d1
	bne.s   loc_208A5E
	moveq   #6,d1

loc_208A5E:
	swap    d1
	move.w  #1,d1
	lsr.b   #4,d0
	add.w   d0,d0
	move.b  byte_208A08(pc,d0.w),d5
	ext.w   d5
	move.b  byte_208A08+1(pc,d0.w),d6
	ext.w   d6
	movea.l a0,a1
	move.w  oX(a0),d2
	move.w  oY(a0),d3
	lea     1(a2),a3
	moveq   #0,d0
	move.b  timeZone,d0

loc_208A8A:
	move.b  -(a3),d4
	lsr.b   d1,d4
	bcs.s   loc_208B04
	dbf     d0,loc_208A8A
	bclr    #7,(a2)
	bra.s   loc_208ABC
; -------------------------------------------------------------------------

loc_208A9A:
	swap    d1
	lea     1(a2),a3
	moveq   #0,d0
	move.b  timeZone,d0

loc_208AA8:
	move.b  -(a3),d4
	lsr.b   d1,d4
	bcs.s   loc_208B04
	dbf     d0,loc_208AA8
	bclr    #7,(a2)
	bsr.w   FindObjSlot
	bne.s   loc_208B10

loc_208ABC:
	move.b  #$10,0(a1)
	addq.b  #2,$24(a1)
	move.w  d2,8(a1)
	move.w  oX(a0),$32(a1)
	move.w  d3,$C(a1)
	move.l  #map_208D50,4(a1)
	move.w  #$A7AE,2(a1)
	move.b  #4,1(a1)
	move.b  #2,$18(a1)
	move.b  #$47,$20(a1) ; 'G'
	move.b  #8,$19(a1)
	move.b  $23(a0),$23(a1)
	move.b  d1,$34(a1)

loc_208B04:
	addq.w  #1,d1
	add.w   d5,d2
	add.w   d6,d3
	swap    d1
	dbf     d1,loc_208A9A

loc_208B10:	
	btst    #0,(a2)
	bne.w   DeleteObject

loc_208B18:	
	move.w  $32(a0),d0
	andi.w  #$FF80,d0
	move.w  cameraX.w,d1
	subi.w  #$80,d1
	andi.w  #$FF80,d1
	sub.w   d1,d0
	cmpi.w  #$280,d0
	bhi.w   loc_208B92
	tst.w   timeStopTimer
	bne.s   loc_208B46
	move.b  ringAnimFrame,oMapFrame(a0)

loc_208B46:
	bra.w   DrawObject

loc_208B4A:
	addq.b  #2,oRoutine(a0)
	move.b  #0,$20(a0)
	move.b  #1,$18(a0)
	bsr.w   CollectRing
	lea     savedObjFlags,a2
	moveq   #0,d0
	move.b  $23(a0),d0
	move.w  d0,d1
	add.w   d1,d1
	add.w   d1,d0
	moveq   #0,d1
	move.b  timeZone,d1
	add.w   d1,d0
	move.b  $34(a0),d1
	subq.b  #1,d1
	bset    d1,2(a2,d0.w)

loc_208B84:
	lea     (ani_208D48).l,a1
	bsr.w   AnimateObject
	bra.w   DrawObject
; -------------------------------------------------------------------------

loc_208B92:
	bra.w   DeleteObject

; -------------------------------------------------------------------------

CollectRing:
	addq.w  #1,rings
	ori.b   #1,updateHUDRings
	move.w  #SFXRingRight,d0
	cmpi.w  #$64,rings
	bcs.s   .PlaySound
	bset    #1,livesFlags
	beq.s   .AddLife
	cmpi.w  #$C8,rings
	bcs.s   .PlaySound
	bset    #2,livesFlags
	bne.s   .PlaySound

.AddLife:
	addq.b  #1,lives
	addq.b  #1,updateHUDLives
	move.w  #$88,d0

.PlaySound:
	jmp     PlayFMSound

; -------------------------------------------------------------------------


ObjLostRing:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjLostRing_Index(pc,d0.w),d1
	jmp     ObjLostRing_Index(pc,d1.w)

; -------------------------------------------------------------------------

ObjLostRing_Index:
    dc.w ObjLostRing_Init-ObjLostRing_Index 
	dc.w ObjLostRing_Main-ObjLostRing_Index
	dc.w ObjLostRing_Collect-ObjLostRing_Index
	dc.w ObjLostRing_Sparkle-ObjLostRing_Index
	dc.w ObjLostRing_Delete-ObjLostRing_Index

; -------------------------------------------------------------------------


ObjLostRing_Init:
	movea.l a0,a1
	moveq   #0,d5
	move.w  rings,d5
	moveq   #$20,d0 ; ' '
	cmp.w   d0,d5
	bcs.s   loc_208C10
	move.w  d0,d5

loc_208C10:
	subq.w  #1,d5
	move.w  #$288,d4
	bra.s   loc_208C20

loc_208C18:
	bsr.w   FindObjSlot
	bne.w   loc_208CA8

loc_208C20:
	move.b  #$11,0(a1)
	addq.b  #2,$24(a1)
	move.b  #8,$16(a1)
	move.b  #8,$17(a1)
	move.w  oX(a0),8(a1)
	move.w  oY(a0),$C(a1)
	move.l  #map_208D50,4(a1)
	move.w  #$A7AE,2(a1)
	move.b  #4,1(a1)
	move.b  #3,$18(a1)
	move.b  #$47,$20(a1) ; 'G'
	move.b  #8,$19(a1)
	move.b  #$FF,ringLossAnimTimer
	tst.w   d4
	bmi.s   loc_208C98
	move.w  d4,d0
	jsr     CalcSine
	move.w  d4,d2
	lsr.w   #8,d2
	asl.w   d2,d0
	asl.w   d2,d1
	move.w  d0,d2
	move.w  d1,d3
	addi.b  #$10,d4
	bcc.s   loc_208C98
	subi.w  #$80,d4
	bcc.s   loc_208C98
	move.w  #$288,d4

loc_208C98:	 ; CODE XREF: ObjLostRing_Init+74?j
		        ; ObjLostRing_Init+8E?j ...
	move.w  d2,$10(a1)
	move.w  d3,$12(a1)
	neg.w   d2
	neg.w   d4
	dbf     d5,loc_208C18

loc_208CA8:	 ; CODE XREF: ObjLostRing_Init+1E?j
	move.w  #0,rings
	move.b  #$80,updateHUDRings
	move.b  #0,livesFlags
	move.w  #SFXRingLoss,d0
	jsr     PlayFMSound

ObjLostRing_Main:	       ; DATA XREF: ROM:00208BF6?o
	move.b  ringLossAnimFrame,oMapFrame(a0)
	bsr.w   ObjMove
	addi.w  #$18,oYVel(a0)
	bmi.s   loc_208D08
	move.b  levelVIntCounter+3,d0
	add.b   d7,d0
	andi.b  #3,d0
	bne.s   loc_208D08
	jsr     CheckFloorEdge
	tst.w   d1
	bpl.s   loc_208D08
	add.w   d1,oY(a0)
	move.w  oYVel(a0),d0
	asr.w   #2,d0
	sub.w   d0,oYVel(a0)
	neg.w   oYVel(a0)

loc_208D08:	 ; CODE XREF: ObjLostRing_Init+DE?j
		        ; ObjLostRing_Init+EC?j ...
	tst.b   ringLossAnimTimer
	beq.s   ObjLostRing_Delete
	move.w  bottomBound.w,d0
	addi.w  #$E0,d0
	cmp.w   oY(a0),d0
	bcs.s   ObjLostRing_Delete
	bra.w   DrawObject
; -------------------------------------------------------------------------

ObjLostRing_Collect:	    ; DATA XREF: ROM:00208BF8?o
	addq.b  #2,oRoutine(a0)
	move.b  #0,$20(a0)
	move.b  #1,$18(a0)
	bsr.w   CollectRing

ObjLostRing_Sparkle:	    ; DATA XREF: ROM:00208BFA?o
	lea     (ani_208D48).l,a1
	bsr.w   AnimateObject
	bra.w   DrawObject
; -------------------------------------------------------------------------

ObjLostRing_Delete:	     ; CODE XREF: ObjLostRing_Init+110?j
		        ; ObjLostRing_Init+11E?j
		        ; DATA XREF: ...
	bra.w   DeleteObject
; End of function ObjLostRing_Init

; -------------------------------------------------------------------------
ani_208D48:     dc.w byte_208D4A-*      ; DATA XREF: sub_208A28:loc_208B84?o
		        ; ObjLostRing_Init:ObjLostRing_Sparkle?o
byte_208D4A:    dc.b  5, 4, 5, 6, 7,$FC ; DATA XREF: ROM:ani_208D48?o
map_208D50:     dc.w byte_208D62-*      ; DATA XREF: sub_208A28+AC?o
		        ; ObjLostRing_Init+44?o ...
	dc.w byte_208D68-map_208D50
	dc.w byte_208D6E-map_208D50
	dc.w byte_208D74-map_208D50
	dc.w byte_208D7A-map_208D50
	dc.w byte_208D80-map_208D50
	dc.w byte_208D86-map_208D50
	dc.w byte_208D8C-map_208D50
	dc.w byte_208D92-map_208D50
byte_208D62:    dc.b  1,$F8, 5, 0       ; DATA XREF: ROM:map_208D50?o
	dc.b  0,$F8
byte_208D68:    dc.b  1,$F8, 5, 0       ; DATA XREF: ROM:00208D52?o
	dc.b  4,$F8
byte_208D6E:    dc.b  1,$F8, 1, 0       ; DATA XREF: ROM:00208D54?o
	dc.b  8,$FC
byte_208D74:    dc.b  1,$F8, 5, 8       ; DATA XREF: ROM:00208D56?o
	dc.b  4,$F8
byte_208D7A:    dc.b  1,$F8, 5, 0       ; DATA XREF: ROM:00208D58?o
	dc.b $A,$F8
byte_208D80:    dc.b  1,$F8, 5,$18      ; DATA XREF: ROM:00208D5A?o
	dc.b $A,$F8
byte_208D86:    dc.b  1,$F8, 5,$10      ; DATA XREF: ROM:00208D5C?o
	dc.b $A,$F8
byte_208D8C:    dc.b  1,$F8, 5, 8       ; DATA XREF: ROM:00208D5E?o
	dc.b $A,$F8
byte_208D92:    dc.b  0, 0, 0, 8, 0,$3B, 0,$64, 0,$79,$A,$E0, 8, 0, 0	;	I'll split these once Kat figures out what these are. ~ MDT
		        ; DATA XREF: ROM:00208D60?o
	dc.b $E8,$E0, 8, 0, 3, 0,$E8,$C, 0, 6,$E0,$E8,$C, 0,$A
	dc.b  0,$F0, 7, 0,$E,$E0,$F0, 7, 0,$16,$10,$10,$C, 0,$1E
	dc.b $E0,$10,$C, 0,$22, 0,$18, 8, 0,$26,$E8,$18, 8, 0
	dc.b $29, 0, 8,$E0,$C, 0,$2C,$F0,$E8, 8, 0,$30,$E8,$E8
	dc.b  9, 0,$33, 0,$F0, 7, 0,$39,$E8,$F8, 5, 0,$41, 8, 8
	dc.b  9, 0,$45, 0,$10, 8, 0,$4B,$E8,$18,$C, 0,$4E,$F0
	dc.b  4,$E0, 7, 0,$52,$F4,$E0, 3, 8,$52, 4, 0, 7, 0,$5A
	dc.b $F4, 0, 3, 8,$5A, 4, 8,$E0,$C, 8,$2C,$F0,$E8, 8, 8
	dc.b $30, 0,$E8, 9, 8,$33,$E8,$F0, 7, 8,$39, 8,$F8, 5
	dc.b  8,$41,$E8, 8, 9, 8,$45,$E8,$10, 8, 8,$4B, 0,$18
	dc.b $C, 8,$4E,$F0, 0,$10, 0,$1B, 0,$30, 0,$45, 0,$5A
	dc.b  0,$6F, 0,$84, 0,$8F, 2,$E0,$F, 0, 0, 0, 0,$F,$10
	dc.b  0, 0, 4,$E0,$F, 0,$10,$F0,$E0, 7, 0,$20,$10, 0,$F
	dc.b $10,$10,$F0, 0, 7,$10,$20,$10, 4,$E0,$F, 0,$28,$E8
	dc.b $E0,$B, 0,$38, 8, 0,$F,$10,$28,$E8, 0,$B,$10,$38
	dc.b  8, 4,$E0,$F, 8,$34,$E0,$E0,$F, 0,$34, 0, 0,$F,$18
	dc.b $34,$E0, 0,$F,$10,$34, 0, 4,$E0,$B, 8,$38,$E0,$E0
	dc.b $F, 8,$28,$F8, 0,$B,$18,$38,$E0, 0,$F,$18,$28,$F8
	dc.b  4,$E0, 7, 8,$20,$E0,$E0,$F, 8,$10,$F0, 0, 7,$18
	dc.b $20,$E0, 0,$F,$18,$10,$F0, 2,$E0,$F, 8, 0,$E0, 0
	dc.b $F,$18, 0,$E0, 4,$E0,$F, 0,$44,$E0,$E0,$F, 8,$44
	dc.b  0, 0,$F,$10,$44,$E0, 0,$F,$18,$44, 0

; -------------------------------------------------------------------------

ObjSmallPlatform:	      
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjSmallPlatform_Index(pc,d0.w),d0
	jsr     ObjSmallPlatform_Index(pc,d0.w)
	move.w  oX(a0),d0
	andi.w  #$FF80,d0
	move.w  cameraX.w,d1
	subi.w  #$80,d1
	andi.w  #$FF80,d1
	sub.w   d1,d0
	cmpi.w  #$280,d0
	bhi.w   DeleteObject
	rts

; -------------------------------------------------------------------------
ObjSmallPlatform_Index:
    dc.w sub_208F16-*
	dc.w loc_208F48-ObjSmallPlatform_Index
	dc.w loc_208F8C-ObjSmallPlatform_Index
	dc.w loc_208FAE-ObjSmallPlatform_Index
	dc.w loc_208FD2-ObjSmallPlatform_Index
	dc.w loc_209000-ObjSmallPlatform_Index
	dc.w loc_209014-ObjSmallPlatform_Index

; -------------------------------------------------------------------------


sub_208F16:	 ; DATA XREF: ROM:ObjSmallPlatform_Index?o

;  AT 0020328A SIZE 0000000E BYTES

	addq.b  #2,oRoutine(a0)
	ori.b   #4,oSprFlags(a0)
	move.l  #MapSpr_SmallPlatform,4(a0)
	moveq   #5,d0
	jsr     LevelObj_SetBaseTile
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	move.b  #4,oYRadius(a0)
	move.b  #5,oMapFrame(a0)

loc_208F48:	 ; DATA XREF: ROM:00208F0A?o
	bsr.w   sub_20901C
	tst.b   timeZone
	beq.s   loc_208F82
	cmpi.b  #2,timeZone
	bne.s   loc_208F68
	btst    #3,oFlags(a0)
	bne.s   loc_208F88
	bra.s   loc_208F82
; -------------------------------------------------------------------------

loc_208F68:	 ; CODE XREF: sub_208F16+46?j
	move.b  #0,oMapFrame(a0)
	btst    #3,oFlags(a0)
	beq.s   loc_208F82
	move.b  #6,oRoutine(a0)
	move.b  #1,oAnim(a0)

loc_208F82:	 ; CODE XREF: sub_208F16+3C?j
		        ; sub_208F16+50?j ...
	jmp     DrawObject
; -------------------------------------------------------------------------

loc_208F88:	 ; CODE XREF: sub_208F16+4E?j
	addq.b  #2,oRoutine(a0)

loc_208F8C:	 ; DATA XREF: ROM:00208F0C?o
	bsr.w   sub_20901C
	addq.w  #2,oY(a0)
	move.w  cameraY.w,d0
	addi.w  #$E0,d0
	cmp.w   oY(a0),d0
	bcc.s   loc_208FA8
	jmp     DeleteObject
; -------------------------------------------------------------------------

loc_208FA8:	 ; CODE XREF: sub_208F16+8A?j
	jmp     DrawObject
; End of function sub_208F16

; -------------------------------------------------------------------------

loc_208FAE:	 ; DATA XREF: ROM:00208F0E?o
	bsr.w   sub_20901C
	btst    #3,oFlags(a0)
	bne.s   loc_208FC2
	move.b  #2,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_208FC2:	 ; CODE XREF: ROM:00208FB8?j
	lea     (ani_209038).l,a1
	bsr.w   AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------

loc_208FD2:	 ; DATA XREF: ROM:00208F10?o
	move.b  #0,oAnim(a0)
	bsr.w   sub_20901C
	btst    #3,oFlags(a0)
	bne.s   loc_208FF0
	addq.b  #2,oRoutine(a0)
	move.b  #2,oAnim(a0)
	rts
; -------------------------------------------------------------------------

loc_208FF0:	 ; CODE XREF: ROM:00208FE2?j
	lea     (ani_209038).l,a1
	bsr.w   AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------

loc_209000:	 ; DATA XREF: ROM:00208F12?o
	bsr.w   sub_20901C
	lea     (ani_209038).l,a1
	bsr.w   AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------

loc_209014:	 ; DATA XREF: ROM:00208F14?o
	move.b  #2,oRoutine(a0)
	rts

sub_20901C:	 ; CODE XREF: sub_208F16:loc_208F48?p
		        ; sub_208F16:loc_208F8C?p ...
	lea     objPlayerSlot.w,a1
	bsr.w   sub_209028
	lea     objPlayerSlot2.w,a1

; -------------------------------------------------------------------------


sub_209028:	 ; CODE XREF: ROM:00209020?p
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	subq.w  #8,d4
	jmp     SolidObject
; End of function sub_209028

; -------------------------------------------------------------------------
ani_209038:     dc.w byte_20903E-*      ; DATA XREF: ROM:loc_208FC2?o
		        ; ROM:loc_208FF0?o ...
	dc.w byte_209042-ani_209038
	dc.w byte_20904C-ani_209038
byte_20903E:    dc.b  2, 5,$FF, 0       ; DATA XREF: ROM:ani_209038?o
byte_209042:    dc.b  2, 1, 5, 2, 5, 3, 5, 4, 5,$FC
		        ; DATA XREF: ROM:0020903A?o
byte_20904C:    dc.b  2, 1, 0, 2, 0, 3, 0, 4, 0,$FC
		        ; DATA XREF: ROM:0020903C?o
MapSpr_SmallPlatform:dc.w byte_209062-* ; DATA XREF: sub_208F16+A?o
		        ; ROM:00209058?o ...
	dc.w byte_209064-MapSpr_SmallPlatform
	dc.w byte_209074-MapSpr_SmallPlatform
	dc.w byte_209084-MapSpr_SmallPlatform
	dc.w byte_209090-MapSpr_SmallPlatform
	dc.w byte_20909C-MapSpr_SmallPlatform
byte_209062:    dc.b  0, 0  ; DATA XREF: ROM:MapSpr_SmallPlatform?o
byte_209064:    dc.b  3,$F4, 9, 0       ; DATA XREF: ROM:00209058?o
	dc.b  0,$F4, 4, 0
	dc.b  0, 0,$FC, 4
	dc.b  0, 0, 0, 4
byte_209074:    dc.b  3,$F4, 9, 8       ; DATA XREF: ROM:0020905A?o
	dc.b  0,$F4, 4, 0
	dc.b  8, 0,$F4, 4
	dc.b  0, 8, 0,$FC
byte_209084:    dc.b  2,$F4, 9,$18      ; DATA XREF: ROM:0020905C?o
	dc.b  0,$F4, 4, 0
	dc.b $18, 0,$FC, 0
byte_209090:    dc.b  2,$F4, 9,$10      ; DATA XREF: ROM:0020905E?o
	dc.b  0,$F4, 4, 0
	dc.b $10, 0,$FC, 0
byte_20909C:    dc.b  1,$F4,$A, 0       ; DATA XREF: ROM:00209060?o
	dc.b  6,$F4

; -------------------------------------------------------------------------


ExecuteTimepost:	        ; CODE XREF: ObjMonitor+6?j

;  AT 0020328A SIZE 0000000E BYTES
;  AT 00206FD2 SIZE 00000048 BYTES

	tst.b   timeAttackMode
	beq.s   ObjTimepost
	jmp     DeleteObject
; -------------------------------------------------------------------------

ObjTimepost:	; CODE XREF: ExecuteTimepost+6?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjTimepost_Index(pc,d0.w),d0
	jsr     ObjTimepost_Index(pc,d0.w)
	jsr     DrawObject
	jmp     CheckObjDespawnTime
; End of function ExecuteTimepost

; -------------------------------------------------------------------------
ObjTimepost_Index:dc.w ObjTimepost_Init-*
		        ; CODE XREF: ExecuteTimepost+18?p
		        ; DATA XREF: ExecuteTimepost+14?r ...
	dc.w loc_20913E-ObjTimepost_Index
	dc.w sub_20916E-ObjTimepost_Index
	dc.w locret_209194-ObjTimepost_Index

; -------------------------------------------------------------------------


ObjTimepost_Init:	       ; DATA XREF: ROM:ObjTimepost_Index?o
	addq.b  #2,oRoutine(a0)
	move.b  #$E,oYRadius(a0)
	move.b  #$E,oXRadius(a0)
	move.l  #MapSpr_Monitor,4(a0)
	move.w  #$5A8,2(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #3,$18(a0)
	move.b  #$F,$19(a0)
	move.b  $28(a0),oAnim(a0)
	bsr.w   sub_209196
	bclr    #7,2(a2,d0.w)
	move.b  #$A,oMapFrame(a0)
	cmpi.b  #8,$28(a0)
	beq.s   loc_209124
	addq.b  #2,oMapFrame(a0)

loc_209124:	 ; CODE XREF: ObjTimepost_Init+4C?j
	btst    #0,2(a2,d0.w)
	beq.s   loc_209138
	addq.b  #1,oMapFrame(a0)
	move.b  #6,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_209138:	 ; CODE XREF: ObjTimepost_Init+58?j
	move.b  #$DF,$20(a0)

loc_20913E:	 ; DATA XREF: ROM:002090CC?o
	tst.b   $21(a0)
	beq.s   locret_20916C
	move.b  #$3C,$2A(a0) ; '<'
	addq.b  #2,oRoutine(a0)
	move.w  #SFXSignpost,d0
	jsr     PlayFMSound
	bsr.w   sub_209196
	bset    #0,2(a2,d0.w)
	move.b  #$FF,timeWarpDir
	cmpi.b  #8,$28(a0)
	beq.s   locret_20916C
	move.b  #1,timeWarpDir

locret_20916C:
	rts

; -------------------------------------------------------------------------


sub_20916E:
	subq.b  #1,$2A(a0)
	beq.s   loc_20917E
	lea     (AniSpr_Monitor).l,a1
	bra.w   AnimateObject
; -------------------------------------------------------------------------

loc_20917E:
	addq.b  #2,oRoutine(a0)
	move.b  #$B,oMapFrame(a0)
	cmpi.b  #8,$28(a0)
	beq.s   locret_209194
	addq.b  #2,oMapFrame(a0)

locret_209194:
	rts

; -------------------------------------------------------------------------

sub_209196: 
	lea     savedObjFlags,a2
	moveq   #0,d0
	move.b  $23(a0),d0
	move.w  d0,d1
	add.w   d1,d1
	add.w   d1,d0
	moveq   #0,d1
	move.b  timeZone,d1
	add.w   d1,d0
	rts

; -------------------------------------------------------------------------

sub_2091B4: 
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	move.b  #1,$25(a0)
	jmp     SolidObject

; -------------------------------------------------------------------------

ObjMonitor: 
	cmpi.b  #8,$28(a0)
	bcc.w   ExecuteTimepost
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjMonitor_Index(pc,d0.w),d1
	jmp     ObjMonitor_Index(pc,d1.w)

; -------------------------------------------------------------------------
ObjMonitor_Index:
	dc.w ObjMonitor_Init-ObjMonitor_Index
	dc.w ObjMonitor_Main-ObjMonitor_Index
	dc.w ObjMonitor_Break-ObjMonitor_Index
	dc.w ObjMonitor_Animate-ObjMonitor_Index
	dc.w ObjMonitor_Display-ObjMonitor_Index

; -------------------------------------------------------------------------


ObjMonitor_Init:	        ; DATA XREF: ROM:ObjMonitor_Index?o

;  AT 00206FD2 SIZE 00000048 BYTES

	addq.b  #2,oRoutine(a0)
	move.b  #$E,oYRadius(a0)
	move.b  #$E,oXRadius(a0)
	move.l  #MapSpr_Monitor,4(a0)
	move.w  #$5A8,2(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #3,$18(a0)
	move.b  #$F,$19(a0)
	bsr.w   sub_209196
	bclr    #7,2(a2,d0.w)
	btst    #0,2(a2,d0.w)
	beq.s   .NotBroken
	move.b  #8,oRoutine(a0)
	move.b  #$11,oMapFrame(a0)
	rts
; -------------------------------------------------------------------------

.NotBroken:	 ; CODE XREF: ObjMonitor_Init+40?j
	move.b  #$46,$20(a0) ; 'F'
	move.b  $28(a0),oAnim(a0)

ObjMonitor_Main:	        ; DATA XREF: ROM:002091E2?o
	tst.b   1(a0)
	bpl.w   ObjMonitor_Display
	move.b  $25(a0),d0
	beq.s   .CheckSolid
	bsr.w   ObjMoveGrv
	jsr     CheckFloorEdge
	tst.w   d1
	bpl.w   ObjMonitor_Animate
	add.w   d1,oY(a0)
	clr.w   oYVel(a0)
	clr.b   $25(a0)
	bra.w   ObjMonitor_Animate
; -------------------------------------------------------------------------

.CheckSolid:	; CODE XREF: ObjMonitor_Init+68?j
	tst.b   1(a0)
	bpl.s   ObjMonitor_Animate
	lea     objPlayerSlot.w,a1
	bsr.w   sub_2091B4
	lea     objPlayerSlot2.w,a1
	bsr.w   sub_2091B4

ObjMonitor_Animate:	     ; CODE XREF: ObjMonitor_Init+76?j
		        ; ObjMonitor_Init+86?j ...
	tst.w   timeStopTimer
	bne.s   ObjMonitor_Display
	lea     (AniSpr_Monitor).l,a1
	bsr.w   AnimateObject

ObjMonitor_Display:	     ; CODE XREF: ObjMonitor_Init+60?j
		        ; ObjMonitor_Init+A6?j
		        ; DATA XREF: ...
	bsr.w   DrawObject
	jmp     CheckObjDespawnTime
; End of function ObjMonitor_Init


; -------------------------------------------------------------------------


ObjMonitor_Break:	       ; DATA XREF: ROM:002091E4?o
	move.w  #SFXDestroy,d0
	jsr     PlayFMSound
	addq.b  #4,oRoutine(a0)
	move.b  #0,$20(a0)
	bsr.w   FindObjSlot
	bne.s   .NoContents
	move.b  #$1A,0(a1)
	move.w  oX(a0),8(a1)
	move.w  oY(a0),$C(a1)
	move.b  oAnim(a0),$1C(a1)

.NoContents:	; CODE XREF: ObjMonitor_Break+18?j
	bsr.w   FindObjSlot
	bne.s   .NoExplosion
	move.b  #$18,0(a1)
	move.w  oX(a0),8(a1)
	move.w  oY(a0),$C(a1)
	move.b  #1,$25(a1)

.NoExplosion:	           ; CODE XREF: ObjMonitor_Break+36?j
	bsr.w   sub_209196
	bset    #0,2(a2,d0.w)
	move.b  #$11,oMapFrame(a0)
	bra.w   DrawObject
; End of function ObjMonitor_Break


; -------------------------------------------------------------------------


ObjMonitorContents:	     ; DATA XREF: ROM:0020355C?o
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjMonitorContents_Index(pc,d0.w),d1
	jsr     ObjMonitorContents_Index(pc,d1.w)
	bra.w   DrawObject
; End of function ObjMonitorContents

; -------------------------------------------------------------------------
ObjMonitorContents_Index:dc.w ObjMonitorContents_Init-*
		        ; CODE XREF: ObjMonitorContents+A?p
		        ; DATA XREF: ObjMonitorContents+6?r ...
	dc.w ObjMonitorContents_Main-ObjMonitorContents_Index
	dc.w loc_2094BC-ObjMonitorContents_Index

; -------------------------------------------------------------------------


ObjMonitorContents_Init:	; DATA XREF: ROM:ObjMonitorContents_Index?o

;  AT 0020940A SIZE 00000006 BYTES
;  AT 0020946A SIZE 00000052 BYTES

	addq.b  #2,oRoutine(a0)
	move.w  #$5A8,2(a0)
	move.b  #$24,oSprFlags(a0) ; '$'
	move.b  #3,$18(a0)
	move.b  #8,$19(a0)
	move.w  #$FD00,oYVel(a0)
	moveq   #0,d0
	move.b  oAnim(a0),d0
	move.b  d0,oMapFrame(a0)
	movea.l #MapSpr_Monitor,a1
	add.b   d0,d0
	adda.w  (a1,d0.w),a1
	addq.w  #1,a1
	move.l  a1,4(a0)

ObjMonitorContents_Main:	; DATA XREF: ROM:0020931E?o
	tst.w   oYVel(a0)
	bpl.w   loc_209374
	bsr.w   ObjMove
	addi.w  #$18,oYVel(a0)
	rts
; -------------------------------------------------------------------------

loc_209374:	 ; CODE XREF: ObjMonitorContents_Init+42?j
	addq.b  #2,oRoutine(a0)
	move.w  #$1D,$1E(a0)
	jsr     GetPlayerObject
	move.b  oAnim(a0),d0
	bne.s   loc_2093A0

loc_20938A:	 ; CODE XREF: ObjMonitorContents_Init+A6?j
		        ; ObjMonitorContents_Init+BC?j
	addq.b  #1,lives
	addq.b  #1,updateHUDLives
	move.w  #$88,d0
	jmp     PlayFMSound
; -------------------------------------------------------------------------

loc_2093A0:	 ; CODE XREF: ObjMonitorContents_Init+66?j
	cmpi.b  #1,d0
	bne.s   loc_2093EC
	addi.w  #$A,rings
	ori.b   #1,updateHUDRings
	cmpi.w  #$64,rings ; 'd'
	bcs.s   loc_2093E2
	bset    #1,livesFlags
	beq.w   loc_20938A
	cmpi.w  #$C8,rings
	bcs.s   loc_2093E2
	bset    #2,livesFlags
	beq.w   loc_20938A

loc_2093E2:	 ; CODE XREF: ObjMonitorContents_Init+9C?j
		        ; ObjMonitorContents_Init+B2?j
	move.w  #SFXRingRight,d0
	jmp     PlayFMSound
; -------------------------------------------------------------------------

loc_2093EC:	 ; CODE XREF: ObjMonitorContents_Init+82?j
	cmpi.b  #2,d0
	bne.s   loc_20940A
; End of function ObjMonitorContents_Init


; -------------------------------------------------------------------------


sub_2093F2:	 ; CODE XREF: ObjMonitorContents_Init:loc_2094B2?p
	move.b  #1,shield
	move.b  #3,objShieldSlot.w
	move.w  #SFXShield,d0
	jmp     PlayFMSound
; End of function sub_2093F2

; -------------------------------------------------------------------------
; START OF  FOR ObjMonitorContents_Init

loc_20940A:	 ; CODE XREF: ObjMonitorContents_Init+CE?j
	cmpi.b  #3,d0
	bne.s   loc_20946A
; END OF  FOR ObjMonitorContents_Init

; -------------------------------------------------------------------------


sub_209410:	 ; CODE XREF: ObjMonitorContents_Init+194?p
	move.b  #1,invincible
	move.w  #$4B0,$32(a6)
	move.b  #3,objInvStar1Slot.w
	move.b  #1,objInvStar1Slot+oAnim.w
	move.b  #3,objInvStar2Slot.w
	move.b  #2,objInvStar2Slot+oAnim.w
	move.b  #3,objInvStar3Slot.w
	move.b  #3,objInvStar3Slot+oAnim.w
	move.b  #3,objInvStar4Slot.w
	move.b  #4,objInvStar4Slot+oAnim.w
	tst.b   bossActive.w
	bne.s   locret_209468
	cmpi.w  #$C,drownTimer
	bls.s   locret_209468
	move.w  #$87,d0
	jmp     PlayFMSound
; -------------------------------------------------------------------------

locret_209468:	          ; CODE XREF: sub_209410+42?j
		        ; sub_209410+4C?j
	rts
; End of function sub_209410

; -------------------------------------------------------------------------
; START OF  FOR ObjMonitorContents_Init

loc_20946A:	 ; CODE XREF: ObjMonitorContents_Init+EC?j
	cmpi.b  #4,d0
	bne.s   loc_20949A

loc_209470:	 ; CODE XREF: ObjMonitorContents_Init+198?j
	move.b  #1,speedShoes
	move.w  #$4B0,$34(a6)
	move.w  #$C00,sonicTopSpeed.w
	move.w  #$18,sonicAcceleration.w
	move.w  #$80,sonicDeceleration.w
	move.w  #$E2,d0
	jmp     PlayFMSound
; -------------------------------------------------------------------------

loc_20949A:	 ; CODE XREF: ObjMonitorContents_Init+14C?j
	cmpi.b  #5,d0
	bne.s   loc_2094AA
	move.w  #$12C,timeStopTimer
	move.b	#1,v_snddriver_ram+f_pausemusic
	rts
; -------------------------------------------------------------------------

loc_2094AA:	 ; CODE XREF: ObjMonitorContents_Init+17C?j
	cmpi.b  #6,d0
	bne.s   loc_2094B2
	nop

loc_2094B2:	 ; CODE XREF: ObjMonitorContents_Init+18C?j
	bsr.w   sub_2093F2
	bsr.w   sub_209410
	bra.s   loc_209470
; END OF  FOR ObjMonitorContents_Init
; -------------------------------------------------------------------------

loc_2094BC:	 ; DATA XREF: ROM:00209320?o
	subq.w  #1,$1E(a0)
	bmi.w   DeleteObject
	rts
; -------------------------------------------------------------------------
AniSpr_Monitor:	include	"Level/_Objects/Monitors & Time Posts/Monitor Animation Script.asm"
MapSpr_Monitor: include	"Level/_Objects/Monitors & Time Posts/Monitor Mappings.asm"
; -------------------------------------------------------------------------

ObjHUD:		 ; DATA XREF: ROM:00203564?o
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjHUD_Index(pc,d0.w),d0
	jmp     ObjHUD_Index(pc,d0.w)
; -------------------------------------------------------------------------
ObjHUD_Index:   dc.w loc_209712-*       ; CODE XREF: ROM:0020970A?j
		        ; DATA XREF: ROM:00209706?r ...
	dc.w loc_209756-ObjHUD_Index
; -------------------------------------------------------------------------

loc_209712:	 ; DATA XREF: ROM:ObjHUD_Index?o
	addq.b  #2,oRoutine(a0)
	move.l  #MapSpr_HUD,4(a0)
	move.w  #$8568,2(a0)
	move.w  #$90,oX(a0)
	move.w  #$88,$A(a0)
	tst.w   debugCheat
	beq.s   loc_20973E
	move.b  #2,oMapFrame(a0)

loc_20973E:	 ; CODE XREF: ROM:00209736?j
	tst.b   $28(a0)
	beq.s   loc_209756
	move.w  #$90,oX(a0)
	move.w  #$148,$A(a0)
	move.b  #1,oMapFrame(a0)

loc_209756:	 ; CODE XREF: ROM:00209742?j
		        ; DATA XREF: ROM:00209710?o
	tst.b   $28(a0)
	bne.s   loc_209770
	move.b  #0,oMapFrame(a0)
	tst.w   debugCheat
	beq.s   loc_209770
	move.b  #2,oMapFrame(a0)

loc_209770:	 ; CODE XREF: ROM:0020975A?j
		        ; ROM:00209768?j
	jmp     DrawObject
; -------------------------------------------------------------------------

MapSpr_HUD:     include	"Level/_Objects/HUD/Mappings.asm"	

; -------------------------------------------------------------------------


sub_20982A:	 ; CODE XREF: ROM:.GivePoints?p
	move.b  #1,updateHUDScore
	lea     score.l,a3
	add.l   d0,(a3)
	move.l  #$F423F,d1
	cmp.l   (a3),d1
	bhi.s   loc_209846
	move.l  d1,(a3)

loc_209846:	 ; CODE XREF: sub_20982A+18?j
	move.l  (a3),d0
	rts
; End of function sub_20982A


; -------------------------------------------------------------------------


sub_20984A:
	tst.w   debugCheat
	beq.s   loc_20986C
	bsr.w   sub_2099DA
	move.l  #$73200002,d0
	moveq   #0,d1
	move.b  debugSubtype2,d1
	bsr.w   sub_209B04
	bra.w   loc_2098B0

; -------------------------------------------------------------------------

loc_20986C:	 ; CODE XREF: sub_20984A+6?j
	tst.b   updateHUDScore
	beq.s   loc_20988A
	clr.b   updateHUDScore
	move.l  #$70600002,d0
	move.l  score.l,d1
	bsr.w   sub_209A02

loc_20988A:	 ; CODE XREF: sub_20984A+28?j
	tst.b   updateHUDRings
	beq.s   loc_2098B0
	bpl.s   loc_209898
	bsr.w   sub_20996C

loc_209898:	 ; CODE XREF: sub_20984A+48?j
	clr.b   updateHUDRings
	move.l  #$73200002,d0
	moveq   #0,d1
	move.w  rings,d1
	bsr.w   sub_2099F8

loc_2098B0:	 ; CODE XREF: sub_20984A+1E?j
		        ; sub_20984A+46?j
	tst.w   debugCheat
	bne.w   loc_20993E
	tst.b   updateHUDTime
	beq.s   loc_20993E
	tst.w   paused.w
	bne.s   loc_20993E
	lea     time,a1
	cmpi.l  #$93B3B,(a1)+
	addq.b  #1,-(a1)
	cmpi.b  #$3C,(a1) ; '<'
	bcs.s   loc_2098F8
	move.b  #0,(a1)
	addq.b  #1,-(a1)
	cmpi.b  #$3C,(a1) ; '<'
	bcs.s   loc_2098F8
	move.b  #0,(a1)
	addq.b  #1,-(a1)
	cmpi.b  #9,(a1)
	bcs.s   loc_2098F8
	move.b  #9,(a1)

loc_2098F8:	 ; CODE XREF: sub_20984A+90?j
		        ; sub_20984A+9C?j ...
	move.l  #$71E00002,d0
	moveq   #0,d1
	move.b  timeMinutes.l,d1
	bsr.w   sub_209B0E
	move.l  #$72200002,d0
	moveq   #0,d1
	move.b  timeSeconds.l,d1
	bsr.w   sub_209B18
	move.l  #$72A00002,d0
	moveq   #0,d1
	move.b  timeFrames.l,d1
	mulu.w  #$64,d1 ; 'd'
	divu.w  #$3C,d1 ; '<'
	swap    d1
	move.w  #0,d1
	swap    d1
	bsr.w   sub_209B18

loc_20993E:
	tst.b   updateHUDLives
	beq.s   locret_209950
	clr.b   updateHUDLives
	bsr.w   sub_209AEE

locret_209950:
	rts

; -------------------------------------------------------------------------

	clr.b   updateHUDTime
	lea     objPlayerSlot.w,a0
	movea.l a0,a2
	bsr.w   KillPlayer
	move.b  #1,timeOver
	rts

; -------------------------------------------------------------------------


sub_20996C:
	move.l  #$73200002,VDPCTRL
	lea     dword_2099D6(pc),a2
	move.w  #2,d2
	bra.s   loc_20999C
; -------------------------------------------------------------------------
	lea     VDPDATA,a6
	bsr.w   sub_209AEE
	move.l  #$5C400003,VDPCTRL
	lea     dword_2099CA(pc),a2
	move.w  #$E,d2

loc_20999C:
	lea     ((ArtUnc_LivesIcon+$180)).l,a1

loc_2099A2:
	move.w  #$F,d1
	move.b  (a2)+,d0
	bmi.s   loc_2099BE
	ext.w   d0
	lsl.w   #5,d0
	lea     (a1,d0.w),a3

loc_2099B2:	 ; CODE XREF: sub_20996C+48?j
	move.l  (a3)+,(a6)
	dbf     d1,loc_2099B2

loc_2099B8:	 ; CODE XREF: sub_20996C+5C?j
	dbf     d2,loc_2099A2
	rts
; -------------------------------------------------------------------------

loc_2099BE:	 ; CODE XREF: sub_20996C+3C?j
		        ; sub_20996C+58?j
	move.l  #0,(a6)
	dbf     d1,loc_2099BE
	bra.s   loc_2099B8
; End of function sub_20996C

; -------------------------------------------------------------------------
dword_2099CA:   dc.l $16FFFFFF          ; DATA XREF: sub_20996C+28?o
	dc.l $FFFFFF00
	dc.l $140000
dword_2099D6:   dc.l $FFFF0000          ; DATA XREF: sub_20996C+A?o

; -------------------------------------------------------------------------


sub_2099DA:	 ; CODE XREF: sub_20984A+8?p
	move.l  #$70E00002,d0
	moveq   #0,d1
	move.w  objPlayerSlot+oX.w,d1
	bsr.w   sub_209AE4
	move.l  #$72200002,d0
	move.w  objPlayerSlot+oY.w,d1
	bra.w   sub_209AE4
; End of function sub_2099DA


; -------------------------------------------------------------------------


sub_2099F8:	 ; CODE XREF: sub_20984A+62?p
	lea     (dword_209AC8).l,a2
	moveq   #2,d6
	bra.s   loc_209A0A
; End of function sub_2099F8


; -------------------------------------------------------------------------


sub_209A02:	 ; CODE XREF: sub_20984A+3C?p
	lea     (dword_209ABC).l,a2
	moveq   #5,d6

loc_209A0A:	 ; CODE XREF: sub_2099F8+8?j
	moveq   #0,d4
	lea     ((ArtUnc_LivesIcon+$180)).l,a1

loc_209A12:	 ; CODE XREF: sub_209A02+5A?j
	moveq   #0,d2
	move.l  (a2)+,d3

loc_209A16:	 ; CODE XREF: sub_209A02+1A?j
	sub.l   d3,d1
	bcs.s   loc_209A1E
	addq.w  #1,d2
	bra.s   loc_209A16
; -------------------------------------------------------------------------

loc_209A1E:	 ; CODE XREF: sub_209A02+16?j
	add.l   d3,d1
	tst.w   d2
	beq.s   loc_209A28
	move.w  #1,d4

loc_209A28:	 ; CODE XREF: sub_209A02+20?j
	tst.w   d4
	beq.s   loc_209A56
	lsl.w   #6,d2
	move.l  d0,4(a6)
	lea     (a1,d2.w),a3
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)

loc_209A56:	 ; CODE XREF: sub_209A02+28?j
	addi.l  #$400000,d0
	dbf     d6,loc_209A12
	rts
; End of function sub_209A02

; -------------------------------------------------------------------------
	move.l  #$5F800003,VDPCTRL
	lea     VDPDATA,a6
	lea     (dword_209ACC).l,a2
	moveq   #1,d6
	moveq   #0,d4
	lea     ((ArtUnc_LivesIcon+$180)).l,a1

loc_209A82:	 ; CODE XREF: ROM:00209AB6?j
	moveq   #0,d2
	move.l  (a2)+,d3

loc_209A86:	 ; CODE XREF: ROM:00209A8C?j
	sub.l   d3,d1
	bcs.s   loc_209A8E
	addq.w  #1,d2
	bra.s   loc_209A86
; -------------------------------------------------------------------------

loc_209A8E:	 ; CODE XREF: ROM:00209A88?j
	add.l   d3,d1
	lsl.w   #6,d2
	lea     (a1,d2.w),a3
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	dbf     d6,loc_209A82
	rts
; -------------------------------------------------------------------------
dword_209ABC:   dc.l $186A0 ; DATA XREF: sub_209A02?o
	dc.l $2710
	dc.l $3E8
dword_209AC8:   dc.l $64	; DATA XREF: sub_2099F8?o
dword_209ACC:   dc.l $A	 ; DATA XREF: ROM:00209A72?o
		        ; sub_209B18?o
dword_209AD0:   dc.l 1	  ; DATA XREF: sub_209B04?o
		        ; sub_209B0E?o
dword_209AD4:   dc.l $1000  ; DATA XREF: sub_209AE4+2?o
	dc.l $100
	dc.l $10
	dc.l 1

; -------------------------------------------------------------------------


sub_209AE4:	 ; CODE XREF: sub_2099DA+C?p
		        ; sub_2099DA+1A?j
	moveq   #3,d6
	lea     (dword_209AD4).l,a2
	bra.s   loc_209B20
; End of function sub_209AE4


; -------------------------------------------------------------------------


sub_209AEE:	 ; CODE XREF: sub_20984A+102?p
		        ; sub_20996C+1A?p
	move.l  #$74600002,d0
	moveq   #0,d1
	move.b  lives,d1
	cmpi.b  #9,d1
	bcs.s   sub_209B04
	moveq   #9,d1
; End of function sub_209AEE


; -------------------------------------------------------------------------


sub_209B04:	 ; CODE XREF: sub_20984A+1A?p
		        ; sub_209AEE+12?j
	lea     (dword_209AD0).l,a2
	moveq   #0,d6
	bra.s   loc_209B20
; End of function sub_209B04


; -------------------------------------------------------------------------


sub_209B0E:	 ; CODE XREF: sub_20984A+BC?p
	lea     (dword_209AD0).l,a2
	moveq   #0,d6
	bra.s   loc_209B20
; End of function sub_209B0E


; -------------------------------------------------------------------------


sub_209B18:	 ; CODE XREF: sub_20984A+CE?p
		        ; sub_20984A+F0?p
	lea     (dword_209ACC).l,a2
	moveq   #1,d6

loc_209B20:	 ; CODE XREF: sub_209AE4+8?j
		        ; sub_209B04+8?j ...
	moveq   #0,d4
	lea     ((ArtUnc_LivesIcon+$180)).l,a1

loc_209B28:	 ; CODE XREF: sub_209B18+56?j
	moveq   #0,d2
	move.l  (a2)+,d3

loc_209B2C:	 ; CODE XREF: sub_209B18+1A?j
	sub.l   d3,d1
	bcs.s   loc_209B34
	addq.w  #1,d2
	bra.s   loc_209B2C
; -------------------------------------------------------------------------

loc_209B34:	 ; CODE XREF: sub_209B18+16?j
	add.l   d3,d1
	tst.w   d2
	beq.s   loc_209B3E
	move.w  #1,d4

loc_209B3E:	 ; CODE XREF: sub_209B18+20?j
	lsl.w   #6,d2
	move.l  d0,4(a6)
	lea     (a1,d2.w),a3
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	move.l  (a3)+,(a6)
	addi.l  #$400000,d0
	dbf     d6,loc_209B28
	rts
; End of function sub_209B18

; -------------------------------------------------------------------------

ObjMosqui:	  ; DATA XREF: ROM:00203540?o
	move.b  $28(a0),d0
	bmi.w   loc_209DEE
	bra.w   loc_209C4C
; -------------------------------------------------------------------------

ObjPataBata:	; DATA XREF: ROM:00203544?o
	move.b  $28(a0),d0
	bmi.w   loc_209F96
	bra.w   loc_20A1A8
; -------------------------------------------------------------------------

ObjAnton:	   ; DATA XREF: ROM:00203548?o
	move.b  $28(a0),d0
	bmi.w   loc_20A538
	bra.w   loc_20A3BA
; -------------------------------------------------------------------------

ObjTagaTaga:	; DATA XREF: ROM:0020354C?o
	move.b  $28(a0),d0
	bmi.w   loc_20A82E
	bra.w   loc_20A71C
; -------------------------------------------------------------------------

ObjTamabboh:	; DATA XREF: ROM:0020357C?o
	move.b  $28(a0),d0
	bmi.w   loc_20AC72
	bra.w   loc_20A940
; -------------------------------------------------------------------------
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_209BBE(pc,d0.w),d0
	jmp     off_209BBE(pc,d0.w)
; -------------------------------------------------------------------------
off_209BBE:     dc.w loc_209BC2-*       ; CODE XREF: ROM:00209BBA?j
		        ; DATA XREF: ROM:00209BB6?r ...
	dc.w loc_209C16-off_209BBE
; -------------------------------------------------------------------------

loc_209BC2:	 ; DATA XREF: ROM:off_209BBE?o
	addq.b  #2,oRoutine(a0)
	move.l  #map_20B4E2,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	move.w  #$400,2(a0)
	move.w  #$C00,2(a0)
	move.w  #$1400,2(a0)
	move.w  #$24FC,2(a0)
	move.l  objPlayerSlot+oX.w,d0
	addi.l  #$A0000,d0
	move.l  d0,oX(a0)
	move.l  objPlayerSlot+oY.w,d0
	subi.l  #$320000,d0
	move.l  d0,oY(a0)
	rts
; -------------------------------------------------------------------------

loc_209C16:	 ; DATA XREF: ROM:00209BC0?o
	move.l  objPlayerSlot+oX.w,d0
	addi.l  #$A0000,d0
	move.l  d0,oX(a0)
	move.l  objPlayerSlot+oY.w,d0
	subi.l  #$320000,d0
	move.l  d0,oY(a0)
	move.b  #0,oAnim(a0)
	lea     (off_20B4D0).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_209C4C:	 ; CODE XREF: ROM:00209B7C?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	beq.s   loc_209C66
	tst.b   1(a0)
	bmi.s   loc_209C66
	jsr     DrawObject
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------

loc_209C66:	 ; CODE XREF: ROM:00209C52?j
		        ; ROM:00209C58?j
	move.w  off_209C74(pc,d0.w),d0
	jsr     off_209C74(pc,d0.w)
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------
off_209C74:     dc.w loc_209C80-*       ; CODE XREF: ROM:00209C6A?p
		        ; DATA XREF: ROM:loc_209C66?r ...
	dc.w loc_209CBC-off_209C74
	dc.w loc_209D04-off_209C74
	dc.w loc_209D76-off_209C74
	dc.w loc_209DA4-off_209C74
	dc.w loc_209DDA-off_209C74
; -------------------------------------------------------------------------

loc_209C80:	 ; DATA XREF: ROM:off_209C74?o
	move.b  #6,$20(a0)
	addq.b  #2,oRoutine(a0)
	move.l  #map_20AFCC,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #0,d0
	jsr     LevelObj_SetBaseTile
	move.b  #1,oAnim(a0)
	move.l  oX(a0),d0
	move.l  d0,$2C(a0)
	rts
; -------------------------------------------------------------------------

loc_209CBC:	 ; DATA XREF: ROM:00209C76?o
	bra.w   loc_209D04
; -------------------------------------------------------------------------
	move.w  #$2C00,2(a0)
	move.l  oX(a0),d0
	addi.l  #$10000,d0
	move.l  d0,oX(a0)
	move.w  oX(a0),d0
	move.w  $2C(a0),d1
	addi.w  #$6E,d1 ; 'n'
	cmp.w   d0,d1
	bpl.w   loc_209CEC
	move.b  #4,oRoutine(a0)

loc_209CEC:	 ; CODE XREF: ROM:00209CE2?j
	bsr.w   loc_209D44
	lea     (ani_20AFA4).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_209D04:	 ; CODE XREF: ROM:loc_209CBC?j
		        ; DATA XREF: ROM:00209C78?o
	moveq   #0,d0
	jsr     LevelObj_SetBaseTile
	move.l  oX(a0),d0
	subi.l  #$10000,d0
	move.l  d0,oX(a0)
	move.w  oX(a0),d0
	move.w  $2C(a0),d1
	subi.w  #$6E,d1 ; 'n'
	cmp.w   d0,d1
	bmi.w   *+4

loc_209D2C:	 ; CODE XREF: ROM:00209D28?j
	bsr.w   loc_209D44
	lea     (ani_20AFA4).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_209D44:	 ; CODE XREF: ROM:loc_209CEC?p
		        ; ROM:loc_209D2C?p
	move.w  objPlayerSlot+oX.w,d1
	move.w  oX(a0),d0
	move.w  d1,d2
	addi.w  #$32,d1 ; '2'
	subi.w  #$32,d2 ; '2'
	cmp.w   d1,d0
	bpl.w   locret_209D74
	cmp.w   d2,d0
	bmi.w   locret_209D74
	move.b  #6,oRoutine(a0)
	move.b  #2,oAnim(a0)
	move.w  #$32,$2A(a0) ; '2'

locret_209D74:	          ; CODE XREF: ROM:00209D58?j
		        ; ROM:00209D5E?j
	rts
; -------------------------------------------------------------------------

loc_209D76:	 ; DATA XREF: ROM:00209C7A?o
	move.w  $2A(a0),d0
	subq.w  #1,d0
	move.w  d0,$2A(a0)
	bne.w   loc_209D90
	move.b  #8,oRoutine(a0)
	move.b  #3,oAnim(a0)

loc_209D90:	 ; CODE XREF: ROM:00209D80?j
	lea     (ani_20AFA4).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_209DA4:	 ; DATA XREF: ROM:00209C7C?o
	move.l  oY(a0),d0
	addi.l  #$60000,d0
	move.l  d0,oY(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	bmi.w   loc_209DD2
	lea     (ani_20AFA4).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_209DD2:	 ; CODE XREF: ROM:00209DBA?j
	move.b  #$A,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_209DDA:	 ; DATA XREF: ROM:00209C7E?o
	lea     (ani_20AFA4).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_209DEE:	 ; CODE XREF: ROM:00209B78?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	beq.s   loc_209E08
	tst.b   1(a0)
	bmi.s   loc_209E08
	jsr     DrawObject
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------

loc_209E08:	 ; CODE XREF: ROM:00209DF4?j
		        ; ROM:00209DFA?j
	move.w  off_209E16(pc,d0.w),d0
	jsr     off_209E16(pc,d0.w)
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------
off_209E16:     dc.w sub_209E22-*       ; CODE XREF: ROM:00209E0C?p
		        ; DATA XREF: ROM:loc_209E08?r ...
	dc.w sub_209E64-off_209E16
	dc.w loc_209EAC-off_209E16
	dc.w sub_209F1E-off_209E16
	dc.w sub_209F4C-off_209E16
	dc.w sub_209F82-off_209E16

; -------------------------------------------------------------------------


sub_209E22:	 ; DATA XREF: ROM:off_209E16?o
	move.b  #6,$20(a0)
	addq.b  #2,oRoutine(a0)
	move.l  #map_20B03E,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	move.w  #$400,2(a0)
	moveq   #0,d0
	jsr     LevelObj_SetBaseTile
	move.b  #1,oAnim(a0)
	move.l  oX(a0),d0
	move.l  d0,$2C(a0)
	rts
; End of function sub_209E22


; -------------------------------------------------------------------------


sub_209E64:	 ; DATA XREF: ROM:00209E18?o
	bra.w   loc_209EAC
; -------------------------------------------------------------------------
	move.w  #$2C00,2(a0)
	move.l  oX(a0),d0
	addi.l  #$10000,d0
	move.l  d0,oX(a0)
	move.w  oX(a0),d0
	move.w  $2C(a0),d1
	addi.w  #$6E,d1 ; 'n'
	cmp.w   d0,d1
	bpl.w   loc_209E94
	move.b  #4,oRoutine(a0)

loc_209E94:	 ; CODE XREF: sub_209E64+26?j
	bsr.w   sub_209EEC
	lea     (ani_20B01C).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_209EAC:	 ; CODE XREF: sub_209E64?j
		        ; DATA XREF: ROM:00209E1A?o
	moveq   #0,d0
	jsr     LevelObj_SetBaseTile
	move.l  oX(a0),d0
	subi.l  #$10000,d0
	move.l  d0,oX(a0)
	move.w  oX(a0),d0
	move.w  $2C(a0),d1
	subi.w  #$6E,d1 ; 'n'
	cmp.w   d0,d1
	bmi.w   *+4

loc_209ED4:	 ; CODE XREF: sub_209E64+6C?j
	bsr.w   sub_209EEC
	lea     (ani_20B01C).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_209E64

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_209EEC:	 ; CODE XREF: sub_209E64:loc_209E94?p
		        ; sub_209E64:loc_209ED4?p
	move.w  objPlayerSlot+oX.w,d1
	move.w  oX(a0),d0
	move.w  d1,d2
	addi.w  #$32,d1 ; '2'
	subi.w  #$32,d2 ; '2'
	cmp.w   d1,d0
	bpl.w   locret_209F1C
	cmp.w   d2,d0
	bmi.w   locret_209F1C
	move.b  #6,oRoutine(a0)
	move.b  #2,oAnim(a0)
	move.w  #$3C,$2A(a0) ; '<'

locret_209F1C:	          ; CODE XREF: sub_209EEC+14?j
		        ; sub_209EEC+1A?j
	rts
; End of function sub_209EEC


; -------------------------------------------------------------------------


sub_209F1E:	 ; DATA XREF: ROM:00209E1C?o
	move.w  $2A(a0),d0
	subq.w  #1,d0
	move.w  d0,$2A(a0)
	bne.w   loc_209F38
	move.b  #8,oRoutine(a0)
	move.b  #3,oAnim(a0)

loc_209F38:	 ; CODE XREF: sub_209F1E+A?j
	lea     (ani_20B01C).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_209F1E

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_209F4C:	 ; DATA XREF: ROM:00209E1E?o
	move.l  oY(a0),d0
	addi.l  #$60000,d0
	move.l  d0,oY(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	bmi.w   loc_209F7A
	lea     (ani_20B01C).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_209F7A:	 ; CODE XREF: sub_209F4C+16?j
	move.b  #$A,oRoutine(a0)
	rts
; End of function sub_209F4C


; -------------------------------------------------------------------------


sub_209F82:	 ; DATA XREF: ROM:00209E20?o
	lea     (ani_20B01C).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_209F82

; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_209F96:	 ; CODE XREF: ROM:00209B84?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_209FAA(pc,d0.w),d0
	jsr     off_209FAA(pc,d0.w)
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------
off_209FAA:     dc.w sub_209FB4-*       ; CODE XREF: ROM:00209FA0?p
		        ; DATA XREF: ROM:00209F9C?r ...
	dc.w sub_20A002-off_209FAA
	dc.w sub_20A136-off_209FAA
	dc.w sub_20A08C-off_209FAA
	dc.w sub_20A136-off_209FAA

; -------------------------------------------------------------------------


sub_209FB4:	 ; DATA XREF: ROM:off_209FAA?o
	move.b  #6,$20(a0)
	addq.b  #2,oRoutine(a0)
	move.l  #off_20B0A4,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #1,d0
	jsr     LevelObj_SetBaseTile
	move.w  #0,$30(a0)
	move.w  #0,$2A(a0)
	bclr    #0,oFlags(a0)
	bclr    #0,oSprFlags(a0)
	move.l  oY(a0),d0
	move.l  d0,$2C(a0)
	rts
; End of function sub_209FB4


; -------------------------------------------------------------------------


sub_20A002:	 ; DATA XREF: ROM:00209FAC?o
	tst.b   1(a0)
	bpl.s   loc_20A086
	move.b  #0,oAnim(a0)
	moveq   #1,d0
	jsr     LevelObj_SetBaseTile
	bclr    #0,oFlags(a0)
	bclr    #0,oSprFlags(a0)
	bsr.w   sub_20A114
	move.l  oX(a0),d0
	subi.l  #$8000,d0
	move.l  d0,oX(a0)
	move.w  $30(a0),d0
	addq.w  #1,d0
	move.w  d0,$30(a0)
	cmpi.w  #$FA,d0
	bne.w   loc_20A05A
	move.w  #0,$30(a0)
	move.b  #$60,$32(a0) ; '`'
	move.b  #4,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_20A05A:	 ; CODE XREF: sub_20A002+40?j
	move.w  $2A(a0),d0
	addq.w  #1,d0
	move.w  d0,$2A(a0)
	cmpi.w  #$300,d0
	bne.w   loc_20A07A
	move.w  #0,$2A(a0)
	move.b  #6,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_20A07A:	 ; CODE XREF: sub_20A002+66?j
	lea     (ani_20B0E0).l,a1
	jsr     AnimateObject

loc_20A086:	 ; CODE XREF: sub_20A002+4?j
		        ; sub_20A08C+4?j ...
	jmp     DrawObject
; End of function sub_20A002


; -------------------------------------------------------------------------


sub_20A08C:	 ; DATA XREF: ROM:00209FB0?o
	tst.b   1(a0)
	bpl.s   loc_20A086
	move.b  #1,oAnim(a0)
	moveq   #1,d0
	jsr     LevelObj_SetBaseTile
	bsr.w   sub_20A114
	bset    #0,oFlags(a0)
	bset    #0,oSprFlags(a0)
	move.l  oX(a0),d0
	addi.l  #$8000,d0
	move.l  d0,oX(a0)
	move.w  $30(a0),d0
	addq.w  #1,d0
	move.w  d0,$30(a0)
	cmpi.w  #$FA,d0
	bne.w   loc_20A0E2
	move.w  #0,$30(a0)
	move.b  #$60,$32(a0) ; '`'
	move.b  #8,oRoutine(a0)

loc_20A0E2:	 ; CODE XREF: sub_20A08C+40?j
	move.w  $2A(a0),d0
	addq.w  #1,d0
	move.w  d0,$2A(a0)
	cmpi.w  #$300,d0
	bne.w   loc_20A100
	move.w  #0,$2A(a0)
	move.b  #2,oRoutine(a0)

loc_20A100:	 ; CODE XREF: sub_20A08C+64?j
	lea     (ani_20B0E0).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20A08C

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20A114:	 ; CODE XREF: sub_20A002+20?p
		        ; sub_20A08C+14?p
	move.w  $2A(a0),d0
	mulu.w  #$100,d0
	divu.w  #$80,d0
	jsr     CalcSine
	muls.w  #$1C00,d0
	move.l  $2C(a0),d1
	add.l   d0,d1
	move.l  d1,oY(a0)
	rts
; End of function sub_20A114


; -------------------------------------------------------------------------


sub_20A136:	 ; DATA XREF: ROM:00209FAE?o
		        ; ROM:00209FB2?o
	tst.b   1(a0)
	bpl.w   loc_20A086
	move.b  $32(a0),d0
	subq.w  #1,d0
	move.b  d0,$32(a0)
	beq.w   loc_20A182
	move.l  #$4000,d1
	addi.b  #$30,d0 ; '0'
	andi.b  #$3F,d0 ; '?'
	cmpi.b  #$20,d0 ; ' '
	bpl.w   loc_20A164
	neg.l   d1

loc_20A164:	 ; CODE XREF: sub_20A136+28?j
	move.l  oY(a0),d2
	add.l   d1,d2
	move.l  d2,oY(a0)
	lea     (ani_20B0E0).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A182:	 ; CODE XREF: sub_20A136+12?j
	move.w  #0,$30(a0)
	move.b  oRoutine(a0),d0
	cmpi.b  #4,d0
	beq.w   loc_20A198
	bra.w   loc_20A1A0
; -------------------------------------------------------------------------

loc_20A198:	 ; CODE XREF: sub_20A136+5A?j
	move.b  #2,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_20A1A0:	 ; CODE XREF: sub_20A136+5E?j
	move.b  #6,oRoutine(a0)
	rts
; End of function sub_20A136

; -------------------------------------------------------------------------

loc_20A1A8:	 ; CODE XREF: ROM:00209B88?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20A1BC(pc,d0.w),d0
	jsr     off_20A1BC(pc,d0.w)
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------
off_20A1BC:     dc.w sub_20A1C6-*       ; CODE XREF: ROM:0020A1B2?p
		        ; DATA XREF: ROM:0020A1AE?r ...
	dc.w sub_20A214-off_20A1BC
	dc.w sub_20A348-off_20A1BC
	dc.w sub_20A2A0-off_20A1BC
	dc.w sub_20A348-off_20A1BC

; -------------------------------------------------------------------------


sub_20A1C6:	 ; DATA XREF: ROM:off_20A1BC?o
	move.b  #6,$20(a0)
	addq.b  #2,oRoutine(a0)
	move.l  #off_20B0A4,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #1,d0
	jsr     LevelObj_SetBaseTile
	move.w  #0,$30(a0)
	move.w  #0,$2A(a0)
	bclr    #0,oFlags(a0)
	bclr    #0,oSprFlags(a0)
	move.l  oY(a0),d0
	move.l  d0,$2C(a0)
	rts
; End of function sub_20A1C6


; -------------------------------------------------------------------------


sub_20A214:	 ; DATA XREF: ROM:0020A1BE?o
	tst.b   1(a0)
	bpl.w   loc_20A29A
	move.b  #0,oAnim(a0)
	moveq   #1,d0
	jsr     LevelObj_SetBaseTile
	bsr.w   sub_20A326
	bclr    #0,oFlags(a0)
	bclr    #0,oSprFlags(a0)
	move.l  oX(a0),d0
	subi.l  #$8000,d0
	move.l  d0,oX(a0)
	move.w  $30(a0),d0
	addq.w  #1,d0
	move.w  d0,$30(a0)
	cmpi.w  #$1F4,d0
	bne.w   loc_20A26E
	move.w  #0,$30(a0)
	move.b  #$60,$32(a0) ; '`'
	move.b  #4,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_20A26E:	 ; CODE XREF: sub_20A214+42?j
	move.w  $2A(a0),d0
	addq.w  #1,d0
	move.w  d0,$2A(a0)
	cmpi.w  #$300,d0
	bne.w   loc_20A28E
	move.w  #0,$2A(a0)
	move.b  #6,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_20A28E:	 ; CODE XREF: sub_20A214+68?j
	lea     (ani_20B08A).l,a1
	jsr     AnimateObject

loc_20A29A:	 ; CODE XREF: sub_20A214+4?j
		        ; sub_20A2A0+4?j ...
	jmp     DrawObject
; End of function sub_20A214


; -------------------------------------------------------------------------


sub_20A2A0:	 ; DATA XREF: ROM:0020A1C2?o
	tst.b   1(a0)
	bpl.s   loc_20A29A
	move.b  #1,oAnim(a0)
	moveq   #1,d0
	jsr     LevelObj_SetBaseTile
	bsr.w   sub_20A326
	bset    #0,oFlags(a0)
	bset    #0,oSprFlags(a0)
	move.l  oX(a0),d0
	addi.l  #$8000,d0
	move.l  d0,oX(a0)
	move.w  $30(a0),d0
	addq.w  #1,d0
	move.w  d0,$30(a0)
	cmpi.w  #$1F4,d0
	bne.w   loc_20A2F6
	move.w  #0,$30(a0)
	move.b  #$60,$32(a0) ; '`'
	move.b  #8,oRoutine(a0)

loc_20A2F6:	 ; CODE XREF: sub_20A2A0+40?j
	move.w  $2A(a0),d0
	addq.w  #1,d0
	move.w  d0,$2A(a0)
	cmpi.w  #$300,d0
	bne.w   loc_20A314
	move.w  #0,$2A(a0)
	move.b  #2,oRoutine(a0)

loc_20A314:	 ; CODE XREF: sub_20A2A0+64?j
	lea     (ani_20B08A).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20A2A0


sub_20A326:	 ; CODE XREF: sub_20A214+16?p
		        ; sub_20A2A0+14?p
	move.w  $2A(a0),d0
	mulu.w  #$100,d0
	divu.w  #$80,d0
	jsr     CalcSine
	muls.w  #$3800,d0
	move.l  $2C(a0),d1
	add.l   d0,d1
	move.l  d1,oY(a0)
	rts

; -------------------------------------------------------------------------


sub_20A348:	 ; DATA XREF: ROM:0020A1C0?o
		        ; ROM:0020A1C4?o
	tst.b   1(a0)
	bne.w   loc_20A29A
	move.b  $32(a0),d0
	subq.w  #1,d0
	move.b  d0,$32(a0)
	beq.w   loc_20A394
	move.l  #$4000,d1
	addi.b  #$30,d0 ; '0'
	andi.b  #$3F,d0 ; '?'
	cmpi.b  #$20,d0 ; ' '
	bpl.w   loc_20A376
	neg.l   d1

loc_20A376:	 ; CODE XREF: sub_20A348+28?j
	move.l  oY(a0),d2
	add.l   d1,d2
	move.l  d2,oY(a0)
	lea     (ani_20B08A).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A394:	 ; CODE XREF: sub_20A348+12?j
	move.w  #0,$30(a0)
	move.b  oRoutine(a0),d0
	cmpi.b  #4,d0
	beq.w   loc_20A3AA
	bra.w   loc_20A3B2
; -------------------------------------------------------------------------

loc_20A3AA:	 ; CODE XREF: sub_20A348+5A?j
	move.b  #2,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_20A3B2:	 ; CODE XREF: sub_20A348+5E?j
	move.b  #6,oRoutine(a0)
	rts
; End of function sub_20A348

; -------------------------------------------------------------------------

loc_20A3BA:	 ; CODE XREF: ROM:00209B94?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	beq.s   loc_20A3D4
	tst.b   1(a0)
	bmi.s   loc_20A3D4
	jsr     DrawObject
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------

loc_20A3D4:	 ; CODE XREF: ROM:0020A3C0?j
		        ; ROM:0020A3C6?j
	move.w  off_20A3E2(pc,d0.w),d0
	jsr     off_20A3E2(pc,d0.w)
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------
off_20A3E2:     dc.w loc_20A3EA-*       ; CODE XREF: ROM:0020A3D8?p
		        ; DATA XREF: ROM:loc_20A3D4?r ...
	dc.w sub_20A41E-off_20A3E2
	dc.w sub_20A458-off_20A3E2
	dc.w sub_20A4C8-off_20A3E2
; -------------------------------------------------------------------------

loc_20A3EA:	 ; DATA XREF: ROM:off_20A3E2?o
	move.b  #6,$20(a0)
	addq.b  #2,oRoutine(a0)
	move.l  #map_20B154,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #2,d0
	jsr     LevelObj_SetBaseTile
	move.b  #0,oAnim(a0)
	rts

; -------------------------------------------------------------------------


sub_20A41E:	 ; DATA XREF: ROM:0020A3E4?o
	move.l  oY(a0),d0
	addi.l  #$20000,d0
	move.l  d0,oY(a0)
	move.b  #$12,oYRadius(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	bmi.w   loc_20A450
	lea     (byte_20B136).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------

loc_20A450:	 ; CODE XREF: sub_20A41E+1C?j
	move.b  #4,oRoutine(a0)
	rts
; End of function sub_20A41E


; -------------------------------------------------------------------------


sub_20A458:	 ; DATA XREF: ROM:0020A3E6?o
	move.b  #$12,oYRadius(a0)
	subi.l  #$10000,oX(a0)
	moveq   #8,d3
	jsr     ObjGetLWallDist
	tst.b   d1
	bne.w   loc_20A478
	bra.w   loc_20A4B2
; -------------------------------------------------------------------------

loc_20A478:	 ; CODE XREF: sub_20A458+18?j
	jsr     CheckFloorEdge
	tst.w   d1
	beq.w   loc_20A49E
	cmpi.w  #7,d1
	bpl.w   loc_20A4B2
	cmpi.w  #$FFF8,d1
	bmi.w   loc_20A4B2
	move.w  oY(a0),d0
	add.w   d1,d0
	move.w  d0,oY(a0)

loc_20A49E:	 ; CODE XREF: sub_20A458+28?j
	lea     (byte_20B136).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A4B2:	 ; CODE XREF: sub_20A458+1C?j
		        ; sub_20A458+30?j ...
	move.b  #6,oRoutine(a0)
	bset    #0,oFlags(a0)
	bset    #0,oSprFlags(a0)
	rts
; End of function sub_20A458

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20A4C8:	 ; DATA XREF: ROM:0020A3E8?o
	move.b  #$12,oYRadius(a0)
	addi.l  #$10000,oX(a0)
	moveq   #8,d3
	jsr     sub_206230
	tst.b   d1
	bne.w   loc_20A4E8
	bra.w   loc_20A522
; -------------------------------------------------------------------------

loc_20A4E8:	 ; CODE XREF: sub_20A4C8+18?j
	jsr     CheckFloorEdge
	tst.w   d1
	beq.w   loc_20A50E
	cmpi.w  #7,d1
	bpl.w   loc_20A522
	cmpi.w  #$FFF8,d1
	bmi.w   loc_20A522
	move.w  oY(a0),d0
	add.w   d1,d0
	move.w  d0,oY(a0)

loc_20A50E:	 ; CODE XREF: sub_20A4C8+28?j
	lea     (byte_20B136).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A522:	 ; CODE XREF: sub_20A4C8+1C?j
		        ; sub_20A4C8+30?j ...
	move.b  #4,oRoutine(a0)
	bclr    #0,oFlags(a0)
	bclr    #0,oSprFlags(a0)
	rts
; End of function sub_20A4C8

; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A538:	 ; CODE XREF: ROM:00209B90?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	beq.s   loc_20A552
	tst.b   1(a0)
	bmi.s   loc_20A552
	jsr     DrawObject
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------

loc_20A552:	 ; CODE XREF: ROM:0020A53E?j
		        ; ROM:0020A544?j
	move.w  off_20A560(pc,d0.w),d0
	jsr     off_20A560(pc,d0.w)
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------
off_20A560:     dc.w sub_20A56C-*       ; CODE XREF: ROM:0020A556?p
		        ; DATA XREF: ROM:loc_20A552?r ...
	dc.w sub_20A5A6-off_20A560
	dc.w sub_20A5E0-off_20A560
	dc.w sub_20A65C-off_20A560
	dc.w sub_20A6A0-off_20A560
	dc.w sub_20A67E-off_20A560

; -------------------------------------------------------------------------


sub_20A56C:	 ; DATA XREF: ROM:off_20A560?o
	move.b  #6,$20(a0)
	addq.b  #2,oRoutine(a0)
	move.l  #map_20B154,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #2,d0
	jsr     LevelObj_SetBaseTile
	move.b  #1,oAnim(a0)
	move.w  #0,oPlayerMoveLock(a0)
	rts
; End of function sub_20A56C


; -------------------------------------------------------------------------


sub_20A5A6:	 ; DATA XREF: ROM:0020A562?o
	move.l  oY(a0),d0
	addi.l  #$10000,d0
	move.l  d0,oY(a0)
	move.b  #$12,oYRadius(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	bmi.w   loc_20A5D8
	lea     (byte_20B136).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------

loc_20A5D8:	 ; CODE XREF: sub_20A5A6+1C?j
	move.b  #4,oRoutine(a0)
	rts
; End of function sub_20A5A6


; -------------------------------------------------------------------------


sub_20A5E0:	 ; DATA XREF: ROM:0020A564?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$F0,d0
	beq.w   loc_20A64E
	move.b  #$12,oYRadius(a0)
	subi.l  #$C000,oX(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	beq.w   loc_20A626
	cmpi.w  #7,d1
	bpl.w   loc_20A63A
	cmpi.w  #$FFF9,d1
	bmi.w   loc_20A63A
	move.w  oY(a0),d0
	add.w   d1,d0
	move.w  d0,oY(a0)

loc_20A626:	 ; CODE XREF: sub_20A5E0+28?j
		        ; sub_20A5E0+7A?j ...
	lea     (byte_20B136).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A63A:	 ; CODE XREF: sub_20A5E0+30?j
		        ; sub_20A5E0+38?j
	move.b  #8,oRoutine(a0)
	bset    #0,oFlags(a0)
	bset    #0,oSprFlags(a0)
	rts
; -------------------------------------------------------------------------

loc_20A64E:	 ; CODE XREF: sub_20A5E0+E?j
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #6,oRoutine(a0)
	bra.s   loc_20A626
; End of function sub_20A5E0


; -------------------------------------------------------------------------


sub_20A65C:	 ; DATA XREF: ROM:0020A566?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$3C,d0 ; '<'
	beq.w   loc_20A670
	bra.s   loc_20A626
; -------------------------------------------------------------------------

loc_20A670:	 ; CODE XREF: sub_20A65C+E?j
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #4,oRoutine(a0)
	bra.s   loc_20A626
; End of function sub_20A65C


; -------------------------------------------------------------------------


sub_20A67E:	 ; DATA XREF: ROM:0020A56A?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$3C,d0 ; '<'
	beq.w   loc_20A692
	bra.s   loc_20A626
; -------------------------------------------------------------------------

loc_20A692:	 ; CODE XREF: sub_20A67E+E?j
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #8,oRoutine(a0)
	bra.s   loc_20A626
; End of function sub_20A67E


; -------------------------------------------------------------------------


sub_20A6A0:	 ; DATA XREF: ROM:0020A568?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$F0,d0
	beq.w   loc_20A70E
	move.b  #$12,oYRadius(a0)
	addi.l  #$C000,oX(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	beq.w   loc_20A6E6
	cmpi.w  #7,d1
	bpl.w   loc_20A6FA
	cmpi.w  #$FFF9,d1
	bmi.w   loc_20A6FA
	move.w  oY(a0),d0
	add.w   d1,d0
	move.w  d0,oY(a0)

loc_20A6E6:	 ; CODE XREF: sub_20A6A0+28?j
		        ; sub_20A6A0+7A?j
	lea     (byte_20B136).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A6FA:	 ; CODE XREF: sub_20A6A0+30?j
		        ; sub_20A6A0+38?j
	move.b  #4,oRoutine(a0)
	bclr    #0,oFlags(a0)
	bclr    #0,oSprFlags(a0)
	rts
; -------------------------------------------------------------------------

loc_20A70E:	 ; CODE XREF: sub_20A6A0+E?j
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #$A,oRoutine(a0)
	bra.s   loc_20A6E6
; End of function sub_20A6A0

; -------------------------------------------------------------------------

loc_20A71C:	 ; CODE XREF: ROM:00209BA0?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20A730(pc,d0.w),d0
	jsr     off_20A730(pc,d0.w)
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------
off_20A730:     dc.w sub_20A738-*       ; CODE XREF: ROM:0020A726?p
		        ; DATA XREF: ROM:0020A722?r ...
	dc.w sub_20A774-off_20A730
	dc.w sub_20A7C4-off_20A730
	dc.w sub_20A81C-off_20A730

; -------------------------------------------------------------------------


sub_20A738:	 ; DATA XREF: ROM:off_20A730?o
	move.b  #6,$20(a0)
	addq.b  #2,oRoutine(a0)
	move.l  #map_20B258,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #3,d0
	jsr     LevelObj_SetBaseTile
	move.l  #$FFFC0000,$2A(a0)
	move.b  #0,oAnim(a0)
	rts
; End of function sub_20A738


; -------------------------------------------------------------------------


sub_20A774:	 ; DATA XREF: ROM:0020A732?o
	addi.l  #$1000,$2A(a0)
	move.l  oY(a0),d0
	move.l  $2A(a0),d1
	add.l   d1,d0
	move.l  d0,oY(a0)
	tst.l   d1
	bpl.w   loc_20A7B6
	cmpi.l  #$FFFFA000,d1
	bpl.w   loc_20A7AE

loc_20A79A:	 ; CODE XREF: sub_20A774+40?j
		        ; sub_20A774+4E?j
	lea     (ani_20B208).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A7AE:	 ; CODE XREF: sub_20A774+22?j
	move.b  #2,oAnim(a0)
	bra.s   loc_20A79A
; -------------------------------------------------------------------------

loc_20A7B6:	 ; CODE XREF: sub_20A774+18?j
	move.b  #4,oRoutine(a0)
	move.b  #3,oAnim(a0)
	bra.s   loc_20A79A
; End of function sub_20A774


; -------------------------------------------------------------------------


sub_20A7C4:	 ; DATA XREF: ROM:0020A734?o
	addi.l  #$1000,$2A(a0)
	move.l  oY(a0),d0
	move.l  $2A(a0),d1
	add.l   d1,d0
	move.l  d0,oY(a0)
	move.l  #$FFFC0000,d2
	neg.l   d2
	cmp.l   d2,d1
	bpl.w   loc_20A806
	cmpi.l  #$10000,d1
	bpl.w   loc_20A814

loc_20A7F2:	 ; CODE XREF: sub_20A7C4+56?j
	lea     (ani_20B208).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A806:	 ; CODE XREF: sub_20A7C4+20?j
	move.b  #6,oRoutine(a0)
	move.w  #$C8,$2E(a0)
	rts
; -------------------------------------------------------------------------

loc_20A814:	 ; CODE XREF: sub_20A7C4+2A?j
	move.b  #1,oAnim(a0)
	bra.s   loc_20A7F2
; End of function sub_20A7C4


; -------------------------------------------------------------------------


sub_20A81C:	 ; DATA XREF: ROM:0020A736?o
	subq.w  #1,$2E(a0)
	beq.w   loc_20A826
	rts
; -------------------------------------------------------------------------

loc_20A826:	 ; CODE XREF: sub_20A81C+4?j
	move.b  #0,oRoutine(a0)
	rts
; End of function sub_20A81C

; -------------------------------------------------------------------------

loc_20A82E:	 ; CODE XREF: ROM:00209B9C?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20A842(pc,d0.w),d0
	jsr     off_20A842(pc,d0.w)
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------
off_20A842:     dc.w sub_20A84A-*       ; CODE XREF: ROM:0020A838?p
		        ; DATA XREF: ROM:0020A834?r ...
	dc.w sub_20A886-off_20A842
	dc.w sub_20A8D6-off_20A842
	dc.w sub_20A92E-off_20A842

; -------------------------------------------------------------------------


sub_20A84A:	 ; DATA XREF: ROM:off_20A842?o
	move.b  #6,$20(a0)
	addq.b  #2,oRoutine(a0)
	move.l  #map_20B258,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #3,d0
	jsr     LevelObj_SetBaseTile
	move.l  #$FFFA0000,$2A(a0)
	move.b  #4,oAnim(a0)
	rts
; End of function sub_20A84A


; -------------------------------------------------------------------------


sub_20A886:	 ; DATA XREF: ROM:0020A844?o
	addi.l  #$2000,$2A(a0)
	move.l  oY(a0),d0
	move.l  $2A(a0),d1
	add.l   d1,d0
	move.l  d0,oY(a0)
	tst.l   d1
	bpl.w   loc_20A8C8
	cmpi.l  #$FFFF0000,d1
	bpl.w   loc_20A8C0

loc_20A8AC:	 ; CODE XREF: sub_20A886+40?j
		        ; sub_20A886+4E?j
	lea     (ani_20B208).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A8C0:	 ; CODE XREF: sub_20A886+22?j
	move.b  #6,oAnim(a0)
	bra.s   loc_20A8AC
; -------------------------------------------------------------------------

loc_20A8C8:	 ; CODE XREF: sub_20A886+18?j
	move.b  #4,oRoutine(a0)
	move.b  #7,oAnim(a0)
	bra.s   loc_20A8AC
; End of function sub_20A886


; -------------------------------------------------------------------------


sub_20A8D6:	 ; DATA XREF: ROM:0020A846?o
	addi.l  #$2000,$2A(a0)
	move.l  oY(a0),d0
	move.l  $2A(a0),d1
	add.l   d1,d0
	move.l  d0,oY(a0)
	move.l  #$FFFA0000,d2
	neg.l   d2
	cmp.l   d2,d1
	bpl.w   loc_20A918
	cmpi.l  #$10000,d1
	bpl.w   loc_20A926

loc_20A904:	 ; CODE XREF: sub_20A8D6+56?j
	lea     (ani_20B208).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A918:	 ; CODE XREF: sub_20A8D6+20?j
	move.b  #6,oRoutine(a0)
	move.w  #$C8,$2E(a0)
	rts
; -------------------------------------------------------------------------

loc_20A926:	 ; CODE XREF: sub_20A8D6+2A?j
	move.b  #5,oAnim(a0)
	bra.s   loc_20A904
; End of function sub_20A8D6


; -------------------------------------------------------------------------


sub_20A92E:	 ; DATA XREF: ROM:0020A848?o
	subq.w  #1,$2E(a0)
	beq.w   loc_20A938
	rts
; -------------------------------------------------------------------------

loc_20A938:	 ; CODE XREF: sub_20A92E+4?j
	move.b  #0,oRoutine(a0)
	rts
; End of function sub_20A92E

; -------------------------------------------------------------------------

loc_20A940:	 ; CODE XREF: ROM:00209BAC?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20A954(pc,d0.w),d0
	jsr     off_20A954(pc,d0.w)
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------
off_20A954:     dc.w sub_20A960-*       ; CODE XREF: ROM:0020A94A?p
		        ; DATA XREF: ROM:0020A946?r ...
	dc.w sub_20A9AC-off_20A954
	dc.w sub_20AA04-off_20A954
	dc.w sub_20AAAA-off_20A954
	dc.w sub_20ABBE-off_20A954
	dc.w sub_20AB50-off_20A954

; -------------------------------------------------------------------------


sub_20A960:	 ; DATA XREF: ROM:off_20A954?o
	move.b  #6,$20(a0)
	addq.b  #2,oRoutine(a0)
	move.l  #map_20B462,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	move.w  #$400,2(a0)
	move.w  #$C00,2(a0)
	move.w  #$1400,2(a0)
	move.w  #$24C1,2(a0)
	moveq   #4,d0
	jsr     LevelObj_SetBaseTile
	move.w  #0,oPlayerMoveLock(a0)
	rts
; End of function sub_20A960


; -------------------------------------------------------------------------


sub_20A9AC:	 ; DATA XREF: ROM:0020A956?o
	move.b  #1,oAnim(a0)
	move.l  oY(a0),d0
	addi.l  #$10000,d0
	move.l  d0,oY(a0)
	move.b  #$E,oYRadius(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	beq.w   loc_20A9EA
	bmi.w   loc_20A9EA
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20A9EA:	 ; CODE XREF: sub_20A9AC+22?j
		        ; sub_20A9AC+26?j
	move.b  #4,oRoutine(a0)
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20A9AC

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20AA04:	 ; DATA XREF: ROM:0020A958?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$120,d0
	beq.w   loc_20AA76
	bclr    #0,oSprFlags(a0)
	bclr    #0,oFlags(a0)
	move.b  #1,oAnim(a0)
	move.b  #$E,oYRadius(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	beq.w   loc_20AA54
	cmpi.w  #7,d1
	bpl.w   loc_20AA76
	cmpi.w  #$FFF9,d1
	bmi.w   loc_20AA76
	move.w  oY(a0),d0
	add.w   d1,d0
	move.w  d0,oY(a0)

loc_20AA54:	 ; CODE XREF: sub_20AA04+32?j
	move.l  oX(a0),d0
	subi.l  #$C000,d0
	move.l  d0,oX(a0)
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20AA76:	 ; CODE XREF: sub_20AA04+E?j
		        ; sub_20AA04+3A?j ...
	move.l  oX(a0),d0
	addi.l  #$C000,d0
	move.l  d0,oX(a0)
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #$A,oRoutine(a0)
	move.b  #2,oAnim(a0)
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20AA04

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20AAAA:	 ; DATA XREF: ROM:0020A95A?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$120,d0
	beq.w   loc_20AB1C
	bset    #0,oSprFlags(a0)
	bset    #0,oFlags(a0)
	move.b  #1,oAnim(a0)
	move.b  #$E,oYRadius(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	beq.w   loc_20AAFA
	cmpi.w  #7,d1
	bpl.w   loc_20AB1C
	cmpi.w  #$FFF9,d1
	bmi.w   loc_20AB1C
	move.w  oY(a0),d0
	add.w   d1,d0
	move.w  d0,oY(a0)

loc_20AAFA:	 ; CODE XREF: sub_20AAAA+32?j
	move.l  oX(a0),d0
	addi.l  #$C000,d0
	move.l  d0,oX(a0)
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20AB1C:	 ; CODE XREF: sub_20AAAA+E?j
		        ; sub_20AAAA+3A?j ...
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #8,oRoutine(a0)
	move.b  #2,oAnim(a0)
	move.l  oX(a0),d0
	subi.l  #$C000,d0
	move.l  d0,oX(a0)
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20AAAA

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20AB50:	 ; DATA XREF: ROM:0020A95E?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$46,d0 ; 'F'
	beq.w   loc_20AB9C
	cmpi.w  #$5A,d0 ; 'Z'
	beq.w   loc_20ABB8
	cmpi.w  #$96,d0
	beq.w   loc_20ABA4
	cmpi.w  #$B4,d0
	beq.w   loc_20AB8E

loc_20AB7A:	 ; CODE XREF: sub_20AB50+4A?j
		        ; sub_20AB50+52?j ...
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20AB8E:	 ; CODE XREF: sub_20AB50+26?j
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #6,oRoutine(a0)
	bra.s   loc_20AB7A
; -------------------------------------------------------------------------

loc_20AB9C:	 ; CODE XREF: sub_20AB50+E?j
	move.b  #3,oAnim(a0)
	bra.s   loc_20AB7A
; -------------------------------------------------------------------------

loc_20ABA4:	 ; CODE XREF: sub_20AB50+1E?j
	move.b  #2,oAnim(a0)
	bset    #0,oSprFlags(a0)
	bset    #0,oFlags(a0)
	bra.s   loc_20AB7A
; -------------------------------------------------------------------------

loc_20ABB8:	 ; CODE XREF: sub_20AB50+16?j
	bsr.w   sub_20AC2C
	bra.s   loc_20AB7A
; End of function sub_20AB50


; -------------------------------------------------------------------------


sub_20ABBE:	 ; DATA XREF: ROM:0020A95C?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$46,d0 ; 'F'
	beq.w   loc_20AC0A
	cmpi.w  #$5A,d0 ; 'Z'
	beq.w   loc_20AC26
	cmpi.w  #$96,d0
	beq.w   loc_20AC12
	cmpi.w  #$B4,d0
	beq.w   loc_20ABFC

loc_20ABE8:	 ; CODE XREF: sub_20ABBE+4A?j
		        ; sub_20ABBE+52?j ...
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20ABFC:	 ; CODE XREF: sub_20ABBE+26?j
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #4,oRoutine(a0)
	bra.s   loc_20ABE8
; -------------------------------------------------------------------------

loc_20AC0A:	 ; CODE XREF: sub_20ABBE+E?j
	move.b  #3,oAnim(a0)
	bra.s   loc_20ABE8
; -------------------------------------------------------------------------

loc_20AC12:	 ; CODE XREF: sub_20ABBE+1E?j
	move.b  #2,oAnim(a0)
	bclr    #0,oSprFlags(a0)
	bclr    #0,oFlags(a0)
	bra.s   loc_20ABE8
; -------------------------------------------------------------------------

loc_20AC26:	 ; CODE XREF: sub_20ABBE+16?j
	bsr.w   sub_20AC2C
	bra.s   loc_20ABE8
; End of function sub_20ABBE


; -------------------------------------------------------------------------


sub_20AC2C:	 ; CODE XREF: sub_20AB50:loc_20ABB8?p
		        ; sub_20ABBE:loc_20AC26?p
	move.b  #1,d6
	bsr.w   sub_20AC3E
	move.b  #2,d6
	bsr.w   sub_20AC3E
	rts
; End of function sub_20AC2C


; -------------------------------------------------------------------------


sub_20AC3E:	 ; CODE XREF: sub_20AC2C+4?p
		        ; sub_20AC2C+C?p
	jsr     sub_20B4F2
	tst.b   d0
	beq.w   locret_20AC70
	move.b  d6,$28(a2)
	move.b  #$23,0(a2) ; '#'
	move.l  oX(a0),d1
	addi.l  #0,d1
	move.l  d1,8(a2)
	move.l  oY(a0),d1
	addi.l  #-$100000,d1
	move.l  d1,$C(a2)

locret_20AC70:	          ; CODE XREF: sub_20AC3E+8?j
	rts
; End of function sub_20AC3E

; -------------------------------------------------------------------------

loc_20AC72:	 ; CODE XREF: ROM:00209BA8?j
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20AC86(pc,d0.w),d0
	jsr     off_20AC86(pc,d0.w)
	jmp     CheckObjDespawnTime
; -------------------------------------------------------------------------
off_20AC86:     dc.w sub_20AC92-*       ; CODE XREF: ROM:0020AC7C?p
		        ; DATA XREF: ROM:0020AC78?r ...
	dc.w sub_20ACDE-off_20AC86
	dc.w sub_20AD36-off_20AC86
	dc.w sub_20ADDC-off_20AC86
	dc.w sub_20AEF0-off_20AC86
	dc.w sub_20AE82-off_20AC86

; -------------------------------------------------------------------------


sub_20AC92:	 ; DATA XREF: ROM:off_20AC86?o
	move.b  #6,$20(a0)
	addq.b  #2,oRoutine(a0)
	move.l  #map_20B462,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	move.w  #$400,2(a0)
	move.w  #$C00,2(a0)
	move.w  #$1400,2(a0)
	move.w  #$24C1,2(a0)
	moveq   #4,d0
	jsr     LevelObj_SetBaseTile
	move.w  #0,oPlayerMoveLock(a0)
	rts
; End of function sub_20AC92


; -------------------------------------------------------------------------


sub_20ACDE:	 ; DATA XREF: ROM:0020AC88?o
	move.b  #4,oAnim(a0)
	move.l  oY(a0),d0
	addi.l  #$10000,d0
	move.l  d0,oY(a0)
	move.b  #$E,oYRadius(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	beq.w   loc_20AD1C
	bmi.w   loc_20AD1C
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20AD1C:	 ; CODE XREF: sub_20ACDE+22?j
		        ; sub_20ACDE+26?j
	move.b  #4,oRoutine(a0)
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20ACDE

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20AD36:	 ; DATA XREF: ROM:0020AC8A?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$1B0,d0
	beq.w   loc_20ADA8
	bclr    #0,oSprFlags(a0)
	bclr    #0,oFlags(a0)
	move.b  #4,oAnim(a0)
	move.b  #$E,oYRadius(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	beq.w   loc_20AD86
	cmpi.w  #7,d1
	bpl.w   loc_20ADA8
	cmpi.w  #$FFF9,d1
	bmi.w   loc_20ADA8
	move.w  oY(a0),d0
	add.w   d1,d0
	move.w  d0,oY(a0)

loc_20AD86:	 ; CODE XREF: sub_20AD36+32?j
	move.l  oX(a0),d0
	subi.l  #$5000,d0
	move.l  d0,oX(a0)
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20ADA8:	 ; CODE XREF: sub_20AD36+E?j
		        ; sub_20AD36+3A?j ...
	move.l  oX(a0),d0
	addi.l  #$5000,d0
	move.l  d0,oX(a0)
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #$A,oRoutine(a0)
	move.b  #2,oAnim(a0)
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20AD36

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20ADDC:	 ; DATA XREF: ROM:0020AC8C?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$1B0,d0
	beq.w   loc_20AE4E
	bset    #0,oSprFlags(a0)
	bset    #0,oFlags(a0)
	move.b  #4,oAnim(a0)
	move.b  #$E,oYRadius(a0)
	jsr     CheckFloorEdge
	tst.w   d1
	beq.w   loc_20AE2C
	cmpi.w  #7,d1
	bpl.w   loc_20AE4E
	cmpi.w  #$FFF9,d1
	bmi.w   loc_20AE4E
	move.w  oY(a0),d0
	add.w   d1,d0
	move.w  d0,oY(a0)

loc_20AE2C:	 ; CODE XREF: sub_20ADDC+32?j
	move.l  oX(a0),d0
	addi.l  #$5000,d0
	move.l  d0,oX(a0)
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20AE4E:	 ; CODE XREF: sub_20ADDC+E?j
		        ; sub_20ADDC+3A?j ...
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #8,oRoutine(a0)
	move.b  #2,oAnim(a0)
	move.l  oX(a0),d0
	subi.l  #$5000,d0
	move.l  d0,oX(a0)
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20ADDC

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20AE82:	 ; DATA XREF: ROM:0020AC90?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$50,d0 ; 'P'
	beq.w   loc_20AECE
	cmpi.w  #$96,d0
	beq.w   loc_20AEEA
	cmpi.w  #$BE,d0
	beq.w   loc_20AED6
	cmpi.w  #$F0,d0
	beq.w   loc_20AEC0

loc_20AEAC:	 ; CODE XREF: sub_20AE82+4A?j
		        ; sub_20AE82+52?j ...
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20AEC0:	 ; CODE XREF: sub_20AE82+26?j
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #6,oRoutine(a0)
	bra.s   loc_20AEAC
; -------------------------------------------------------------------------

loc_20AECE:	 ; CODE XREF: sub_20AE82+E?j
	move.b  #3,oAnim(a0)
	bra.s   loc_20AEAC
; -------------------------------------------------------------------------

loc_20AED6:	 ; CODE XREF: sub_20AE82+1E?j
	move.b  #2,oAnim(a0)
	bset    #0,oSprFlags(a0)
	bset    #0,oFlags(a0)
	bra.s   loc_20AEAC
; -------------------------------------------------------------------------

loc_20AEEA:	 ; CODE XREF: sub_20AE82+16?j
	bsr.w   sub_20AF5E
	bra.s   loc_20AEAC
; End of function sub_20AE82


; -------------------------------------------------------------------------


sub_20AEF0:	 ; DATA XREF: ROM:0020AC8E?o
	move.w  oPlayerMoveLock(a0),d0
	addq.w  #1,d0
	move.w  d0,oPlayerMoveLock(a0)
	cmpi.w  #$50,d0 ; 'P'
	beq.w   loc_20AF3C
	cmpi.w  #$96,d0
	beq.w   loc_20AF58
	cmpi.w  #$BE,d0
	beq.w   loc_20AF44
	cmpi.w  #$F0,d0
	beq.w   loc_20AF2E

loc_20AF1A:	 ; CODE XREF: sub_20AEF0+4A?j
		        ; sub_20AEF0+52?j ...
	lea     (ani_20B408).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20AF2E:	 ; CODE XREF: sub_20AEF0+26?j
	move.w  #0,oPlayerMoveLock(a0)
	move.b  #4,oRoutine(a0)
	bra.s   loc_20AF1A
; -------------------------------------------------------------------------

loc_20AF3C:	 ; CODE XREF: sub_20AEF0+E?j
	move.b  #3,oAnim(a0)
	bra.s   loc_20AF1A
; -------------------------------------------------------------------------

loc_20AF44:	 ; CODE XREF: sub_20AEF0+1E?j
	move.b  #2,oAnim(a0)
	bclr    #0,oSprFlags(a0)
	bclr    #0,oFlags(a0)
	bra.s   loc_20AF1A
; -------------------------------------------------------------------------

loc_20AF58:	 ; CODE XREF: sub_20AEF0+16?j
	bsr.w   sub_20AF5E
	bra.s   loc_20AF1A
; End of function sub_20AEF0


; -------------------------------------------------------------------------


sub_20AF5E:	 ; CODE XREF: sub_20AE82:loc_20AEEA?p
		        ; sub_20AEF0:loc_20AF58?p
	move.b  #3,d6
	bsr.w   sub_20AF70
	move.b  #4,d6
	bsr.w   sub_20AF70
	rts
; End of function sub_20AF5E


; -------------------------------------------------------------------------


sub_20AF70:	 ; CODE XREF: sub_20AF5E+4?p
		        ; sub_20AF5E+C?p
	jsr     sub_20B4F2
	tst.b   d0
	beq.w   locret_20AFA2
	move.b  d6,$28(a2)
	move.b  #$23,0(a2) ; '#'
	move.l  oX(a0),d1
	addi.l  #0,d1
	move.l  d1,8(a2)
	move.l  oY(a0),d1
	addi.l  #-$100000,d1
	move.l  d1,$C(a2)

locret_20AFA2:	          ; CODE XREF: sub_20AF70+8?j
	rts
; End of function sub_20AF70

; -------------------------------------------------------------------------
;	I'll split these when Kat figures out what these are.	~ MDT
ani_20AFA4:     dc.w byte_20AFAC-*      ; DATA XREF: ROM:00209CF0?o
		        ; ROM:00209D30?o ...
	dc.w byte_20AFB4-ani_20AFA4
	dc.w byte_20AFB8-ani_20AFA4
	dc.w byte_20AFC8-ani_20AFA4
byte_20AFAC:    dc.b $13, 0, 1, 2, 3, 4,$FF, 0
		        ; DATA XREF: ROM:ani_20AFA4?o
byte_20AFB4:    dc.b  1, 0, 1,$FF       ; DATA XREF: ROM:0020AFA6?o
byte_20AFB8:    dc.b  6, 2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,$FF, 0
		        ; DATA XREF: ROM:0020AFA8?o
byte_20AFC8:    dc.b  0, 4,$FF, 0       ; DATA XREF: ROM:0020AFAA?o
map_20AFCC:     dc.w byte_20AFD6-*      ; DATA XREF: ROM:00206C94?o
		        ; ROM:00209C8A?o ...
	dc.w byte_20AFE1-map_20AFCC
	dc.w byte_20AFEC-map_20AFCC
	dc.w byte_20AFFC-map_20AFCC
	dc.w byte_20B00C-map_20AFCC
byte_20AFD6:    dc.b  2,$F4,$A, 0       ; DATA XREF: ROM:map_20AFCC?o
	dc.b  0,$F8,$FC, 0
	dc.b  0, 9,$F0
byte_20AFE1:    dc.b  2,$FC, 9, 0       ; DATA XREF: ROM:0020AFCE?o
	dc.b $A,$F8,$FC, 0
	dc.b  0, 9,$F0
byte_20AFEC:    dc.b  3,$F0, 6, 0       ; DATA XREF: ROM:0020AFD0?o
	dc.b $10, 0, 8, 4
	dc.b  0,$16,$F0, 0
	dc.b  0, 0,$18,$F8
byte_20AFFC:    dc.b  3,$F0, 9, 0       ; DATA XREF: ROM:0020AFD2?o
	dc.b $19,$F8, 0, 4
	dc.b  0,$1F,$F8, 8
	dc.b  0, 0,$21,$F8
byte_20B00C:    dc.b  3,$F0, 6, 0       ; DATA XREF: ROM:0020AFD4?o
	dc.b $22,$F4, 8, 0
	dc.b  0,$28,$FC,$F0
	dc.b  0, 0,$29, 4
ani_20B01C:     dc.w byte_20B024-*      ; DATA XREF: sub_209E64+34?o
		        ; sub_209E64+74?o ...
	dc.w byte_20B02C-ani_20B01C
	dc.w byte_20B030-ani_20B01C
	dc.w byte_20B03A-ani_20B01C
byte_20B024:    dc.b $13, 0, 1, 2, 3, 4,$FF, 0
		        ; DATA XREF: ROM:ani_20B01C?o
byte_20B02C:    dc.b  4, 0, 1,$FF       ; DATA XREF: ROM:0020B01E?o
byte_20B030:    dc.b $E, 2, 3, 4, 4, 4, 4, 4,$FF, 0
		        ; DATA XREF: ROM:0020B020?o
byte_20B03A:    dc.b  0, 4,$FF, 0       ; DATA XREF: ROM:0020B022?o
map_20B03E:     dc.w byte_20B048-*      ; DATA XREF: sub_209E22+A?o
		        ; ROM:0020B040?o ...
	dc.w byte_20B053-map_20B03E
	dc.w byte_20B059-map_20B03E
	dc.w byte_20B069-map_20B03E
	dc.w byte_20B079-map_20B03E
byte_20B048:    dc.b  2,$F4,$A, 0       ; DATA XREF: ROM:map_20B03E?o
	dc.b $2A,$F8,$FC, 1
	dc.b  0,$33,$F0
byte_20B053:    dc.b  1,$FC,$D, 0       ; DATA XREF: ROM:0020B040?o
	dc.b $35,$F0
byte_20B059:    dc.b  3,$F0, 6, 0       ; DATA XREF: ROM:0020B042?o
	dc.b $10, 0, 0, 1
	dc.b  0,$3D,$F8, 8
	dc.b  0, 0,$3F,$F0
byte_20B069:    dc.b  3,$F0, 9, 0       ; DATA XREF: ROM:0020B044?o
	dc.b $19,$F8, 0, 4
	dc.b  0,$40,$F8, 8
	dc.b  0, 0,$42,$F8
byte_20B079:    dc.b  3,$F0, 6, 0       ; DATA XREF: ROM:0020B046?o
	dc.b $43,$F4, 8, 0
	dc.b  0,$49,$FC,$F0
	dc.b  0, 0,$29, 4
	dc.b  0
ani_20B08A:     dc.b  0,$A, 0,$12,$13, 0, 1, 2, 1,$FF
		        ; DATA XREF: sub_20A214:loc_20A28E?o
		        ; sub_20A2A0:loc_20A314?o ...
	dc.b  4, 0, 0, 1, 2, 1,$FF
	dc.b  0, 4, 3, 3, 4, 5, 4,$FF, 0
off_20B0A4:     dc.w byte_20B0B0-*      ; DATA XREF: ROM:00206CA0?o
		        ; sub_209FB4+A?o ...
	dc.w byte_20B0C0-off_20B0A4
	dc.w byte_20B0D0-off_20B0A4
	dc.w byte_20B0B0-off_20B0A4
	dc.w byte_20B0C0-off_20B0A4
	dc.w byte_20B0D0-off_20B0A4
byte_20B0B0:    dc.b  3,$F0, 8, 0       ; DATA XREF: ROM:off_20B0A4?o
		        ; ROM:0020B0AA?o
	dc.b  0,$F8,$F8,$D
	dc.b  0, 3,$F0, 8
	dc.b  8, 0,$B,$F0
byte_20B0C0:    dc.b  3,$F8, 9, 0       ; DATA XREF: ROM:0020B0A6?o
		        ; ROM:0020B0AC?o
	dc.b $E,$F0, 0, 0
	dc.b  0,$14, 8, 8
	dc.b  0, 0,$15, 0
byte_20B0D0:    dc.b  3,$F0, 0, 0       ; DATA XREF: ROM:0020B0A8?o
		        ; ROM:0020B0AE?o
	dc.b $16,$F0,$F8, 8
	dc.b  0,$17,$F0, 0
	dc.b $D, 0,$1A,$F0
ani_20B0E0:     dc.b  0,$A, 0,$12,$13, 0, 1, 2, 1,$FF, 4, 0, 0, 1, 2, 1
		        ; DATA XREF: sub_20A002:loc_20A07A?o
		        ; sub_20A08C:loc_20A100?o ...
	dc.b $FF, 0, 4, 3, 3, 4, 5, 4,$FF, 0, 0,$C, 0,$1C, 0,$2C
	dc.b  0,$C, 0,$1C, 0,$2C, 3,$F0, 8, 0, 0,$F8,$F8,$D, 0
	dc.b $22,$F0, 8, 8, 0,$B,$F0, 3,$F8, 9, 0,$E,$F0, 0, 0
	dc.b  0,$14, 8, 8, 0, 0,$15, 0, 3,$F0, 0, 0,$16,$F0,$F8
	dc.b  8, 0,$17,$F0, 0,$D, 0,$2A,$F0
byte_20B136:    dc.b  0,$16, 0,$1A, 0,$12, 0, 8,$13, 0, 1, 2, 3, 4, 5
		        ; DATA XREF: sub_20A41E+20?o
		        ; sub_20A458:loc_20A49E?o ...
	dc.b  6, 7,$FF,$13, 0,$FF, 0, 3, 6, 7,$FF, 3, 8, 9,$FF
map_20B154:     dc.b    0, $7C,   0, $8C,   0, $92,   0, $98
		        ; DATA XREF: ROM:00206CAC?o
		        ; ROM:0020A3F4?o ...
	dc.b    0, $9E,   0, $A4,   0, $14,   0, $2E
	dc.b    0, $48,   0, $62,   5, $EA,   5,   0
	dc.b    0, $F4, $FA,   0,   0,   4, $F4, $FA
	dc.b    5,   0,   5, $FC,   2,   5,   0,   9
	dc.b  $F8, $FA,   0,   0, $11,  $E,   5, $EB
	dc.b    5,   0,   0, $F4, $FB,   0,   0,   4
	dc.b  $F4, $FB,   5,   0,   5, $FC,   2,   5
	dc.b    0,  $D, $F8, $FA,   0,   0, $11, $12
	dc.b    5, $EA,   5,   0, $12, $F4, $FA,   0
	dc.b    0,   4, $F4, $FA,   5,   0,   5, $FC
	dc.b    2,   5,   0,   9, $F8, $FA,   0,   0
	dc.b  $11,  $E,   5, $EB,   5,   0, $12, $F4
	dc.b  $FB,   0,   0,   4, $F4, $FB,   5,   0
	dc.b    5, $FC,   2,   5,   0,  $D, $F8, $FA
	dc.b    0,   0, $11, $12,   3, $F0,   5,   0
	dc.b    0, $F4,   0,   0,   0,   4, $F4,   0
	dc.b    5,   0,   5, $FC,   1, $F8,   5,   0
	dc.b    9, $F8,   1, $F8,   5,   0,  $D, $F8
	dc.b    1, $FC,   0,   0, $11, $FC,   1, $FC
	dc.b    0,   0, $11,   0,   3, $F0,   5,   0
	dc.b  $12, $F4,   0,   0,   0,   4, $F4,   0
	dc.b    5,   0,   5, $FC
ani_20B208:     dc.w byte_20B21C-*      ; DATA XREF: sub_20A774:loc_20A79A?o
		        ; sub_20A7C4:loc_20A7F2?o ...
	dc.w byte_20B220-ani_20B208
	dc.w byte_20B224-ani_20B208
	dc.w byte_20B228-ani_20B208
	dc.w byte_20B22C-ani_20B208
	dc.w byte_20B230-ani_20B208
	dc.w byte_20B234-ani_20B208
	dc.w byte_20B238-ani_20B208
	dc.w byte_20B23C-ani_20B208
	dc.w byte_20B244-ani_20B208
byte_20B21C:    dc.b  9, 6, 7,$FF       ; DATA XREF: ROM:ani_20B208?o
byte_20B220:    dc.b  9, 8, 9,$FF       ; DATA XREF: ROM:0020B20A?o
byte_20B224:    dc.b $27,$A,$FF, 0      ; DATA XREF: ROM:0020B20C?o
byte_20B228:    dc.b $27,$B,$FF, 0      ; DATA XREF: ROM:0020B20E?o
byte_20B22C:    dc.b  9, 6, 7,$FF       ; DATA XREF: ROM:0020B210?o
byte_20B230:    dc.b  9,$C,$D,$FF       ; DATA XREF: ROM:0020B212?o
byte_20B234:    dc.b $27,$A,$FF, 0      ; DATA XREF: ROM:0020B214?o
byte_20B238:    dc.b $27,$E,$FF, 0      ; DATA XREF: ROM:0020B216?o
byte_20B23C:    dc.b $27, 0, 1, 2, 3, 4, 5,$FF
		        ; DATA XREF: ROM:0020B218?o
byte_20B244:    dc.b  9, 6, 7, 6, 7, 6, 7,$A ; DATA XREF: ROM:0020B21A?o
	dc.b $A,$B,$B, 8, 9, 9, 8, 9
	dc.b  8, 9,$FF, 0
map_20B258:     dc.w byte_20B276-*      ; DATA XREF: sub_20A738+A?o
		        ; sub_20A84A+A?o ...
	dc.w byte_20B28B-map_20B258
	dc.w byte_20B2A0-map_20B258
	dc.w byte_20B2B5-map_20B258
	dc.w byte_20B2CA-map_20B258
	dc.w byte_20B2D5-map_20B258
	dc.w byte_20B30A-map_20B258
	dc.w byte_20B32A-map_20B258
	dc.w byte_20B34A-map_20B258
	dc.w byte_20B36A-map_20B258
	dc.w byte_20B38A-map_20B258
	dc.w byte_20B3A0-map_20B258
	dc.w byte_20B3B5-map_20B258
	dc.w byte_20B3D4-map_20B258
	dc.w byte_20B3F3-map_20B258
byte_20B276:    dc.b  4,$F0, 3, 0, 0,$F8,$F8, 0
		        ; DATA XREF: ROM:map_20B258?o
	dc.b  0, 4,$F0,$F0, 3, 8, 0, 0
	dc.b $F8, 0, 8, 4, 8
byte_20B28B:    dc.b  4,$F0, 6, 0, 5,$F0, 8, 0
		        ; DATA XREF: ROM:0020B25A?o
	dc.b  0,$B,$F8,$F0, 6, 8, 5, 0
	dc.b  8, 0, 8,$B, 0
byte_20B2A0:    dc.b  4,$F8, 6, 0,$C,$F0,$F0, 0
		        ; DATA XREF: ROM:0020B25C?o
	dc.b  0,$12,$F8,$F8, 6, 8,$C, 0
	dc.b $F0, 0, 8,$12, 0
byte_20B2B5:    dc.b  4,$F0, 3, 0,$13,$F8, 0, 0
		        ; DATA XREF: ROM:0020B25E?o
	dc.b $10, 4,$F0,$F0, 3, 8,$13, 0
	dc.b  0, 0,$18, 4, 8
byte_20B2CA:    dc.b  2,$F4, 6, 0,$17,$F0,$F4, 6
		        ; DATA XREF: ROM:0020B260?o
	dc.b  8,$17, 0
byte_20B2D5:    dc.b  2,$F4, 6, 0,$1D,$F0,$F4, 6
		        ; DATA XREF: ROM:0020B262?o
	dc.b  8,$1D, 0, 4,$F8, 6, 0,$23
	dc.b $F0,$F0, 0, 0,$29,$F8,$F8, 6
	dc.b  8,$23, 0,$F0, 0, 8,$29, 0
	dc.b  4,$F0, 3, 0,$2A,$F8, 0, 0
	dc.b $10, 4,$F0,$F0, 3, 8,$2A, 0
	dc.b  0, 0,$18, 4, 8
byte_20B30A:    dc.b  6,$F0, 3, 0, 0,$F8,$F8, 0
		        ; DATA XREF: ROM:0020B264?o
	dc.b  0, 4,$F0,$F0, 3, 8, 0, 0
	dc.b $F8, 0, 8, 4, 8,$E5, 6, 0
	dc.b $17,$F0,$E5, 6, 8,$17, 0, 0
byte_20B32A:    dc.b  6,$F0, 3, 0, 0,$F8,$F8, 0
		        ; DATA XREF: ROM:0020B266?o
	dc.b  0, 4,$F0,$F0, 3, 8, 0, 0
	dc.b $F8, 0, 8, 4, 8,$E5, 6, 0
	dc.b $1D,$F0,$E5, 6, 8,$1D, 0, 0
byte_20B34A:    dc.b  6,$F0, 3, 0,$13,$F8, 0, 0
		        ; DATA XREF: ROM:0020B268?o
	dc.b $10, 4,$F0,$F0, 3, 8,$13, 0
	dc.b  0, 0,$18, 4, 8, 3, 6,$10
	dc.b $17,$F0, 3, 6,$18,$17, 0, 0
byte_20B36A:    dc.b  6,$F0, 3, 0,$13,$F8, 0, 0
		        ; DATA XREF: ROM:0020B26A?o
	dc.b $10, 4,$F0,$F0, 3, 8,$13, 0
	dc.b  0, 0,$18, 4, 8, 3, 6,$10
	dc.b $1D,$F0, 3, 6,$18,$1D, 0, 0
byte_20B38A:    dc.b  4,$F0, 6, 0, 5,$F0, 8, 0
		        ; DATA XREF: ROM:0020B26C?o
	dc.b  0,$B,$F8,$F0, 6, 8, 5, 0
	dc.b  8, 0, 8,$B, 0, 0
byte_20B3A0:    dc.b  4,$F8, 6, 0,$C,$F0,$F0, 0
		        ; DATA XREF: ROM:0020B26E?o
	dc.b  0,$12,$F8,$F8, 6, 8,$C, 0
	dc.b $F0, 0, 8,$12, 0
byte_20B3B5:    dc.b  6,$F0, 3, 0,$2A,$F8, 0, 0
		        ; DATA XREF: ROM:0020B270?o
	dc.b $10, 4,$F0,$F0, 3, 8,$2A, 0
	dc.b  0, 0,$18, 4, 8, 3, 6,$10
	dc.b $17,$F0, 3, 6,$18,$17, 0
byte_20B3D4:    dc.b  6,$F0, 3, 0,$2A,$F8, 0, 0
		        ; DATA XREF: ROM:0020B272?o
	dc.b $10, 4,$F0,$F0, 3, 8,$2A, 0
	dc.b  0, 0,$18, 4, 8, 3, 6,$10
	dc.b $1D,$F0, 3, 6,$18,$1D, 0
byte_20B3F3:    dc.b  4,$F8, 6, 0,$23,$F0,$F0, 0
		        ; DATA XREF: ROM:0020B274?o
	dc.b  0,$29,$F8,$F8, 6, 8,$23, 0
	dc.b $F0, 0, 8,$29, 0
ani_20B408:     dc.w byte_20B412-*      ; DATA XREF: sub_20A9AC+2A?o
		        ; sub_20A9AC+44?o ...
	dc.w byte_20B44E-ani_20B408
	dc.w byte_20B454-ani_20B408
	dc.w byte_20B458-ani_20B408
	dc.w byte_20B45C-ani_20B408
byte_20B412:    dc.b $13, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
		        ; DATA XREF: ROM:ani_20B408?o
	dc.b  1, 0, 1, 0, 1, 0, 1, 0, 1, 5, 7, 1, 7, 1, 7, 1, 7
	dc.b  1, 7, 1, 7, 1, 7, 1, 7, 1, 7, 1, 7, 1, 7, 1, 7, 1
	dc.b  5, 0, 1, 2, 3, 4, 5, 6, 7,$FF
byte_20B44E:    dc.b $13, 0, 1, 0, 1,$FF ; DATA XREF: ROM:0020B40A?o
byte_20B454:    dc.b $13, 0, 0,$FF      ; DATA XREF: ROM:0020B40C?o
byte_20B458:    dc.b  9, 2, 2,$FF       ; DATA XREF: ROM:0020B40E?o
byte_20B45C:    dc.b  5, 1, 7, 1, 7,$FF ; DATA XREF: ROM:0020B410?o
map_20B462:     dc.w byte_20B472-*      ; DATA XREF: ROM:00206CB8?o
		        ; sub_20A960+A?o ...
	dc.w byte_20B487-map_20B462
	dc.w byte_20B49C-map_20B462
	dc.w byte_20B4A7-map_20B462
	dc.w byte_20B4AD-map_20B462
	dc.w byte_20B4B3-map_20B462
	dc.w byte_20B4B9-map_20B462
	dc.w byte_20B4BF-map_20B462
byte_20B472:    dc.b  4,$F0, 9, 0, 0,$F8, 0, 9
		        ; DATA XREF: ROM:map_20B462?o
	dc.b  0, 6,$F8,$F8, 0, 0,$C,$F0
	dc.b  0, 0, 0,$D,$F0
byte_20B487:    dc.b  4,$F1, 9, 0, 0,$F8, 1, 9
		        ; DATA XREF: ROM:0020B464?o
	dc.b  0,$E,$F8,$F9, 0, 0,$C,$F0
	dc.b  1, 0, 0,$D,$F0
byte_20B49C:    dc.b  2,$F0, 8, 0,$14,$F8,$F8,$E
		        ; DATA XREF: ROM:0020B466?o
	dc.b  0,$17,$F0
byte_20B4A7:    dc.b  1,$FC, 0, 0,$23,$FC ; DATA XREF: ROM:0020B468?o
byte_20B4AD:    dc.b  1,$FC, 0, 0,$24,$FC ; DATA XREF: ROM:0020B46A?o
byte_20B4B3:    dc.b  1,$F8, 5, 0,$25,$F8 ; DATA XREF: ROM:0020B46C?o
byte_20B4B9:    dc.b  1,$F8, 5, 0,$29,$F8 ; DATA XREF: ROM:0020B46E?o
byte_20B4BF:    dc.b  3,$EF, 9, 0,$2D,$F8,$F7, 0
		        ; DATA XREF: ROM:0020B470?o
	dc.b  0,$C,$F0,$FF,$D, 0,$33,$F0
	dc.b  0
off_20B4D0:     dc.w byte_20B4D6-*      ; DATA XREF: ROM:00209C38?o
		        ; ROM:0020B4D2?o ...
	dc.w byte_20B4DA-off_20B4D0
	dc.w byte_20B4DE-off_20B4D0
byte_20B4D6:    dc.b $1D, 0, 1,$FF      ; DATA XREF: ROM:off_20B4D0?o
byte_20B4DA:    dc.b  0, 0,$FF, 0       ; DATA XREF: ROM:0020B4D2?o
byte_20B4DE:    dc.b  0, 1,$FF, 0       ; DATA XREF: ROM:0020B4D4?o
map_20B4E2:     dc.w byte_20B4E6-*      ; DATA XREF: ROM:00209BC6?o
		        ; ROM:0020B4E4?o
	dc.w byte_20B4EC-map_20B4E2
byte_20B4E6:    dc.b  1,$F8, 5, 0, 0,$F8 ; DATA XREF: ROM:map_20B4E2?o
byte_20B4EC:    dc.b  1,$F8, 5, 0, 4,$F8 ; DATA XREF: ROM:0020B4E4?o

; -------------------------------------------------------------------------


sub_20B4F2:	 ; CODE XREF: sub_20AC3E?p
		        ; sub_20AF70?p
	lea     objMissileSlots.w,a2
	moveq   #0,d0

loc_20B4F8:	 ; CODE XREF: sub_20B4F2+18?j
	move.b  0(a2),d1
	beq.w   loc_20B510
	addq.w  #1,d0
	lea     $40(a2),a2
	cmpi.w  #$3C,d0 ; '<'
	bne.s   loc_20B4F8
	moveq   #0,d0
	rts
; -------------------------------------------------------------------------

loc_20B510:	 ; CODE XREF: sub_20B4F2+A?j
	moveq   #$FFFFFFFF,d0
	rts
; End of function sub_20B4F2


; -------------------------------------------------------------------------


ObjUnkMissile:	          ; DATA XREF: ROM:00203580?o
	moveq   #0,d0
	move.b  $28(a0),d0
	andi.w  #$7F,d0
	add.w   d0,d0
	move.w  ObjUnkMissile_Index(pc,d0.w),d0
	jmp     ObjUnkMissile_Index(pc,d0.w)
; -------------------------------------------------------------------------
	rts
; End of function ObjUnkMissile

; -------------------------------------------------------------------------
ObjUnkMissile_Index:dc.w ObjUnkMissile_Null-*
		        ; CODE XREF: ObjUnkMissile+10?j
		        ; DATA XREF: ObjUnkMissile+C?r ...
	dc.w ObjUnkMissile_Null-ObjUnkMissile_Index
	dc.w ObjUnkMissile_Null-ObjUnkMissile_Index
	dc.w ObjUnkMissile_Null-ObjUnkMissile_Index
	dc.w ObjUnkMissile_Null-ObjUnkMissile_Index
	dc.w ObjUnkMissile_Null-ObjUnkMissile_Index
	dc.w ObjUnkMissile_Null-ObjUnkMissile_Index
	dc.w ObjUnkMissile_Null-ObjUnkMissile_Index
	dc.w ObjUnkMissile_Null-ObjUnkMissile_Index
	dc.w ObjUnkMissile_09-ObjUnkMissile_Index
; -------------------------------------------------------------------------

ObjUnkMissile_Null:	     ; DATA XREF: ROM:ObjUnkMissile_Index?o
		        ; ROM:0020B52C?o ...
	rts
; -------------------------------------------------------------------------

ObjUnkMissile_09:	       ; DATA XREF: ROM:0020B53C?o
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20B54E(pc,d0.w),d0
	jmp     off_20B54E(pc,d0.w)
; -------------------------------------------------------------------------
off_20B54E:     dc.w loc_20B552-*       ; CODE XREF: ROM:0020B54A?j
		        ; DATA XREF: ROM:0020B546?r ...
	dc.w sub_20B592-off_20B54E
; -------------------------------------------------------------------------

loc_20B552:	 ; DATA XREF: ROM:off_20B54E?o
	addq.b  #2,oRoutine(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #4,oXRadius(a0)
	move.b  #4,oYRadius(a0)
	move.w  #$2400,2(a0)
	move.l  #map_20B5B4,4(a0)
	move.l  #$10000,$2A(a0)
	move.b  $3F(a0),d0
	bpl.w   locret_20B590
	neg.l   $2A(a0)

locret_20B590:	          ; CODE XREF: ROM:0020B588?j
	rts

; -------------------------------------------------------------------------


sub_20B592:	 ; DATA XREF: ROM:0020B550?o
	move.l  $2A(a0),d0
	add.l   d0,oX(a0)
	lea     (ani_20B5AE).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20B592

; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------
ani_20B5AE:     dc.w byte_20B5B0-*      ; DATA XREF: sub_20B592+8?o
byte_20B5B0:    dc.b  1, 0, 1,$FF       ; DATA XREF: ROM:ani_20B5AE?o
map_20B5B4:     dc.w byte_20B5B8-*      ; DATA XREF: ROM:0020B574?o
		        ; ROM:0020B5B6?o
	dc.w byte_20B5CD-map_20B5B4
byte_20B5B8:    dc.b  4,$F8, 0, 0,$2A,$F8,$F8, 0
		        ; DATA XREF: ROM:map_20B5B4?o
	dc.b  8,$2A, 0, 0, 0,$10,$2A,$F8
	dc.b  0, 0,$18,$2A, 0
byte_20B5CD:    dc.b  4,$F8, 0, 0,$2B,$F8,$F8, 0
		        ; DATA XREF: ROM:0020B5B6?o
	dc.b  8,$2B, 0, 0, 0,$10,$2B,$F8
	dc.b  0, 0,$18,$2B, 0,$22,$48,$70
	dc.b $3F,$72, 0,$12,$C1,$51,$C8,$FF
	dc.b $FC
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------
	move.l  d1,-(sp)
	move.l  rngSeed.w,d1
	bne.s   loc_20B5FE
	move.l  #$2A6D365A,d1

loc_20B5FE:	 ; CODE XREF: ROM:0020B5F6?j
	move.l  d1,d0
	asl.l   #2,d1
	add.l   d0,d1
	asl.l   #3,d1
	add.l   d0,d1
	move.w  d1,d0
	swap    d1
	add.w   d1,d0
	move.w  d0,d1
	swap    d1
	move.l  d1,rngSeed.w
	move.l  (sp)+,d1
	rts
; -------------------------------------------------------------------------

UnkObject2:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  UnkObject2_Index(pc,d0.w),d0
	jmp     UnkObject2_Index(pc,d0.w)
; -------------------------------------------------------------------------
UnkObject2_Index:dc.w UnkObject2_Init-* ; CODE XREF: ROM:0020B624?j
		        ; DATA XREF: ROM:0020B620?r ...
	dc.w UnkObject2_Main-UnkObject2_Index
; -------------------------------------------------------------------------

UnkObject2_Init:	        ; DATA XREF: ROM:UnkObject2_Index?o
	addq.b  #2,oRoutine(a0)
	move.l  #MapSpr_UnkObject2,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	move.w  #$47A,2(a0)
	move.l  objPlayerSlot+oX.w,d0
	addi.l  #$32,d0 ; '2'
	move.l  d0,oX(a0)
	move.l  objPlayerSlot+oY.w,d0
	addi.l  #$320000,d0
	move.l  d0,oY(a0)
	rts

; -------------------------------------------------------------------------


UnkObject2_Main:	        ; DATA XREF: ROM:0020B62A?o
	move.l  objPlayerSlot+oX.w,d0
	addi.l  #$320000,d0
	move.l  d0,oX(a0)
	move.l  objPlayerSlot+oY.w,d0
	subi.l  #$320000,d0
	move.l  d0,oY(a0)
	lea     (AniSpr_StaticObj).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function UnkObject2_Main

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20B69E:	 ; CODE XREF: sub_20B8A2+2?p
		        ; sub_20B8E2+2?p ...
	lea     objPlayerSlot.w,a1
	move.w  $12(a1),d1
	bmi.w   loc_20B6AE
	bra.w   loc_20B706
; -------------------------------------------------------------------------

loc_20B6AE:	 ; CODE XREF: sub_20B69E+8?j
	moveq   #0,d1
	bclr    #3,oFlags(a0)
	rts
; -------------------------------------------------------------------------
	lea     objPlayerSlot.w,a1
	move.w  $12(a1),d1
	bpl.w   loc_20B6C8
	bra.w   loc_20B706
; -------------------------------------------------------------------------

loc_20B6C8:	 ; CODE XREF: sub_20B69E+22?j
	moveq   #0,d1
	bclr    #3,oFlags(a0)
	rts
; -------------------------------------------------------------------------
	lea     objPlayerSlot.w,a1
	move.w  $10(a1),d1
	bmi.w   loc_20B6E2
	bra.w   loc_20B706
; -------------------------------------------------------------------------

loc_20B6E2:	 ; CODE XREF: sub_20B69E+3C?j
	moveq   #0,d1
	bclr    #3,oFlags(a0)
	rts
; -------------------------------------------------------------------------
	lea     objPlayerSlot.w,a1
	move.w  $10(a1),d1
	bpl.w   loc_20B6FC
	bra.w   loc_20B706
; -------------------------------------------------------------------------

loc_20B6FC:	 ; CODE XREF: sub_20B69E+56?j
	moveq   #0,d1
	bclr    #3,oFlags(a0)
	rts
; -------------------------------------------------------------------------

loc_20B706:	 ; CODE XREF: sub_20B69E+C?j
		        ; sub_20B69E+26?j ...
	lea     (word_20B7D0).l,a2
	move.l  d0,d1
	andi.w  #$FF00,d0
	cmpi.w  #$100,d0
	bne.w   loc_20B720
	lea     (word_20B820).l,a2

loc_20B720:	 ; CODE XREF: sub_20B69E+78?j
	cmpi.w  #$200,d0
	bne.w   loc_20B72E
	lea     (word_20B824).l,a2

loc_20B72E:	 ; CODE XREF: sub_20B69E+86?j
	cmpi.w  #$300,d0
	bne.w   loc_20B73C
	lea     (word_20B828).l,a2

loc_20B73C:	 ; CODE XREF: sub_20B69E+94?j
	move.w  d1,d0
	andi.w  #$FF,d0
	asl.w   #2,d0
	lea     (a2,d0.w),a2
	lea     objPlayerSlot.w,a1
	move.w  oX(a0),d0
	move.w  8(a1),d1
	move.b  $17(a1),d3
	ext.w   d3
	move.b  0(a2),d2
	ext.w   d2
	move.w  d0,d4
	move.w  d1,d5
	add.w   d2,d4
	sub.w   d3,d5
	cmp.w   d4,d5
	bpl.w   loc_20B7C6
	move.b  1(a2),d2
	ext.w   d2
	neg.w   d2
	move.w  d0,d4
	move.w  d1,d5
	sub.w   d2,d4
	add.w   d3,d5
	cmp.w   d5,d4
	bpl.w   loc_20B7C6
	move.w  oY(a0),d0
	move.w  $C(a1),d1
	move.b  $16(a1),d3
	ext.w   d3
	move.b  2(a2),d2
	ext.w   d2
	move.w  d0,d4
	move.w  d1,d5
	add.w   d2,d4
	sub.w   d3,d5
	cmp.w   d4,d5
	bpl.w   loc_20B7C6
	move.b  3(a2),d2
	ext.w   d2
	neg.w   d2
	move.w  d0,d4
	move.w  d1,d5
	sub.w   d2,d4
	add.w   d3,d5
	cmp.w   d5,d4
	bpl.w   loc_20B7C6
	moveq   #$FFFFFFFF,d1
	bset    #3,oFlags(a0)
	rts
; -------------------------------------------------------------------------

loc_20B7C6:	 ; CODE XREF: sub_20B69E+CC?j
		        ; sub_20B69E+E2?j ...
	moveq   #0,d1
	bclr    #3,oFlags(a0)
	rts
; End of function sub_20B69E

; -------------------------------------------------------------------------
word_20B7D0:    dc.w $10F0  ; DATA XREF: sub_20B69E:loc_20B706?o
	dc.w $10F0
	dc.w $10F0
	dc.w $4FC
	dc.w $9F7
	dc.w $3810
	dc.w $E8
	dc.w $4FC
	dc.w $E8
	dc.w $C00
	dc.w $1800
	dc.w $4FC
	dc.w $1800
	dc.w $C00
	dc.w $20E0
	dc.w $20E0
	dc.w $10F0
	dc.w $1000
	dc.w $20E0
	dc.w $1000
	dc.w $8F8
	dc.w $10F0
	dc.w $8F8
	dc.w $18E8
	dc.w $10F0
	dc.w $801
	dc.w $10F0
	dc.w $F8
	dc.w $10F0
	dc.w $10F0
	dc.w $8F8
	dc.w $10C0
	dc.w $17E9
	dc.w $10F0
	dc.w $8F8
	dc.w $8F8
	dc.w $10F0
	dc.w $10F0
	dc.w $10F0
	dc.w $40C0
word_20B820:    dc.w $10F0  ; DATA XREF: sub_20B69E+7C?o
	dc.w $10F0
word_20B824:    dc.w $10F0  ; DATA XREF: sub_20B69E+8A?o
	dc.w $10F0
word_20B828:    dc.w $10F0  ; DATA XREF: sub_20B69E+98?o
	dc.w $10F0

; -------------------------------------------------------------------------


ObjSpringBoard:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20B840(pc,d0.w),d0
	jsr     off_20B840(pc,d0.w)
	jmp     CheckObjDespawnTime

; -------------------------------------------------------------------------
off_20B840:     
	dc.w sub_20B84E-off_20B840
	dc.w sub_20B8A2-off_20B840
	dc.w sub_20B8E2-off_20B840
	dc.w sub_20B9CE-off_20B840
	dc.w sub_20B922-off_20B840
	dc.w sub_20BA16-off_20B840
	dc.w sub_20B96A-off_20B840

; -------------------------------------------------------------------------


sub_20B84E:	 ; DATA XREF: ROM:off_20B840?o
	move.l  #MapSpr_SpringBoard,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #7,d0
	jsr     LevelObj_SetBaseTile(pc)
	move.b  #$18,oXRadius(a0)
	move.b  #4,oYRadius(a0)
	move.b  $28(a0),d0
	cmpi.b  #1,d0
	beq.w   loc_20B894
	move.b  #3,oAnim(a0)
	move.b  #2,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_20B894:	 ; CODE XREF: sub_20B84E+34?j
	move.b  #4,oAnim(a0)
	move.b  #4,oRoutine(a0)
	rts
; End of function sub_20B84E


; -------------------------------------------------------------------------


sub_20B8A2:	 ; DATA XREF: ROM:0020B842?o
	moveq   #5,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20B8D0
	lea     objPlayerSlot.w,a1
	move.l  oY(a0),d0
	moveq   #0,d1
	move.b  $16(a1),d1
	swap    d1
	sub.l   d1,d0
	move.l  d0,$C(a1)
	move.b  #$A,oRoutine(a0)
	move.b  #3,oAnim(a0)

loc_20B8D0:	 ; CODE XREF: sub_20B8A2+8?j
	lea     (AniSpr_SpringBoard).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20B8A2


; -------------------------------------------------------------------------


sub_20B8E2:	 ; DATA XREF: ROM:0020B844?o
	moveq   #3,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20B910
	lea     objPlayerSlot.w,a1
	move.l  oY(a0),d0
	moveq   #0,d1
	move.b  $16(a1),d1
	swap    d1
	sub.l   d1,d0
	move.l  d0,$C(a1)
	move.b  #$C,oRoutine(a0)
	move.b  #4,oAnim(a0)

loc_20B910:	 ; CODE XREF: sub_20B8E2+8?j
	lea     (AniSpr_SpringBoard).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20B8E2


; -------------------------------------------------------------------------


sub_20B922:	 ; DATA XREF: ROM:0020B848?o
	moveq   #3,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20B940
	lea     (AniSpr_SpringBoard).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------

loc_20B940:	 ; CODE XREF: sub_20B922+8?j
	lea     objPlayerSlot.w,a1
	bclr    #3,$22(a1)
	move.b  #4,oRoutine(a0)
	btst    #1,$22(a1)
	bne.w   loc_20B95C
	rts
; -------------------------------------------------------------------------

loc_20B95C:	 ; CODE XREF: sub_20B922+34?j
	move.w  #$64,$2A(a0) ; 'd'
	move.b  #$C,oRoutine(a0)
	rts
; End of function sub_20B922


; -------------------------------------------------------------------------


sub_20B96A:	 ; DATA XREF: ROM:0020B84C?o
	move.b  #2,oAnim(a0)
	moveq   #4,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20B9A0
	lea     objPlayerSlot.w,a1
	move.w  $12(a1),d0
	addi.w  #$100,d0
	cmpi.w  #$A00,d0
	bmi.w   loc_20B994
	move.w  #$A00,d0

loc_20B994:	 ; CODE XREF: sub_20B96A+22?j
	neg.w   d0
	move.w  d0,$12(a1)
	move.w  #SFXBoing,d0
	jsr     PlayFMSound
	move.w  #$64,$2A(a0) ; 'd'

loc_20B9A0:	 ; CODE XREF: sub_20B96A+E?j
	move.w  $2A(a0),d0
	subq.w  #1,d0
	move.w  d0,$2A(a0)
	bne.w   loc_20B9BC
	move.b  #4,oRoutine(a0)
	move.b  #4,oAnim(a0)
	rts
; -------------------------------------------------------------------------

loc_20B9BC:	 ; CODE XREF: sub_20B96A+40?j
	lea     (AniSpr_SpringBoard).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20B96A


; -------------------------------------------------------------------------


sub_20B9CE:	 ; DATA XREF: ROM:0020B846?o
	moveq   #5,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20B9EC
	lea     (AniSpr_SpringBoard).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------

loc_20B9EC:	 ; CODE XREF: sub_20B9CE+8?j
	lea     objPlayerSlot.w,a1
	bclr    #3,$22(a1)
	move.b  #2,oRoutine(a0)
	btst    #1,$22(a1)
	bne.w   loc_20BA08
	rts
; -------------------------------------------------------------------------

loc_20BA08:	 ; CODE XREF: sub_20B9CE+34?j
	move.w  #$64,$2A(a0) ; 'd'
	move.b  #$A,oRoutine(a0)
	rts
; End of function sub_20B9CE


; -------------------------------------------------------------------------


sub_20BA16:	 ; DATA XREF: ROM:0020B84A?o
	move.b  #1,oAnim(a0)
	moveq   #6,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20BA4C
	lea     objPlayerSlot.w,a1
	move.w  $12(a1),d0
	addi.w  #$100,d0
	cmpi.w  #$A00,d0
	bmi.w   loc_20BA40
	move.w  #$A00,d0

loc_20BA40:	 ; CODE XREF: sub_20BA16+22?j
	neg.w   d0
	move.w  d0,$12(a1)
	move.w  #SFXBoing,d0
	jsr     PlayFMSound
	move.w  #$64,$2A(a0) ; 'd'

loc_20BA4C:	 ; CODE XREF: sub_20BA16+E?j
	move.w  $2A(a0),d0
	subq.w  #1,d0
	move.w  d0,$2A(a0)
	bne.w   loc_20BA68
	move.b  #2,oRoutine(a0)
	move.b  #3,oAnim(a0)
	rts
; -------------------------------------------------------------------------

loc_20BA68:	 ; CODE XREF: sub_20BA16+40?j
	lea     (AniSpr_SpringBoard).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20BA16


; -------------------------------------------------------------------------

ObjUnusedFlipPlatform:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20BA8E(pc,d0.w),d0
	jsr     off_20BA8E(pc,d0.w)
	jmp     CheckObjDespawnTime

; -------------------------------------------------------------------------

off_20BA8E:     
    dc.w sub_20BA96-off_20BA8E
	dc.w sub_20BABC-off_20BA8E
	dc.w sub_20BAFE-off_20BA8E
	dc.w sub_20BBC2-off_20BA8E

; -------------------------------------------------------------------------

sub_20BA96:
	addq.b  #2,oRoutine(a0)
	move.l  #MapSpr_UnusedFlipPlatform,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #8,d0
	jsr     LevelObj_SetBaseTile(pc)
	rts

; -------------------------------------------------------------------------

sub_20BABC:
	tst.b   1(a0)
	bpl.w   loc_20BAF8
	moveq   #9,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20BAEC
	lea     objPlayerSlot.w,a1
	bclr    #1,$22(a1)
	bset    #3,$22(a1)
	move.b  #4,oRoutine(a0)
	move.w  #0,$2A(a0)

loc_20BAEC:
	lea     (AniSpr_UnusedFlipPlatform).l,a1
	jsr     AnimateObject

loc_20BAF8:
	jmp     DrawObject
; End of function sub_20BABC


; -------------------------------------------------------------------------


sub_20BAFE:	 ; DATA XREF: ROM:0020BA92?o
	tst.b   1(a0)
	bpl.s   loc_20BAF8
	moveq   #7,d0
	bsr.w   sub_20B69E
	tst.b   d1
	bne.w   loc_20BB26
	lea     objPlayerSlot.w,a1
	bclr    #3,$22(a1)
	move.b  #6,oRoutine(a0)
	move.w  #0,$2A(a0)

loc_20BB26:	 ; CODE XREF: sub_20BAFE+E?j
	lea     objPlayerSlot.w,a1
	move.w  oX(a0),d2
	move.w  8(a1),d3
	move.w  $10(a1),d4
	beq.w   loc_20BB56
	bmi.w   loc_20BB42
	bpl.w   loc_20BB4C

loc_20BB42:	 ; CODE XREF: sub_20BAFE+3C?j
	cmp.w   d2,d3
	bpl.w   loc_20BB64
	bra.w   loc_20BB56
; -------------------------------------------------------------------------

loc_20BB4C:	 ; CODE XREF: sub_20BAFE+40?j
	cmp.w   d2,d3
	bmi.w   loc_20BB64
	bra.w   loc_20BB56
; -------------------------------------------------------------------------

loc_20BB56:	 ; CODE XREF: sub_20BAFE+38?j
		        ; sub_20BAFE+4A?j
		        ; DATA XREF: ...
	move.l  $C(a1),d0
	addi.l  #$8000,d0
	move.l  d0,$C(a1)

loc_20BB64:	 ; CODE XREF: sub_20BAFE+46?j
		        ; sub_20BAFE+50?j
	moveq   #0,d0
	move.w  $2A(a0),d0
	addq.w  #1,d0
	move.w  d0,$2A(a0)
	lea     (loc_20BC9A).l,a3
	lea     (byte_20BC38).l,a2
	move.w  oX(a0),d2
	move.w  8(a1),d3
	cmp.w   d2,d3
	bmi.w   loc_20BB96
	lea     ((byte_20BC38+$16)).l,a2
	lea     (loc_20BC9A).l,a3

loc_20BB96:	 ; CODE XREF: sub_20BAFE+88?j
	divu.w  #2,d0
	move.b  (a2,d0.w),d1
	move.b  d1,oAnim(a0)
	cmpi.b  #6,d1
	bne.w   loc_20BBB0
	bclr    #3,$22(a1)

loc_20BBB0:	 ; CODE XREF: sub_20BAFE+A8?j
	lea     (AniSpr_UnusedFlipPlatform).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20BAFE


; -------------------------------------------------------------------------


sub_20BBC2:	 ; DATA XREF: ROM:0020BA94?o
	tst.b   1(a0)
	bne.w   loc_20BAF8
	moveq   #9,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20BBF2
	lea     objPlayerSlot.w,a1
	bclr    #1,$22(a1)
	bset    #3,$22(a1)
	move.b  #4,oRoutine(a0)
	move.w  #0,$2A(a0)

loc_20BBF2:	 ; CODE XREF: sub_20BBC2+10?j
	lea     (sub_20BC64).l,a2
	move.w  $2A(a0),d0
	addq.w  #1,d0
	move.w  d0,$2A(a0)
	move.b  (a2,d0.w),d1
	bmi.w   loc_20BC20
	move.b  d1,oAnim(a0)
	lea     (AniSpr_UnusedFlipPlatform).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------

loc_20BC20:	 ; CODE XREF: sub_20BBC2+44?j
	move.b  #2,oRoutine(a0)
	lea     (AniSpr_UnusedFlipPlatform).l,a1
	jsr     AnimateObject
	jmp     DrawObject

; -------------------------------------------------------------------------

byte_20BC38:    
	dc.b    1,   1,   2,   2,   3,   3,   4,   4
	dc.b    5,   6,   6,   6,   6,   6,   6,   6
	dc.b    6,   6,   6,   6,   6,   6,   7,   7
	dc.b    8,   8,   9,   9,  $A,  $A,  $B,   6
	dc.b    6,   6,   6,   6,   6,   6,   6,   6
	dc.b    6,   6,   6,   0

; -------------------------------------------------------------------------


sub_20BC64:
	dc.b	0, 5, 4, 3, 2, 1, 0
	dc.b    $D, 7, 8, 9, $A, $B, $A, 9, 8, 7
	dc.b    $D, 1, 2, 3, 4, 3, 2, 1 
	dc.b    $D, 7, 8, 9, $A, 9, 8, 7 
	dc.b    $D, 1, 2, 3, 2, 1 
	dc.b	$D, 7, 8, 7 
	dc.b	$D, 1, 2, 1 
	dc.b    $D, 7 
	dc.b    $D, 1 
	dc.b    $D, -1
	even

loc_20BC9A:
	move.w  oX(a0),d0
	andi.w  #$FF80,d0
	move.w  cameraX.w,d1
	subi.w  #$80,d1
	andi.w  #$FF80,d1
	sub.w   d1,d0
	cmpi.w  #$280,d0
	bcs.s   locret_20BCBC
	jmp     DeleteObject

; -------------------------------------------------------------------------

locret_20BCBC:
	rts

; -------------------------------------------------------------------------
; Unused, unreferenced bridge object
; Setting the subtype value here to a non-zero value causes it to collapse

ObjUnusedBridge:
	moveq   #0,d0           
	move.b  oRoutine(a0),d0
	move.w  off_20BCCC(pc,d0.w),d0
	jmp     off_20BCCC(pc,d0.w)
; -------------------------------------------------------------------------
off_20BCCC:     
    dc.w sub_20BCEE-off_20BCCC       
	dc.w sub_20BDE0-off_20BCCC
	dc.w sub_20BE84-off_20BCCC
	dc.w sub_20BEF2-off_20BCCC
	dc.w sub_20C166-off_20BCCC
	dc.w sub_20C1A6-off_20BCCC
	dc.w sub_20C118-off_20BCCC
	dc.w sub_20C2BC-off_20BCCC
	dc.w sub_20C360-off_20BCCC
	dc.w sub_20C3CA-off_20BCCC
	dc.w sub_20C292-off_20BCCC
	dc.w sub_20C22C-off_20BCCC
	dc.w sub_20C1B8-off_20BCCC
	dc.w sub_20C424-off_20BCCC
	dc.w locret_20C616-off_20BCCC
	dc.w sub_20C602-off_20BCCC
	dc.w sub_20C5EE-off_20BCCC

; -------------------------------------------------------------------------


sub_20BCEE:	 ; DATA XREF: ROM:off_20BCCC?o
	move.b  #$C,oRoutine(a0)
	move.l  #MapSpr_UnusedBridge,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #9,d0
	jsr     LevelObj_SetBaseTile(pc)
	move.b  #1,oAnim(a0)
	move.b  #0,$30(a0)
	move.b  #0,$31(a0)
	moveq   #0,d7

loc_20BD28:	 ; CODE XREF: sub_20BCEE+5E?j
	jsr     FindObjSlot
	bne.w   loc_20BDD0
	move.b  #$25,0(a1) ; '%'
	move.b  #2,$24(a1)
	move.w  a0,$3E(a1)
	move.b  d7,$3C(a1)
	addq.w  #1,d7
	cmpi.w  #8,d7
	bne.s   loc_20BD28
	jsr     FindObjSlot
	bne.w   loc_20BDD0
	move.b  #$25,0(a1) ; '%'
	move.b  #4,$24(a1)
	move.w  a0,$3E(a1)
	move.b  #$FF,$3C(a1)
	move.b  #2,$1C(a1)
	move.l  oX(a0),d0
	subi.l  #$100000,d0
	move.l  d0,8(a1)
	move.l  oY(a0),d0
	subi.l  #$100000,d0
	move.l  d0,$C(a1)
	bsr.w   FindObjSlot
	bne.w   loc_20BDD0
	move.b  #$25,0(a1) ; '%'
	move.b  #4,$24(a1)
	move.w  a0,$3E(a1)
	move.b  #$FE,$3C(a1)
	move.b  #2,$1C(a1)
	move.l  oX(a0),d0
	addi.l  #$800000,d0
	move.l  d0,8(a1)
	move.l  oY(a0),d0
	subi.l  #$100000,d0
	move.l  d0,$C(a1)

loc_20BDD0:	 ; CODE XREF: sub_20BCEE+40?j
		        ; sub_20BCEE+66?j ...
	tst.b   $28(a0)
	beq.w   locret_20BDDE
	move.b  #$1C,oRoutine(a0)

locret_20BDDE:	          ; CODE XREF: sub_20BCEE+E6?j
	rts
; End of function sub_20BCEE


; -------------------------------------------------------------------------


sub_20BDE0:	 ; DATA XREF: ROM:0020BCCE?o
	move.b  #6,oRoutine(a0)
	move.l  #MapSpr_UnusedBridge,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #9,d0
	jsr     LevelObj_SetBaseTile(pc)
	move.b  #1,oAnim(a0)
	movea.w oPlayerMoveLock(a0),a2
	tst.b   $28(a2)
	beq.w   loc_20BE1E
	move.b  #$1A,oRoutine(a0)

loc_20BE1E:	 ; CODE XREF: sub_20BDE0+34?j
	movea.w oPlayerMoveLock(a0),a1
	moveq   #0,d1
	move.b  $3C(a0),d1
	mulu.w  #$10,d1
	swap    d1
	move.l  8(a1),d0
	add.l   d1,d0
	move.l  d0,oX(a0)
	move.l  $C(a1),d0
	move.l  d0,oY(a0)
	swap    d0
	move.w  d0,$38(a0)
	move.w  d0,$34(a0)
	moveq   #0,d1
	move.b  $3C(a0),d1
	mulu.w  #8,d1
	sub.w   d1,d0
	addi.w  #$60,d0 ; '`'
	move.w  d0,$36(a0)
	movea.w oPlayerMoveLock(a0),a2
	moveq   #0,d1
	move.w  8(a2),d0
	move.w  oX(a0),d1
	move.w  #$58,d2 ; 'X'
	sub.w   d0,d1
	sub.w   d2,d1
	muls.w  d1,d1
	mulu.w  #$A,d1
	muls.w  d2,d2
	divu.w  d2,d1
	move.w  d1,$3A(a0)
	rts
; End of function sub_20BDE0


; -------------------------------------------------------------------------


sub_20BE84:	 ; DATA XREF: ROM:0020BCD0?o
	move.b  #8,oRoutine(a0)
	move.l  #MapSpr_UnusedBridge,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #9,d0
	jsr     LevelObj_SetBaseTile(pc)
	movea.w oPlayerMoveLock(a0),a2
	tst.b   $28(a2)
	beq.w   loc_20BEDA
	move.b  #$1E,oRoutine(a0)
	move.b  $3C(a0),d0
	cmpi.b  #$FE,d0
	beq.w   loc_20BEDA
	move.w  oY(a0),d1
	addi.w  #$70,d1 ; 'p'
	move.w  d1,oY(a0)
	ori.w   #$800,2(a0)

loc_20BEDA:	 ; CODE XREF: sub_20BE84+2E?j
		        ; sub_20BE84+40?j
	move.w  oY(a0),d0
	move.w  d0,$38(a0)
	move.w  d0,$34(a0)
	moveq   #0,d1
	addi.w  #$60,d0 ; '`'
	move.w  d0,$36(a0)
	rts
; End of function sub_20BE84


; -------------------------------------------------------------------------


sub_20BEF2:	 ; DATA XREF: ROM:0020BCD2?o
	movea.w oPlayerMoveLock(a0),a2
	move.b  $24(a2),d0
	cmpi.b  #$18,d0
	bne.w   loc_20BF08
	move.b  #$E,oRoutine(a0)

loc_20BF08:	 ; CODE XREF: sub_20BEF2+C?j
	moveq   #$13,d0
	bsr.w   loc_20B706
	tst.b   d1
	beq.w   loc_20BF5C
	moveq   #$B,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20BF5C
	movea.w oPlayerMoveLock(a0),a2
	move.b  $3C(a0),d0
	addq.w  #1,d0
	move.b  d0,$31(a2)
	lea     objPlayerSlot.w,a1
	bset    #3,$22(a1)
	bset    #3,oFlags(a0)
	bclr    #1,$22(a1)
	move.l  oY(a0),d0
	subi.l  #$80000,d0
	moveq   #0,d1
	move.b  $16(a1),d1
	swap    d1
	sub.l   d1,d0
	move.l  d0,$C(a1)

loc_20BF5C:	 ; CODE XREF: sub_20BEF2+1E?j
		        ; sub_20BEF2+2A?j
	bsr.w   sub_20C05C
	bsr.w   sub_20BFE8
	lea     (AniSpr_UnusedBridge).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20BEF2

; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------
	moveq   #0,d2
	movea.w oPlayerMoveLock(a0),a2
	move.b  $3D(a2),d2
	lea     (byte_20BFA8).l,a3
	andi.w  #$3F,d2 ; '?'
	move.b  (a3,d2.w),d2
	move.w  $38(a0),d0
	move.w  $3A(a0),d1
	muls.w  d2,d1
	divs.w  #$A,d1
	sub.w   d2,d1
	sub.w   d1,d0
	move.w  d0,oY(a0)
	rts
; -------------------------------------------------------------------------
byte_20BFA8:    dc.b  0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 7, 7, 6, 6, 5, 5
		        ; DATA XREF: ROM:0020BF82?o
	dc.b  4, 4, 3, 3, 2, 2, 1, 1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,$A,$B,$C,$D,$E,$F
	dc.b $10,$F,$E,$D,$C,$B,$A, 9, 8, 7, 6, 5, 4, 3, 2, 1

; -------------------------------------------------------------------------


sub_20BFE8:	 ; CODE XREF: sub_20BEF2+6E?p
		        ; sub_20C360+52?p
	lea     objPlayerSlot.w,a1
	lea     (byte_20C068).l,a3
	movea.w oPlayerMoveLock(a0),a2
	move.w  8(a2),d0
	subi.w  #$10,d0
	move.w  8(a1),d1
	sub.w   d0,d1
	move.b  $30(a2),d0
	bne.w   loc_20C02E
	bra.w   loc_20C052
; -------------------------------------------------------------------------
	move.w  8(a2),d0
	subi.w  #$10,d0
	move.w  8(a1),d1
	sub.w   d0,d1
	bpl.w   loc_20C024
	moveq   #0,d1

loc_20C024:	 ; CODE XREF: sub_20BFE8+36?j
	cmpi.w  #$C0,d1
	bmi.w   loc_20C02E
	moveq   #0,d1

loc_20C02E:	 ; CODE XREF: sub_20BFE8+20?j
		        ; sub_20BFE8+40?j
	asr.w   #3,d1
	mulu.w  #8,d1
	lea     (a3,d1.w),a3
	moveq   #0,d0
	move.b  $3C(a0),d0
	moveq   #0,d2
	move.b  (a3,d0.w),d2
	asr.b   #1,d2
	move.w  $38(a0),d3
	add.w   d2,d3
	move.w  d3,oY(a0)
	rts
; -------------------------------------------------------------------------

loc_20C052:	 ; CODE XREF: sub_20BFE8+24?j
	move.w  $38(a0),d3
	move.w  d3,oY(a0)
	rts
; End of function sub_20BFE8


; -------------------------------------------------------------------------


sub_20C05C:
	btst    #0,unkBridgeStat.w
	beq.w   *+4

locret_20C066:
	rts

; -------------------------------------------------------------------------
byte_20C068:    dc.b  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		        ; DATA XREF: sub_20BFE8+4?o
	dc.b  2, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 2, 4, 2, 0, 0, 0, 0, 0
	dc.b  2, 4, 4, 2, 0, 0, 0, 0, 2, 4, 6, 4, 2, 0, 0, 0, 2, 4, 6, 6, 4, 2, 0, 0
	dc.b  2, 4, 6, 8, 6, 4, 2, 0, 2, 4, 6, 8, 8, 6, 4, 2, 2, 4, 6, 8, 8, 6, 4, 2
	dc.b  0, 2, 4, 6, 8, 6, 4, 2, 0, 0, 2, 4, 6, 6, 4, 2, 0, 0, 0, 2, 4, 6, 4, 2
	dc.b  0, 0, 0, 0, 2, 4, 4, 2, 0, 0, 0, 0, 0, 2, 4, 2, 0, 0, 0, 0, 0, 0, 2, 2
	dc.b  0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b  0, 0, 0, 0, 0, 0, 0, 0

; -------------------------------------------------------------------------


sub_20C118:	 ; DATA XREF: ROM:0020BCD8?o
	move.b  $31(a0),$30(a0)
	move.b  #0,$31(a0)
	btst    #0,unkBridgeStat.w
	beq.w   loc_20C134
	move.b  #$18,oRoutine(a0)

loc_20C134:	 ; CODE XREF: sub_20C118+12?j
	move.b  oPlayerStandObj(a0),d0
	addq.w  #1,d0
	move.b  d0,oPlayerStandObj(a0)
	lea     objPlayerSlot.w,a1
	move.w  oX(a0),d0
	move.w  8(a1),d1
	move.w  d0,d2
	addi.w  #$80,d2
	subi.w  #$10,d0
	cmp.w   d0,d1
	bmi.w   locret_20C164
	cmp.w   d2,d1
	bpl.w   locret_20C164
	bra.w   *+4
; -------------------------------------------------------------------------

locret_20C164:	          ; CODE XREF: sub_20C118+3E?j
		        ; sub_20C118+44?j ...
	rts
; End of function sub_20C118


; -------------------------------------------------------------------------


sub_20C166:	 ; DATA XREF: ROM:0020BCD4?o
	movea.w oPlayerMoveLock(a0),a2
	move.b  $24(a2),d0
	cmpi.b  #$18,d0
	bne.w   loc_20C17C
	move.b  #$16,oRoutine(a0)

loc_20C17C:	 ; CODE XREF: sub_20C166+C?j
	moveq   #$F,d0
	bsr.w   loc_20B706
	tst.b   d1
	beq.w   loc_20C192
	lea     objPlayerSlot.w,a1
	bclr    #3,$22(a1)

loc_20C192:	 ; CODE XREF: sub_20C166+1E?j
	lea     (AniSpr_UnusedBridge).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20C166

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20C1A6:	 ; DATA XREF: ROM:0020BCD6?o
	lea     (AniSpr_StaticObj).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20C1A6


; -------------------------------------------------------------------------


sub_20C1B8:	 ; DATA XREF: ROM:0020BCE4?o
	move.w  $32(a0),d0
	addq.w  #1,d0
	move.w  d0,$32(a0)
	cmpi.w  #$64,d0 ; 'd'
	bne.w   loc_20C1D2
	nop
	move.b  #$12,oRoutine(a0)

loc_20C1D2:	 ; CODE XREF: sub_20C1B8+E?j
	move.b  oPlayerStandObj(a0),d0
	addq.w  #1,d0
	move.b  d0,oPlayerStandObj(a0)
	lea     objPlayerSlot.w,a1
	move.w  oX(a0),d0
	move.w  8(a1),d1
	move.w  d0,d2
	addi.w  #$C0,d2
	subi.w  #$10,d0
	cmp.w   d0,d1
	bmi.w   loc_20C214
	cmp.w   d2,d1
	bpl.w   loc_20C214
	bset    #3,$22(a1)
	bset    #3,oFlags(a0)
	move.b  #0,$26(a1)
	bra.w   locret_20C22A
; -------------------------------------------------------------------------

loc_20C214:	 ; CODE XREF: sub_20C1B8+3C?j
		        ; sub_20C1B8+42?j
	btst    #3,oFlags(a0)
	beq.w   locret_20C164
	bclr    #3,$22(a1)
	bclr    #3,oFlags(a0)

locret_20C22A:	          ; CODE XREF: sub_20C1B8+58?j
	rts
; End of function sub_20C1B8


; -------------------------------------------------------------------------


sub_20C22C:	 ; DATA XREF: ROM:0020BCE2?o
	movea.w oPlayerMoveLock(a0),a2
	move.b  $24(a2),d0
	cmpi.b  #$18,d0
	beq.w   loc_20C242
	move.b  #$14,oRoutine(a0)

loc_20C242:	 ; CODE XREF: sub_20C22C+C?j
	move.b  $3C(a0),d0
	cmpi.b  #$FE,d0
	beq.w   loc_20C268
	move.w  $32(a2),d0
	move.w  #$64,d1 ; 'd'
	move.w  #$60,d2 ; '`'
	mulu.w  d2,d0
	divu.w  d1,d0
	move.w  $34(a0),d1
	add.w   d1,d0
	move.w  d0,oY(a0)

loc_20C268:	 ; CODE XREF: sub_20C22C+1E?j
	moveq   #$F,d0
	bsr.w   loc_20B706
	tst.b   d1
	beq.w   loc_20C27E
	lea     objPlayerSlot.w,a1
	bclr    #3,$22(a1)

loc_20C27E:	 ; CODE XREF: sub_20C22C+44?j
	lea     (AniSpr_UnusedBridge).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20C22C

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20C292:	 ; DATA XREF: ROM:0020BCE0?o
	moveq   #$F,d0
	bsr.w   loc_20B706
	tst.b   d1
	beq.w   loc_20C2A8
	lea     objPlayerSlot.w,a1
	bclr    #3,$22(a1)

loc_20C2A8:	 ; CODE XREF: sub_20C292+8?j
	lea     (AniSpr_UnusedBridge).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20C292

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20C2BC:	 ; DATA XREF: ROM:0020BCDA?o
	movea.w oPlayerMoveLock(a0),a2
	move.b  $24(a2),d0
	cmpi.b  #$18,d0
	beq.w   loc_20C2DC
	move.b  #$10,oRoutine(a0)
	move.w  $36(a0),$38(a0)
	bra.w   loc_20C348
; -------------------------------------------------------------------------

loc_20C2DC:	 ; CODE XREF: sub_20C2BC+C?j
	move.w  $36(a0),d2
	move.w  $34(a0),d3
	sub.w   d3,d2
	move.w  $32(a2),d0
	move.w  #$64,d1 ; 'd'
	mulu.w  d2,d0
	divu.w  d1,d0
	move.w  $34(a0),d1
	add.w   d1,d0
	move.w  d0,oY(a0)
	move.w  $32(a2),d1
	add.b   $3C(a0),d1
	andi.w  #1,d1
	add.w   d1,d0
	move.w  d0,oY(a0)
	moveq   #$B,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20C348
	lea     objPlayerSlot.w,a1
	bset    #3,$22(a1)
	bset    #3,oFlags(a0)
	bclr    #1,$22(a1)
	move.l  oY(a0),d0
	subi.l  #$80000,d0
	moveq   #0,d1
	move.b  $16(a1),d1
	swap    d1
	sub.l   d1,d0
	move.l  d0,$C(a1)

loc_20C348:	 ; CODE XREF: sub_20C2BC+1C?j
		        ; sub_20C2BC+5A?j
	bsr.w   sub_20C05C
	lea     (AniSpr_UnusedBridge).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20C2BC

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20C360:	 ; DATA XREF: ROM:0020BCDC?o
	btst    #1,unkBridgeStat.w
	beq.w   loc_20C374
	move.b  $3C(a0),d0
	move.b  #$1A,oRoutine(a0)

loc_20C374:	 ; CODE XREF: sub_20C360+6?j
	moveq   #$B,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20C3AE
	lea     objPlayerSlot.w,a1
	bset    #3,$22(a1)
	bset    #3,oFlags(a0)
	bclr    #1,$22(a1)
	move.l  oY(a0),d0
	subi.l  #$80000,d0
	moveq   #0,d1
	move.b  $16(a1),d1
	swap    d1
	sub.l   d1,d0
	move.l  d0,$C(a1)

loc_20C3AE:	 ; CODE XREF: sub_20C360+1C?j
	bsr.w   sub_20C05C
	bsr.w   sub_20BFE8
	lea     (AniSpr_UnusedBridge).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20C360

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20C3CA:	 ; DATA XREF: ROM:0020BCDE?o
	move.b  oPlayerStandObj(a0),d0
	addq.w  #1,d0
	move.b  d0,oPlayerStandObj(a0)
	lea     objPlayerSlot.w,a1
	move.w  oX(a0),d0
	move.w  8(a1),d1
	move.w  d0,d2
	addi.w  #$C0,d2
	subi.w  #$10,d0
	cmp.w   d0,d1
	bmi.w   locret_20C164
	cmp.w   d2,d1
	bpl.w   loc_20C40C
	bset    #3,$22(a1)
	bset    #3,oFlags(a0)
	move.b  #0,$26(a1)
	bra.w   locret_20C422
; -------------------------------------------------------------------------

loc_20C40C:	 ; CODE XREF: sub_20C3CA+28?j
	btst    #3,oFlags(a0)
	beq.w   locret_20C164
	bclr    #3,$22(a1)
	bclr    #3,oFlags(a0)

locret_20C422:	          ; CODE XREF: sub_20C3CA+3E?j
	rts
; End of function sub_20C3CA


; -------------------------------------------------------------------------


sub_20C424:	 ; DATA XREF: ROM:0020BCE6?o
	bsr.w   sub_20C476
	moveq   #$B,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20C462
	lea     objPlayerSlot.w,a1
	bset    #3,$22(a1)
	bset    #3,oFlags(a0)
	bclr    #1,$22(a1)
	move.l  oY(a0),d0
	subi.l  #$80000,d0
	moveq   #0,d1
	move.b  $16(a1),d1
	swap    d1
	sub.l   d1,d0
	move.l  d0,$C(a1)

loc_20C462:	 ; CODE XREF: sub_20C424+C?j
	lea     (AniSpr_UnusedBridge).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20C424

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20C476:	 ; CODE XREF: sub_20C424?p

;  AT 0020C516 SIZE 00000064 BYTES
;  AT 0020C59C SIZE 00000052 BYTES

	move.b  $3C(a0),d0
	cmpi.b  #7,d0
	bpl.w   loc_20C516
	cmpi.b  #5,d0
	bpl.w   loc_20C59C
	bra.w   loc_20C492
; -------------------------------------------------------------------------
	dc.b  $12, $34, $56, $78 ; unused, unknown, unreferenced
		        ; dunno what'd be either
; -------------------------------------------------------------------------

loc_20C492:	 ; CODE XREF: sub_20C476+14?j
	movea.w oPlayerMoveLock(a0),a2
	lea     (UnusedBridge_Data1).l,a3
	move.w  $32(a0),d0
	moveq   #0,d1
	move.b  $3C(a0),d1
	move.w  #$E,d2
	asl.w   #1,d1
	lsr.w   #1,d0
	mulu.w  d0,d2
	add.w   d1,d2
	moveq   #0,d6
	moveq   #0,d3
	move.b  (a3,d2.w),d6
	move.b  1(a3,d2.w),d3
	ext.w   d3
	move.w  8(a2),d4
	move.w  $C(a2),d5
	add.w   d6,d4
	add.w   d3,d5
	addi.w  #$60,d5 ; '`'
	move.w  d4,oX(a0)
	move.w  d5,oY(a0)
	move.w  $32(a0),d0
	addq.w  #1,d0
	move.w  d0,$32(a0)
	cmpi.w  #$26,d0 ; '&'
	bne.w   locret_20C4F4
	move.b  #$20,oRoutine(a0) ; ' '
	bsr.w   sub_20C4F6

locret_20C4F4:	          ; CODE XREF: sub_20C476+70?j
	rts
; End of function sub_20C476


; -------------------------------------------------------------------------


sub_20C4F6:	 ; CODE XREF: sub_20C476+7A?p
	move.b  $3C(a0),d0
	move.w  $C(a2),d1
	move.w  8(a2),d2
	mulu.w  #$10,d0
	add.w   d0,d1
	addi.w  #$60,d1 ; '`'
	move.w  d1,oY(a0)
	move.w  d2,oX(a0)
	rts
; End of function sub_20C4F6

; -------------------------------------------------------------------------
; START OF  FOR sub_20C476

loc_20C516:	 ; CODE XREF: sub_20C476+8?j
	movea.w oPlayerMoveLock(a0),a2
	lea     (UnusedBridge_Data2).l,a3
	move.w  $32(a0),d0
	moveq   #0,d1
	move.b  $3C(a0),d1
	move.w  #$E,d2
	subq.b  #6,d1
	asl.w   #1,d1
	lsr.w   #1,d0
	mulu.w  d0,d2
	add.w   d1,d2
	moveq   #0,d6
	moveq   #0,d3
	move.b  (a3,d2.w),d6
	move.b  1(a3,d2.w),d3
	move.w  8(a2),d4
	move.w  $C(a2),d5
	sub.w   d6,d4
	add.w   d3,d5
	addi.w  #$B0,d4
	move.w  d4,oX(a0)
	move.w  d5,oY(a0)
	move.w  $32(a0),d0
	addq.w  #1,d0
	move.w  d0,$32(a0)
	cmpi.w  #$26,d0 ; '&'
	bne.w   locret_20C578
	move.b  #$20,oRoutine(a0) ; ' '
	bsr.w   sub_20C57A

locret_20C578:	          ; CODE XREF: sub_20C476+F4?j
	rts
; END OF  FOR sub_20C476

; -------------------------------------------------------------------------


sub_20C57A:	 ; CODE XREF: sub_20C476+FE?p
		        ; sub_20C476+174?p
	move.b  $3C(a0),d0
	move.w  $C(a2),d1
	move.w  8(a2),d2
	subq.w  #6,d0
	mulu.w  #$10,d0
	add.w   d0,d1
	addi.w  #$B0,d2
	move.w  d1,oY(a0)
	move.w  d2,oX(a0)
	rts
; End of function sub_20C57A

; -------------------------------------------------------------------------
; START OF  FOR sub_20C476

loc_20C59C:	 ; CODE XREF: sub_20C476+10?j
	movea.w oPlayerMoveLock(a0),a2
	move.w  $32(a0),d0
	mulu.w  #$C,d0
	move.w  $C(a2),d1
	add.w   d0,d1
	addi.w  #$28,d1 ; '('
	move.w  d1,oY(a0)
	move.w  $32(a0),d0
	move.w  oX(a0),d1
	move.b  $3C(a0),d2
	cmpi.b  #6,d2
	beq.w   loc_20C5CC
	neg.w   d0

loc_20C5CC:	 ; CODE XREF: sub_20C476+150?j
	add.w   d0,d1
	move.w  d1,oX(a0)
	move.w  $32(a0),d0
	addq.w  #1,d0
	move.w  d0,$32(a0)
	cmpi.w  #$26,d0 ; '&'
	bne.w   locret_20C5EC
	move.b  #$20,oRoutine(a0) ; ' '
	bsr.s   sub_20C57A

locret_20C5EC:	          ; CODE XREF: sub_20C476+16A?j
	rts
; END OF  FOR sub_20C476

; -------------------------------------------------------------------------


sub_20C5EE:	 ; DATA XREF: ROM:0020BCEC?o
	lea     (AniSpr_UnusedBridge).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20C5EE

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20C602:	 ; DATA XREF: ROM:0020BCEA?o
	lea     (AniSpr_UnusedBridge).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20C602

; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

locret_20C616:	          ; DATA XREF: ROM:0020BCE8?o
	rts
; -------------------------------------------------------------------------
UnusedBridge_Data1:
	dc.b    0,   0,  $F, $F8, $1F, $F0, $2F, $E8
	dc.b  $3F, $E0, $4F, $D8, $5F, $D0,   0,   0
	dc.b  $11, $FC, $23, $F8, $34, $F5, $46, $F1
	dc.b  $57, $EE, $69, $EA,   0,   0, $11,   0
	dc.b  $23, $FF, $35, $FE, $47, $FD, $59, $FC
	dc.b  $6B, $FB,   0,   0, $11,   5, $22,  $A
	dc.b  $33,  $F, $44, $14, $55, $19, $66, $1E
	dc.b    0,   0,  $F,   8, $1F, $11, $2E, $1A
	dc.b  $3E, $22, $4E, $2B, $5D, $34,   0,   0
	dc.b   $D,  $B, $1B, $16, $29, $22, $37, $2D
	dc.b  $44, $39, $52, $44,   0,   0,  $B,  $D
	dc.b  $17, $1A, $23, $28, $2F, $35, $3B, $43
	dc.b  $46, $50,   0,   0,   9,  $E, $13, $1D
	dc.b  $1D, $2C, $27, $3B, $31, $4A, $3B, $59
	dc.b    0,   0,   8,  $F, $10, $1F, $18, $2F
	dc.b  $21, $3F, $29, $4F, $31, $5F,   0,   0
	dc.b    6, $10,  $D, $21, $14, $31, $1B, $42
	dc.b  $21, $52, $28, $63,   0,   0,   5, $11
	dc.b   $B, $22, $10, $33, $16, $44, $1B, $55
	dc.b  $21, $66,   0,   0,   4, $11,   8, $22
	dc.b   $D, $33, $11, $45, $16, $56, $1A, $67
	dc.b    0,   0,   3, $11,   7, $23,  $A, $34
	dc.b   $E, $46, $12, $57, $15, $69,   0,   0
	dc.b    2, $11,   5, $23,   8, $34,  $B, $46
	dc.b   $E, $58, $11, $69,   0,   0,   2, $11
	dc.b    4, $23,   6, $35,   8, $46,  $B, $58
	dc.b   $D, $6A,   0,   0,   1, $11,   3, $23
	dc.b    5, $35,   6, $47,   8, $59,  $A, $6A
	dc.b    0,   0,   1, $11,   2, $23,   3, $35
	dc.b    5, $47,   6, $59,   7, $6B,   0,   0
	dc.b    0, $11,   1, $23,   2, $35,   3, $47
	dc.b    4, $59,   5, $6B,   0,   0,   0, $11
	dc.b    1, $23,   1, $35,   2, $47,   3, $59
	dc.b    3, $6B
UnusedBridge_Data2:
	dc.b    0,   0,  $F,   7, $1F,  $F, $2F, $17
	dc.b  $3F, $1F, $4F, $27, $5F, $2F,   0,   0
	dc.b   $E,   9, $1D, $13, $2C, $1D, $3B, $27
	dc.b  $4A, $31, $59, $3B,   0,   0,  $D,  $B
	dc.b  $1B, $17, $28, $22, $36, $2E, $44, $3A
	dc.b  $51, $45,   0,   0,  $C,  $D, $18, $1A
	dc.b  $24, $27, $30, $34, $3C, $41, $49, $4E
	dc.b    0,   0,  $A,  $E, $15, $1C, $20, $2B
	dc.b  $2A, $39, $35, $47, $40, $56,   0,   0
	dc.b    9,  $F, $12, $1E, $1B, $2E, $24, $3D
	dc.b  $2D, $4C, $37, $5C,   0,   0,   7, $10
	dc.b   $F, $20, $17, $30, $1F, $40, $26, $50
	dc.b  $2E, $60,   0,   0,   6, $10,  $C, $21
	dc.b  $13, $31, $19, $42, $20, $53, $26, $63
	dc.b    0,   0,   5, $11,  $A, $22, $10, $33
	dc.b  $15, $44, $1A, $55, $20, $66,   0,   0
	dc.b    4, $11,   8, $22,  $D, $34, $11, $45
	dc.b  $15, $56, $1A, $68,   0,   0,   3, $11
	dc.b    6, $23,  $A, $34,  $D, $46, $11, $57
	dc.b  $14, $69,   0,   0,   2, $11,   5, $23
	dc.b    8, $35,  $B, $46,  $D, $58, $10, $6A
	dc.b    0,   0,   2, $11,   4, $23,   6, $35
	dc.b    8, $47,  $A, $58,  $C, $6A,   0,   0
	dc.b    1, $11,   3, $23,   4, $35,   6, $47
	dc.b    8, $59,   9, $6A,   0,   0,   1, $11
	dc.b    2, $23,   3, $35,   4, $47,   6, $59
	dc.b    7, $6B,   0,   0,   0, $11,   1, $23
	dc.b    2, $35,   3, $47,   4, $59,   5, $6B
	dc.b    0,   0,   0, $11,   1, $23,   1, $35
	dc.b    2, $47,   3, $59,   3, $6B,   0,   0
	dc.b    0, $11,   0, $23,   1, $35,   1, $47
	dc.b    1, $59,   2, $6B,   0,   0,   0, $11
	dc.b    0, $23,   0, $35,   0, $47,   1, $59
	dc.b    1, $6B

; -------------------------------------------------------------------------

ObjSpikes:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20C83A(pc,d0.w),d0
	jmp     off_20C83A(pc,d0.w)

; -------------------------------------------------------------------------

off_20C83A:     
	dc.w sub_20C83E-off_20C83A
	dc.w sub_20C8A4-off_20C83A

; -------------------------------------------------------------------------


sub_20C83E:
	addq.b  #2,oRoutine(a0)
	move.l  #MapSpr_Spikes,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	moveq   #$A,d0
	jsr     LevelObj_SetBaseTile(pc)
	move.b  $28(a0),d0
	andi.b  #7,d0
	move.b  d0,oAnim(a0)
	move.b  #$86,$20(a0)
	move.b  #$10,$19(a0)
	move.b  #$C,oYRadius(a0)
	cmpi.b  #3,d0
	bne.w   loc_20C88E
	move.b  #2,$19(a0)
	move.b  #$C,oYRadius(a0)

loc_20C88E:
	cmpi.b  #4,d0
	bmi.w   locret_20C8A2
	move.b  #$10,$19(a0)
	move.b  #3,oYRadius(a0)

locret_20C8A2:
	rts

; -------------------------------------------------------------------------

sub_20C8A4:
	lea     objPlayerSlot.w,a1
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	jsr     SolidObject
	lea     (AniSpr_StaticObj).l,a1
	jsr     AnimateObject
	jsr     DrawObject
	jmp     CheckObjDespawnTime

; -------------------------------------------------------------------------

ObjUnusedMovingPForm:
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  ObjUnusedMovingPForm_Index(pc,d0.w),d0
	jmp     ObjUnusedMovingPForm_Index(pc,d0.w)

; -------------------------------------------------------------------------

ObjUnusedMovingPForm_Index:
	dc.w ObjUnusedMovingPForm_Init-ObjUnusedMovingPForm_Index
	dc.w sub_20C9C6-ObjUnusedMovingPForm_Index
	dc.w sub_20CBB2-ObjUnusedMovingPForm_Index
	dc.w sub_20CC1C-ObjUnusedMovingPForm_Index

; -------------------------------------------------------------------------

ObjUnusedMovingPForm_Init:
	addq.b  #2,oRoutine(a0)
	move.l  #MapSpr_UnusedMovingPForm,4(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #$10,$19(a0)
	moveq   #$11,d0
	jsr     LevelObj_SetBaseTile
	move.b  oPlayerStandObj(a0),d0
	bne.s   loc_20C948
	move.b  $28(a0),d6
	andi.w  #$F,d6
	jsr     sub_20C956(pc)
	move.b  $3D(a1),d0
	ori.b   #$80,d0
	move.b  d0,$3D(a1)
	movea.w a2,a4
	subq.w  #1,d6

loc_20C92C:
	jsr     sub_20C956(pc)
	subq.w  #1,d6
	bne.s   loc_20C92C
	move.b  $28(a0),d0
	andi.b  #$70,d0 ; 'p'
	cmpi.b  #$70,d0
	bne.s   locret_20C946
	jsr     sub_20C980(pc)

locret_20C946:
	rts
; -------------------------------------------------------------------------

loc_20C948:	 ; CODE XREF: ROM:0020C90E?j
	move.b  oPlayerStandObj(a0),d0
	bpl.s   locret_20C954
	move.b  #4,oRoutine(a0)

locret_20C954:	          ; CODE XREF: ROM:0020C94C?j
	rts

; -------------------------------------------------------------------------


sub_20C956:	 ; CODE XREF: ROM:0020C918?p
		        ; ROM:loc_20C92C?p
	jsr     FindObjSlot
	bne.s   locret_20C97E
	move.b  $28(a0),$28(a1)
	move.b  #$29,0(a1) ; ')'
	move.w  a0,$3E(a1)
	move.w  oX(a0),8(a1)
	move.w  oY(a0),$C(a1)
	move.b  d6,$3D(a1)

locret_20C97E:	          ; CODE XREF: sub_20C956+6?j
		        ; sub_20C980+6?j
	rts
; End of function sub_20C956


; -------------------------------------------------------------------------


sub_20C980:	 ; CODE XREF: ROM:0020C942?p
	jsr     FindObjSlot
	bne.s   locret_20C97E
	move.b  #$13,0(a1)
	move.w  oX(a0),8(a1)
	move.w  oY(a0),$C(a1)
	move.w  a4,$3E(a1)
	move.b  #1,$3D(a1)
	rts
; End of function sub_20C980

; -------------------------------------------------------------------------
byte_20C9A6:    dc.b  1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
		        ; DATA XREF: sub_20C9C6+6?o
	dc.b  2, 2, 2, 2, 2, 2, 2, 2

; -------------------------------------------------------------------------


sub_20C9C6:	 ; DATA XREF: ROM:0020C8DE?o
	moveq   #0,d0
	move.b  oPlayerStandObj(a0),d0
	lea     (byte_20C9A6).l,a3
	move.b  (a3,d0.w),d2
	move.b  d2,oAnim(a0)
	tst.b   d0
	beq.s   loc_20C9F4
	jsr     sub_20CB5A(pc)
	lea     (AniSpr_UnusedMovingPForm).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------

loc_20C9F4:	 ; CODE XREF: sub_20C9C6+16?j
	moveq   #0,d0
	move.b  $28(a0),d0
	andi.w  #$F0,d0
	asr.w   #2,d0
	lea     (off_20CA20).l,a3
	movea.l (a3,d0.w),a4
	jsr     (a4)
	lea     (AniSpr_UnusedMovingPForm).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20C9C6

; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------
off_20CA20:     dc.l sub_20CA40         ; DATA XREF: sub_20C9C6+3A?o
	dc.l sub_20CA4C
	dc.l sub_20CA58
	dc.l sub_20CA88
	dc.l sub_20CAB8
	dc.l sub_20CAEE
	dc.l sub_20CB24
	dc.l sub_20CA4C

; -------------------------------------------------------------------------


sub_20CA40:	 ; DATA XREF: ROM:off_20CA20?o
	move.b  $3C(a0),d0
	addq.w  #1,d0
	move.b  d0,$3C(a0)
	rts
; End of function sub_20CA40


; -------------------------------------------------------------------------


sub_20CA4C:	 ; DATA XREF: ROM:0020CA24?o
		        ; ROM:0020CA3C?o
	move.b  $3C(a0),d0
	subq.w  #1,d0
	move.b  d0,$3C(a0)
	rts
; End of function sub_20CA4C


; -------------------------------------------------------------------------


sub_20CA58:	 ; DATA XREF: ROM:0020CA28?o
	move.w  $32(a0),d0
	addq.w  #1,d0
	andi.w  #$FF,d0
	move.w  d0,$32(a0)
	cmpi.w  #$80,d0
	bpl.w   loc_20CA72
	bmi.w   loc_20CA7C

loc_20CA72:	 ; CODE XREF: sub_20CA58+12?j
	addi.w  #$40,d0 ; '.'
	move.b  d0,$3C(a0)
	rts
; -------------------------------------------------------------------------

loc_20CA7C:	 ; CODE XREF: sub_20CA58+16?j
	not.w   d0
	addi.w  #$40,d0 ; '.'
	move.b  d0,$3C(a0)
	rts
; End of function sub_20CA58


; -------------------------------------------------------------------------


sub_20CA88:	 ; DATA XREF: ROM:0020CA2C?o
	move.w  $32(a0),d0
	addq.w  #1,d0
	andi.w  #$FF,d0
	move.w  d0,$32(a0)
	cmpi.w  #$80,d0
	bpl.w   loc_20CAA2
	bmi.w   loc_20CAAC

loc_20CAA2:	 ; CODE XREF: sub_20CA88+12?j
	addi.w  #$C0,d0
	move.b  d0,$3C(a0)
	rts
; -------------------------------------------------------------------------

loc_20CAAC:	 ; CODE XREF: sub_20CA88+16?j
	not.w   d0
	addi.w  #$C0,d0
	move.b  d0,$3C(a0)
	rts
; End of function sub_20CA88


; -------------------------------------------------------------------------


sub_20CAB8:	 ; DATA XREF: ROM:0020CA30?o
	move.w  $32(a0),d0
	addq.w  #1,d0
	cmpi.w  #$300,d0
	bmi.w   loc_20CAC8
	moveq   #0,d0

loc_20CAC8:	 ; CODE XREF: sub_20CAB8+A?j
	move.w  d0,$32(a0)
	cmpi.w  #$180,d0
	bpl.w   loc_20CAD8
	bmi.w   loc_20CAE2

loc_20CAD8:	 ; CODE XREF: sub_20CAB8+18?j
	addi.w  #$C0,d0
	move.b  d0,$3C(a0)
	rts
; -------------------------------------------------------------------------

loc_20CAE2:	 ; CODE XREF: sub_20CAB8+1C?j
	not.w   d0
	addi.w  #$C0,d0
	move.b  d0,$3C(a0)
	rts
; End of function sub_20CAB8


; -------------------------------------------------------------------------


sub_20CAEE:	 ; DATA XREF: ROM:0020CA34?o
	move.w  $32(a0),d0
	addq.w  #1,d0
	cmpi.w  #$200,d0
	bmi.w   loc_20CAFE
	moveq   #0,d0

loc_20CAFE:	 ; CODE XREF: sub_20CAEE+A?j
	move.w  d0,$32(a0)
	cmpi.w  #$100,d0
	bpl.w   loc_20CB0E
	bmi.w   loc_20CB18

loc_20CB0E:	 ; CODE XREF: sub_20CAEE+18?j
	addi.w  #$80,d0
	move.b  d0,$3C(a0)
	rts
; -------------------------------------------------------------------------

loc_20CB18:	 ; CODE XREF: sub_20CAEE+1C?j
	addi.w  #$80,d0
	not.w   d0
	move.b  d0,$3C(a0)
	rts
; End of function sub_20CAEE


; -------------------------------------------------------------------------


sub_20CB24:	 ; DATA XREF: ROM:0020CA38?o
	move.w  $32(a0),d0
	addq.w  #1,d0
	cmpi.w  #$80,d0
	bmi.w   loc_20CB34
	moveq   #0,d0

loc_20CB34:	 ; CODE XREF: sub_20CB24+A?j
	move.w  d0,$32(a0)
	cmpi.w  #$40,d0 ; '.'
	bpl.w   loc_20CB44
	bmi.w   loc_20CB4E

loc_20CB44:	 ; CODE XREF: sub_20CB24+18?j
	addi.w  #$A0,d0
	move.b  d0,$3C(a0)
	rts
; -------------------------------------------------------------------------

loc_20CB4E:	 ; CODE XREF: sub_20CB24+1C?j
	addi.w  #$E0,d0
	not.w   d0
	move.b  d0,$3C(a0)
	rts
; End of function sub_20CB24


; -------------------------------------------------------------------------


sub_20CB5A:	 ; CODE XREF: sub_20C9C6+18?p
		        ; sub_20CBB2+6?p ...
	move.l  oX(a0),$38(a0)
	move.l  oY(a0),$34(a0)
	movea.w oPlayerMoveLock(a0),a2
	moveq   #0,d0
	move.b  $3C(a2),d0
	jsr     CalcSine
	moveq   #0,d3
	move.b  oPlayerStandObj(a0),d3
	andi.w  #$F,d3
	mulu.w  #$100,d3
	muls.w  d3,d0
	asl.l   #4,d0
	move.l  d0,d4
	move.l  8(a2),d2
	add.l   d0,d2
	move.l  d2,oX(a0)
	muls.w  d3,d1
	asl.l   #4,d1
	move.l  d1,d5
	move.l  $C(a2),d2
	add.l   d1,d2
	move.l  d2,oY(a0)
	asr.l   #8,d4
	asr.l   #8,d5
	move.w  d4,$10(a2)
	move.w  d5,$12(a2)
	rts
; End of function sub_20CB5A


; -------------------------------------------------------------------------


sub_20CBB2:	 ; DATA XREF: ROM:0020C8E0?o
	move.b  #3,oAnim(a0)
	bsr.s   sub_20CB5A
	move.b  #$18,$19(a0)
	move.b  #8,oYRadius(a0)
	move.b  #8,oYRadius(a0)
	lea     objPlayerSlot.w,a1
	bsr.w   sub_20B69E
	beq.w   loc_20CC08
	bsr.w   sub_20CC66
	bne.w   loc_20CC08
	move.w  oY(a0),d0
	moveq   #0,d1
	move.b  $16(a1),d1
	sub.w   d1,d0
	move.b  oYRadius(a0),d1
	sub.w   d1,d0
	move.w  d0,$C(a1)
	bset    #3,$22(a1)
	bclr    #1,$22(a1)
	move.b  #6,oRoutine(a0)

loc_20CC08:	 ; CODE XREF: sub_20CBB2+22?j
		        ; sub_20CBB2+2A?j ...
	lea     (AniSpr_UnusedMovingPForm).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; End of function sub_20CBB2

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------


sub_20CC1C:	 ; DATA XREF: ROM:0020C8E2?o
	move.b  #3,oAnim(a0)
	bsr.w   sub_20CB5A
	lea     objPlayerSlot.w,a1
	moveq   #$10,d0
	bsr.w   sub_20B69E
	tst.b   d1
	beq.w   loc_20CC58
	move.l  oX(a0),d0
	sub.l   $38(a0),d0
	add.l   8(a1),d0
	move.l  d0,8(a1)
	move.l  oY(a0),d0
	sub.l   $34(a0),d0
	add.l   $C(a1),d0
	move.l  d0,$C(a1)
	bra.s   loc_20CC08
; -------------------------------------------------------------------------

loc_20CC58:	 ; CODE XREF: sub_20CC1C+16?j
	bclr    #3,$22(a1)
	move.b  #4,oRoutine(a0)
	bra.s   loc_20CC08
; End of function sub_20CC1C


; -------------------------------------------------------------------------


sub_20CC66:	 ; CODE XREF: sub_20CBB2+26?p
	lea     objPlayerSlot.w,a1
	moveq   #0,d2
	moveq   #0,d3
	move.b  oYRadius(a0),d2
	move.b  $16(a1),d3
	move.w  oY(a0),d0
	move.w  $C(a1),d1
	add.w   d2,d0
	add.w   d3,d1
	cmp.w   d0,d1
	bpl.w   loc_20CC8C
	bmi.w   loc_20CC90

loc_20CC8C:	 ; CODE XREF: sub_20CC66+1E?j
	moveq   #$FFFFFFFF,d1
	rts
; -------------------------------------------------------------------------

loc_20CC90:	 ; CODE XREF: sub_20CC66+22?j
	moveq   #0,d1
	rts
; End of function sub_20CC66

; -------------------------------------------------------------------------
MapSpr_Unknown2:dc.b 1	  ; "And also this set of mappings data
		        ; that doesn't even have an index table attached"
				
				;	yeah that's nice ~ MDT
	dc.b $F8, 5, 0, 0,$F8
	dc.b 1
	dc.b $F8,$D, 0, 4,$F0
	dc.b 1
	dc.b $FC, 0, 0,$C,$FC
	dc.b 1
	dc.b $F0, 3, 0,$D,$FC
	dc.b 1
	dc.b $F0, 3, 0,$11,$FC
	dc.b 1
	dc.b $F8, 5, 8, 0,$F8
	dc.b 1
	dc.b $F8,$D, 8, 4,$F0
	dc.b 1
	dc.b $FC, 0, 8,$C,$FC
	dc.b 1
	dc.b $F0, 3, 8,$D,$FC
	dc.b 1
	dc.b $F0, 3, 8,$11,$FC
AniSpr_SpringBoard:	include	"Level/_Objects/Springboard/Animation Script.asm"
MapSpr_SpringBoard:	include	"Level/_Objects/Springboard/Mappings.asm"
AniSpr_UnusedFlipPlatform:include	"Level/_Objects/Flipping Platform/Animation Script.asm"
MapSpr_UnusedFlipPlatform:include	"Level/_Objects/Flipping Platform/Mappings.asm"
AniSpr_UnusedBridge:include	"Level/_Objects/Bridge/Animation Script.asm"
MapSpr_UnusedBridge:include	"Level/_Objects/Bridge/Mappings.asm"
AniSpr_StaticObj:	include	"Level/_Objects/Static Object/Animation Script.asm"
MapSpr_UnkObject2:	include	"Level/_Objects/Spikes/Unknown Object 2 Mappings.asm"
MapSpr_Unknown1:	include	"Level/_Objects/Spikes/Unknown 1 Mappings.asm"
MapSpr_Spikes:		include	"Level/_Objects/Spikes/Mappings.asm"
AniSpr_UnusedMovingPForm:include	"Level/_Objects/Moving Platform/Animation Script.asm"
MapSpr_UnusedMovingPForm:include	"Level/_Objects/Moving Platform/Mappings.asm"

; -------------------------------------------------------------------------


ObjCollapsingPlatform:	  ; DATA XREF: ROM:00203574?o
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20D04A(pc,d0.w),d0
	jsr     off_20D04A(pc,d0.w)
	jmp     DrawObject
; End of function ObjCollapsingPlatform

; -------------------------------------------------------------------------
off_20D04A:     dc.w sub_20D052-*       ; CODE XREF: ObjCollapsingPlatform+A?p
		        ; DATA XREF: ObjCollapsingPlatform+6?r ...
	dc.w loc_20D0C6-off_20D04A
	dc.w loc_20D10C-off_20D04A
	dc.w sub_20D150-off_20D04A

; -------------------------------------------------------------------------


sub_20D052:	 ; DATA XREF: ROM:off_20D04A?o

;  AT 0020D18A SIZE 000001DC BYTES

	addq.b  #2,oRoutine(a0)
	ori.b   #4,oSprFlags(a0)
	move.b  #3,$18(a0)
	move.w  #$4000,2(a0)
	tst.w	zone
	bne.s	.a2
	lea     MapSpr_CollapsePlatform1(pc),a1
	lea     ObjCollapsePlatform_Sizes1(pc),a2
	move.b  $28(a0),d0
	bpl.w   loc_20D080
	lea     MapSpr_CollapsePlatform2(pc),a1
	lea     ObjCollapsePlatform_Sizes2(pc),a2
	bra.s	loc_20D080
.a2:
	lea     MapSpr_CollapsePlatform1A2(pc),a1
	lea     ObjCollapsePlatform_Sizes1(pc),a2
	move.b  $28(a0),d0
	bpl.w   loc_20D080
	lea     MapSpr_CollapsePlatform2A2(pc),a1
	lea     ObjCollapsePlatform_Sizes2(pc),a2

loc_20D080:	 ; CODE XREF: sub_20D052+22?j
	move.l  a1,4(a0)
	btst    #4,d0
	beq.w   loc_20D098
	bset    #0,oSprFlags(a0)
	bset    #0,oFlags(a0)

loc_20D098:	 ; CODE XREF: sub_20D052+36?j
	andi.w  #$F,d0
	move.b  d0,oMapFrame(a0)
	add.w   d0,d0
	move.w  (a2,d0.w),d0
	move.b  (a2,d0.w),d1
	addq.b  #1,d1
	asl.b   #3,d1
	move.b  d1,$19(a0)
	move.b  1(a2,d0.w),d1
	bpl.w   loc_20D0BC
	neg.b   d1

loc_20D0BC:	 ; CODE XREF: sub_20D052+64?j
	addq.b  #1,d1
	asl.b   #3,d1
	addq.b  #2,d1
	move.b  d1,oYRadius(a0)

loc_20D0C6:	 ; DATA XREF: ROM:0020D04C?o
	tst.b   1(a0)
	bpl.s   locret_20D0FA
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	lea     objPlayerSlot.w,a3
	lea     objPlayerSlot2.w,a1
	move.b  usePlayer2,d0
	beq.w   loc_20D0E8
	exg     a1,a3

loc_20D0E8:	 ; CODE XREF: sub_20D052+90?j
	jsr     SolidObject
	exg     a1,a3
	jsr     SolidObject
	bne.w   loc_20D0FC

locret_20D0FA:	          ; CODE XREF: sub_20D052+78?j
	rts
; -------------------------------------------------------------------------

loc_20D0FC:	 ; CODE XREF: sub_20D052+A4?j
	move.w  #SFXCrumble,d0
	jsr     PlayFMSound
	addq.b  #2,oRoutine(a0)
	move.b  $28(a0),d0
	bpl.w   ObjCollapsePlatform_BreakUp_MultiRow
	bra.w   loc_20D27C
; End of function sub_20D052

; -------------------------------------------------------------------------

loc_20D10C:	 ; DATA XREF: ROM:0020D04E?o
	lea     $2A(a0),a3
	addi.w  #-1,(a3)
	bne.w   loc_20D11C
	addq.b  #2,oRoutine(a0)

loc_20D11C:	 ; CODE XREF: ROM:0020D114?j
	move.b  oPlayerMoveLock(a0),d0
	beq.w   locret_20D14E
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	lea     objPlayerSlot.w,a1
	bsr.w   sub_20D138
	lea     objPlayerSlot2.w,a1

; -------------------------------------------------------------------------


sub_20D138:	 ; CODE XREF: ROM:0020D130?p
	jsr     SolidObject
	beq.w   locret_20D14E
	tst.w   (a3)
	bne.w   locret_20D14E
	bclr    #3,$22(a1)

locret_20D14E:	          ; CODE XREF: ROM:0020D120?j
		        ; sub_20D138+6?j ...
	rts
; End of function sub_20D138


; -------------------------------------------------------------------------


sub_20D150:	 ; DATA XREF: ROM:0020D050?o

;  AT 0020328A SIZE 0000000E BYTES

	move.l  $2C(a0),d0
	add.l   d0,oY(a0)
	addi.l  #$4000,$2C(a0)
	move.w  oY(a0),d0
	lea     objPlayerSlot.w,a1
	move.b  usePlayer2,d1
	beq.w   loc_20D176
	lea     objPlayerSlot2.w,a1

loc_20D176:	 ; CODE XREF: sub_20D150+1E?j
	sub.w   $C(a1),d0
	cmpi.w  #$200,d0
	bgt.w   loc_20D184
	rts
; -------------------------------------------------------------------------

loc_20D184:	 ; CODE XREF: sub_20D150+2E?j
	jmp     DeleteObject
; End of function sub_20D150

; -------------------------------------------------------------------------
; START OF  FOR sub_20D052

ObjCollapsePlatform_BreakUp_MultiRow:   ; CODE XREF: sub_20D052+B2?j
		        ; DATA XREF: sub_20D052+146?o
	move.b  $28(a0),d0
	suba.l  a4,a4
	btst    #4,d0
	beq.w   loc_20D19C
	lea     ObjCollapsePlatform_BreakUp_MultiRow(pc),a4

loc_20D19C:	 ; CODE XREF: sub_20D052+142?j
	lea     ObjCollapsePlatform_Sizes1(pc),a6
	andi.w  #$F,d0
	add.w   d0,d0
	move.w  (a6,d0.w),d0
	lea     (a6,d0.w),a6
	moveq   #0,d0
	move.b  (a6)+,d0
	movea.w d0,a5
	asl.w   #3,d0
	move.w  #$FFF0,d1
	cmpa.w  #0,a4
	bne.w   loc_20D1C6
	neg.w   d0
	neg.w   d1

loc_20D1C6:	 ; CODE XREF: sub_20D052+16C?j
	add.w   oX(a0),d0
	movea.w d0,a2
	movea.w d1,a3
	moveq   #0,d6
	move.b  (a6)+,d6
	move.w  d6,d4
	asl.w   #3,d4
	add.w   oY(a0),d4
	move.w  #9,d2
	move.b  0(a0),$3F(a0)
	clr.b   0(a0)

loc_20D1E8:	 ; CODE XREF: sub_20D052+224?j
	move.w  a5,d5
	move.w  a2,d3
	move.w  d2,d1

loc_20D1EE:	 ; CODE XREF: sub_20D052+21A?j
	jsr     FindNextObjSlot
	bne.w   locret_20D27A
	move.b  (a6)+,d0
	bmi.w   loc_20D266
	move.b  d0,$1A(a1)
	ori.b   #4,1(a1)
	move.b  #3,$18(a1)
	move.w  #$4000,2(a1)
	tst.w	zone
	bne.s	.a2
	move.l  #MapSpr_CollapsePlatform3,4(a1)
	bra.s	.conti
.a2:
	move.l  #MapSpr_CollapsePlatform3A2,4(a1)
.conti:
	move.l  #$20000,$2C(a1)
	move.b  $3F(a0),0(a1)
	move.b  oRoutine(a0),$24(a1)
	cmpa.w  #0,a4
	beq.w   loc_20D244
	bset    #0,1(a1)
	bset    #0,$22(a1)

loc_20D244:	 ; CODE XREF: sub_20D052+1E2?j
	tst.w   d6
	bne.w   loc_20D25A
	st      $3E(a1)
	move.b  #8,$19(a1)
	move.b  #9,$16(a1)

loc_20D25A:	 ; CODE XREF: sub_20D052+1F4?j
	move.w  d4,$C(a1)
	move.w  d3,8(a1)
	move.w  d1,$2A(a1)

loc_20D266:	 ; CODE XREF: sub_20D052+1A8?j
	add.w   a3,d3
	addi.w  #$C,d1
	dbf     d5,loc_20D1EE
	addi.w  #-$10,d4
	addq.w  #5,d2
	dbf     d6,loc_20D1E8

locret_20D27A:	          ; CODE XREF: sub_20D052+1A2?j
	rts
; -------------------------------------------------------------------------

loc_20D27C:	 ; CODE XREF: sub_20D052+B6?j
	move.b  $28(a0),d2
	lea     ObjCollapsePlatform_Sizes2(pc),a6
	move.b  d2,d0
	andi.w  #$1F,d0
	add.w   d0,d0
	move.w  (a6,d0.w),d0
	lea     (a6,d0.w),a6
	move.b  (a6)+,d5
	move.b  (a6)+,d1
	addq.b  #1,d1
	asl.b   #3,d1
	addq.b  #2,d1
	andi.w  #$FF,d5
	move.w  d5,d4
	lsl.w   #3,d4
	neg.w   d4
	move.w  #$10,d3
	moveq   #1,d6
	btst    #6,d2
	bne.w   loc_20D2BC
	lsl.b   #2,d2
	bra.w   loc_20D2DE
; -------------------------------------------------------------------------

loc_20D2BC:	 ; CODE XREF: sub_20D052+260?j
	lea     objPlayerSlot.w,a1
	move.b  usePlayer2,d0
	beq.w   loc_20D2CE
	lea     objPlayerSlot2.w,a1

loc_20D2CE:	 ; CODE XREF: sub_20D052+274?j
	move.w  $10(a1),d0
	btst    #5,d2
	beq.w   loc_20D2DC
	neg.w   d0

loc_20D2DC:	 ; CODE XREF: sub_20D052+284?j
	tst.w   d0

loc_20D2DE:	 ; CODE XREF: sub_20D052+266?j
	bpl.w   loc_20D2EC
	lea     (a6,d5.w),a6
	neg.w   d4
	neg.w   d3
	neg.w   d6

loc_20D2EC:	 ; CODE XREF: sub_20D052:loc_20D2DE?j
	add.w   oX(a0),d4
	move.w  #9,d2
	move.b  0(a0),$3F(a0)
	clr.b   0(a0)

loc_20D2FE:	 ; CODE XREF: sub_20D052+30E?j
	jsr     FindNextObjSlot
	bne.w   locret_20D364
	move.b  #3,$18(a1)
	move.w  #$4000,2(a1)
	ori.b   #4,1(a1)
	tst.w	zone
	bne.s	.a2
	move.l  #MapSpr_CollapsePlatform4,4(a1)
	bra.s	.conti
.a2:
	move.l  #MapSpr_CollapsePlatform4A2,4(a1)
.conti:
	move.l  #$20000,$2C(a1)
	move.b  $3F(a0),0(a1)
	move.b  oRoutine(a0),$24(a1)
	move.w  oY(a0),$C(a1)
	st      $3E(a1)
	move.b  #8,$19(a1)
	move.b  d1,$16(a1)
	move.b  (a6),$1A(a1)
	lea     (a6,d6.w),a6
	move.w  d4,8(a1)
	add.w   d3,d4
	move.w  d2,$2A(a1)
	addi.w  #$C,d2
	dbf     d5,loc_20D2FE

locret_20D364:	          ; CODE XREF: sub_20D052+2B2?j
	rts
; END OF  FOR sub_20D052
; -------------------------------------------------------------------------
ObjCollapsePlatform_Sizes1:dc.w byte_20D434-*
		        ; DATA XREF: sub_20D052+1A?o
		        ; sub_20D052:loc_20D19C?o ...
	dc.w byte_20D44A-ObjCollapsePlatform_Sizes1
byte_20D434:    dc.b    4,   3, $FF, $FF,   0,   0,   0,   1
		        ; DATA XREF: ROM:ObjCollapsePlatform_Sizes1?o
	dc.b    2,   3,   3,   4,   0,   5,   5,   5
	dc.b    5,   6,   6,   6,   6,   6
byte_20D44A:    dc.b    3,   2,   1,   2,   3,   3,   5,   5
		        ; DATA XREF: ROM:0020D432?o
	dc.b    5,   5,   6,   6,   6,   6
ObjCollapsePlatform_Sizes2:dc.b    0,  $C,   0,  $C,   0, $14,   0, $1F
		        ; DATA XREF: sub_20D052+2A?o
		        ; sub_20D052+22E?o
	dc.b    0, $26,   0, $2D,   5,   1,   0,   0
	dc.b    0,   0,   0,   0,   8,   3,   1,   3
	dc.b    3,   3,   3,   3,   3,   3,   2,   4
	dc.b    2,   4,   6,   6,   6,   6,   4,   2
	dc.b    6,   6,   6,   6,   5,   9,   3,   1
	dc.b    3,   3,   3,   3,   3,   3,   3,   3
	dc.b    2,   0
MapSpr_CollapsePlatform1:include	"Level/_Objects/Collapsing Platform/Mappings.asm"
MapSpr_CollapsePlatform3:include	"Level/_Objects/Collapsing Platform/Mappings 3.asm"
MapSpr_CollapsePlatform2:include	"Level/_Objects/Collapsing Platform/Mappings 2.asm"
MapSpr_CollapsePlatform4:include	"Level/_Objects/Collapsing Platform/Mappings 4.asm"
MapSpr_CollapsePlatform1A2:include	"Level/_Objects/Collapsing Platform/A2Mappings.asm"
MapSpr_CollapsePlatform3A2:include	"Level/_Objects/Collapsing Platform/A2Mappings 3.asm"
MapSpr_CollapsePlatform2A2:include	"Level/_Objects/Collapsing Platform/A2Mappings 2.asm"
MapSpr_CollapsePlatform4A2:include	"Level/_Objects/Collapsing Platform/A2Mappings 4.asm"

; -------------------------------------------------------------------------


ObjFloatingPlatform:	    ; DATA XREF: ROM:00203578?o
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20D8A0(pc,d0.w),d0
	jsr     off_20D8A0(pc,d0.w)
	jsr     DrawObject
	rts
; End of function ObjFloatingPlatform

; -------------------------------------------------------------------------
off_20D8A0:     dc.w loc_20D8B8-*       ; CODE XREF: ObjFloatingPlatform+A?p
		        ; DATA XREF: ObjFloatingPlatform+6?r ...
	dc.w loc_20D98A-off_20D8A0

; -------------------------------------------------------------------------


sub_20D8A4:	 ; CODE XREF: ROM:0020D992?j
		        ; ROM:0020D9F2?j ...
	lea     objPlayerSlot.w,a1
	move.w  oX(a0),d3
	move.w  oY(a0),d4
	subq.w  #4,d4
	jmp     SolidObject
; End of function sub_20D8A4

; -------------------------------------------------------------------------

loc_20D8B8:	 ; DATA XREF: ROM:off_20D8A0?o
	ori.b   #4,oSprFlags(a0)
	move.w  #$4000,2(a0)
	move.b  #3,$18(a0)
	move.w  oX(a0),$38(a0)
	move.w  oY(a0),$3A(a0)
	move.w  oY(a0),$36(a0)
	move.l  #MapSpr_FloatingPlatform1,d0
	cmpi.w  #0,zone
	beq.s   loc_20D902
	move.l  #MapSpr_FloatingPlatform2,d0
	cmpi.w  #1,zone
	beq.s   loc_20D902
	move.l  #MapSpr_FloatingPlatform2,d0

loc_20D902:	 ; CODE XREF: ROM:0020D8EA?j
		        ; ROM:0020D8FA?j
	move.l  d0,4(a0)
	move.b  $28(a0),d0
	move.b  d0,d1
	andi.w  #3,d0
	move.b  d0,oMapFrame(a0)
	move.b  loc_20D982(pc,d0.w),$19(a0)
	move.b  #4,oYRadius(a0)
	lsr.b   #2,d1
	andi.w  #3,d1
	move.b  loc_20D986(pc,d1.w),$2D(a0)
	move.b  $29(a0),d0
	beq.s   loc_20D97C
	jsr     FindObjSlot
	beq.s   loc_20D940
	jmp     DeleteObject
; -------------------------------------------------------------------------

loc_20D940:	 ; CODE XREF: ROM:0020D938?j
	move.b  #$A,0(a1)
	move.w  oX(a0),8(a1)
	move.w  oY(a0),$C(a1)
	subi.w  #$10,$C(a1)
	move.b  #$F0,$39(a1)
	move.w  a0,$34(a1)
	move.b  $29(a0),d0
	move.b  d0,d1
	andi.b  #2,d1
	move.b  d1,$28(a1)
	andi.b  #$F8,d0
	move.b  d0,$38(a1)
	add.w   d0,8(a1)

loc_20D97C:	 ; CODE XREF: ROM:0020D930?j
	addq.b  #2,oRoutine(a0)
	rts
; -------------------------------------------------------------------------

loc_20D982:	 ; DATA XREF: ROM:0020D914?r
	move.b  -(a0),d0
	move.w  d0,d0

loc_20D986:	 ; DATA XREF: ROM:0020D926?r
	move.l  $60(a0,d4.w),d0

loc_20D98A:	 ; DATA XREF: ROM:0020D8A2?o
	tst.w   timeStopTimer
	beq.s   loc_20D996
	bra.w   sub_20D8A4
; -------------------------------------------------------------------------

loc_20D996:	 ; CODE XREF: ROM:0020D990?j
	move.b  $28(a0),d0
	lsr.b   #4,d0
	andi.w  #$F,d0
	add.w   d0,d0
	move.w  off_20D9CE(pc,d0.w),d0
	jsr     off_20D9CE(pc,d0.w)
	move.w  $38(a0),d0
	andi.w  #$FF80,d0
	move.w  cameraX.w,d1
	subi.w  #$80,d1
	andi.w  #$FF80,d1
	sub.w   d1,d0
	cmpi.w  #$280,d0
	bls.s   locret_20D9CC
	jmp     DeleteObject
; -------------------------------------------------------------------------

locret_20D9CC:	          ; CODE XREF: ROM:0020D9C4?j
	rts
; -------------------------------------------------------------------------
off_20D9CE:     dc.w loc_20D9E2-*       ; CODE XREF: ROM:0020D9A6?p
		        ; DATA XREF: ROM:0020D9A2?r ...
	dc.w loc_20D9F8-off_20D9CE
	dc.w loc_20DA52-off_20D9CE
	dc.w loc_20DA76-off_20D9CE
	dc.w sub_20DA9C-off_20D9CE
	dc.w loc_20DAB0-off_20D9CE
	dc.w loc_20DB26-off_20D9CE
	dc.w loc_20DB7A-off_20D9CE
	dc.w loc_20DBDA-off_20D9CE
	dc.w loc_20DC52-off_20D9CE
; -------------------------------------------------------------------------

loc_20D9E2:	 ; DATA XREF: ROM:off_20D9CE?o
	addq.b  #1,$2A(a0)
	jsr     sub_20DCCA(pc)
	add.w   $3A(a0),d0
	move.w  d0,oY(a0)
	jmp     sub_20D8A4
; -------------------------------------------------------------------------

loc_20D9F8:	 ; DATA XREF: ROM:0020D9D0?o
	move.l  oX(a0),-(sp)
	jsr     sub_20DCCA(pc)
	add.w   $38(a0),d0
	move.w  d0,oX(a0)
	addq.b  #1,$2A(a0)
	moveq   #0,d0
	move.b  $2C(a0),d0
	asr.b   #1,d0
	add.w   $3A(a0),d0
	move.w  d0,oY(a0)

loc_20DA1C:	 ; CODE XREF: ROM:0020DA72?j
		        ; ROM:0020DA98?j ...
	move.l  (sp)+,d0
	move.l  oX(a0),d1
	sub.l   d0,d1
	asr.l   #8,d1
	move.w  d1,oXVel(a0)
; START OF  FOR sub_20DA9C

loc_20DA2A:	 ; CODE XREF: sub_20DA9C+10?j
		        ; ROM:0020DBC4?j
	jsr     sub_20D8A4(pc)
	beq.s   loc_20DA42
	move.b  $2C(a0),d0
	cmpi.b  #8,d0
	bcc.s   loc_20DA3E
	addq.b  #1,$2C(a0)

loc_20DA3E:	 ; CODE XREF: sub_20DA9C-64?j
	moveq   #1,d0
	rts
; -------------------------------------------------------------------------

loc_20DA42:	 ; CODE XREF: sub_20DA9C-6E?j
	moveq   #0,d0
	move.b  $2C(a0),d0
	beq.s   loc_20DA4E
	subq.b  #1,$2C(a0)

loc_20DA4E:	 ; CODE XREF: sub_20DA9C-54?j
	moveq   #0,d0
	rts
; END OF  FOR sub_20DA9C
; -------------------------------------------------------------------------

loc_20DA52:	 ; DATA XREF: ROM:0020D9D2?o
	move.l  oX(a0),-(sp)
	addq.b  #1,$2A(a0)
	jsr     sub_20DCCA(pc)
	add.w   $3A(a0),d0
	move.w  d0,oY(a0)
	jsr     sub_20DCCA(pc)
	add.w   $38(a0),d0
	move.w  d0,oX(a0)
	bra.w   loc_20DA1C
; -------------------------------------------------------------------------

loc_20DA76:	 ; DATA XREF: ROM:0020D9D4?o
	move.l  oX(a0),-(sp)
	addq.b  #1,$2A(a0)
	jsr     sub_20DCCA(pc)
	add.w   $3A(a0),d0
	move.w  d0,oY(a0)
	jsr     sub_20DCCA(pc)
	neg.w   d0
	add.w   $38(a0),d0
	move.w  d0,oX(a0)
	bra.w   loc_20DA1C

; -------------------------------------------------------------------------


sub_20DA9C:	 ; CODE XREF: ROM:0020DAB6?p
		        ; ROM:0020DAD2?j ...

;  AT 0020DA2A SIZE 00000028 BYTES

	moveq   #0,d0
	move.b  $2C(a0),d0
	asr.b   #1,d0
	add.w   $3A(a0),d0
	move.w  d0,oY(a0)
	bra.w   loc_20DA2A
; End of function sub_20DA9C

; -------------------------------------------------------------------------

loc_20DAB0:	 ; DATA XREF: ROM:0020D9D8?o
	move.b  $2B(a0),d0
	bne.s   loc_20DAC8
	jsr     sub_20DA9C(pc)
	bne.s   loc_20DABE
	rts
; -------------------------------------------------------------------------

loc_20DABE:	 ; CODE XREF: ROM:0020DABA?j
	move.b  #$1E,$2E(a0)
	addq.b  #2,$2B(a0)

loc_20DAC8:	 ; CODE XREF: ROM:0020DAB4?j
	move.b  $2E(a0),d0
	beq.s   loc_20DAD6
	subq.b  #1,$2E(a0)
	bra.w   sub_20DA9C
; -------------------------------------------------------------------------

loc_20DAD6:	 ; CODE XREF: ROM:0020DACC?j
	jsr     sub_20D8A4(pc)
	move.l  oY(a0),d1
	move.w  oYVel(a0),d0
	ext.l   d0
	asl.l   #8,d0
	add.l   d0,d1
	move.l  d1,oY(a0)
	move.w  oYVel(a0),d0
	cmpi.w  #$400,d0
	bcc.s   loc_20DAFC
	addi.w  #$40,oYVel(a0) ; '.'

loc_20DAFC:	 ; CODE XREF: ROM:0020DAF4?j
	jsr     CheckFloorEdge
	tst.w   d1
	bpl.s   loc_20DB10
	lea     objPlayerSlot.w,a1
	bclr    #3,$22(a1)

loc_20DB10:	 ; CODE XREF: ROM:0020DB04?j
	move.w  cameraY.w,d0
	addi.w  #$E0,d0
	cmp.w   oY(a0),d0
	bcc.s   locret_20DB24
	jmp     DeleteObject
; -------------------------------------------------------------------------

locret_20DB24:	          ; CODE XREF: ROM:0020DB1C?j
	rts
; -------------------------------------------------------------------------

loc_20DB26:	 ; DATA XREF: ROM:0020D9DA?o
	move.b  $2B(a0),d0
	andi.w  #$FF,d0
	move.w  off_20DB36(pc,d0.w),d0
	jmp     off_20DB36(pc,d0.w)
; -------------------------------------------------------------------------
off_20DB36:     dc.w loc_20DB3C-*       ; CODE XREF: ROM:0020DB32?j
		        ; DATA XREF: ROM:0020DB2E?r ...
	dc.w loc_20DB48-off_20DB36
	dc.w loc_20DB76-off_20DB36
; -------------------------------------------------------------------------

loc_20DB3C:	 ; DATA XREF: ROM:off_20DB36?o
	jsr     sub_20DA9C(pc)
	bne.s   loc_20DB44
	rts
; -------------------------------------------------------------------------

loc_20DB44:	 ; CODE XREF: ROM:0020DB40?j
	addq.b  #2,$2B(a0)

loc_20DB48:	 ; DATA XREF: ROM:0020DB38?o
	move.b  $2A(a0),d0
	cmpi.b  #$40,d0 ; '.'
	bcc.w   loc_20DB6C
	jsr     sub_20DCCA(pc)
	neg.w   d0
	add.w   $3A(a0),d0
	move.w  d0,oY(a0)
	addq.b  #2,$2A(a0)
	jmp     sub_20D8A4
; -------------------------------------------------------------------------

loc_20DB6C:	 ; CODE XREF: ROM:0020DB50?j
	move.w  oY(a0),$3A(a0)
	addq.b  #2,$2B(a0)

loc_20DB76:	 ; DATA XREF: ROM:0020DB3A?o
	bra.w   sub_20DA9C
; -------------------------------------------------------------------------

loc_20DB7A:	 ; DATA XREF: ROM:0020D9DC?o
	move.b  $2B(a0),d0
	andi.w  #$FF,d0
	move.w  off_20DB8A(pc,d0.w),d0
	jmp     off_20DB8A(pc,d0.w)
; -------------------------------------------------------------------------
off_20DB8A:     dc.w loc_20DB90-*       ; CODE XREF: ROM:0020DB86?j
		        ; DATA XREF: ROM:0020DB82?r ...
	dc.w loc_20DBA2-off_20DB8A
	dc.w loc_20DBD6-off_20DB8A
; -------------------------------------------------------------------------

loc_20DB90:	 ; DATA XREF: ROM:off_20DB8A?o
	jsr     sub_20DA9C(pc)
	bne.s   loc_20DB98
	rts
; -------------------------------------------------------------------------

loc_20DB98:	 ; CODE XREF: ROM:0020DB94?j
	addq.b  #2,$2B(a0)
	move.b  #$3C,$2E(a0) ; '<'

loc_20DBA2:	 ; DATA XREF: ROM:0020DB8C?o
	move.b  $2E(a0),d0
	beq.s   loc_20DBB0
	subq.b  #1,$2E(a0)
	bra.w   sub_20DA9C
; -------------------------------------------------------------------------

loc_20DBB0:	 ; CODE XREF: ROM:0020DBA6?j
	jsr     ObjMove
	subq.w  #8,oYVel(a0)
	jsr     ObjGetCeilDist
	tst.w   d1
	bmi.s   loc_20DBC8
	bra.w   loc_20DA2A
; -------------------------------------------------------------------------

loc_20DBC8:	 ; CODE XREF: ROM:0020DBC2?j
	sub.w   d1,oY(a0)
	move.w  oY(a0),$3A(a0)
	addq.b  #2,$2B(a0)

loc_20DBD6:	 ; DATA XREF: ROM:0020DB8E?o
	bra.w   sub_20DA9C
; -------------------------------------------------------------------------

loc_20DBDA:	 ; DATA XREF: ROM:0020D9DE?o
	move.b  $2B(a0),d0
	andi.w  #$FF,d0
	move.w  off_20DBEA(pc,d0.w),d0
	jmp     off_20DBEA(pc,d0.w)
; -------------------------------------------------------------------------
off_20DBEA:     dc.w loc_20DBF0-*       ; CODE XREF: ROM:0020DBE6?j
		        ; DATA XREF: ROM:0020DBE2?r ...
	dc.w loc_20DC02-off_20DBEA
	dc.w loc_20DC4E-off_20DBEA
; -------------------------------------------------------------------------

loc_20DBF0:	 ; DATA XREF: ROM:off_20DBEA?o
	jsr     sub_20DA9C(pc)
	bne.s   loc_20DBF8
	rts
; -------------------------------------------------------------------------

loc_20DBF8:	 ; CODE XREF: ROM:0020DBF4?j
	addq.b  #2,$2B(a0)
	move.b  #$3C,$2E(a0) ; '<'

loc_20DC02:	 ; DATA XREF: ROM:0020DBEC?o
	move.b  $2E(a0),d0
	beq.s   loc_20DC10
	subq.b  #1,$2E(a0)
	bra.w   sub_20DA9C
; -------------------------------------------------------------------------

loc_20DC10:	 ; CODE XREF: ROM:0020DC06?j
	move.b  $2A(a0),d0
	cmpi.b  #$40,d0 ; '.'
	bcc.w   loc_20DC44
	move.l  oX(a0),-(sp)
	jsr     sub_20DCCA(pc)
	add.w   $38(a0),d0
	move.w  d0,oX(a0)
	addq.b  #1,$2A(a0)
	moveq   #0,d0
	move.b  $2C(a0),d0
	asr.b   #1,d0
	add.w   $3A(a0),d0
	move.w  d0,oY(a0)
	bra.w   loc_20DA1C
; -------------------------------------------------------------------------

loc_20DC44:	 ; CODE XREF: ROM:0020DC18?j
	move.w  oX(a0),$38(a0)
	addq.b  #2,$2B(a0)

loc_20DC4E:	 ; DATA XREF: ROM:0020DBEE?o
	bra.w   sub_20DA9C
; -------------------------------------------------------------------------

loc_20DC52:	 ; DATA XREF: ROM:0020D9E0?o
	move.b  $2B(a0),d0
	andi.w  #$FF,d0
	move.w  off_20DC62(pc,d0.w),d0
	jmp     off_20DC62(pc,d0.w)
; -------------------------------------------------------------------------
off_20DC62:     dc.w loc_20DC68-*       ; CODE XREF: ROM:0020DC5E?j
		        ; DATA XREF: ROM:0020DC5A?r ...
	dc.w loc_20DC7A-off_20DC62
	dc.w loc_20DCC6-off_20DC62
; -------------------------------------------------------------------------

loc_20DC68:	 ; DATA XREF: ROM:off_20DC62?o
	jsr     sub_20DA9C(pc)
	bne.s   loc_20DC70
	rts
; -------------------------------------------------------------------------

loc_20DC70:	 ; CODE XREF: ROM:0020DC6C?j
	addq.b  #2,$2B(a0)
	move.b  #$3C,$2E(a0) ; '<'

loc_20DC7A:	 ; DATA XREF: ROM:0020DC64?o
	move.b  $2E(a0),d0
	beq.s   loc_20DC88
	subq.b  #1,$2E(a0)
	bra.w   sub_20DA9C
; -------------------------------------------------------------------------

loc_20DC88:	 ; CODE XREF: ROM:0020DC7E?j
	move.b  $2A(a0),d0
	cmpi.b  #$40,d0 ; '.'
	bcc.s   loc_20DCBC
	move.l  oX(a0),-(sp)
	jsr     sub_20DCCA(pc)
	neg.w   d0
	add.w   $38(a0),d0
	move.w  d0,oX(a0)
	addq.b  #1,$2A(a0)
	moveq   #0,d0
	move.b  $2C(a0),d0
	asr.b   #1,d0
	add.w   $3A(a0),d0
	move.w  d0,oY(a0)
	bra.w   loc_20DA1C
; -------------------------------------------------------------------------

loc_20DCBC:	 ; CODE XREF: ROM:0020DC90?j
	move.w  oX(a0),$38(a0)
	addq.b  #2,$2B(a0)

loc_20DCC6:	 ; DATA XREF: ROM:0020DC66?o
	bra.w   sub_20DA9C

; -------------------------------------------------------------------------


sub_20DCCA:	 ; CODE XREF: ROM:0020D9E6?p
		        ; ROM:0020D9FC?p ...
	moveq   #0,d0
	move.b  $2A(a0),d0
	jsr     CalcSine
	moveq   #0,d2
	move.b  $2D(a0),d2
	muls.w  d2,d0
	lsr.l   #8,d0
	rts
; End of function sub_20DCCA

; -------------------------------------------------------------------------
MapSpr_FloatingPlatform1:	
    include	"Level/_Objects/Floating Platform/Mappings 1.asm"
MapSpr_FloatingPlatform2:	
    include	"Level/_Objects/Floating Platform/Mappings 2.asm"
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Section art load functions
; -------------------------------------------------------------------------

LoadSectionArt:
	lea	SectionRanges(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	cameraX.w,d0

.Loop:
	cmp.w	(a1)+,d0
	bcs.s	.LoadPLC
	addq.b	#2,d1
	bra.s	.Loop

.LoadPLC:
	move.b	d1,sectionID
	move.w	SectionInitPLCs(pc,d1.w),d0
	jmp	LoadPLC

; -------------------------------------------------------------------------

UpdateSectionArt:
	lea	SectionRanges(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	cameraX.w,d0

.Loop:
	cmp.w	(a1)+,d0
	bcs.s	.FoundRange
	addq.b	#2,d1
	bra.s	.Loop

.FoundRange:
	cmp.b	sectionID,d1
	bne.s	.LoadPLC
	rts

.LoadPLC:
	move.b	d1,sectionID
	move.w	SectionUpdatePLCs(pc,d1.w),d0
	jmp	InitPLC

; -------------------------------------------------------------------------
; Section Data
; -------------------------------------------------------------------------

SectionRanges:  ;	(x pos)
	dc.w $1200	;	LOAD 1	(DIAGONAL SPRINGS, SPRINGS, SPIKES)
	dc.w $2580	;	LOAD 2	(SIGNPOST)
	dc.w -1		;	TERMINATOR
SectionUpdatePLCs:;	(plc ID)
	dc.w 5	;	BASE PLC
	dc.w 5	;	LOAD 4	(DIAGONAL SPRINGS, SPRINGS, SPIKES)
	dc.w 4	;	LOAD 5	(SIGNPOST)
SectionInitPLCs:    
	dc.w 2	;	BASE PLC
	dc.w 2	;	LOAD 1	(DIAGONAL SPRINGS, SPRINGS, SPIKES)
	dc.w 6	;	LOAD 2	(SIGNPOST)

; -------------------------------------------------------------------------

LevelObj_SetBaseTile:
	lea     (BaseTileIndex).l,a1
	add.w   d0,d0
	move.w  BaseTileIndex(pc,d0.w),d4
	lea     BaseTileIndex(pc,d4.w),a2
	moveq   #0,d1
	move.b  $29(a0),d1
	add.w   d1,d1
	move.w  (a2,d1.w),d5
	move.w  d5,2(a0)
	rts

; -------------------------------------------------------------------------
BaseTileIndex:    
	dc.w	$0024   ;	
	dc.w	$0026   ;	
	dc.w	$0028   ;	
	dc.w	$002A   ;	
	dc.w	$002C   ;	
	dc.w	$002E   ;	
	dc.w	$0038   ;	
	dc.w	$0032	;	
	dc.w	$0036   ;	
	dc.w	$0034   ;	
	dc.w	$0030   ;	
	dc.w	$003A   ;	
	dc.w	$003C	;	
	dc.w	$003E	;	
	dc.w	$0040	;	
	dc.w	$0042	;	
	dc.w	$0044 	;	
	dc.w	$0046	;	
	dc.w	$23E4	;	
	dc.w	$242E	;	
	dc.w	$23CE	;	
	dc.w	$249E	;	16 - Tagataga
	dc.w	$2462   ;	
	dc.w	$4381	;	
	dc.w	ArtPoint_Spikes   ;	spikes
	dc.w	$04CC   ;	28 - Spring Board / Bounce Pole
	dc.w	$4000   ;	
	dc.w	$4000   ;	
	dc.w	$0393   ;	
	dc.w	$03A2   ;	
	dc.w	$8375   ;	
	dc.w	ArtPoint_WaterSplash	;	
	dc.w	$036D   ;	
	dc.w	ArtPoint_DiagSpring   ;	
	dc.w	$0469   ;	
	dc.w	0		;	End
	
ArtPoint_DiagSpring		= $4E1
ArtPoint_Spikes 		= $518
ArtPoint_WaterSplash 	= $4E1
ArtPoint_Sign 			= $4E1

; -------------------------------------------------------------------------


ObjAnimal:	  ; DATA XREF: ROM:00203584?o

;  AT 00206FD2 SIZE 00000048 BYTES

	moveq   #0,d0
	move.b  $28(a0),d0
	add.w   d0,d0
	move.w  off_20DED4(pc,d0.w),d0
	jsr     off_20DED4(pc,d0.w)
	jmp     CheckObjDespawnTime
; End of function ObjAnimal

; -------------------------------------------------------------------------
off_20DED4:     dc.w loc_20DED8-*       ; CODE XREF: ObjAnimal+C?p
		        ; DATA XREF: ObjAnimal+8?r ...
	dc.w loc_20DFD2-off_20DED4
; -------------------------------------------------------------------------

loc_20DED8:	 ; DATA XREF: ROM:off_20DED4?o
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20DEE6(pc,d0.w),d0
	jmp     off_20DEE6(pc,d0.w)
; -------------------------------------------------------------------------
off_20DEE6:     dc.w loc_20DEEC-*       ; CODE XREF: ROM:0020DEE2?j
		        ; DATA XREF: ROM:0020DEDE?r ...
	dc.w sub_20DF2A-off_20DEE6
	dc.w sub_20DF7A-off_20DEE6
; -------------------------------------------------------------------------

loc_20DEEC:	 ; DATA XREF: ROM:off_20DEE6?o
	addq.b  #2,oRoutine(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #8,oXRadius(a0)
	move.b  #8,oYRadius(a0)
	move.w  #$3B6,2(a0)
	move.l  #off_20DFC2,4(a0)
	move.l  oX(a0),$2A(a0)
	move.l  oY(a0),$2E(a0)
	move.b  #1,$32(a0)
	rts

; -------------------------------------------------------------------------


sub_20DF2A:	 ; DATA XREF: ROM:0020DEE8?o
	move.b  $32(a0),d0
	jsr     CalcSine
	swap    d1
	swap    d0
	asr.l   #1,d1
	asr.l   #1,d0
	add.l   $2A(a0),d1
	add.l   $2E(a0),d0
	move.l  d1,oX(a0)
	move.l  d0,oY(a0)
	move.w  #$BB6,2(a0)
	addq.b  #1,$32(a0)
	cmpi.b  #$7F,$32(a0)
	bpl.w   loc_20DF74

loc_20DF60:	 ; CODE XREF: sub_20DF2A+4E?j
		        ; sub_20DF7A+38?j ...
	lea     (ani_20DFBC).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20DF74:	 ; CODE XREF: sub_20DF2A+32?j
	addq.b  #2,oRoutine(a0)
	bra.s   loc_20DF60
; End of function sub_20DF2A


; -------------------------------------------------------------------------


sub_20DF7A:	 ; DATA XREF: ROM:0020DEEA?o
	move.b  $32(a0),d0
	jsr     CalcSine
	swap    d1
	swap    d0
	asr.l   #1,d1
	asr.l   #1,d0
	add.l   $2A(a0),d1
	add.l   $2E(a0),d0
	move.l  d1,oX(a0)
	move.l  d0,oY(a0)
	move.w  #$3B6,2(a0)
	addi.b  #-1,$32(a0)
	cmpi.b  #1,$32(a0)
	bmi.w   loc_20DFB4
	bra.s   loc_20DF60
; -------------------------------------------------------------------------

loc_20DFB4:	 ; CODE XREF: sub_20DF7A+34?j
	addi.b  #-2,oRoutine(a0)
	bra.s   loc_20DF60
; End of function sub_20DF7A

; -------------------------------------------------------------------------
ani_20DFBC:     dc.w byte_20DFBE-*      ; DATA XREF: sub_20DF2A:loc_20DF60?o
byte_20DFBE:    dc.b  $13,   0,   1, $FF ; DATA XREF: ROM:ani_20DFBC?o
off_20DFC2:     dc.w byte_20DFC6-*      ; DATA XREF: ROM:00206C7C?o
		        ; ROM:0020DF0E?o ...
	dc.w byte_20DFCC-off_20DFC2
byte_20DFC6:    dc.b    1, $F8,   5,   0,   0, $F8
		        ; DATA XREF: ROM:off_20DFC2?o
byte_20DFCC:    dc.b    1, $F8,   5,   0,   4, $F8
		        ; DATA XREF: ROM:0020DFC4?o
; -------------------------------------------------------------------------

loc_20DFD2:	 ; DATA XREF: ROM:0020DED6?o
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20DFE0(pc,d0.w),d0
	jmp     off_20DFE0(pc,d0.w)
; -------------------------------------------------------------------------
off_20DFE0:     dc.w loc_20DFE6-*       ; CODE XREF: ROM:0020DFDC?j
		        ; DATA XREF: ROM:0020DFD8?r ...
	dc.w sub_20E01A-off_20DFE0
	dc.w sub_20E076-off_20DFE0
; -------------------------------------------------------------------------

loc_20DFE6:	 ; DATA XREF: ROM:off_20DFE0?o
	addq.b  #2,oRoutine(a0)
	move.b  #4,oSprFlags(a0)
	move.b  #1,$18(a0)
	move.b  #8,oXRadius(a0)
	move.b  #8,oYRadius(a0)
	move.w  #$3B6,2(a0)
	move.l  #map_20E0CE,4(a0)
	move.l  #$FFFC0000,$2A(a0)
	rts

sub_20E01A:	 ; DATA XREF: ROM:0020DFE2?o
	move.w  #$3B6,2(a0)
	addi.l  #$10000,oX(a0)
	move.l  $2A(a0),d0
	add.l   d0,oY(a0)
	move.b  #0,oAnim(a0)
	addi.l  #$2000,$2A(a0)
	bmi.w   loc_20E048
	move.b  #1,oAnim(a0)

loc_20E048:	 ; CODE XREF: ROM:0020E03E?j
	jsr     CheckFloorEdge
	tst.w   d1
	bmi.w   loc_20E068

loc_20E054:	 ; CODE XREF: ROM:0020E074?j
		        ; ROM:0020E0B0?j ...
	lea     (ani_20E0C2).l,a1
	jsr     AnimateObject
	jmp     DrawObject
; -------------------------------------------------------------------------
	rts
; -------------------------------------------------------------------------

loc_20E068:	 ; CODE XREF: ROM:0020E050?j
	addq.b  #2,oRoutine(a0)
	move.l  #$FFFC0000,$2A(a0)
	bra.s   loc_20E054

sub_20E076:	 ; DATA XREF: ROM:0020DFE4?o
	move.w  #$BB6,2(a0)
	addi.l  #-$10000,oX(a0)
	move.l  $2A(a0),d0
	add.l   d0,oY(a0)
	move.b  #0,oAnim(a0)
	addi.l  #$2000,$2A(a0)
	bmi.w   loc_20E0A4
	move.b  #1,oAnim(a0)

loc_20E0A4:	 ; CODE XREF: ROM:0020E09A?j
	jsr     CheckFloorEdge
	tst.w   d1
	bmi.w   loc_20E0B2
	bra.s   loc_20E054
; -------------------------------------------------------------------------

loc_20E0B2:	 ; CODE XREF: ROM:0020E0AC?j
	addi.b  #-2,oRoutine(a0)
	move.l  #$FFFC0000,$2A(a0)
	bra.s   loc_20E054
; -------------------------------------------------------------------------
ani_20E0C2:     dc.w byte_20E0C6-*      ; DATA XREF: ROM:loc_20E054?o
		        ; ROM:0020E0C4?o
	dc.w byte_20E0CA-ani_20E0C2
byte_20E0C6:    dc.b  $13,   1, $FF,   0 ; DATA XREF: ROM:ani_20E0C2?o
byte_20E0CA:    dc.b  $13,   0, $FF,   0 ; DATA XREF: ROM:0020E0C4?o
map_20E0CE:     dc.w byte_20E0D2-*      ; DATA XREF: ROM:00206C88?o
		        ; ROM:0020E008?o ...
	dc.w byte_20E0D8-map_20E0CE
byte_20E0D2:    dc.b  1,$F8, 9, 0       ; DATA XREF: ROM:map_20E0CE?o
	dc.b  8,$F4
byte_20E0D8:    dc.b  1,$F8, 9, 0       ; DATA XREF: ROM:0020E0D0?o
	dc.b $E,$F4

; -------------------------------------------------------------------------


ObjYouSay:	  ; DATA XREF: ROM:00203550?o
	moveq   #0,d0
	move.b  oRoutine(a0),d0
	move.w  off_20E0F2(pc,d0.w),d0
	jsr     off_20E0F2(pc,d0.w)
	jmp     DrawObject
; End of function ObjYouSay

; -------------------------------------------------------------------------
off_20E0F2:     
	dc.w sub_20E0FC-off_20E0F2
	dc.w loc_20E11A-off_20E0F2
	dc.w sub_20E148-off_20E0F2
	dc.w sub_20E15A-off_20E0F2
	dc.w sub_20E178-off_20E0F2

; -------------------------------------------------------------------------

sub_20E0FC:	 ; DATA XREF: ROM:off_20E0F2?o
	addq.b  #2,oRoutine(a0)
	ori.b   #4,oSprFlags(a0)
	move.b  #4,$18(a0)
	move.w  #ArtPoint_Sign,2(a0)
	move.l  #map_20E1DA,4(a0)

loc_20E11A:	 ; DATA XREF: ROM:0020E0F4?o
	jsr     GetPlayerObject
	move.w  oX(a0),d0
	cmp.w   8(a6),d0
	bcc.s   locret_20E146
	move.w  rightBound.w,leftBound.w
	clr.b   updateHUDTime
	move.b  #$3C,$2A(a0) ; '<'
	move.w  #SFXSignpost,d0
	jsr     PlayFMSound
	move.b  #0,oMapFrame(a0)
	addq.b  #2,oRoutine(a0)

locret_20E146:	          ; CODE XREF: sub_20E0FC+2C?j
	rts
; End of function sub_20E0FC


; -------------------------------------------------------------------------


sub_20E148:	 ; DATA XREF: ROM:0020E0F6?o
	subq.b  #1,$2A(a0)
	bne.s   locret_20E158
	addq.b  #2,oRoutine(a0)
	move.b  #1,$2A(a0)

locret_20E158:	          ; CODE XREF: sub_20E148+4?j
	lea     (AniSpr_Sign).l,a1
	jsr   	AnimateObject
	rts
; End of function sub_20E148


; -------------------------------------------------------------------------


sub_20E15A:	 ; DATA XREF: ROM:0020E0F8?o
	subq.b  #1,$2A(a0)
	bne.s   locret_20E176
	bset    #0,ctrlLocked.w
	move.w  #$808,playerCtrl.w
	move.b  #$3C,$2A(a0) ; '<'
	addq.b  #2,oRoutine(a0)

locret_20E176:	          ; CODE XREF: sub_20E15A+4?j
	lea     (AniSpr_Sign).l,a1
	jsr   	AnimateObject
	rts

; -------------------------------------------------------------------------

sub_20E178:
	subq.b  #1,$2A(a0)
	bne.s   locret_20E1CE
	move.w  #2,levelRestart
	move.b  #0,spawnMode
	clr.w   sectionID
	clr.l   flowerCount
	move.b  #1,timeZone
	move.b  act.l,d0
	addq.b  #1,d0
	cmpi.b  #2,d0	;	act to trigger end screen on
	beq.s   .timetrigger
	cmpi.b  #3,d0	;	act to trigger end screen on
	blo.s   loc_20E1C2
	move.b	#GM_ENDSCR,gameMode
	move.w  #$E0,d0
	jmp     PlayFMSound
	
.timetrigger:
	move.b	#TIME_FUTURE,timeZone

loc_20E1C2:
	move.b  d0,act.l
	move.w  #$E0,d0
	jsr     PlayFMSound

locret_20E1CE:
	lea     (AniSpr_Sign).l,a1
	jsr   	AnimateObject
	rts

; -------------------------------------------------------------------------

	dc.w $0002
	dc.w $0100
	dc.w $0102
	dc.w $0304
	dc.w $FF00

; -------------------------------------------------------------------------	

map_20E1DA:	include "Level/_Objects/Signpost/Map.asm"
AniSpr_Sign:	
	dc.w @spin-AniSpr_Sign
@spin:	dc.b   2,  3,  0, 4, 0
		dc.b	3,  0, 4, 1
		dc.b	3,  0, 4, 1
		dc.b	3,  0, 4, 1
		dc.b	3,  0, 4, 1
		dc.b	3,  0, 4, 1
		dc.b	1,1,1,1,1,1,2,1,1,1,1,2,1,2,1,$FE,15
	even


	include	"Level/_Objects/Boss/Boss.asm"
	include	"Level/_Objects/Boss/Boss Mappings and Anims.asm"
; -------------------------------------------------------------------------
; Weird Sonic 2-Esque JmpTo thing. No idea what this is about.

JmpTo_LoadShieldArt:
	jmp     LoadShieldArt

; -------------------------------------------------------------------------
; Level Data Index pointers
; -------------------------------------------------------------------------

LEVELDATA	MACRO	art,block,chunk,pal,plc,mus
	dc.l	$3000000|art					;	04
	dc.l	(plc*$1000000)|block            ;	08 (4+4)
	dc.l	chunk                           ;	0C
	dc.b	mus	;	free space ooooooooo    ;	0D
	dc.b	0                               ;	0E
	dc.b	0                               ;	0F
	dc.b	pal                             ;	10 (8+8)
	endm

Null_LevelDataIndex: 
	LEVELDATA	ArtNem_LevelArt_Past,		LevelBlocks_Past,		LevelChunks_Past,		0, 0, $E0
Past_LevelDataIndex: 
	LEVELDATA	ArtNem_LevelArt_Past,		LevelBlocks_Past,		LevelChunks_Past,		4, 2, $81
Present_LevelDataIndex: 
	LEVELDATA	ArtNem_LevelArt_Present,	LevelBlocks_Present,	LevelChunks_Present,	5, 2, $82
Future_LevelDataIndex: 
	LEVELDATA	ArtNem_LevelArt_Future,		LevelBlocks_Future,		LevelChunks_Future,		6, 2, $83
Past_LevelDataIndex2: 
	LEVELDATA	ArtNem_LevelArt_Past2,		LevelBlocks_Past2,		LevelChunks_Past2,		4, 2, $81
Present_LevelDataIndex2: 
	LEVELDATA	ArtNem_LevelArt_Present2,	LevelBlocks_Present2,	LevelChunks_Present2,	5, 2, $82
Future_LevelDataIndex2: 
	LEVELDATA	ArtNem_LevelArt_Future2,	LevelBlocks_Future2,	LevelChunks_Future2,	6, 2, $83
LevelDataIndex3: 
	LEVELDATA	ArtNem_LevelArt_Future3,	LevelBlocks_Future3,	LevelChunks_Future3,	6, 2, $83
LevelDataIndex_R3: 
	LEVELDATA	ArtNem_LevelArt_R3,			LevelBlocks_R3,			LevelChunks_R3,			8, 2, $84
LevelData_LockOn: 
	LEVELDATA	LOCK_ART,					LOCK_BLOCK,				LOCK_CHUNK,				9, 0, $E0
PLCLists:       
	dc.w PLC_Null-PLCLists		;	0
	dc.w PLC_Standard-PLCLists	;	1
	dc.w InitPLC_Lev-PLCLists	;	2
	dc.w PLC_Null-PLCLists		;	3
	dc.w PLC_Sign-PLCLists		;	4
	dc.w PLC_Springs-PLCLists	;	5
	dc.w InitPLC_Sign-PLCLists	;	6
	dc.w PLC_Boss-PLCLists		;	7
PLC_Null:      
	dc.w 0
	dc.l 0
	dc.w 0
PLC_Standard:   
	dc.w 5
	dc.l ArtNem_Diag_Spring+$2C8
	dc.w $A400
	dc.l ArtNem_HUD
	dc.w $AD00
	dc.l ArtNem_MonitorTimePosts
	dc.w $B500
	dc.l ArtNem_Explosions
	dc.w $D000
	dc.l ArtNem_Flower
	dc.w $DAC0
	dc.l ArtNem_Rings
	dc.w $F5C0
	even
InitPLC_Lev:          dc.w $D	 ; DATA XREF: ROM:0020E216?o
	dc.l ArtNem_Spikes
	dc.w ArtPoint_Spikes*$20
	dc.l ArtNem_BouncePole  ; penis hype
	dc.w $4CC*$20
	dc.l ArtNem_SpringWheel
	dc.w $6DA0
	dc.l ArtNem_Trapdoor
	dc.w $6EA0
	dc.l ArtNem_HiddenPlatforms
	dc.w $7020
	dc.l ArtNem_SpinningCyl
	dc.w $7260
	dc.l ArtNem_GreyRock
	dc.w $7440
	dc.l ArtNem_PPZAnimals
	dc.w $76C0
	dc.l ArtNem_Anton
	dc.w $79C0
	dc.l ArtNem_Mosqui
	dc.w $7C80
	dc.l ArtNem_PataBata
	dc.w $85C0
	dc.l ArtNem_Tamabboh
	dc.w $8C40
	dc.l ArtNem_TagaTaga
	dc.w $49E*$20
	dc.l ArtNem_Diag_Spring
	dc.w ArtPoint_DiagSpring*$20
	even
PLC_Sign:	dc.w	0
	dc.l ArtNem_YouSay
	dc.w ArtPoint_Sign*$20
	even
PLC_Springs:	dc.w	2
	dc.l ArtNem_Diag_Spring+$2C8
	dc.w $A400
	dc.l ArtNem_Spikes
	dc.w ArtPoint_Spikes*$20
	dc.l ArtNem_Diag_Spring
	dc.w ArtPoint_DiagSpring*$20
	even
InitPLC_Sign:	dc.w	12
	dc.l ArtNem_BouncePole  ; penis hype
	dc.w $4CC*$20
	dc.l ArtNem_SpringWheel
	dc.w $6DA0
	dc.l ArtNem_Trapdoor
	dc.w $6EA0
	dc.l ArtNem_HiddenPlatforms
	dc.w $7020
	dc.l ArtNem_SpinningCyl
	dc.w $7260
	dc.l ArtNem_GreyRock
	dc.w $7440
	dc.l ArtNem_PPZAnimals
	dc.w $76C0
	dc.l ArtNem_Anton
	dc.w $79C0
	dc.l ArtNem_Mosqui
	dc.w $7C80
	dc.l ArtNem_PataBata
	dc.w $85C0
	dc.l ArtNem_Tamabboh
	dc.w $8C40
	dc.l ArtNem_TagaTaga
	dc.w $49E*$20
	dc.l ArtNem_YouSay
	dc.w ArtPoint_Sign*$20
	even
PLC_Boss:   dc.w 1
	;dc.l ArtNem_Capsule
	;dc.w $9020
	dc.l ArtNem_Boss
	dc.w $6B20
	dc.l ArtNem_Eggman
	dc.w $8220
	
LevelChunks_Future:    
	incbin "Level/R1 Salad Plain/Act 1 Future/Chunks.unc"
	even
LevelBlocks_Future:
	incbin	"Level/R1 Salad Plain/Act 1 Future/Blocks.nem"
	even
ArtNem_LevelArt_Future:	
	incbin	"Level/R1 Salad Plain/Act 1 Future/Art.nem"
	even
LevelCollision_Future:
	incbin	"Level/R1 Salad Plain/Act 1 Future/Collision.bin"
	even
	
LevelChunks_Present:    
	incbin "Level/R1 Salad Plain/Act 1 Present/Chunks.unc"
LevelBlocks_Present:
	incbin	"Level/R1 Salad Plain/Act 1 Present/Blocks.nem"
	even
ArtNem_LevelArt_Present:	
	incbin	"Level/R1 Salad Plain/Act 1 Present/Art.nem"
	even
LevelCollision_Present:
	incbin	"Level/R1 Salad Plain/Act 1 Present/Collision.bin"
	
LevelChunks_Past:    
	incbin "Level/R1 Salad Plain/Act 1 Past/Chunks.unc"
LevelBlocks_Past:
	incbin	"Level/R1 Salad Plain/Act 1 Past/Blocks.nem"
	even
ArtNem_LevelArt_Past:	
	incbin	"Level/R1 Salad Plain/Act 1 Past/Art.nem"
	even
LevelCollision_Past:
	incbin	"Level/R1 Salad Plain/Act 1 Past/Collision.bin"
	even
	
LevelChunks_Present2:    
	incbin "Level/R1 Salad Plain/Act 2 Present/Chunks.unc"
	even
LevelBlocks_Present2:
	incbin	"Level/R1 Salad Plain/Act 2 Present/Blocks.nem"
	even
ArtNem_LevelArt_Present2:	
	incbin	"Level/R1 Salad Plain/Act 2 Present/Art.nem"
	even
LevelCollision_Present2:
	incbin	"Level/R1 Salad Plain/Act 2 Present/Collision.bin"
	
LevelChunks_Past2:    
	incbin "Level/R1 Salad Plain/Act 2 Past/Chunks.bin"
	even
LevelBlocks_Past2:
	incbin	"Level/R1 Salad Plain/Act 2 Past/Blocks.nem"
	even
ArtNem_LevelArt_Past2:	
	incbin	"Level/R1 Salad Plain/Act 2 Past/Art.nem"
	even
LevelCollision_Past2:
	incbin	"Level/R1 Salad Plain/Act 2 Past/Collision.bin"
	
LevelChunks_Future2:    
	incbin "Level/R1 Salad Plain/Act 2 Future/Chunks.bin"
	even
LevelBlocks_Future2:
	incbin	"Level/R1 Salad Plain/Act 2 Future/Blocks.nem"
	even
ArtNem_LevelArt_Future2:	
	incbin	"Level/R1 Salad Plain/Act 2 Future/Art.nem"
	even
LevelCollision_Future2:
	incbin	"Level/R1 Salad Plain/Act 2 Future/Collision.bin"
	
LevelChunks_Future3:    
	incbin "Level/R1 Salad Plain/Act 3 Future/Chunks.bin"
	even
LevelBlocks_Future3:
	incbin	"Level/R1 Salad Plain/Act 3 Future/Blocks.nem"
	even
ArtNem_LevelArt_Future3:	
	incbin	"Level/R1 Salad Plain/Act 3 Future/Art.nem"
	even
LevelCollision_Future3:
	incbin	"Level/R1 Salad Plain/Act 3 Future/Collision.bin"
	
LevelChunks_R3:    
	incbin "Level/R3/Chunks.bin"
	even
LevelBlocks_R3:
	incbin	"Level/R3/Blocks.nem"
	even
ArtNem_LevelArt_R3:	
	incbin	"Level/R3/Art.nem"
	even
LevelCollision_R3:
	incbin	"Level/R3/Collision.bin"

; -------------------------------------------------------------------------
;	ALIGN $20000
ArtUnc_Sonic:
	incbin	"Level/_Objects/Sonic/Data/Art.bin"
	
MapSpr_Sonic:
	include	"Level/_Objects/Sonic/Data/Mappings.asm"
	
DPLC_Sonic:     
	include	"Level/_Objects/Sonic/Data/DPLCs.asm"

ArtUnc_Shield:  
	incbin	"Level/_Objects/Shield/Shield Art.bin"
	
ArtUnc_Invincibility:
	incbin	"Level/_Objects/Shield/Invincible Art.bin"
	
ArtUnc_TimeTravelSpark:
	incbin	"Level/_Objects/Time Travel Spark/Art.bin"
	
ArtNem_Diag_Spring:
	incbin	"Level/_Objects/Springs/Diagonal Art.nem"

ArtNem_MonitorTimePosts:
	incbin	"Level/_Objects/Monitors & Time Posts/Art.nem"

ArtNem_Explosions:
	incbin	"Level/_Objects/Explosion/Art.nem"

ArtNem_Rings:
	incbin	"Level/_Objects/Rings/Art.nem"

ArtUnc_LivesIcon:
	incbin	"Level/_Objects/HUD/Lives Icon Art.bin"

ArtNem_HUD:
	incbin	"Level/_Objects/HUD/Art.nem"

ArtNem_Flower:  
	incbin	"Level/_Objects/Flower/Art.nem"

ArtNem_YouSay:  
	incbin	"Level/_Objects/Signpost/Art.nem"

ArtNem_GreyRock:
	incbin	"Level/_Objects/Grey Rock/Art.nem"

ArtNem_HiddenPlatforms:
	incbin	"Level/_Objects/Hidden Platforms/Art.nem"

ArtNem_SpringWheel:
	incbin	"Level/_Objects/Spinning Wheel/Art.nem"

ArtNem_SpinningCyl:
	incbin	"Level/_Objects/Spinning Cylindar/Art.nem"

ArtNem_WaterSplash:
	incbin	"Level/_Objects/Water Splash/Art2.nem"

ArtNem_Trapdoor:
	incbin	"Level/_Objects/Trapdoor/Art.nem"

ArtNem_Mosqui:
	incbin	"Level/_Objects/Mosqui/Art.nem"

ArtNem_PataBata:
	incbin	"Level/_Objects/PataBata/Art.nem"

ArtNem_Anton:
	incbin	"Level/_Objects/Anton/Art.nem"

ArtNem_Tamabboh:
	incbin	"Level/_Objects/Tamabboh/Art.nem"

ArtNem_TagaTaga:
	incbin	"Level/_Objects/TagaTaga/Art.nem"
	even

ArtNem_BouncePole:
	incbin	"Level/_Objects/Bounce Pole/Art.nem"

ArtNem_Spikes:
	incbin	"Level/_Objects/Spikes/Art.nem"

ArtNem_PPZAnimals:	
	incbin	"Level/_Objects/Critters/Art.nem"
	
ArtNem_Boss:	
	incbin	"Level/_Objects/Boss/Boss.nem"

ArtNem_Eggman:	
	incbin	"Level/_Objects/Boss/Eggman.nem"
	
ColAngleMap:
	incbin	"Level/Universal/Collision Angle Map.bin"

ColHeightMap:	
	incbin	"Level/Universal/Collision Height Map.bin"

ColWidthMap:    
	incbin	"Level/Universal/Collision Width Map.bin"
	
	include "FMV Program/LOGO.ASM"
	include "Title Screen/Title.asm"
	include "End Screen/ENDSCR.asm"
	include "SHC Splash/SHC.ASM"

	include		"Sound Driver/MegaPCM.asm"
	include		"Sound Driver/SampleTable.asm"
	include		"Sound Driver/SOUNDRAM.I"
	include		"Sound Driver/driver.asm"
	
; end of 'ROM'
; ==============================================================
; --------------------------------------------------------------
; Debugging modules
; --------------------------------------------------------------

   include   "_Include/ErrorHandler.asm"
   
	LLD:	; OK  so i'm a fucking moron and defined all of these incorrectly
			; this label is literally just for a smaller form factor
LevelLayoutData:
;			Foreground			 Background			"Plane Z" (unused)
;	R11
	dc.w	FGLayout_Past-LLD,		BGLayout-LLD,		ZLayout_Null-LLD	;	6
	dc.w	FGLayout_Present-LLD,	BGLayout-LLD,		ZLayout_Null-LLD	;	C
	dc.w	FGLayout_Future-LLD,	BGLayout-LLD,		ZLayout_Null-LLD	;	12
	dc.w	ZLayout_Null-LLD,		BGLayout-LLD,		ZLayout_Null-LLD	;	18
;	R12
	dc.w	FGLayout_Past2-LLD,		BGLayout-LLD,		ZLayout_Null-LLD	;	1E
	dc.w	FGLayout_Present2-LLD,	BGLayout-LLD,		ZLayout_Null-LLD	;	24
	dc.w	FGLayout_Future2-LLD,	BGLayout-LLD,		ZLayout_Null-LLD	;	2A
	dc.w	ZLayout_Null-LLD,		BGLayout-LLD,		ZLayout_Null-LLD	;	30
;	R13
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD	;	36
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD	;	3C
	dc.w	FGLayout_Future3-LLD,	BGLayout_Future3-LLD,	ZLayout_Null-LLD	;	42
	dc.w	ZLayout_Null-LLD,		BGLayout-LLD,			ZLayout_Null-LLD	;	48
;	R21
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	LOCK_LAYOUT-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
;	R22
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
;	R23
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
;	R31
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	FGLayout_R3-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD
	dc.w	ZLayout_Null-LLD,		ZLayout_Null-LLD,		ZLayout_Null-LLD

FGLayout_Present:
	incbin	"Level/R1 Salad Plain/Act 1 Present/Foreground.bin"
FGLayout_Future:
	incbin	"Level/R1 Salad Plain/Act 1 Future/Foreground.bin"
FGLayout_Past:
	incbin	"Level/R1 Salad Plain/Act 1 Past/Foreground.bin"
FGLayout_Past2:
	incbin	"Level/R1 Salad Plain/Act 2 Past/Foreground.bin"
FGLayout_Present2:
	incbin	"Level/R1 Salad Plain/Act 2 Present/Foreground.bin"
FGLayout_Future2:
	incbin	"Level/R1 Salad Plain/Act 2 Future/Foreground.bin"
FGLayout_Future3:
	incbin	"Level/R1 Salad Plain/Act 3 Future/Foreground.bin"
FGLayout_R3:
	incbin	"Level/R3/Foreground.bin"
	
BGLayout:
	incbin	"Level/R1 Salad Plain/Act 1 Background.bin"
BGLayout_Future3:
	incbin	"Level/R1 Salad Plain/Act 3 Background.bin"
	
ZLayout_Null:
	dc.l	0
	
GHZ_Act2_Layout:
	incbin	"Level/Leftover/Green Hill Zone Act 2 Layout.bin"
	
GHZ_ZLayout_Null:
	dc.l	0
	
GHZ_Act3_Layout:
	incbin	"Level/Leftover/Green Hill Zone Act 3 Layout.bin"
	
BGLayout_Null:
	dc.l	0
	
_Null:
	dc.l	0

	align	$100000
	END
