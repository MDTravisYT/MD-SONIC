; =============================================================================================
; Created by Flamewing, based on S1SMPS2ASM version 1.1 by Marc Gordon (AKA Cinossu)

; Now Debut's SMPS2ASM because nothing else used this before!
; =============================================================================================
SonicDriverVer:	equ	5
align0	macro	val
	cnop	0,\val
    endm
	
smpsWeirdD1LRR macro
		dc.b	$F9
	endm
; ---------------------------------------------------------------------------------------------
; Standard Octave Pitch Equates
smpsPitch10lo:	EQU -120	; $88
smpsPitch09lo:	EQU -108	; $94
smpsPitch08lo:	EQU  -96	; $A0
smpsPitch07lo:	EQU  -84	; $AC
smpsPitch06lo:	EQU  -72	; $B8
smpsPitch05lo:	EQU  -60	; $C4
smpsPitch04lo:	EQU  -48	; $D0
smpsPitch03lo:	EQU  -36	; $DC
smpsPitch02lo:	EQU  -24	; $E8
smpsPitch01lo:	EQU  -12	; $F4
smpsPitch00:	EQU    0	; $00
smpsPitch01hi:	EQU  +12	; $0C
smpsPitch02hi:	EQU  +24	; $18
smpsPitch03hi:	EQU  +36	; $24
smpsPitch04hi:	EQU  +48	; $30
smpsPitch05hi:	EQU  +60	; $3C
smpsPitch06hi:	EQU  +72	; $48
smpsPitch07hi:	EQU  +84	; $54
smpsPitch08hi:	EQU  +96	; $60
smpsPitch09hi:	EQU +108	; $6C
smpsPitch10hi:	EQU +120	; $78

