titlemus_Header:
smpsHeaderStartSong = 1
	smpsHeaderVoice     titlemus_Voices
	smpsHeaderChan      $06, $03
	smpsHeaderTempo     $01, $07

	smpsHeaderDAC       titlemus_DAC
	smpsHeaderFM        titlemus_FM1,	$00, $17
	smpsHeaderFM        titlemus_FM2,	$00, $13
	smpsHeaderFM        titlemus_FM3,	$00, $22
	smpsHeaderFM        titlemus_FM4,	$00, $11
	smpsHeaderFM        titlemus_FM5,	$00, $11
	smpsHeaderPSG       titlemus_PSG1,	$E8, $08, $00, $00
	smpsHeaderPSG       titlemus_PSG2,	$E8, $08, $00, $00
	smpsHeaderPSG       titlemus_PSG3,	$24, $06, $00, $00

titlemus_FM0:
	smpsStop

; FM1 Data
titlemus_FM1:
	smpsSetvoice        $00
	dc.b	nRst, $60, nRst, $54

titlemus_Loop02:
	dc.b	nB3, $06
	smpsLoop            $00, $3C, titlemus_Loop02
	smpsAlterVol        $FD
	smpsCall            titlemus_Call03

titlemus_Loop03:
	dc.b	nG3
	smpsLoop            $00, $1E, titlemus_Loop03

titlemus_Loop04:
	dc.b	nA3
	smpsLoop            $00, $1E, titlemus_Loop04
	smpsCall            titlemus_Call03

titlemus_Loop05:
	dc.b	nG2
	smpsLoop            $00, $10, titlemus_Loop05

titlemus_Loop06:
	dc.b	nA2
	smpsLoop            $00, $10, titlemus_Loop06

titlemus_Loop07:
	dc.b	nB2, nB2
	smpsLoop            $00, $87, titlemus_Loop07
	dc.b	nB2

titlemus_Loop08:
	smpsAlterVol        $01
	dc.b	nB2, nB2, nB2, nB2
	smpsLoop            $00, $18, titlemus_Loop08
	smpsSetvoice        $02
	smpsAlterVol        $E8
	smpsPan             panRight, $00
	dc.b	nB1, $60, smpsNoAttack, $60, smpsNoAttack, $30
	smpsStop

titlemus_Call03:
	dc.b	nB3
	smpsLoop            $00, $3C, titlemus_Call03

titlemus_Loop10:
	dc.b	nG3
	smpsLoop            $00, $3C, titlemus_Loop10

titlemus_Loop11:
	dc.b	nE3
	smpsLoop            $00, $0F, titlemus_Loop11

titlemus_Loop12:
	dc.b	nFs3
	smpsLoop            $00, $0F, titlemus_Loop12

titlemus_Loop13:
	dc.b	nD3
	smpsLoop            $00, $0F, titlemus_Loop13

titlemus_Loop14:
	dc.b	nB2
	smpsLoop            $00, $0F, titlemus_Loop14
	smpsReturn

; FM2 Data
titlemus_FM2:
	smpsSetvoice        $01
	dc.b	nRst, $60, nRst, nRst, nRst, nRst, nRst, $3C, nCs4, $5A, nD4, nCs4
	dc.b	nD4, nE4, nFs4, nE4, nFs4, $60, smpsNoAttack, $54, nE4, $60, smpsNoAttack, $54
	dc.b	nD4, $60, smpsNoAttack, $60, smpsNoAttack, $1E, nE4, $30, nCs4, $60, smpsNoAttack, $60
	dc.b	smpsNoAttack, $4E, nD4, $5A, nCs4, nD4, nE4, nFs4, nE4, nFs4, $60, smpsNoAttack
	dc.b	$54, nE4, $60, smpsNoAttack, $54, nD4, $60, smpsNoAttack, $42, nE4, $60, smpsNoAttack
	dc.b	$60, smpsNoAttack, $0C, nEb4, $60, smpsNoAttack, $0C, nRst, $60, nRst, nRst, $12
	smpsSetvoice        $02
	smpsCall            titlemus_Call02
	dc.b	nD4, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $30
	smpsStop

titlemus_Call02:
	dc.b	nB3, $60, smpsNoAttack, $30, nCs4, $60, smpsNoAttack, $18, nD4, $60, nRst, $18
	dc.b	nB3, $60, smpsNoAttack, $30, nCs4, $60, smpsNoAttack, $18, nFs3, $60, nRst, $18
	dc.b	nB3, $60, smpsNoAttack, $30, nCs4, $60, smpsNoAttack, $18, nD4, $48, nFs4, $18
	dc.b	nD4, $48, nE4, $18, nCs4, $60, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $60
	smpsReturn

