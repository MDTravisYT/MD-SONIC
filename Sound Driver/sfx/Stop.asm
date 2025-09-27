StopSFX_Header:
smpsHeaderStartSong = 1
	smpsHeaderVoice     StopSFX_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cFM5, StopSFX_FM6,	$00, $05

; FM6 Data
StopSFX_FM6:
	dc.b	nRst, $01
	smpsStop

StopSFX_Voices:
