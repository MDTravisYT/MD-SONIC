; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023
; -------------------------------------------------------------------------
; Sound definitions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Addresses
; -------------------------------------------------------------------------

; FM driver (Z80)
	if def(MAINCPU)
FMDrvQueue1	EQU	Z80RAM+$1C09		; Sound queue 1
FMDrvQueue2	EQU	Z80RAM+$1C0A		; Sound queue 2
	endif

; -------------------------------------------------------------------------
; IDs
; -------------------------------------------------------------------------

; CDDA
	rsset	2
CDDA_R1A	rs.b	1			; Palmtree Panic present
CDDA_R1C	rs.b	1			; Palmtree Panic good future
CDDA_R1D	rs.b	1			; Palmtree Panic bad future
CDDA_R3A	rs.b	1			; Collision Chaos present
CDDA_R3C	rs.b	1			; Collision Chaos good future
CDDA_R3D	rs.b	1			; Collision Chaos bad future
CDDA_R4A	rs.b	1			; Tidal Tempest present
CDDA_R4C	rs.b	1			; Tidal Tempest good future
CDDA_R4D	rs.b	1			; Tidal Tempest bad future
CDDA_R5A	rs.b	1			; Quartz Quadrant present
CDDA_R5C	rs.b	1			; Quartz Quadrant good future
CDDA_R5D	rs.b	1			; Quartz Quadrant bad future
CDDA_R6A	rs.b	1			; Wacky Workbench present
CDDA_R6C	rs.b	1			; Wacky Workbench good future
CDDA_R6D	rs.b	1			; Wacky Workbench bad future
CDDA_R7A	rs.b	1			; Stardust Speedway present
CDDA_R7C	rs.b	1			; Stardust Speedway good future
CDDA_R7D	rs.b	1			; Stardust Speedway bad future
CDDA_R8A	rs.b	1			; Metallic Madness present
CDDA_R8C	rs.b	1			; Metallic Madness good future
CDDA_R8D	rs.b	1			; Metallic Madness bad future

; -------------------------------------------------------------------------
