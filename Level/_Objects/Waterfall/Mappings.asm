	dc.w MapSpr_Waterfall_frame1-MapSpr_Waterfall
		        ; DATA XREF: ROM:002067A2?o
		        ; ROM:MapSpr_Waterfall?t ...
	dc.w MapSpr_Waterfall_frame2-MapSpr_Waterfall
MapSpr_Waterfall_frame1:dc.b      6,   $F0,    $F
		        ; DATA XREF: ROM:MapSpr_Waterfall?t
	dcb.b 2,     0
	dc.b    $A0,   $F0,    $F
	dcb.b 2,     0
	dc.b    $C0,   $F0,    $F
	dcb.b 2,     0
	dc.b    $E0,   $F0,    $F
	dcb.b 3,     0
	dc.b    $F0,    $F
	dcb.b 2,     0
	dc.b    $20,   $F0,    $F
	dcb.b 2,     0
	dc.b    $40,     0
MapSpr_Waterfall_frame2:dc.b      6,   $F0,    $F,     0,   $10,   $A0
		        ; DATA XREF: ROM:0020698E?t
	dc.b    $F0,    $F,     0,   $10,   $C0,   $F0
	dc.b     $F,     0,   $10,   $E0,   $F0,    $F
	dc.b      0,   $10,     0,   $F0,    $F,     0
	dc.b    $10,   $20,   $F0,    $F,     0,   $10
	dc.b    $40,     0