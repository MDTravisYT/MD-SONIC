	dc.w byte_208950-*
	dc.w byte_20895C-MapSpr_Spring1
	dc.w byte_208962-MapSpr_Spring1
;	WARNING! Some data in the prototype points to the
;	middle of the mapping header. To edit this, please
;	redefine where this secondary mapping would be. ~ MDT
MapSpr_Spring2:
	dc.w byte_20896C-MapSpr_Spring1
	dc.w byte_208978-MapSpr_Spring1
	dc.w byte_20897E-MapSpr_Spring1
byte_208950:    dc.b    2, $F8,  $C,   0,   0, $F0,   0,  $C
	dc.b    0,   4, $F0,   0
byte_20895C:    dc.b    1,   0,  $C,   0,   0, $F0
byte_208962:    dc.b    3, $E0,  $C,   0,   0, $F0, $E8,   6
	dc.b    0,   8
byte_20896C:    dc.b  $F8,   0,  $C,   0,  $E, $F0,   2, $F0
	dc.b    3,   0, $12,   0
byte_208978:    dc.b  $F0,   3,   0, $16, $F8,   0
byte_20897E:    dc.b    1, $F0,   3,   0, $12, $F8,   3, $F0
	dc.b    3,   0, $12, $18, $F8,   9,   0, $1A
	dc.b    0, $F0,   3,   0, $20, $F8