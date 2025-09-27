; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023, Devon 2021
; -------------------------------------------------------------------------
; System definitions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; File IDs
; -------------------------------------------------------------------------

	rsreset
FID_R11A	    rs.b	1	; Salad Plain Act 1 Present
FID_R11B	    rs.b	1	; Salad Plain Act 1 Past
FID_R11C	    rs.b	1	; Salad Plain Act 1 Good Future
FID_R11D	    rs.b	1	; Salad Plain Act 1 Bad Future
FID_SEGAM	    rs.b	1	; SEGA Screen Main
FID_SEGAS	    rs.b	1	; SEGA Screen Sub
FID_STAGESEL	    rs.b	1	; Stage select
FID_R12A	    rs.b	1	; Salad Plain Act 2 Present
FID_R12B	    rs.b	1	; Salad Plain Act 2 Past
FID_R12C	    rs.b	1	; Salad Plain Act 2 Good Future
FID_R12D	    rs.b	1	; Salad Plain Act 2 Bad Future
FID_TITLEMAIN	    rs.b	1	; Title screen (Main CPU)
FID_PCM000  	    rs.b	1	; SEGA Screen PCM Driver
FID_WARP	    rs.b	1	; Warp sequence
FID_TIMEATKMAIN	    rs.b	1	; Time attack menu (Main CPU)
FID_TIMEATKSUB	    rs.b	1	; Time attack menu (Sub CPU)
FID_IPX		    rs.b	1	; Main program
FID_OPENSTM	    rs.b	1	; Opening FMV data
FID_OPENMAIN	    rs.b	1	; Opening FMV (Main CPU)
FID_OPENSUB	    rs.b	1	; Opening FMV (Sub CPU)
FID_COMINSOON	    rs.b	1	; "Comin' Soon" screen

; -------------------------------------------------------------------------
; Sub CPU commands
; -------------------------------------------------------------------------

	rsset	1
SCMD_R11A	rs.b	1	; Load Salad Plain Act 1 Present
SCMD_R11B	rs.b	1	; Load Salad Plain Act 1 Past
SCMD_R11C	rs.b	1	; Load Salad Plain Act 1 Good Future
SCMD_R11D	rs.b	1	; Load Salad Plain Act 1 Bad Future
SCMD_SEGA	rs.b	1	; Load Mega Drive initialization
SCMD_STAGESEL	rs.b	1	; Load stage select
SCMD_R12A	rs.b	1	; Load Salad Plain Act 2 Present
SCMD_R12B	rs.b	1	; Load Salad Plain Act 2 Past
SCMD_R12C	rs.b	1	; Load Salad Plain Act 2 Good Future
SCMD_R12D	rs.b	1	; Load Salad Plain Act 2 Bad Future
SCMD_TITLE	rs.b	1	; Load title screen
SCMD_WARP	rs.b	1	; Load time warp sequence
SCMD_TIMEATK	rs.b	1	; Load time attack menu
SCMD_FADECDA	rs.b	1	; Fade out CDDA music
SCMD_R1AMUS	rs.b	1	; Play Salad Plain Present music
SCMD_TMATKMUS	rs.b	1	; Play Time Attack (R3A) music
SCMD_TITLEMUS	rs.b	1	; Play title screen music
SCMD_R1CMUS	rs.b	1	; Play Salad Plain Good Future music
SCMD_R1DMUS	rs.b	1	; Play Salad Plain Bad Future music
SCMD_R1BMUS	rs.b	1	; Play Salad Plain Past music
SCMD_UNKMUS1	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS2	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS3	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS4	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS5	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS6	rs.b	1       ; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS7	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS8	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS9	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS10	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS11	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS12	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS13	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_UNKMUS14	rs.b	1	; (Unused/Removed) Play Salad Plain Present music
SCMD_IPX	rs.b	1	; Load main program
SCMD_OPENING	rs.b	1	; Load opening FMV
SCMD_COMINSOON	rs.b	1	; Load "Comin' Soon" screen

; -------------------------------------------------------------------------

	if def(SUBCPU)

; -------------------------------------------------------------------------
; Addresses
; -------------------------------------------------------------------------

