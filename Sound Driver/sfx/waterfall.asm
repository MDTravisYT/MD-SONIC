WaterfallSFX_Header:
smpsHeaderStartSong = 1
	smpsHeaderVoice     WaterfallSFX_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cFM4, WaterfallSFX_FM4,	$00, $0D

; The following track data was present at 22004 bytes from the start of the song.
WaterfallSFX_Jump00:

; FM4 Data
WaterfallSFX_FM4:
	smpsSetvoice        $00
	dc.b	nG6, $02, smpsNoAttack, $01
	smpsConditionalJump $2B, WaterfallSFX_Jump00

WaterfallSFX_Loop00:
	dc.b	$01
	smpsFMAlterVol      $01
	smpsLoop            $00, $22, WaterfallSFX_Loop00
	dc.b	nRst, $01
	smpsFade            $00
	smpsStop

WaterfallSFX_Voices:
;	Voice $00
;	$38
;	$0F, $0F, $0F, $0F, 	$1F, $1F, $1F, $0E, 	$00, $00, $00, $00
;	$00, $00, $00, $00, 	$0F, $0F, $0F, $1F, 	$00, $00, $00, $80
	smpsVcAlgorithm     $00
	smpsVcFeedback      $07
	smpsVcUnusedBits    $00
	smpsVcDetune        $00, $00, $00, $00
	smpsVcCoarseFreq    $0F, $0F, $0F, $0F
	smpsVcRateScale     $00, $00, $00, $00
	smpsVcAttackRate    $0E, $1F, $1F, $1F
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $00, $00, $00, $00
	smpsVcDecayRate2    $00, $00, $00, $00
	smpsVcDecayLevel    $01, $00, $00, $00
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $00, $00, $00, $00

