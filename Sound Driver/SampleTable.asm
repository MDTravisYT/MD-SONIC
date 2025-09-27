
; ---------------------------------------------------------------
SampleTable:
	;			type			pointer		Hz
	dcSample	TYPE_DPCM, 		Kick, 		8000				; $81
	dcSample	TYPE_PCM,		Snare,		18000				; $82
	dcSample	TYPE_DPCM, 		Timpani, 	7250				; $83
;	dcSample	TYPE_DPCM, 		PastDrum, 	16000				; $84
	dcSample	TYPE_NONE										; $84
	dcSample	TYPE_NONE										; $85
	dcSample	TYPE_NONE										; $86
	dcSample	TYPE_NONE										; $87
	dcSample	TYPE_DPCM, 		Timpani, 	9750				; $88
	dcSample	TYPE_DPCM, 		Timpani, 	8750				; $89
	dcSample	TYPE_DPCM, 		Timpani, 	7150				; $8A
	dcSample	TYPE_DPCM, 		Timpani, 	7000				; $8B
	dcSample	TYPE_PCM,		SegaPCM,	22050				; $8C	NOTE: sample rate is auto-detected from WAV file
	dc.w	-1	; end marker

; ---------------------------------------------------------------
	incdac	Kick, "sound driver/dac/kick.dpcm"
	incdac	Snare, "sound driver/dac/snare.pcm"
	incdac	Timpani, "sound driver/dac/timpani.dpcm"
	incdac	SegaPCM, "sound driver/dac/sega.wav"
;	incdac	PastDrum, "sound driver/dac/pastdac.dpcm"
	even