; ---------------------------------------------------------------------------------------------
; Note Equates
nRst:	EQU $80		; $80
nC0:	EQU $81		; $81
nCs0:	EQU nC0+1	; $82
nD0:	EQU nCs0+1	; $83
nEb0:	EQU nD0+1	; $84
nE0:	EQU nEb0+1	; $85
nF0:	EQU nE0+1	; $86
nFs0:	EQU nF0+1	; $87
nG0:	EQU nFs0+1	; $88
nAb0:	EQU nG0+1	; $89
nA0:	EQU nAb0+1	; $8A
nBb0:	EQU nA0+1	; $8B
nB0:	EQU nBb0+1	; $8C
nC1:	EQU nB0+1	; $8D
nCs1:	EQU nC1+1	; $8E
nD1:	EQU nCs1+1	; $8F
nEb1:	EQU nD1+1	; $90
nE1:	EQU nEb1+1	; $91
nF1:	EQU nE1+1	; $92
nFs1:	EQU nF1+1	; $93
nG1:	EQU nFs1+1	; $94
nAb1:	EQU nG1+1	; $95
nA1:	EQU nAb1+1	; $96
nBb1:	EQU nA1+1	; $97
nB1:	EQU nBb1+1	; $98
nC2:	EQU nB1+1	; $99
nCs2:	EQU nC2+1	; $9A
nD2:	EQU nCs2+1	; $9B
nEb2:	EQU nD2+1	; $9C
nE2:	EQU nEb2+1	; $9D
nF2:	EQU nE2+1	; $9E
nFs2:	EQU nF2+1	; $9F
nG2:	EQU nFs2+1	; $A0
nAb2:	EQU nG2+1	; $A1
nA2:	EQU nAb2+1	; $A2
nBb2:	EQU nA2+1	; $A3
nB2:	EQU nBb2+1	; $A4
nC3:	EQU nB2+1	; $A5
nCs3:	EQU nC3+1	; $A6
nD3:	EQU nCs3+1	; $A7
nEb3:	EQU nD3+1	; $A8
nE3:	EQU nEb3+1	; $A9
nF3:	EQU nE3+1	; $AA
nFs3:	EQU nF3+1	; $AB
nG3:	EQU nFs3+1	; $AC
nAb3:	EQU nG3+1	; $AD
nA3:	EQU nAb3+1	; $AE
nBb3:	EQU nA3+1	; $AF
nB3:	EQU nBb3+1	; $B0
nC4:	EQU nB3+1	; $B1
nCs4:	EQU nC4+1	; $B2
nD4:	EQU nCs4+1	; $B3
nEb4:	EQU nD4+1	; $B4
nE4:	EQU nEb4+1	; $B5
nF4:	EQU nE4+1	; $B6
nFs4:	EQU nF4+1	; $B7
nG4:	EQU nFs4+1	; $B8
nAb4:	EQU nG4+1	; $B9
nA4:	EQU nAb4+1	; $BA
nBb4:	EQU nA4+1	; $BB
nB4:	EQU nBb4+1	; $BC
nC5:	EQU nB4+1	; $BD
nCs5:	EQU nC5+1	; $BE
nD5:	EQU nCs5+1	; $BF
nEb5:	EQU nD5+1	; $C0
nE5:	EQU nEb5+1	; $C1
nF5:	EQU nE5+1	; $C2
nFs5:	EQU nF5+1	; $C3
nG5:	EQU nFs5+1	; $C4
nAb5:	EQU nG5+1	; $C5
nA5:	EQU nAb5+1	; $C6
nBb5:	EQU nA5+1	; $C7
nB5:	EQU nBb5+1	; $C8
nC6:	EQU nB5+1	; $C9
nCs6:	EQU nC6+1	; $CA
nD6:	EQU nCs6+1	; $CB
nEb6:	EQU nD6+1	; $CC
nE6:	EQU nEb6+1	; $CD
nF6:	EQU nE6+1	; $CE
nFs6:	EQU nF6+1	; $CF
nG6:	EQU nFs6+1	; $D0
nAb6:	EQU nG6+1	; $D1
nA6:	EQU nAb6+1	; $D2
nBb6:	EQU nA6+1	; $D3
nB6:	EQU nBb6+1	; $D4
nC7:	EQU nB6+1	; $D5
nCs7:	EQU nC7+1	; $D6
nD7:	EQU nCs7+1	; $D7
nEb7:	EQU nD7+1	; $D8
nE7:	EQU nEb7+1	; $D9
nF7:	EQU nE7+1	; $DA
nFs7:	EQU nF7+1	; $DB
nG7:	EQU nFs7+1	; $DC
nAb7:	EQU nG7+1	; $DD
nA7:	EQU nAb7+1	; $DE
nBb7:	EQU nA7+1	; $DF

; ---------------------------------------------------------------------------------------------
; PSG envelope equates

nMaxPSG				EQU nA5
nMaxPSG1			EQU nA5+psgdelta
nMaxPSG2			EQU nA5+psgdelta
; ---------------------------------------------------------------------------------------------
; DAC Equates (depracted; this is now handled in the SONAR percussion kit definitions file)
dKick			EQU	$81
dSnare			EQU	$82
;dTimpani		EQU	$83
;dHiTom			EQU	$84
;dMidTom			EQU	$85
;dLowTom			EQU	$86
;dHiHat			EQU	$87
;dHiTimpani		EQU	$88
;dMidTimpani		EQU	$89
;dLowTimpani		EQU	$8A
;dVLowTimpani		EQU	$8B
;dClap			EQU	$8C
;dCrashCymbal		EQU	$8D
;dCowbell		EQU	$8E
;dScratch		EQU	$8F
;dScratchEnd		EQU	$90
;dSourceSnare		EQU	$91
;dASKick			EQU	$92
;dROYAM			EQU	$93
;dRideCymbal		EQU	$95

; ---------------------------------------------------------------------------------------------
; Channel IDs for SFX
cPSG1				EQU $80
cPSG2				EQU $A0
cPSG3				EQU $C0
cNoise				EQU $E0	; Not for use in S3/S&K/S3D
cFM3				EQU $02
cFM4				EQU $04
cFM5				EQU $05
cFM6				EQU $06	; Only in S3/S&K/S3D, overrides DAC