; FM3 Data
titlemus_FM3:
	smpsPan             panLeft, $00
	smpsAlterNote       $FC
	smpsSetvoice        $03
	dc.b	nRst, $60, nRst, nRst, nRst, nRst, nRst, $4E, nCs4, $5A, nD4
	smpsPan             panRight, $00
	dc.b	nCs4, nD4
	smpsPan             panLeft, $00
	dc.b	nE4, nFs4
	smpsPan             panRight, $00
	dc.b	nE4, nFs4, $60, smpsNoAttack, $54
	smpsPan             panLeft, $00
	dc.b	nE4, $60, smpsNoAttack, $54
	smpsPan             panRight, $00
	dc.b	nD4, $60, smpsNoAttack, $60, smpsNoAttack, $1E
	smpsPan             panCenter, $00
	dc.b	nE4, $30
	smpsPan             panLeft, $00
	dc.b	nCs4, $60, smpsNoAttack, $60, smpsNoAttack, $4E, nD4, $5A
	smpsPan             panRight, $00
	dc.b	nCs4, nD4
	smpsPan             panLeft, $00
	dc.b	nE4, nFs4
	smpsPan             panRight, $00
	dc.b	nE4, nFs4, $60, smpsNoAttack, $54
	smpsPan             panLeft, $00
	dc.b	nE4, $60, smpsNoAttack, $54
	smpsPan             panRight, $00
	dc.b	nD4, $60, smpsNoAttack, $42
	smpsPan             panCenter, $00
	dc.b	nE4, $60, smpsNoAttack, $60, smpsNoAttack, $0C
	smpsPan             panLeft, $00
	dc.b	nEb4, $60, smpsNoAttack, $0C, nRst, $60, nRst, nRst, $18
	smpsSetvoice        $04
	smpsCall            titlemus_Call02
	dc.b	nD4, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $18
	smpsStop

; FM4 Data
titlemus_FM4:
	smpsPan             panRight, $00
	smpsAlterNote       $02
	smpsSetvoice        $01
	dc.b	nRst, $60, nRst, nRst, nRst, nRst, nRst, $3C, nA3, $5A, nB3, nA3
	dc.b	nB3, nCs4, nD4, nCs4, nD4, $60, smpsNoAttack, $54, nCs4, $60, smpsNoAttack, $54
	dc.b	nB3, $60, smpsNoAttack, $60, smpsNoAttack, $4E, nA3, $60, smpsNoAttack, $60, smpsNoAttack, $4E
	dc.b	nB3, $5A, nA3, nB3, nCs4, nD4, nCs4, nD4, $60, smpsNoAttack, $54, nCs4
	dc.b	$60, smpsNoAttack, $54, nB3, $60, smpsNoAttack, $5A, nCs4, $60, smpsNoAttack, $54, nB3
	dc.b	$60, smpsNoAttack, $0C, nRst, $60, nRst, nRst, $12
	smpsSetvoice        $02
	dc.b	nG3, $60, smpsNoAttack, $30, nA3, $60, smpsNoAttack, $18, nB3, $60, nRst, $18
	dc.b	nG3, $60, smpsNoAttack, $30, nA3, $60, smpsNoAttack, $18, nD3, $60, nRst, $18
	dc.b	nG3, $60, smpsNoAttack, $30, nA3, $60, smpsNoAttack, $18, nB3, $48, nB3, $18
	dc.b	nG3, $48, nA3, $18, nFs3, $60, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $60
	dc.b	smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $30
	smpsStop

; FM5 Data
titlemus_FM5:
	smpsPan             panLeft, $00
	smpsAlterNote       $FE
	smpsSetvoice        $01
	dc.b	nRst, $60, nRst, nRst, nRst, nRst, nRst, $3C, nE3, $5A, nFs3, nE3
	dc.b	nFs3, nA3, nB3, nA3, nB3, $60, smpsNoAttack, $54, nA3, $60, smpsNoAttack, $54
	dc.b	nFs3, $5A, nG3, $60, smpsNoAttack, $54, nE3, $60, smpsNoAttack, $60, smpsNoAttack, $4E
	dc.b	nFs3, $5A, nE3, nFs3, nA3, nB3, nA3, nB3, $60, smpsNoAttack, $54, nA3
	dc.b	$60, smpsNoAttack, $54, nFs3, $5A, nG3, $60, nA3, smpsNoAttack, $54, nFs3, $60
	dc.b	smpsNoAttack, $0C

