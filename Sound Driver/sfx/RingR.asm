RingRSFX_Header:
smpsHeaderStartSong = 1
	smpsHeaderVoice     RingLSFX_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cFM4, RingRSFX_FM6,	$00, $05

; FM6 Data
RingRSFX_FM6:
	smpsSetvoice        $00
	smpsPan             panRight, $00
	dc.b	nE5, $05, nG5, $05, nC6, $1B
	smpsStop

; Song seems to not use any FM voices
RingRSFX_Voices:
