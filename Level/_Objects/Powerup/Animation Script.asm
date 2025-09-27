	dc.w byte_205A70-*      ; DATA XREF: UnusedBadnik_Init+52?o
		        ; ObjPowerup_Shield+30?o ...
	dc.w byte_205A78-AniSpr_Powerup
	dc.w byte_205A7E-AniSpr_Powerup
	dc.w byte_205A98-AniSpr_Powerup
	dc.w byte_205AB2-AniSpr_Powerup
	dc.w byte_205ACC-AniSpr_Powerup
	dc.w byte_205AD8-AniSpr_Powerup
	dc.w byte_205B12-AniSpr_Powerup
	dc.w byte_205B4C-AniSpr_Powerup
byte_205A70:    dc.b  1, 1, 0, 2, 0, 3, 0,$FF
		        ; DATA XREF: ROM:AniSpr_Powerup?o
byte_205A78:    dc.b  5, 4, 5, 6, 7,$FF ; DATA XREF: ROM:00205A60?o
byte_205A7E:    dc.b  0, 4, 4, 0, 4, 4, 0, 5, 5, 0, 5, 5, 0, 6, 6, 0, 6
		        ; DATA XREF: ROM:00205A62?o
	dc.b  6, 0, 7, 7, 0, 7, 7, 0,$FF
byte_205A98:    dc.b  0, 4, 4, 0, 4, 0, 0, 5, 5, 0, 5, 0, 0, 6, 6, 0, 6
		        ; DATA XREF: ROM:00205A64?o
	dc.b  0, 0, 7, 7, 0, 7, 0, 0,$FF
byte_205AB2:    dc.b  0, 4, 0, 0, 4, 0, 0, 5, 0, 0, 5, 0, 0, 6, 0, 0, 6
		        ; DATA XREF: ROM:00205A66?o
	dc.b  0, 0, 7, 0, 0, 7, 0, 0,$FF
byte_205ACC:    dc.b  0, 8, 9,$A,$B,$C,$B,$A, 9, 8, 0,$FF
		        ; DATA XREF: ROM:00205A68?o
byte_205AD8:    dc.b  0, 8, 8, 0, 8, 8, 0, 9, 9, 0, 9, 9, 0,$A,$A, 0,$A
		        ; DATA XREF: ROM:00205A6A?o
	dc.b $A, 0,$B,$B, 0,$B,$B, 0,$C,$C, 0,$C,$C, 0,$B,$B, 0
	dc.b $B,$B, 0,$A,$A, 0,$A,$A, 0, 9, 9, 0, 9, 9, 0, 8, 8
	dc.b  0, 8, 8, 0, 0,$FF, 0
byte_205B12:    dc.b  0, 8, 8, 0, 8, 0, 0, 9, 9, 0, 9, 0, 0,$A,$A, 0,$A
		        ; DATA XREF: ROM:00205A6C?o
	dc.b  0, 0,$B,$B, 0,$B, 0, 0,$C,$C, 0,$C, 0, 0,$B,$B, 0
	dc.b $B, 0, 0,$A,$A, 0,$A, 0, 0, 9, 9, 0, 9, 0, 0, 8, 8
	dc.b  0, 8, 0, 0, 0,$FF, 0
byte_205B4C:    dc.b  0, 8, 0, 0, 8, 0, 0, 9, 0, 0, 9, 0, 0,$A, 0, 0,$A
		        ; DATA XREF: ROM:00205A6E?o
	dc.b  0, 0,$B, 0, 0,$B, 0, 0,$C, 0, 0,$C, 0, 0,$B, 0, 0
	dc.b $B, 0, 0,$A, 0, 0,$A, 0, 0, 9, 0, 0, 9, 0, 0, 8, 0
	dc.b  0, 8, 0, 0, 0,$FF, 0