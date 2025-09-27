; -------------------------------------------------------------------------
; Sonic CD (Prototype) Ver 0.02 Disassembly
; By KatKuriN 2023
; -------------------------------------------------------------------------
; Main CPU global variables
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

; Time zones
	rsreset
TIME_PAST		rs.b	1		; Past
TIME_PRESENT		rs.b	1		; Present
TIME_FUTURE		rs.b	1		; Future

; -------------------------------------------------------------------------
; Variables
;
; Unlike the final game's disassembly, I didn't really go through and make
; these easily shiftable because for one, it's a pain in the ass, and two,
; this shouldn't be used for hacking at all. This for research, anyways.
;
; WORKRAM+$500?, LoRAM 0xFF0000-0xFF7FFF
; -------------------------------------------------------------------------


timeAttackMode          EQU $FFFF0580
ipxVSync                EQU $00FF0583

unkBuffer               EQU $00FF1000
levelRestart            EQU $00FF1202
levelFrames             EQU $00FF1204
debugObject             EQU $00FF1206
debugMode               EQU $00FF1208

levelVIntCounter        EQU $00FF120C
zone                    EQU $00FF1210
act                     EQU $00FF1211
lives                   EQU $00FF1212
drownTimer              EQU $00FF1214
usePlayer2              EQU $00FF1219
timeOver                EQU $00FF121A
livesFlags              EQU $00FF121B
updateHUDLives		EQU $00FF121C
updateHUDRings	        EQU $00FF121D
updateHUDTime		EQU $00FF121E
updateHUDScore		EQU $00FF121F
rings			EQU $00FF1220
time    		EQU $00FF1222
timeMinutes             EQU $00FF1223
timeSeconds             EQU $00FF1224
timeFrames              EQU $00FF1225              
score                   EQU $00FF1226


plcLoadFlags            EQU $00FF122A
shield                  EQU $00FF122C
invincible              EQU $00FF122D
speedShoes              EQU $00FF122E
timeWarp                EQU $00FF122F
spawnMode		EQU $00FF1230

savedSpawnMode          EQU $00FF1231 
savedX                  EQU $00FF1232 
savedY                  EQU $00FF1234        
savedRings              EQU $00FF1236     
savedTime               EQU $00FF1238                                               
savedEventRoutine       EQU $00FF123C                                         
timeZone                EQU $00FF123D
savedBtmBound           EQU $00FF123E   
savedCamX               EQU $00FF1240       
savedCamY               EQU $00FF1242     
savedCamBgX             EQU $00FF1244        
savedCamBgY             EQU $00FF1246    
savedCamBg2X            EQU $00FF1248   
savedCamBg2Y            EQU $00FF124A  
savedCamBg3X            EQU $00FF124C   
savedCamBg3Y            EQU $00FF124E  
savedWaterHeight        EQU $00FF1250                                             
savedWaterRoutine       EQU $00FF1252                                           
savedWaterFull          EQU $00FF1253 
savedLivesFlags         EQU $00FF1254 

warpSpawnMode           EQU $00FF1255
warpX                   EQU $00FF1256
warpY                   EQU $00FF1258
warpEventRoutine        EQU $00FF125A
warpBtmBound            EQU $00FF125C
warpCamX                EQU $00FF125E
warpCamY                EQU $00FF1260
warpCamBgX              EQU $00FF1262
warpCamBgY              EQU $00FF1264
warpCamBg2X             EQU $00FF1266
warpCamBg2Y             EQU $00FF1268
warpCamBg3X             EQU $00FF126A
warpCamBg3Y             EQU $00FF126C
warpWaterHeight         EQU $00FF126E
warpWaterRoutine        EQU $00FF1270
warpWaterFull           EQU $00FF1271
timeStopTimer           EQU $00FF1278
goodFuture              EQU $00FF127A
powerup	                EQU $00FF127B

logSpikeAnimTimer       EQU $00FF12C0
logSpikeAnimFrame       EQU $00FF12C1
ringAnimTimer           EQU $00FF12C2
ringAnimFrame           EQU $00FF12C3
unkAnimTimer            EQU $00FF12C4
unkAnimFrame            EQU $00FF12C5
ringLossAnimTimer       EQU $00FF12C6
ringLossAnimFrame       EQU $00FF12C7
ringLossAnimAccum       EQU $00FF12C8

sectionID               EQU $00FF12F4

camXCopy		EQU $00FF1310
camYCopy                EQU $00FF1314
camXBgCopy              EQU $00FF1318
camYBgCopy              EQU $00FF131C
camXBg2Copy             EQU $00FF1320          
camYBg2Copy             EQU $00FF1324
camXBg3Copy             EQU $00FF1328
camYBg3Copy             EQU $00FF132C
scrollFlagsCopy		EQU $00FF1330
scrollFlagsBgCopy       EQU $00FF1332         
scrollFlagsBg2Copy      EQU $00FF1334
scrollFlagsBg3Copy      EQU $00FF1336
debugAngle              EQU $00FF13EC           
debugAngleShift         EQU $00FF13ED 
debugQuadrant           EQU $00FF13EE 
debugFloorDist          EQU $00FF13EF 
demoMode                EQU $00FF13F0
s1CreditsIndex          EQU $00FF13F4
versionCache            EQU $00FF4000
debugCheat              EQU $00FF13FA
initFlag                EQU $00FF4004
lockOnFlag				EQU	$00FF4008

savedObjFlags           EQU $00FF1400                ; ds.b $180
flowerPosBuf            EQU $00FF1580                ; ds.b $300
flowerCount             EQU $00FF1880
debugBlock              EQU $00FF1884
cczNoBumper             EQU $00FF1886
debugSubtype2           EQU $00FF188A

aniArtBuffer            EQU $00FF1900                ; ds.b $480   

LOCK_LAYOUT		EQU	$00008+$100000
LOCK_CHUNK		EQU	$00200+$100000
LOCK_ART		EQU	$10200+$100000
LOCK_BLOCK		EQU	$18200+$100000
LOCK_PAL		EQU	$1C200+$100000
LOCK_COLLISION	EQU	$1C260+$100000

; -------------------------------------------------------------------------
; RAM
; WORKRAM+$FF00A000, HiRAM 0xFF80000-0xFFFFFF
; -------------------------------------------------------------------------

VARSSTART               EQU $FFFF8000                 ; Start of HiRAM vars
                        ; ...Seems reserved for mostly levels