; ---------------------------------------------------------------------------------------------
;---------------------------------------------
; SMPS F_Tone Equates 
;---------------------------------------------	
fTone_00:	EQU $00
fTone_01:	EQU fTone_00+1
fTone_02:	EQU fTone_01+1
fTone_03:	EQU fTone_02+1
fTone_04:	EQU fTone_03+1
fTone_05:	EQU fTone_04+1
fTone_06:	EQU fTone_05+1
fTone_07:	EQU fTone_06+1
fTone_08:	EQU fTone_07+1
fTone_09:	EQU fTone_08+1
fTone_0A:	EQU fTone_09+1
fTone_0B:	EQU fTone_0A+1
fTone_0C:	EQU fTone_0B+1
fTone_0D:	EQU fTone_0C+1
fTone_0E:	EQU fTone_0D+1
fTone_0F:	EQU fTone_0E+1
fTone_10:	EQU fTone_0F+1
fTone_11:	EQU fTone_10+1
fTone_12:	EQU fTone_11+1
fTone_13:	EQU fTone_12+1
fTone_14:	EQU fTone_13+1
fTone_15:	EQU fTone_14+1
fTone_16:	EQU fTone_15+1
fTone_17:	EQU fTone_16+1
fTone_18:	EQU fTone_17+1
fTone_19:	EQU fTone_18+1
fTone_1A:	EQU fTone_19+1
fTone_1B:	EQU fTone_1A+1
fTone_1C:	EQU fTone_1B+1
fTone_1D:	EQU fTone_1C+1
fTone_1E:	EQU fTone_1D+1
fTone_1F:	EQU fTone_1E+1
fTone_20:	EQU fTone_1F+1
fTone_21:	EQU fTone_20+1
fTone_22:	EQU fTone_21+1
fTone_23:	EQU fTone_22+1
fTone_24:	EQU fTone_23+1
fTone_25:	EQU fTone_24+1
fTone_26:	EQU fTone_25+1

; ---------------------------------------------------------------------------------------------
; PSG conversion to S3/S&K/S3D drivers require a tone shift of 12 semi-tones.
conv0To256  macro val 
	if val<$01
		dc.b (256-val+$FF)&$FF
	else	
		dc.b (256-val)&$FF	
	endc
	endm
SMPSModFix:	macro steps
	dc.b (steps/(speed-1))
	endm	
psgdelta	EQU $0C
PSGPitch macro pitch
		dc.b	(pitch+psgdelta)&$FF
	endm

s1TempotoS2 macro tmod
	if tmod<$01
		dc.b ((($FF+tmod-1)*256+($FF+tmod/2))/$FF+tmod)&$FF 	
	else
		dc.b (((tmod-1)*256+(tmod/2))/tmod)&$FF
	endc
	endm
	
s3TempotoS2 macro tmod
	if tmod<$01
		dc.b (256-tmod+$FF)&$FF
	else	
		dc.b (256-tmod)&$FF	
	endc
	endm
	
convertMainTempoMod	macro tmod
	if 		smpsHeaderStartSong=2
		dc.b tmod
	elseif 		smpsHeaderStartSong<2
		s1TempotoS2 	\tmod
	elseif	smpsHeaderStartSong>2
		s3TempotoS2  	\tmod
	endc
	endm	
; ---------------------------------------------------------------------------------------------
; Header Macros
smpsHeaderStartSong = 0

smpsHeaderVoiceNull macro
	dc.w	$0000
	endm

; Header - Set up Voice Location
; Common to music and SFX
smpsHeaderVoice macro loc
songStart set *
	dc.w	loc-songStart
	endm

; Header - Set up Voice Location as S3's Universal Voice Bank
; Common to music and SFX
smpsHeaderVoiceUVB macro
	if songStart<>*
		fail "Missing smpsHeaderStartSong or smpsHeaderStartSongConvert"
	endc
	;dc.w	little_endian(z80_UniVoiceBank)
	z80_ptr	z80_UniVoiceBank
	endm

; Header macros for music (not for SFX)
; Header - Set up Channel Usage
smpsHeaderChan macro fm,psg
	dc.b	fm,psg
	endm

