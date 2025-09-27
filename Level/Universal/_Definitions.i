btnStart:	equ %10000000 ; Start 	($80)
btnA:		equ %01000000 ; A		($40)
btnC:		equ %00100000 ; C		($20)
btnB:		equ %00010000 ; B		($10)
btnR:		equ %00001000 ; Right	($08)
btnL:		equ %00000100 ; Left	($04)
btnDn:		equ %00000010 ; Down	($02)
btnUp:		equ %00000001 ; Up		($01)
btnDir:		equ %00001111 ; All DPad
bitStart:	equ 7
bitA:		equ 6
bitC:		equ 5
bitB:		equ 4
bitR:		equ 3
bitL:		equ 2
bitDn:		equ 1
bitUp:		equ 0

; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023
; -------------------------------------------------------------------------
; Level variables
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Object ID table
; -------------------------------------------------------------------------

		rsreset
ObjID_Sonic           		rs.b		1
ObjID_SonicP2          		rs.b		1	
ObjID_Powerup         		rs.b		1
ObjID_Waterfall       		rs.b		1
ObjID_UnkDemolishSwitch 	rs.b		1
ObjID_TestBadnik      		rs.b		1
ObjID_SpinTunnel      		rs.b		1
ObjID_LayoutDemolish  		rs.b		1
ObjID_RotPlatform     		rs.b		1
ObjID_Spring          		rs.b		1
ObjID_WaterSplash     		rs.b		1
ObjID_FlapDoor_ChkCollision rs.b		1
ObjID_FlapDoorH       		rs.b		1
ObjID_WaterfallSplash 		rs.b		1
ObjID_MovingSpring    		rs.b		1
ObjID_Ring					rs.b		1
ObjID_LostRing        		rs.b		1
ObjID_SmallPlatform   		rs.b		1
ObjID_Mosqui          		rs.b		1
ObjID_PataBata        		rs.b		1
ObjID_Anton           		rs.b		1
ObjID_TagaTaga        		rs.b		1
ObjID_YouSay          		rs.b		1
ObjID_Explosion       		rs.b		1
ObjID_Monitor         		rs.b		1
ObjID_MonitorContents 		rs.b		1
ObjID_GrayRock        		rs.b		1
ObjID_HUD 					rs.b		1
							rs.b		1
							rs.b		1
ObjID_Flower        		rs.b		1
ObjID_CollapsingPlatform 	rs.b		1
ObjID_FloatingPlatform   	rs.b		1
ObjID_Tamabboh        		rs.b		1
ObjID_UnkMissile      		rs.b		1
ObjID_Animal          		rs.b		1
							rs.b		1
ObjID_Spikes          		rs.b		1
ObjID_UnusedFlipPlatform 	rs.b		1
ObjID_SpringBoard     		rs.b		1
ObjID_UnusedMovingPForm 	rs.b		1

; -------------------------------------------------------------------------
; RAM
; WORKRAM+$FF00A000, HiRAM 0xFF80000-0xFFFFFF
; -------------------------------------------------------------------------

;VARSSTART               EQU $FFFF8000                 ; Start of HiRAM vars

Title_PadProg	        EQU $FFFF0000			
LevelChunks	            EQU $FFFF0000			

levelLayout             EQU $FFFFA400
deformBuffer			EQU $FFFFA800
nemBuffer               EQU $FFFFAA00
objDrawQueue            EQU $FFFFAC00
blockBuffer             EQU $FFFFB000
sonicArtBuf             EQU $FFFFC800  
sonicRecordBuf          EQU $FFFFCB00

hscroll					EQU $FFFFCC00

objects           		EQU $FFFFD000
objPlayerSlot           EQU $FFFFD000
objPlayerSlot2          EQU $FFFFD040
objHUDScoreSlot         EQU $FFFFD080
objHUDLivesSlot         EQU $FFFFD0C0
objShieldSlot           EQU $FFFFD180
objInvStar1Slot         EQU $FFFFD200
objInvStar2Slot         EQU $FFFFD240
objInvStar3Slot         EQU $FFFFD280
objInvStar4Slot         EQU $FFFFD2C0
objTimeStar1Slot        EQU $FFFFD300
objTimeStar2Slot        EQU $FFFFD340
objTimeStar3Slot        EQU $FFFFD380
objTimeStar4Slot        EQU $FFFFD3C0

