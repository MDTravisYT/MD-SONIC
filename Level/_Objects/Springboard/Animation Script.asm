	dc.w byte_20CCDA-*   ; DATA XREF: sub_20B8A2:loc_20B8D0?o
		        ; sub_20B8E2:loc_20B910?o ...
	dc.w byte_20CCEA-AniSpr_SpringBoard
	dc.w byte_20CCF4-AniSpr_SpringBoard
	dc.w byte_20CCFE-AniSpr_SpringBoard
	dc.w byte_20CD02-AniSpr_SpringBoard
byte_20CCDA:    dc.b  2, 0, 1, 0, 2, 0, 1, 0, 3, 4, 3, 5, 3, 4, 3
		        ; DATA XREF: ROM:AniSpr_SpringBoard?o
	dc.b $FF
byte_20CCEA:    dc.b  2, 0, 1, 0, 2, 0, 1, 0,$FF, 0
		        ; DATA XREF: ROM:0020CCD2?o
byte_20CCF4:    dc.b  2, 3, 4, 3, 5, 3, 4, 3,$FF, 0
		        ; DATA XREF: ROM:0020CCD4?o
byte_20CCFE:    dc.b  0, 0,$FF          ; DATA XREF: ROM:0020CCD6?o
	dc.b 0
byte_20CD02:    dc.b  0, 3,$FF, 0       ; DATA XREF: ROM:0020CCD8?o