; Header - Set up Tempo
smpsHeaderTempo macro tdiv,tmod
	dc.b	tdiv,tmod
	endm

; Header - Set up DAC Channel
smpsHeaderDAC macro loc,pitch,vol
	dc.w	loc-songStart
	if narg>=2
		dc.b	\pitch
	else
		dc.b	$00
	endc
	if narg>=3
		dc.b	\vol
	else
		dc.b	$00
	endc
	endm

; Header - Set up FM Channel
smpsHeaderFM macro loc,pitch,vol
	dc.w	loc-songStart
	dc.b	pitch,vol
	endm

; Header - Set up PSG Channel
smpsHeaderPSG macro loc,pitch,vol,mod,voice
	dc.w	loc-songStart
	dc.b	pitch,vol,mod,voice
	endm

; Header macros for SFX (not for music)
; Header - Set up Tempo
smpsHeaderTempoSFX macro div
	dc.b	div
	endm

; Header - Set up Channel Usage
smpsHeaderChanSFX macro chan
	dc.b	chan
	endm

; Header - Set up FM Channel
smpsHeaderSFXChannel macro chanid,loc,pitch,vol
	if (chanid=cNoise)
		fail "Using channel ID of cNoise ($E0) in Sonic 3 driver is dangerous. Fix the song so that it turns into a noise channel instead."
	endc
	dc.b	$80,chanid
	dc.w	loc-songStart
	dc.b	pitch, vol
	endm

; ---------------------------------------------------------------------------------------------
; Co-ord Flag Macros and Equates
; E0xx - Panning, AMS, FMS
smpsPan macro direction,amsfms
panNone set $00
panRight set $40
panLeft set $80
panCentre set $C0
panCenter set $C0 ; silly Americans :U
	dc.b $E0,direction+amsfms
	endm

; E1xx - Set channel frequency displacement to xx
smpsAlterNote macro val
	dc.b	$E1,val
	endm

; E2xx - Useless
smpsNop macro val
	dc.b	$E2,val
	endm
; Return (used after smpsCall)
smpsReturn macro val
	dc.b	$E3
	endm

; Fade in previous song (ie. 1-Up)
smpsFade macro val
	dc.b	$E4
	endm

; E5xx - Set channel tempo divider to xx
smpsChanTempoDiv macro val
	dc.b	$E5,val
;	endc
	endm

; E6xx - Alter Volume by xx
smpsAlterVol macro val
	dc.b	$E6,val
	endm

sVol  macro val
	$E6,val
	endm
; E7 - Prevent attack of next note
smpsNoAttack	EQU $E7

; E8xx - Set note fill to xx
smpsNoteFill macro val
		dc.b	$E8,val
;	endc
	endm
smpsAlterPitch 	macro	value
	dc.b $E9,value
	endm


; Set music tempo modifier to xx
smpsSetTempoMod macro mod
	dc.b	$EA,mod
	endm

; Set music tempo divider to xx
smpsSetTempoDiv macro val
	dc.b	$EB,val
	endm

; ECxx - Set Volume to xx
smpsSetVol macro val
	dc.b	$EC,val
	endm

; Works on all drivers
smpsPSGAlterVol macro vol
	dc.b	$EC,vol
	endm

; Clears pushing sound flag in S1
smpsClearPush macro	
	dc.b	$ED
	endm

; Stops special SFX (S1 only) and restarts overridden music track
smpsStopSpecial macro
		dc.b	$EE
	endm

; EFxx[yy] - Set Voice of FM channel to xx; xx < 0 means yy present
smpsSetvoice macro voice,songID
	if narg<=1
		dc.b	$EF,voice
	else
		dc.b	$EF,voice|$80,songID+$81
	endc
	endm

; F0wwxxyyzz - Modulation - ww: wait time - xx: modulation speed - yy: change per step - zz: number of steps
smpsModSet macro wait,speed,change,step
	dc.b	$F0
	dc.b	wait,speed,change,step
	endm

; Turn on Modulation
smpsModOn macro
	dc.b	$F1
	endm