objMissileSlots         EQU $FFFFD400

dynObjects              EQU $FFFFD800

fmSndQueue1             EQU $FFFFF00B
fmSndQueue2             EQU $FFFFF00C

gameMode                EQU $FFFFF600
playerCtrl              EQU $FFFFF602
playerCtrlTap           EQU $FFFFF603
p1CtrlData              EQU $FFFFF604
p1CtrlTap               EQU $FFFFF605
p2CtrlData              EQU $FFFFF606

vdpReg01                EQU $FFFFF60C
vintTimer				EQU $FFFFF614
vscrollScreen			EQU $FFFFF616
hscrollScreen           EQU $FFFFF61A

vdpReg0A                EQU $FFFFF624
palFadeInfo				EQU $FFFFF626
palFadeStart            EQU $FFFFF626
palFadeLen				EQU $FFFFF627
miscVariables           EQU $FFFFF628

vintRoutine             EQU $FFFFF62A

spriteCount		EQU $FFFFF62C

palCycleSteps           EQU $FFFFF632
rngSeed                 EQU $FFFFF636
paused                  EQU $FFFFF63A
dmaCmdLow               EQU $FFFFF640
hintFlag		EQU $FFFFF644
waterHeight             EQU $FFFFF646
waterHeight2            EQU $FFFFF648
destWaterHeight         EQU $FFFFF64A
waterMoveSpeed          EQU $FFFFF64C
waterRoutine            EQU $FFFFF64D
waterFullscreen		EQU $FFFFF64E
hintUpdates             EQU $FFFFF64F
palCycleTimers          EQU $FFFFF65C

; Pattern Load Cues
plcBuffer               EQU $FFFFF680
plcNemWrite             EQU $FFFFF6E0

plcRepeat               EQU plcNemWrite+4
plcPixel                EQU plcRepeat+4
plcRow                  EQU plcPixel+4       
plcRead                 EQU plcRow+4
plcShift                EQU plcRead+4
plcTileCount            EQU plcShift+4
plcProcTileCnt		EQU plcTileCount+2



cameraX                 EQU $FFFFF700
cameraY			EQU $FFFFF704
cameraBgX		EQU $FFFFF708
cameraBg2X		EQU $FFFFF710
cameraBg3X		EQU $FFFFF718
cameraBgY		EQU $FFFFF70C
cameraBg2Y		EQU $FFFFF714
cameraBg3Y		EQU $FFFFF71C
destLeftBound		EQU $FFFFF720
destRightBound          EQU $FFFFF722
destTopBound		EQU $FFFFF724
destBottomBound         EQU $FFFFF726
leftBound		EQU $FFFFF728
rightBound              EQU $FFFFF72A
topBound                EQU $FFFFF72C
bottomBound             EQU $FFFFF72E   
unusedF730              EQU $FFFFF730
leftBound3		EQU $FFFFF732

scrollXDiff		EQU $FFFFF73A
scrollYDiff		EQU $FFFFF73C

camYCenter		EQU $FFFFF73E
unusedF740 		EQU $FFFFF740
unusedF741 		EQU $FFFFF741
eventRoutine 		EQU $FFFFF742
scrollLock		EQU $FFFFF744
unusedF746 		EQU $FFFFF746
unusedF748 		EQU $FFFFF748
horizBlkCrossed 	EQU $FFFFF74A
vertiBlkCrossed		EQU $FFFFF74B
horizBlkCrossedBg       EQU $FFFFF74C
vertiBlkCrossedBg       EQU $FFFFF74D
horizBlkCrossedBg2      EQU $FFFFF74E
vertiBlkCrossedBg2      EQU $FFFFF74F
horizBlkCrossedBg3      EQU $FFFFF750
vertiBlkCrossedBg3      EQU $FFFFF751

