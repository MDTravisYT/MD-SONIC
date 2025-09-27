	dc.w byte_20CF60-MapSpr_Unknown1      ; DATA XREF: ROM:0020CF5A?o
		        ; ROM:0020CF5C?o ...
		        ; This data appears different to the one Devon found in R11A...
	dc.w byte_20CF75-MapSpr_Unknown1
	dc.w byte_20CF8A-MapSpr_Unknown1
	dc.w byte_20CF9F-MapSpr_Unknown1
byte_20CF60:    dc.b    4, $F0,   3,   0,   0, $F0, $F1,   3
		        ; DATA XREF: ROM:MapSpr_Unknown1?o
	dc.b    0,   0, $F8, $F2,   3,   0,   0,   0
	dc.b  $F3,   3,   0,   0,   8
byte_20CF75:    dc.b    4, $F0,  $C,   0,   4, $F0, $F8,  $C
		        ; DATA XREF: ROM:0020CF5A?o
	dc.b    0,   4, $F1,   0,  $C,   0,   4, $F2
	dc.b    8,  $C,   0,   4, $F3
byte_20CF8A:    dc.b    4, $F0,  $C,   8,   4, $F3, $F8,  $C
		        ; DATA XREF: ROM:0020CF5C?o
	dc.b    8,   4, $F2,   0,  $C,   8,   4, $F1
	dc.b    8,  $C,   8,   4, $F0
byte_20CF9F:    dc.b    2, $F0,   3,   0,   0, $F4, $F0,   3
		        ; DATA XREF: ROM:0020CF5E?o
	dc.b    0,   0,   4