; F2 - End of channel
smpsStop macro
	dc.b	$F2
	endm

; F3xx - PSG waveform to xx
smpsPSGform macro form
	dc.b	$F3,form
	endm

; Turn off Modulation
smpsModOff macro
	dc.b	$F4
	endm

; F5xx - PSG voice to xx
smpsPSGvoice macro voice
	dc.b	$F5,voice
	endm

; F6xxxx - Jump to xxxx
smpsJump macro loc
	dc.b	$F6
	dc.w	loc-*-1
	endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
smpsLoop macro index,loops,loc
	dc.b	$F7
	dc.b	index,loops
	dc.w	loc-*-1
	endm

; F8xxxx - Call pattern at xxxx, saving return point
smpsCall macro loc
	dc.b	$F8
	dc.w	loc-*-1
	endm

; ---------------------------------------------------------------------------------------------
; Alter Volume
smpsFMAlterVol macro val1,val2
	if narg<=1
		dc.b	$E6,val1
	else
		dc.b	$E5,val1,val2
	endc
	endm

; S3/S&K/S3D-only coordination flags
; Silences FM channel then stops as per smpsStop
smpsStopFM macro
	dc.b	$E3
	endm

; Spindash Rev
smpsSpindashRev macro
	dc.b	$E9
	endm
	
smpsPlayDACSample macro sample
	dc.b	$EA,sample
	endm
	
smpsConditionalJump macro index,loc
	dc.b	$EB
	dc.b	index
	dc.w	loc-songStart
	endm

; Set note values to xx-$40
smpsSetNote macro val
	dc.b	$ED,val
	endm

smpsFMICommand macro reg,val
	dc.b	$EE,reg,val
	endm

; Set Modulation
smpsModChange2 macro fmmod,psgmod
	dc.b	$F1,fmmod,psgmod
	endm

; Set Modulation
smpsModChange macro val
	dc.b	$F4,val
	endm

; FCxxxx - Jump to xxxx
smpsContinuousLoop macro loc
	dc.b	$FC
	dc.w	loc-songStart
	endm

smpsAlternateSMPS macro flag
	dc.b	$FD,flag
	endm

smpsFM3SpecialMode macro ind1,ind2,ind3,ind4
	dc.b	$FE,ind1,ind2,ind3,ind4
	endm

smpsPlaySound macro index
	dc.b	$FF,$01,index
	endm

smpsHaltMusic macro flag
	dc.b	$FF,$02,flag
	endm

smpsCopyData macro data,len
	fail "Coord. Flag to copy data should not be used. Complain to Flamewing if any music uses it."
	dc.b	$FF,$03
	;dc.w	little_endian(data)
	z80_ptr	data
	dc.b	len
	endm

smpsSSGEG macro op1,op2,op3,op4
	dc.b	$FF,$05,op1,op2,op3,op4
	endm

smpsFMFlutter macro tone,mask
	dc.b	$FF,$06,tone,mask
	endm

smpsResetSpindashRev macro val
	dc.b	$FF,$07
	endm

; ---------------------------------------------------------------------------------------------
; Macros for FM instruments
; Voices - Feedback
smpsVcFeedback macro val
vcFeedback set \val
	endm

; Voices - Algorithm
smpsVcAlgorithm macro val
vcAlgorithm set \val
	endm

smpsVcUnusedBits macro val
vcUnusedBits set \val
	endm

; Voices - Detune
smpsVcDetune macro op1,op2,op3,op4
vcDT1 set \op1
vcDT2 set \op2
vcDT3 set \op3
vcDT4 set \op4
	endm

; Voices - Coarse-Frequency
smpsVcCoarseFreq macro op1,op2,op3,op4
vcCF1 set \op1
vcCF2 set \op2
vcCF3 set \op3
vcCF4 set \op4
	endm

; Voices - Rate Scale
smpsVcRateScale macro op1,op2,op3,op4
vcRS1 set \op1
vcRS2 set \op2
vcRS3 set \op3
vcRS4 set \op4
	endm

