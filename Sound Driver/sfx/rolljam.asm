RollJamSFX_Header:
smpsHeaderStartSong = 1
	smpsHeaderVoice     RollJamSFX_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cFM5, RollJamSFX_FM6,	$FD, $00

; FM6 Data
RollJamSFX_FM6:
	smpsSetvoice        $00
	dc.b	nB3, $04, nRst, $01, nE5, $03
	smpsStop

RollJamSFX_Voices:
;	Voice $00
;	$83
;	$0C, $10, $13, $1F, 	$1F, $1F, $1F, $1F, 	$00, $00, $00, $00
;	$02, $02, $02, $02, 	$2F, $2F, $FF, $3F, 	$05, $10, $34, $85
	smpsVcAlgorithm     $03
	smpsVcFeedback      $00
	smpsVcUnusedBits    $02
	smpsVcDetune        $01, $01, $01, $00
	smpsVcCoarseFreq    $0F, $03, $00, $0C
	smpsVcRateScale     $00, $00, $00, $00
	smpsVcAttackRate    $1F, $1F, $1F, $1F
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $00, $00, $00, $00
	smpsVcDecayRate2    $02, $02, $02, $02
	smpsVcDecayLevel    $03, $0F, $02, $02
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $05, $34, $10, $05