; System program
SPVariables	EQU	$7000			; Variables
SaveDataTemp	EQU	$7400			; Temporary save data buffer
SPIRQ2		EQU	$7700			; IRQ2 handler
LoadFile	EQU	$7800			; Load file
GetFileName	EQU	$7840			; Get file name
FileFunc	EQU	$7880			; File engine function handler
FileVars	EQU	$8C00			; File engine variables
; FMV
FMVPCMBUF	EQU	PRGRAM+$40000		; PCM data buffer
FMVGFXBUF	EQU	WORDRAM1M		; Graphics data buffer

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

; File engine functions
	rsreset
FFUNC_INIT	rs.b	1			; Initialize
FFUNC_OPER	rs.b	1			; Perform operation
FFUNC_STATUS	rs.b	1			; Get status
FFUNC_GETFILES	rs.b	1			; Get files
FFUNC_LOADFILE	rs.b	1			; Load file
FFUNC_FINDFILE	rs.b	1			; Find file
FFUNC_LOADFMV	rs.b	1			; Load FMV
FFUNC_RESET	rs.b	1			; Reset

; File engine operation modes
	rsreset
FMODE_NONE	rs.b	1			; No function
FMODE_GETFILES	rs.b	1			; Get files
FMODE_LOADFILE	rs.b	1			; Load file
FMODE_LOADFMV	rs.b	1			; Load FMV

; File engine statuses
FSTAT_OK	EQU	100			; OK
FSTAT_GETFAIL	EQU	-1			; File get failed
FSTAT_NOTFOUND	EQU	-2			; File not found
FSTAT_LOADFAIL	EQU	-3			; File load failed
FSTAT_READFAIL	EQU	-100			; Failed

; FMV data types
FMVT_PCM	EQU	0			; PCM data type
FMVT_GFX	EQU	1			; Graphics data type

; FMV flags
FMVF_INIT	EQU	3			; Initialized flag
FMVF_PBUF	EQU	4			; PCM buffer ID
FMVF_READY	EQU	5			; Ready flag
FMVF_SECT	EQU	7			; Reading data section 1 flag

; File data
FILENAMESZ	EQU	12			; File name length

; -------------------------------------------------------------------------
; SP variables
; -------------------------------------------------------------------------

	rsset	SPVariables
curPCMDriver	rs.l	1			; Current PCM driver
ssFlagsCopy	rs.b	1			; Special stage flags copy
pcmDrvFlags	rs.b	1			; PCM driver flags
		rs.b	$400-__rs
SPVARSSZ	rs.b	1			; Size of structure

; -------------------------------------------------------------------------
; File engine variables structure
; -------------------------------------------------------------------------

	rsreset
feOperMark	rs.l	1			; Operation bookmark
feSector	rs.l	1			; Sector to read from
feSectorCnt	rs.l	1			; Number of sectors to read
feReturnAddr	rs.l	1			; Return address for CD read functions
feReadBuffer	rs.l	1			; Read buffer address
feReadTime	rs.b	0			; Time of read sector
feReadMin	rs.b	1			; Read sector minute
feReadSec	rs.b	1			; Read sector second
feReadFrame	rs.b	1			; Read sector frame
		rs.b	1
feDirSectors	rs.b	0			; Directory size in sectors
feFileSize	rs.l	1			; File size buffer
feOperMode	rs.w	1			; Operation mode
feStatus	rs.w	1			; Status code
feFileCount	rs.w	1			; File count
feWaitTime	rs.w	1			; Wait timer
feRetries	rs.w	1			; Retry counter
feSectorsRead	rs.w	1			; Number of sectors read
feCDC		rs.b	1			; CDC mode
feSectorFrame	rs.b	1			; Sector frame
feFileName	rs.b	FILENAMESZ		; File name buffer
		rs.b	$100-__rs
feFileList	rs.b	$1000			; File list
feDirReadBuf	rs.b	$900			; Directory read buffer
feFMVSectFrame	rs.w	1			; FMV sector frame
feFMVDataType	rs.b	1			; FMV read data type
feFMV		rs.b	1			; FMV flags
feFMVFailCount	rs.b	1			; FMV fail counter
FILEVARSSZ	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; File entry structure
; -------------------------------------------------------------------------

	rsreset
fileName	rs.b	FILENAMESZ		; File name
		rs.b	$17-__rs
fileFlags	rs.b	1			; File flags
fileSector	rs.l	1			; File sector
fileLength	rs.l	1			; File size
FILEENTRYSZ	rs.b	0			; Size of structure
	endif

; -------------------------------------------------------------------------
