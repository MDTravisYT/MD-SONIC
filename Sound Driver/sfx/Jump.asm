JumpSFX_Header:
smpsHeaderStartSong = 1
	smpsHeaderVoice     JumpSFX_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cFM5, JumpSFX_FM6,	$EA, $0E

; FM6 Data
JumpSFX_FM6:
	smpsSetvoice        $00
	dc.b	nB2, $05
	smpsModSet          $02, $01, $33, $FF
	dc.b	nFs3, $15
	smpsStop

JumpSFX_Voices:
;	Voice $00
;	$47
;	$0A, $0A, $0A, $0A, 	$1F, $1F, $1F, $1F, 	$00, $00, $00, $00
;	$00, $00, $00, $00, 	$FF, $FF, $FF, $FF, 	$81, $81, $81, $81
	smpsVcAlgorithm     $07
	smpsVcFeedback      $00
	smpsVcUnusedBits    $01
	smpsVcDetune        $00, $00, $00, $00
	smpsVcCoarseFreq    $0A, $0A, $0A, $0A
	smpsVcRateScale     $00, $00, $00, $00
	smpsVcAttackRate    $1F, $1F, $1F, $1F
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $00, $00, $00, $00
	smpsVcDecayRate2    $00, $00, $00, $00
	smpsVcDecayLevel    $0F, $0F, $0F, $0F
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $01, $01, $01, $01

