ButtonSFX_Header:
smpsHeaderStartSong = 1
	smpsHeaderVoice     ButtonSFX_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cFM5, ButtonSFX_FM6,	$00, $00

; FM6 Data
ButtonSFX_FM6:
	smpsSetvoice        $00
	dc.b	nE4, $02
	smpsStop

ButtonSFX_Voices:
;	Voice $00
;	$07
;	$0A, $0A, $0A, $0A, 	$1F, $1F, $1F, $1F, 	$00, $00, $00, $00
;	$00, $00, $00, $00, 	$0F, $0F, $0F, $0F, 	$88, $88, $88, $88
	smpsVcAlgorithm     $07
	smpsVcFeedback      $00
	smpsVcUnusedBits    $00
	smpsVcDetune        $00, $00, $00, $00
	smpsVcCoarseFreq    $0A, $0A, $0A, $0A
	smpsVcRateScale     $00, $00, $00, $00
	smpsVcAttackRate    $1F, $1F, $1F, $1F
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $00, $00, $00, $00
	smpsVcDecayRate2    $00, $00, $00, $00
	smpsVcDecayLevel    $00, $00, $00, $00
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $08, $08, $08, $08