scrollFlags             EQU $FFFFF754
scrollFlagsBg		EQU $FFFFF756
scrollFlagsBg2		EQU $FFFFF758
scrollFlagsBg3		EQU $FFFFF75A
btmBoundShift		EQU $FFFFF75C
sonicLastFrameP2        EQU $FFFFF75D
miniSonic               EQU $FFFFF75E
sneezeFlag              EQU $FFFFF75F
sonicTopSpeed           EQU $FFFFF760
sonicAcceleration       EQU $FFFFF762
sonicDeceleration       EQU $FFFFF764
sonicLastFrame          EQU $FFFFF766
updateSonicArt		EQU $FFFFF767
primaryAngle		EQU $FFFFF768
secondaryAngle		EQU $FFFFF76A
objSpawnRoutine         EQU $FFFFF76C 
objPrevChunk            EQU $FFFFF76E
objChunkRight           EQU $FFFFF770
objChunkLeft            EQU $FFFFF774
objChunkNullR           EQU $FFFFF778
objChunkNullL           EQU $FFFFF77C
boredTimer		EQU $FFFFF780
boredTimerP2            EQU $FFFFF782
timeWarpDir             EQU $FFFFF784
timeWarpTimer           EQU $FFFFF786
lookMode                EQU $FFFFF788

debugSpeed            EQU $FFFFF790
collisionPtr		EQU $FFFFF796

camXCenter              EQU $FFFFF7A0
sonicRecordIndex        EQU $FFFFF7A8
bossActive              EQU $FFFFF7AA
specialChunks		EQU $FFFFF7AC
unkAnimFlag             EQU $FFFFF7C7
waterSlideFlag          EQU $FFFFF7CA
ctrlLocked              EQU $FFFFF7CC

scoreChain              EQU $FFFFF7D0
savedSR                 EQU $FFFFF7DA
unkBridgeStat           EQU $FFFFF7DC
sprites                 EQU $FFFFF800
waterFadePal		EQU $FFFFFA00
waterPalette		EQU $FFFFFA80
palette                 EQU $FFFFFB00
fadePalette		EQU $FFFFFB80

; -------------------------------------------------------------------------
; Object variables and constants
; -------------------------------------------------------------------------

oSize		EQU	$40
c = 0
	rept	oSize
oVar\$c		EQU	c
		c: = c+1
	endr

	rsreset
oID		rs.b	1			; ID
oSprFlags	rs.b	1			; Sprite flags
oTile		rs.w	1			; Base tile ID
oMap		rs.l	1			; Sprite mappings pointer
oX		rs.w	1			; X position
oYScr		rs.b	0			; Y position (screen mode)
oXSub		rs.w	1			; X position subpixel
oY		rs.w	1			; Y position
oYSub		rs.w	1			; Y position subpixel
oXVel		rs.w	1			; X velocity
oYVel		rs.w	1			; Y velocity
oTimer		rs.b	1
			rs.b	1
oYRadius	rs.b	1			; Y radius
oXRadius	rs.b	1			; X radius
oPriority	rs.b	1			; Sprite draw priority level
oWidth		rs.b	1			; Width
oMapFrame	rs.b	1			; Sprite mapping frame ID
oAnimFrame	rs.b	1			; Animation script frame ID
oAnim		rs.b	1			; Animation ID
oPrevAnim	rs.b	1			; Previous previous animation ID
oAnimTime	rs.b	1			; Animation timer
oAnimTime2		rs.b	1
oColType	rs.b	1			; Collision type
oColStatus	rs.b	1			; Collision status
oFlags		rs.b	1			; Flags
oSavedFlagsID	rs.b	1			; Saved flags entry ID
oRoutine	rs.b	1			; Routine ID
oSolidType	rs.b	0			; Solidity type
oRoutine2	rs.b	1			; Secondary routine ID
oAngle		rs.b	1			; Angle
		rs.b	1			; Object specific variable
oSubtype	rs.b	1			; Subtype ID
oLayer		rs.b	0			; Layer ID
oSubtype2	rs.b	1			; Secondary subtype ID

; -------------------------------------------------------------------------
; Player object variables
; -------------------------------------------------------------------------

oPlayerGVel		EQU	oVar14		; Ground velocity
oPlayerCharge		EQU	oVar2A		; Peelout/spindash charge timer