; Voices - Attack Rate
smpsVcAttackRate macro op1,op2,op3,op4
vcAR1 set \op1
vcAR2 set \op2
vcAR3 set \op3
vcAR4 set \op4
	endm

; Voices - Amplitude Modulation
smpsVcAmpMod macro op1,op2,op3,op4
vcAM1 set \op1
vcAM2 set \op2
vcAM3 set \op3
vcAM4 set \op4
	endm

; Voices - First Decay Rate
smpsVcDecayRate1 macro op1,op2,op3,op4
vcD1R1 set \op1
vcD1R2 set \op2
vcD1R3 set \op3
vcD1R4 set \op4
	endm

; Voices - Second Decay Rate
smpsVcDecayRate2 macro op1,op2,op3,op4
vcD2R1 set \op1
vcD2R2 set \op2
vcD2R3 set \op3
vcD2R4 set \op4
	endm

; Voices - Decay Level
smpsVcDecayLevel macro op1,op2,op3,op4
vcDL1 set \op1
vcDL2 set \op2
vcDL3 set \op3
vcDL4 set \op4
	endm

; Voices - Release Rate
smpsVcReleaseRate macro op1,op2,op3,op4
vcRR1 set \op1
vcRR2 set \op2
vcRR3 set \op3
vcRR4 set \op4
	endm

; Voices - Total Level
smpsVcTotalLevel macro op1,op2,op3,op4
vcTL1 set \op1
vcTL2 set \op2
vcTL3 set \op3
vcTL4 set \op4
	dc.b	(vcUnusedBits<<6)+(vcFeedback<<3)+vcAlgorithm
;   0     1     2     3     4     5     6     7
;%1000,%1000,%1000,%1000,%1010,%1110,%1110,%1111
vcTLMask4 set ((vcAlgorithm=7)<<7)
vcTLMask3 set ((vcAlgorithm>=4)<<7)
vcTLMask2 set ((vcAlgorithm>=5)<<7)
vcTLMask1 set $80
;	dc.b	(vcDT4<<4)+vcCF4 ,(vcDT3<<4)+vcCF3 ,(vcDT2<<4)+vcCF2 ,(vcDT1<<4)+vcCF1
;	dc.b	(vcRS4<<6)+vcAR4 ,(vcRS3<<6)+vcAR3 ,(vcRS2<<6)+vcAR2 ,(vcRS1<<6)+vcAR1
;	dc.b	(vcAM4<<5)+vcD1R4,(vcAM3<<5)+vcD1R3,(vcAM2<<5)+vcD1R2,(vcAM1<<5)+vcD1R1
;	dc.b	vcD2R4           ,vcD2R3           ,vcD2R2           ,vcD2R1
;	dc.b	(vcDL4<<4)+vcRR4 ,(vcDL3<<4)+vcRR3 ,(vcDL2<<4)+vcRR2 ,(vcDL1<<4)+vcRR1
;	dc.b	vcTL4|vcTLMask4  ,vcTL3|vcTLMask3  ,vcTL2|vcTLMask2  ,vcTL1|vcTLMask1
	dc.b	(vcDT4<<4)+vcCF4,(vcDT3<<4)+vcCF3,(vcDT2<<4)+vcCF2,(vcDT1<<4)+vcCF1
	dc.b	(vcRS4<<6)+vcAR4,(vcRS3<<6)+vcAR3,(vcRS2<<6)+vcAR2,(vcRS1<<6)+vcAR1
	dc.b	(vcAM4<<5)+vcD1R4,(vcAM3<<5)+vcD1R3,(vcAM2<<5)+vcD1R2,(vcAM1<<5)+vcD1R1
	dc.b	vcD2R4,vcD2R3,vcD2R2,vcD2R1
	dc.b	(vcDL4<<4)+vcRR4,(vcDL3<<4)+vcRR3,(vcDL2<<4)+vcRR2,(vcDL1<<4)+vcRR1
	dc.b	vcTL4|vcTLMask4,vcTL3|vcTLMask3,vcTL2|vcTLMask2,vcTL1|vcTLMask1
	endm