titlemus_Loop01:
	dc.b	nRst, $60
	smpsLoop            $00, $0A, titlemus_Loop01
	smpsSetvoice        $02
	dc.b	nRst, $12
	smpsCall            titlemus_Call01
	smpsStop

titlemus_Call01:
	dc.b	nB2, $60, smpsNoAttack, $30, nCs3, $60, smpsNoAttack, $18, nD3, $48, nG3, $18
	dc.b	nE3, $48, nG3, $18, nE3, $60, smpsNoAttack, $60, nB2, smpsNoAttack, $60, smpsNoAttack
	dc.b	$60, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $30
	smpsReturn

; PSG1 Data
titlemus_PSG1:
	smpsPSGvoice        fTone_01

titlemus_Loop0F:
	dc.b	nD5, $0C, nE4, nE4, nE4, nG4, nD4, nD4, nE3, nA4, nG4, nA4
	dc.b	nD4, nE4, nE4, nA3
	smpsLoop            $00, $11, titlemus_Loop0F
	dc.b	nD5, nE4, nE4, nA4, nD4, nE4, nE4, nA3, nE5, nE4, nE4, nA4
	dc.b	nD4, nE4, nE4, nA3, nD5, nE4, nE4, nA4, nD4, nE4, nE4, nB3
	dc.b	nB2, nB2, nFs3, nFs3, nEb4, nEb4, nB4, nB4
	smpsPSGAlterVol     $01
	dc.b	nB4, nB4
	smpsPSGAlterVol     $01
	dc.b	nB5, nB5
	smpsPSGAlterVol     $02
	dc.b	nB5, nB5, nRst, $60, nRst, $2A
	smpsPSGAlterVol     $FB
	smpsPSGvoice        fTone_0A
	smpsAlterNote       $02
	smpsCall            titlemus_Call02
	dc.b	nD4, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $60, smpsNoAttack, $30
	smpsStop

; PSG2 Data
titlemus_PSG2:
	smpsPSGvoice        fTone_01
	dc.b	nRst, $06

titlemus_Loop0D:
	dc.b	nA4, $0C, nG4, nA4, nD4, nE4, nE4, nA3, nD5, nE4, nE4, nE4
	dc.b	nG4, nD4, nD4, nE3
	smpsLoop            $00, $11, titlemus_Loop0D

titlemus_Loop0E:
	dc.b	nA4, nG4, nD4, nE4, nG4, nD4, nD4, nE3
	smpsLoop            $00, $02, titlemus_Loop0E
	dc.b	nA4, nG4, nD4, nE4, nG4, nD4, nD4, nFs3, nFs2, nEb3, nEb3, nB3
	dc.b	nB3, nFs4, nFs4, nEb5
	smpsPSGAlterVol     $01
	dc.b	nFs4, nEb5
	smpsPSGAlterVol     $01
	dc.b	nFs5, nEb6
	smpsPSGAlterVol     $02
	dc.b	nFs5, nEb6, nRst, $60, nRst, nRst, nRst, nRst, nRst, nRst, nRst, nRst
	dc.b	nRst, $24
	smpsPSGAlterVol     $FB
	smpsPSGvoice        fTone_0A
	smpsAlterNote       $FE
	smpsCall            titlemus_Call01
	smpsStop

; PSG3 Data
titlemus_PSG3:
	smpsPSGform         $E7
	smpsPSGvoice        fTone_06

titlemus_Loop09:
	dc.b	nRst, $60
	smpsLoop            $00, $14, titlemus_Loop09
	dc.b	nRst, $30, nB3, $0C

titlemus_Loop0A:
	smpsCall            titlemus_Call04
	smpsLoop            $00, $03, titlemus_Loop0A
	smpsCall            titlemus_Call05

titlemus_Loop0B:
	smpsCall            titlemus_Call04
	smpsLoop            $00, $03, titlemus_Loop0B
	smpsPSGvoice        fTone_04
	dc.b	nB3, $12, $06, nRst, nB3, nB3, nB3, nRst, nB3, nB3, nRst, $18
	smpsPSGvoice        fTone_05
	dc.b	nB3, $12
	smpsPSGvoice        fTone_04
	dc.b	nB3, $06, nRst, nB3, nB3, nB3, nRst, nB3, nB3, nRst, nB3, $0C
	smpsPSGvoice        fTone_06
	dc.b	nB3, $06

