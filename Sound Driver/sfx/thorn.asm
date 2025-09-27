ThornSFX_Header:
smpsHeaderStartSong = 1
	smpsHeaderVoice     ThornSFX_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cFM5, ThornSFX_FM6,	$00, $03

; FM6 Data
ThornSFX_FM6:
	smpsSetvoice        $00
	dc.b	nA4, $06, $15
	smpsStop

ThornSFX_Voices:
;	Voice $00
;	$02
;	$03, $00, $00, $00, 	$0F, $0F, $0F, $12, 	$12, $11, $14, $0F
;	$FA, $F3, $FA, $FD, 	$FF, $FF, $FF, $FF, 	$05, $19, $05, $83
	smpsVcAlgorithm     $02
	smpsVcFeedback      $00
	smpsVcUnusedBits    $00
	smpsVcDetune        $00, $00, $00, $00
	smpsVcCoarseFreq    $00, $00, $00, $03
	smpsVcRateScale     $00, $00, $00, $00
	smpsVcAttackRate    $12, $0F, $0F, $0F
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $0F, $14, $11, $12
	smpsVcDecayRate2    $FD, $FA, $F3, $FA
	smpsVcDecayLevel    $0F, $0F, $0F, $0F
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $03, $05, $19, $05

