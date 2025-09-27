TravelSFX_Header:
smpsHeaderStartSong = 1
	smpsHeaderVoice     TravelSFX_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $02

	smpsHeaderSFXChannel cFM5, TravelSFX_FM2,	$00, $09
	smpsHeaderSFXChannel cFM4, TravelSFX_FM3,	$05, $06
; FM2 Data
TravelSFX_FM2:
	smpsSetvoice        $00
	smpsModSet          $01, $01, $0A, $07
TravelSFX_Jump01:
	dc.b	nBb3, $50, smpsNoAttack
	smpsLoop 	$00, $02, TravelSFX_Jump01

TravelSFX_Loop00:
	smpsFMAlterVol      $01
	dc.b	smpsNoAttack
	smpsLoop            $00, $14, TravelSFX_Loop00
	smpsStop

; FM3 Data
TravelSFX_FM3:
	smpsSetvoice        $01

TravelSFX_Jump00:
	dc.b	nB5, $07, nC6, nCs6, nD6, nEb6, nD6, nCs6, nC6
	smpsLoop 	$00, $03, TravelSFX_Jump00
	dc.b	nB5
	smpsFMAlterVol      $02
	dc.b	nC6
	smpsFMAlterVol      $02
	dc.b	nCs6
	smpsFMAlterVol      $02
	dc.b	nD6
	smpsFMAlterVol      $02
	dc.b	nEb6
	smpsFMAlterVol      $02
	dc.b	nD6
	smpsFMAlterVol      $02
	dc.b	nCs6
	smpsFMAlterVol      $02
	dc.b	nC6
	smpsStop

TravelSFX_Voices:
;	Voice $00
;	$08
;	$0A, $70, $30, $00, 	$0B, $0A, $4F, $3F, 	$03, $03, $03, $03
;	$00, $00, $00, $01, 	$0F, $0F, $0F, $0F, 	$21, $2D, $11, $80
	smpsVcAlgorithm     $00
	smpsVcFeedback      $01
	smpsVcUnusedBits    $00
	smpsVcDetune        $00, $03, $07, $00
	smpsVcCoarseFreq    $00, $00, $00, $0A
	smpsVcRateScale     $00, $01, $00, $00
	smpsVcAttackRate    $3F, $0F, $0A, $0B
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $03, $03, $03, $03
	smpsVcDecayRate2    $01, $00, $00, $00
	smpsVcDecayLevel    $00, $00, $00, $00
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $00, $11, $2D, $21

;	Voice $01
;	$24
;	$04, $31, $11, $52, 	$1A, $9C, $95, $98, 	$04, $06, $0E, $18
;	$01, $04, $00, $03, 	$4F, $8F, $2F, $1F, 	$19, $8A, $16, $8A
	smpsVcAlgorithm     $04
	smpsVcFeedback      $04
	smpsVcUnusedBits    $00
	smpsVcDetune        $05, $01, $03, $00
	smpsVcCoarseFreq    $02, $01, $01, $04
	smpsVcRateScale     $02, $02, $02, $00
	smpsVcAttackRate    $18, $15, $1C, $1A
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $18, $0E, $06, $04
	smpsVcDecayRate2    $03, $00, $04, $01
	smpsVcDecayLevel    $01, $02, $08, $04
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $0A, $16, $0A, $19

