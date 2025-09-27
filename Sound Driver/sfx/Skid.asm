SkidSFX_Header:
smpsHeaderStartSong = 1
	smpsHeaderVoice     SkidSFX_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $02

	smpsHeaderSFXChannel cFM4, SkidSFX_FM6,	$F4, $0C
	smpsHeaderSFXChannel cFM5, SkidSFX_FM5,	$F4, $0C

; FM6 Data
SkidSFX_FM6:
	smpsSetvoice        $00
	dc.b	nBb3, $01, nRst, nBb3, nRst, $03

SkidSFX_Loop01:
	dc.b	nBb3, $01, nRst, $01
	smpsLoop            $00, $0B, SkidSFX_Loop01
	smpsStop

; FM5 Data
SkidSFX_FM5:
	smpsSetvoice        $00
	dc.b	nRst, $01, nAb3, nRst, nAb3, nRst, $03

SkidSFX_Loop00:
	dc.b	nAb3, $01, nRst, $01
	smpsLoop            $00, $0B, SkidSFX_Loop00
	smpsStop

SkidSFX_Voices:
;	Voice $00
;	$07
;	$08, $08, $08, $08, 	$1F, $1F, $1F, $1F, 	$00, $00, $00, $00
;	$00, $00, $00, $00, 	$0F, $0F, $0F, $0F, 	$88, $88, $88, $80
	smpsVcAlgorithm     $07
	smpsVcFeedback      $00
	smpsVcUnusedBits    $00
	smpsVcDetune        $00, $00, $00, $00
	smpsVcCoarseFreq    $08, $08, $08, $08
	smpsVcRateScale     $00, $00, $00, $00
	smpsVcAttackRate    $1F, $1F, $1F, $1F
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $00, $00, $00, $00
	smpsVcDecayRate2    $00, $00, $00, $00
	smpsVcDecayLevel    $00, $00, $00, $00
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $00, $08, $08, $08

