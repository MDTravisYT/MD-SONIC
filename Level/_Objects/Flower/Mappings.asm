	dc.w byte_205E30-*      ; DATA XREF: ROM:00205632?o
		        ; ROM:00205E22?o ...
	dc.w byte_205E36-MapSpr_Flower
	dc.w byte_205E3C-MapSpr_Flower
	dc.w byte_205E42-MapSpr_Flower
	dc.w byte_205E48-MapSpr_Flower
	dc.w byte_205E54-MapSpr_Flower
	dc.w byte_205E5A-MapSpr_Flower
	dc.w byte_205E6A-MapSpr_Flower
byte_205E30:    dc.b  1,$F0, 1, 0       ; DATA XREF: ROM:MapSpr_Flower?o
	dc.b  0,$FC
byte_205E36:    dc.b  1,$F0, 1, 8       ; DATA XREF: ROM:00205E22?o
	dc.b  0,$FC
byte_205E3C:    dc.b  1,$F0, 5, 0       ; DATA XREF: ROM:00205E24?o
	dc.b  2,$F8
byte_205E42:    dc.b  1,$F0, 5, 0       ; DATA XREF: ROM:00205E26?o
	dc.b  6,$F8
byte_205E48:    dc.b  2,$E8, 9, 0       ; DATA XREF: ROM:00205E28?o
	dc.b $1C,$F4,$F8, 0
	dc.b  0,$22,$FC, 0
byte_205E54:    dc.b  1,$F0, 5, 0       ; DATA XREF: ROM:00205E2A?o
	dc.b $23,$F8
byte_205E5A:    dc.b  3,$D0,$A, 0       ; DATA XREF: ROM:00205E2C?o
	dc.b $A,$F4,$E8, 9
	dc.b  0,$1C,$F4,$F8
	dc.b  0, 0,$22,$FC
byte_205E6A:    dc.b  3,$D0,$A, 0       ; DATA XREF: ROM:00205E2E?o
	dc.b $13,$F4,$E8, 9
	dc.b  0,$1C,$F4,$F8
	dc.b  0, 0,$22,$FC