titlemus_Loop0C:
	smpsCall            titlemus_Call04
	smpsLoop            $00, $02, titlemus_Loop0C
	smpsCall            titlemus_Call05
	smpsPSGvoice        fTone_05
	dc.b	nB3, $12
	smpsPSGvoice        fTone_04
	dc.b	nB3, $0C, nRst, $06, nB3, nB3, nB3, nRst, nB3, nB3, nRst, nB3
	dc.b	$0C
	smpsPSGvoice        fTone_06
	dc.b	nB3, $06
	smpsPSGvoice        fTone_04
	dc.b	nB3, $12, nB3, $06, nB3, nRst, nB3
	smpsPSGvoice        fTone_06
	dc.b	nB3, $0C
	smpsPSGvoice        fTone_04
	dc.b	nB3, $06, nRst, $24
	smpsPSGvoice        fTone_05
	dc.b	nB3, $18
	smpsPSGvoice        fTone_04
	dc.b	nB3, $18, nB3, nB3, $0C, nB3, $18, nB3, $0C, nB3, $18, nB3
	smpsPSGvoice        fTone_06
	dc.b	nB3, $18
	smpsStop

titlemus_Call04:
	smpsPSGvoice        fTone_04
	dc.b	nB3, $12, $06, nRst, nB3, nB3, nB3, nRst, nB3, nB3, nRst, nB3
	dc.b	$0C
	smpsPSGvoice        fTone_06
	dc.b	nB3, $06
	smpsReturn

titlemus_Call05:
	smpsPSGvoice        fTone_04
	dc.b	nB3, $12, $06, nRst, nB3, nB3, nB3, nRst, nB3, nB3
	smpsPSGvoice        fTone_06
	dc.b	nB3
	smpsPSGvoice        fTone_04
	dc.b	nB3, $0C
	smpsPSGvoice        fTone_06
	dc.b	nB3, $06
	smpsReturn

; DAC Data
titlemus_DAC:
	dc.b	nRst, $60
	smpsLoop            $00, $14, titlemus_DAC
	dc.b	nRst, $3C
	smpsCall            titlemus_Call00
	dc.b	dKick, $12, dKick, $30, dSnare, $06, dKick, $0C, dSnare, $06
	smpsCall            titlemus_Call00
	dc.b	dKick, $12, dKick, $30, nRst, $06, nRst, nRst, nRst
	smpsCall            titlemus_Call00
	dc.b	dKick, $12, dKick, $30, dSnare, $06, dKick, $0C, dSnare, $06, dKick, $12
	dc.b	dKick, $36, dSnare, $18, dKick, $12, dKick, $2A, nRst, $04, nRst, nRst
	dc.b	nRst, $06, nRst, nRst, nRst, dKick, $18, dSnare, dKick, dSnare, $0C, dKick
	dc.b	$18, dKick, $0C, dSnare, $18, dKick, nRst, $06, nRst, nRst, nRst

titlemus_Loop00:
	dc.b	nRst, $60
	smpsLoop            $00, $0D, titlemus_Loop00
	dc.b	nRst, $5A
	smpsSetTempoMod     $20
	smpsStop

titlemus_Call00:
	dc.b	dKick, $12, $30, dSnare, $18
	smpsLoop            $00, $03, titlemus_Call00
	smpsReturn

titlemus_Voices:
	dc.b	$40, $00, $03, $30, $50, $5E, $1B, $5E, $1B, $07, $0B, $07
	dc.b	$0B, $07, $09, $07, $0B, $38, $46, $38, $56, $0D, $2E, $16
	dc.b	nRst, $2C, $71, $32, $71, $34, $1E, $06, $1E, $06, $05, $08
	dc.b	$05, $08, $07, $03, $07, $03, $43, $27, $43, $27, $0D, $8D
	dc.b	$06, $90, $73, $51, $01, $00, $21, $12, $0B, $11, $07, $00
	dc.b	$06, $00, $06, $03, $06, $03, $06, $05, $07, $05, $07, $0F
	dc.b	$1E, $2F, nRst, $2C, $71, $32, $72, $34, $1D, $09, $1D, $09
	dc.b	$05, $08, $05, $08, $07, $03, $07, $03, $43, $27, $43, $27
	dc.b	$0D, $90, $06, $90, $2C, $72, $33, $71, $34, $1E, $06, $1E
	dc.b	$06, $05, $08, $05, $08, $07, $03, $07, $03, $43, $27, $43
	dc.b	$27, $0D, $92, $06, $95, $00