oPlayerCtrl		EQU	oVar2C		; Control flags
oPlayerJump		EQU	oVar3C		; Jump flag
oPlayerMoveLock		EQU	oVar3E		; Movement lock timer

oPlayerPriAngle		EQU	oVar36		; Primary angle
oPlayerSecAngle		EQU	oVar37		; Secondary angle
oPlayerStick		EQU	oVar38		; Collision stick flag

oPlayerHurt		EQU	oVar30		; Hurt timer
oPlayerInvinc		EQU	oVar32		; Invincibility timer
oPlayerShoes		EQU	oVar34		; Speed shoes timer
oPlayerReset		EQU	oVar3A		; Reset timer

oPlayerRotAngle		EQU	oVar2B		; Rotation angle
oPlayerRotDist		EQU	oVar39		; Rotation distance
oPlayerRotCenter	EQU	oVar3E		; Rotation center

oPlayerPushObj		EQU	oVar20		; ID of object being pushed on
oPlayerStandObj		EQU	oVar3D		; ID of object being stood on

oPlayerHangAni		EQU	oVar1F		; Hanging animation timer

; -------------------------------------------------------------------------
; Object layout entry structure
; -------------------------------------------------------------------------

	rsreset
oeX		rs.w	1			; X position
oeY		rs.w	1			; Y position/flags
oeID		rs.b	1			; ID
oeSubtype	rs.b	1			; Subtype
oeTimeZones	rs.b	1			; Time zones
oeSubtype2	rs.b	1			; Subtype 2
oeSize		rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; VDP DMA from 68000 memory to VDP memory
; -------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in 68000 memory
;	dest - Destination address in VDP memory
;	len  - Length of data in bytes
;	type - Type of VDP memory
; -------------------------------------------------------------------------

LVLDMA macro src, dest, len, type
	lea	VDPCTRL,a5
	move.l	#$94009300|((((\len)/2)&$FF00)<<8)|(((\len)/2)&$FF),(a5)
	move.l	#$96009500|((((\src)/2)&$FF00)<<8)|(((\src)/2)&$FF),(a5)
	move.w	#$9700|(((\src)>>17)&$7F),(a5)
	VDPCMD	move.w,\dest,\type,DMA,>>16,(a5)
	VDPCMD	move.w,\dest,\type,DMA,&$FFFF,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)
	endm

; -------------------------------------------------------------------------
; Background section
; -------------------------------------------------------------------------
; PARAMETERS:
;	size - Size of scrion
;	id   - Section type
; -------------------------------------------------------------------------

BGSTATIC	EQU	0
BGDYNAMIC1	EQU	2
BGDYNAMIC2	EQU	4
BGDYNAMIC3	EQU	6

; -------------------------------------------------------------------------

BGSECT macro size, id
	dcb.b	(\size)/16, \id
	endm

; -------------------------------------------------------------------------
; Start debug item index
; -------------------------------------------------------------------------
; PARAMETERS:
;	off - (OPTION) Count offset
; -------------------------------------------------------------------------

__dbgID = 0
DBSTART macro off
	__dbgCount: = 0
	if narg>0
		dc.b	(__dbgCount\#__dbgID\)+(\off)
	else
		dc.b	__dbgCount\#__dbgID
	endif
	even
	endm

; -------------------------------------------------------------------------
; Debug item
; -------------------------------------------------------------------------
; PARAMETERS:
;	id       - Object ID
;	priority - Priority
;	mappings - Mappings
;	tile     - Tile ID
;	subtype  - Subtype
;	flip     - Flip flags
;	subtype2 - Subtype 2
;	frame    - Sprite frame
; -------------------------------------------------------------------------

DBGITEM macro id, priority, mappings, tile, subtype, flip, subtype2, frame
	dc.b	\id, \priority
	dc.l	\mappings
	dc.w	\tile
	dc.b	\subtype, \flip, \subtype2, \frame
	__dbgCount: = __dbgCount+1
	endm

; -------------------------------------------------------------------------
; End debug item index
; -------------------------------------------------------------------------

DBGEND macro
	__dbgCount\#__dbgID: EQU __dbgCount
	endm

; -------------------------------------------------------------------------

