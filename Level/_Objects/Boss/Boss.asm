; ---------------------------------------------------------------------------
; Partially documented HVC-001 Boss program from Sonic CD 510
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Boss defines (Inherited from object code)
; ---------------------------------------------------------------------------

OBJID_BOSSMAIN:      equ $2A
OBJID_BOSSBODY:      equ $2B
OBJID_BOSSTHIGH:     equ $2C
OBJID_BOSSLEG:       equ $2D
OBJID_BOSSFEET:      equ $2E
OBJID_BOSSSHOULDERS: equ $2F
OBJID_BOSSUPARM:     equ $30
OBJID_BOSSLOARM:     equ $31
OBJID_BOSSHAND:      equ $32
OBJID_BOSSPINCER:    equ $33

PLCID_BOSSART:       equ $7     ; default
PALID_BOSS:          equ $A

bossFlags:			 equ $FFFFF7A7     ; you can tell i just gave up

                    rsreset
obj.ID:             rs.b 1
obj.RenderFlags:    rs.b 1
obj.Tile:           rs.w 1
obj.Map:            rs.l 1
obj.X:              rs.w 1
obj.YScr:           rs.w 1
obj.Y:              rs.w 1
obj.YSub:           rs.w 1
obj.XSpeed:         rs.w 1
obj.YSpeed:         rs.w 1
obj.Inertia:        rs.w 1
obj.YRad:           rs.b 1
obj.XRad:           rs.b 1
obj.Priority:       rs.b 1
obj.Width:          rs.b 1
obj.Frame:          rs.b 1
obj.AnimFrame:      rs.b 1
obj.Anim:           rs.b 1
obj.AnimPrevious:   rs.b 1
obj.FrameTimer:     rs.b 1
obj.USER_1F:        rs.b 1
obj.ColInfo:        rs.b 1
obj.ColStatus:      rs.b 1
obj.Status:         rs.b 1
obj.Respawn:        rs.b 1
obj.Action:         rs.b 1
obj.SubAction:      rs.b 1
obj.Angle:          rs.b 1
obj.USER_27:        rs.b 1
obj.Argument:       rs.b 1
obj.Layer:          rs.b 1
obj.USER_2A:        rs.b 1
obj.USER_2B:        rs.b 1
obj.ChildType:      rs.b 1
obj.USER_2D:        rs.b 1
obj.Parent:         rs.b 1
obj.USER_2F:        rs.b 1
obj.Child:          rs.b 1
obj.USER_31:        rs.b 1
obj.USER_32:        rs.b 1
obj.USER_33:        rs.b 1
obj.USER_34:        rs.b 1
obj.field_35:       rs.b 1
obj.field_36:       rs.b 1
obj.field_37:       rs.b 1
obj.field_38:       rs.b 1
obj.field_39:       rs.b 1
obj.field_3A:       rs.b 1
obj.field_3B:       rs.b 1
obj.USER_3C:        rs.b 1
obj.field_3D:       rs.b 1
obj.field_3E:       rs.b 1
obj.field_3F:       rs.b 1
Size:               rs.b 1
;obj             ends


; ---------------------------------------------------------------------------
; Initial boss program itself
; ---------------------------------------------------------------------------
objBossMain:
                bsr.w   loc_20AE08
                bsr.w   _bossMoveCamUp
                bsr.w   loc_20AEFE
                bsr.w   loc_20AE4A
                moveq   #0,d0
                move.b  obj.Action(a0),d0
                move.w  .Index(pc,d0.w),d0
                jsr     .Index(pc,d0.w)
                lea     (AniSpr_BossEggman).l,a1
                jsr     (AnimateObject).l
                jmp     DrawObject
; ---------------------------------------------------------------------------
.Index:
                dc.w Boss_Init-.Index
                dc.w Boss_SetLevelBounds-.Index
                dc.w BossMain_20B4C2-.Index
                dc.w BossMain_20B544-.Index
                dc.w Boss_Defeated-.Index
                dc.w BossMain_20B66E-.Index
                dc.w Boss_CenterCam-.Index
                dc.w Boss_Setup-.Index
; ---------------------------------------------------------------------------

loc_20AE08:
                tst.b   obj.USER_2A(a0)
                beq.s   locret_20AE2A
                subq.b  #1,obj.USER_2A(a0)
                bne.s   locret_20AE2A
                clr.b   obj.Frame(a0)
                clr.b   obj.AnimFrame(a0)
                clr.b   obj.FrameTimer(a0)
                clr.b   obj.USER_1F(a0)
                move.b  #0,obj.Anim(a0)

locret_20AE2A:
                rts
; ---------------------------------------------------------------------------

_bossMoveCamUp:
                tst.b   obj.field_35(a0)
                beq.s   locret_20AE48
                subq.b  #1,obj.field_35(a0)
                move.w  #2,d0
                btst    #0,obj.field_35(a0)
                beq.s   loc_20AE44
                neg.w   d0

loc_20AE44:
                add.w   d0,(camYCenter).w

locret_20AE48:
                rts
; ---------------------------------------------------------------------------

loc_20AE4A:
                tst.b   obj.USER_34(a0)
                bne.s   loc_20AE5A
                btst    #3,obj.ChildType(a0)
                bne.s   loc_20AE68
                rts
; ---------------------------------------------------------------------------

loc_20AE5A:
                subq.b  #1,obj.USER_34(a0)
                bne.s   locret_20AE66
                jsr     (loc_20B058).l

locret_20AE66:
                rts
; ---------------------------------------------------------------------------

loc_20AE68:
                movea.l a0,a1
                tst.b   obj.ColInfo(a1)
                beq.w   loc_20AF3E
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                movea.w obj.Child(a1),a1
                tst.b   obj.ColInfo(a1)
                beq.w   loc_20AF3E
                movea.w obj.Child(a1),a1
                tst.b   obj.ColInfo(a1)
                beq.w   loc_20AF3E
                movea.w obj.Child(a0),a1
                movea.w obj.USER_32(a1),a1
                movea.w obj.Child(a1),a1
                tst.b   obj.ColInfo(a1)
                beq.w   loc_20AF3E
                movea.w obj.Child(a1),a1
                tst.b   obj.ColInfo(a1)
                beq.w   loc_20AF3E
                cmpi.b  #3,obj.USER_2B(a0)
                beq.s   loc_20AEC4
                cmpi.b  #2,obj.USER_2B(a0)
                beq.s   loc_20AEDC
                rts
; ---------------------------------------------------------------------------

loc_20AEC4:
                movea.w obj.USER_32(a0),a1
                movea.w obj.USER_32(a1),a1
                movea.w obj.Child(a1),a1
                movea.w obj.Child(a1),a1
                tst.b   obj.ColInfo(a1)
                beq.w   loc_20AEF6

loc_20AEDC:
                movea.w obj.USER_32(a0),a1
                movea.w obj.Child(a1),a1
                movea.w obj.Child(a1),a1
                movea.w obj.Child(a1),a1
                tst.b   obj.ColInfo(a1)
                beq.w   loc_20AEF6
                rts
; ---------------------------------------------------------------------------

loc_20AEF6:
                bsr.w   _bossGetSonicObj
                bra.w   loc_20B058
; ---------------------------------------------------------------------------

loc_20AEFE:
                tst.b   obj.Anim(a0)
                bne.s   locret_20AF1E
                lea     (objPlayerSlot).w,a1
                bsr.w   loc_20AF10
                lea     (objPlayerSlot2).w,a1

loc_20AF10:
                tst.w   $30(a1)
                bne.s   loc_20AF20
                cmpi.b  #6,obj.Action(a1)
                beq.s   loc_20AF20

locret_20AF1E:
                rts
; ---------------------------------------------------------------------------

loc_20AF20:
                clr.b   obj.Frame(a0)
                clr.b   obj.AnimFrame(a0)
                clr.b   obj.FrameTimer(a0)
                clr.b   obj.USER_1F(a0)
                move.b  #1,obj.Anim(a0)
                move.b  #$3C,obj.USER_2A(a0) ; '<'
                rts
; ---------------------------------------------------------------------------

loc_20AF3E:
                move.b  #$14,obj.USER_34(a0)
                bsr.w   _bossGetSonicObj
                clr.b   obj.Frame(a0)
                clr.b   obj.AnimFrame(a0)
                clr.b   obj.FrameTimer(a0)
                clr.b   obj.USER_1F(a0)
                move.b  #2,obj.Anim(a0)
                move.b  #$78,obj.USER_2A(a0) ; 'x'
                subq.b  #1,obj.USER_2B(a0)
                beq.w   loc_20AF92
                cmpi.b  #2,obj.USER_2B(a0)
                beq.w   loc_20AF84
                movea.w obj.USER_32(a0),a1
                bset    #6,obj.ChildType(a1)
                bra.w   loc_20B08A
; ---------------------------------------------------------------------------

loc_20AF84:
                movea.w obj.USER_32(a0),a1
                bset    #5,obj.ChildType(a1)
                bra.w   loc_20B07E
; ---------------------------------------------------------------------------

loc_20AF92:
                clr.b   obj.Frame(a0)
                clr.b   obj.AnimFrame(a0)
                clr.b   obj.FrameTimer(a0)
                clr.b   obj.USER_1F(a0)
                move.b  #2,obj.Anim(a0)
                clr.b   obj.USER_2A(a0)
                bclr    #3,obj.ChildType(a0)
                clr.b   obj.SubAction(a0)
                move.b  #6,obj.Action(a0)
                clr.b   obj.ColInfo(a0)
                clr.b   obj.ColStatus(a0)
                movea.w obj.USER_32(a0),a1
                move.b  #4,obj.Action(a1)
                movea.w obj.Child(a0),a1
                move.b  #$E,obj.Action(a1)
                movea.w obj.Child(a1),a1
                bsr.w   loc_20AFE8
                movea.w obj.Child(a0),a1
                movea.w obj.USER_32(a1),a1

loc_20AFE8:
                move.b  #$18,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #$E,obj.Action(a1)
                clr.b   obj.ColInfo(a1)
                clr.b   obj.ColStatus(a1)
                movea.w obj.Child(a1),a1
                move.b  #$C,obj.Action(a1)
                clr.b   obj.ColInfo(a1)
                clr.b   obj.ColStatus(a1)
                rts
; ---------------------------------------------------------------------------

_bossGetSonicObj:
                lea     (objPlayerSlot).w,a2
                cmpi.b  #5,obj.ColStatus(a1)
                beq.s   .CollideSonic
                lea     (objPlayerSlot2).w,a2

.CollideSonic:
                move.w  #$400,d1
                move.w  #$FC00,d2
                move.w  #$400,obj.Inertia(a2)
                btst    #1,obj.Status(a2)
                bne.s   loc_20B042
                eori.b  #$80,obj.Angle(a2)
                moveq   #0,d2

loc_20B042:
                move.w  obj.X(a2),d0
                cmp.w   obj.X(a1),d0
                bcc.s   loc_20B04E
                neg.w   d1

loc_20B04E:
                move.w  d1,obj.XSpeed(a2)
                move.w  d2,obj.YSpeed(a2)
                rts
; ---------------------------------------------------------------------------

loc_20B058:
                cmpi.b  #3,obj.USER_2B(a0)
                beq.s   loc_20B072
                cmpi.b  #2,obj.USER_2B(a0)
                beq.s   loc_20B07E
                cmpi.b  #1,obj.USER_2B(a0)
                beq.s   loc_20B08A
                rts
; ---------------------------------------------------------------------------

loc_20B072:
                movea.w obj.USER_32(a0),a1
                movea.w obj.USER_32(a1),a1
                bsr.w   loc_20B0E4

loc_20B07E:
                movea.w obj.USER_32(a0),a1
                movea.w obj.Child(a1),a1
                bsr.w   loc_20B0E4

loc_20B08A:
                move.b  #$FC,obj.ColInfo(a0)
                move.b  #2,obj.ColStatus(a0)
                movea.w obj.Child(a0),a2
                movea.w $30(a2),a1
                movea.w obj.Child(a1),a1
                move.b  #$BD,obj.ColInfo(a1)
                move.b  #2,obj.ColStatus(a1)
                movea.w obj.Child(a1),a1
                move.b  #$BE,obj.ColInfo(a1)
                move.b  #2,obj.ColStatus(a1)
                movea.w $32(a2),a1
                movea.w obj.Child(a1),a1
                move.b  #$BD,obj.ColInfo(a1)
                move.b  #2,obj.ColStatus(a1)
                movea.w obj.Child(a1),a1
                move.b  #$BE,obj.ColInfo(a1)
                move.b  #2,obj.ColStatus(a1)
                rts
; ---------------------------------------------------------------------------

loc_20B0E4:
                movea.w obj.Child(a1),a1
                movea.w obj.Child(a1),a1
                move.b  #$FF,obj.ColInfo(a1)
                move.b  #2,obj.ColStatus(a1)
                rts
; ---------------------------------------------------------------------------

Boss_Init:
                moveq   #PLCID_BOSSART,d0
                jsr     (LoadPLC).l
                move.b  #1,(bossActive).w
                clr.b   obj.Status(a0)
                move.b  #2,obj.Action(a0)
                move.b  #4,obj.RenderFlags(a0)
                move.b  #6,obj.Priority(a0)
                move.b  #$14,obj.Width(a0)
                move.b  #8,obj.YRad(a0)
                move.w  #$411,obj.Tile(a0)
                move.l  #MapSpr_BossEggman,obj.Map(a0)
                move.b  #1,obj.Anim(a0)
                clr.b   obj.Frame(a0)
                clr.b   obj.AnimFrame(a0)
                clr.b   obj.FrameTimer(a0)
                clr.b   obj.USER_1F(a0)
                move.w  #$C52,obj.X(a0)
                move.w  #$78,obj.Y(a0) ; 'x'
                movem.l d7-a7,-(sp)
                move.w  #PALID_BOSS,d0
                jsr     (LoadPalette).l
                movem.l (sp)+,d7-a7
                rts
; End of function objBossMain


; =============== S U B R O U T I N E =======================================


_bossFindSlot:
                jsr     (FindObjSlot).l
                bne.w   .NoneFound
                move.w  obj.X(a0),obj.X(a1)
                move.w  obj.Y(a0),obj.Y(a1)
                moveq   #0,d0

.NoneFound:
                rts
; End of function _bossFindSlot


; =============== S U B R O U T I N E =======================================


_bossSpawnParts:

boss.Parent     =  $2E

                movea.l a0,a3           ; Start with the body
                                        ; Store parent object offset
                bsr.s   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a1,obj.Child(a3)
                move.w  a3,obj.Parent(a1)
                move.b  #6,obj.Priority(a1)
                move.b  #OBJID_BOSSBODY,obj.ID(a1)
                movea.l a1,a3
                movea.l a1,a4           ; a4 = Body pointer
                bsr.s   _bossFindSlot   ; First leg
                bne.w   .NoSlotFound
                move.w  a1,obj.Child(a3)
                move.w  a3,obj.Parent(a1)
                move.b  #6,obj.Priority(a1)
                move.b  #OBJID_BOSSTHIGH,obj.ID(a1)
                movea.l a1,a3
                bsr.s   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a1,obj.Child(a3)
                move.w  a3,boss.Parent(a1)
                move.b  #3,obj.Priority(a1)
                move.b  #OBJID_BOSSLEG,obj.ID(a1)
                movea.l a1,a3
                bsr.s   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a1,obj.Child(a3)
                move.w  a3,obj.Parent(a1)
                move.b  #2,obj.Priority(a1)
                move.b  #OBJID_BOSSFEET,obj.ID(a1)
                movea.w a4,a3           ; Set body as child to legs
                move.w  a3,obj.Child(a1)
                bsr.w   _bossFindSlot   ; Second leg
                bne.w   .NoSlotFound
                move.w  a1,obj.USER_32(a3)
                move.w  a3,obj.Parent(a1)
                move.b  #7,obj.Priority(a1)
                move.b  #OBJID_BOSSTHIGH,obj.ID(a1)
                bset    #2,obj.ChildType(a1)
                movea.l a1,a3
                bsr.w   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a1,obj.Child(a3)
                move.w  a3,obj.Parent(a1)
                move.b  #6,obj.Priority(a1)
                move.b  #OBJID_BOSSLEG,obj.ID(a1)
                bset    #2,obj.ChildType(a1)
                movea.l a1,a3
                bsr.w   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a1,obj.Child(a3)
                move.w  a3,obj.Parent(a1)
                move.b  #5,obj.Priority(a1)
                move.b  #OBJID_BOSSFEET,obj.ID(a1)
                bset    #2,obj.ChildType(a1)
                movea.l a1,a3
                movea.w a4,a3           ; Get body parent again
                move.w  a3,obj.Child(a1)
                bsr.w   _bossFindSlot   ; Spawn the "shoulders"
                                        ; Controls both arms pos. at once
                bne.w   .NoSlotFound
                move.w  a3,obj.Parent(a1)
                movea.w obj.Parent(a3),a3
                move.w  a1,obj.USER_32(a3)
                move.b  #3,obj.Priority(a1)
                move.b  #OBJID_BOSSSHOULDERS,obj.ID(a1)
                movea.l a1,a3
                bsr.w   _bossFindSlot   ; Spawn arm 1
                bne.w   .NoSlotFound
                move.w  a1,obj.Child(a3)
                move.b  #$80,obj.USER_2A(a1)
                move.w  a3,obj.Parent(a1)
                move.w  a1,obj.Child(a3)
                move.b  #5,obj.Priority(a1)
                move.b  #OBJID_BOSSUPARM,obj.ID(a1)
                movea.l a1,a3
                bsr.w   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a3,obj.Parent(a1)
                move.w  a1,obj.Child(a3)
                move.b  #4,obj.Priority(a1)
                move.l  #MapSpr_BossArm1,obj.Map(a1)
                move.b  #OBJID_BOSSLOARM,obj.ID(a1)
                movea.l a1,a3
                bsr.w   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a3,$2E(a1)
                move.w  a1,obj.Child(a3)
                move.b  #3,obj.Priority(a1)
                move.b  #OBJID_BOSSHAND,obj.ID(a1)
                movea.l a1,a3
                bsr.w   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a3,$2E(a1)
                move.w  a1,obj.Child(a3)
                move.b  #2,obj.Priority(a1)
                move.b  #OBJID_BOSSPINCER,obj.ID(a1)
                move.w  a4,obj.Child(a1)
                bsr.w   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a3,obj.Parent(a1)
                move.w  a1,obj.USER_32(a3)
                move.b  #2,obj.Priority(a1)
                move.b  #OBJID_BOSSPINCER,obj.ID(a1)
                bset    #4,obj.ChildType(a1)
                move.w  a4,obj.Child(a1)
                movea.w obj.Parent(a3),a3
                movea.w obj.Parent(a3),a3
                movea.w obj.Parent(a3),a3
                bsr.w   _bossFindSlot   ; Now spawn arm 2
                bne.w   .NoSlotFound
                move.w  a1,obj.USER_32(a3)
                move.w  a3,obj.Parent(a1)
                move.b  #7,obj.Priority(a1)
                move.b  #OBJID_BOSSUPARM,obj.ID(a1)
                bset    #2,obj.ChildType(a1)
                movea.l a1,a3
                bsr.w   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a3,obj.Parent(a1)
                move.w  a1,obj.Child(a3)
                move.b  #7,obj.Priority(a1)
                move.l  #MapSpr_BossArm2,obj.Map(a1)
                move.b  #OBJID_BOSSLOARM,obj.ID(a1)
                bset    #2,obj.ChildType(a1)
                movea.l a1,a3
                bsr.w   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a3,obj.Parent(a1)
                move.w  a1,obj.Child(a3)
                move.b  #7,obj.Priority(a1)
                move.b  #OBJID_BOSSHAND,obj.ID(a1)
                bset    #2,obj.ChildType(a1)
                movea.l a1,a3
                bsr.w   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a3,obj.Parent(a1)
                move.w  a1,obj.Child(a3)
                move.b  #6,obj.Priority(a1)
                move.b  #OBJID_BOSSPINCER,obj.ID(a1)
                bset    #2,obj.ChildType(a1)
                move.w  a4,obj.Child(a1)
                bsr.w   _bossFindSlot
                bne.w   .NoSlotFound
                move.w  a3,obj.Parent(a1)
                move.w  a1,obj.USER_32(a3)
                move.b  #6,obj.Priority(a1)
                move.b  #OBJID_BOSSPINCER,obj.ID(a1)
                bset    #2,obj.ChildType(a1)
                bset    #4,obj.ChildType(a1)
                move.w  a4,obj.Child(a1)
                move.b  #3,obj.USER_2B(a0)
                jsr     (loc_20B058).l

.NoSlotFound:
                rts
; End of function _bossSpawnParts


; =============== S U B R O U T I N E =======================================


Boss_SetLevelBounds:
                move.w  #$AC0,d0
                move.w  d0,(rightBound).w
                move.w  d0,(destRightBound).w
                bsr.w   _bossGetPlayer
                cmpi.w  #$A6A,8(a1)
                blt.s   locret_20B472
                move.w  8(a1),d0
                subi.w  #$A0,d0
                cmp.w   (leftBound).w,d0
                blt.s   locret_20B472
                cmpi.w  #$B60,8(a1)
                blt.s   loc_20B46A
                move.b  #$C,$24(a0)
                move.w  #$AC0,d0
                move.w  d0,(rightBound).w
                move.w  d0,(destRightBound).w
                move.w  #$AC0,d0

loc_20B46A:
                move.w  d0,(leftBound).w
                move.w  d0,(destLeftBound).w

locret_20B472:
                rts
; End of function Boss_SetLevelBounds


; =============== S U B R O U T I N E =======================================


Boss_CenterCam:
                addq.w  #6,(camYCenter).w
                cmpi.w  #$C8,(camYCenter).w
                bge.s   .Centered
                rts
; ---------------------------------------------------------------------------

.Centered:
                move.w  #S1bgm_Boss,d0
                jsr     (PlayFMSound).l
                move.b  #1,(bossFlags).w
                move.b  #$E,obj.Action(a0)
                rts
; End of function Boss_CenterCam


; =============== S U B R O U T I N E =======================================


Boss_Setup:
                addq.b  #1,obj.USER_2B(a0)
                cmpi.b  #$3C,obj.USER_2B(a0) ; '<'
                bne.s   locret_20B4C0
                clr.b   obj.USER_2B(a0)
                move.b  #4,obj.Action(a0)
                move.w  #$BD2,obj.X(a0)
                move.w  #$78,obj.Y(a0) ; 'x'
                bsr.w   _bossSpawnParts

locret_20B4C0:
                rts
; End of function Boss_Setup


; =============== S U B R O U T I N E =======================================


BossMain_20B4C2:
                movea.w $30(a0),a1
                bclr    #0,$2C(a1)
                beq.s   locret_20B52E
                cmpi.b  #2,$25(a0)
                bne.s   loc_20B502
                move.w  #0,$1C(a0)
                clr.b   $1A(a0)
                clr.b   $1B(a0)
                clr.b   $1E(a0)
                clr.b   $1F(a0)
                move.b  #3,$2B(a0)
                bset    #3,$2C(a0)
                jsr     (loc_20B058).l
                movea.w $30(a0),a1

loc_20B502:
                addq.b  #2,$25(a0)
                moveq   #0,d0
                bclr    #1,$2C(a1)

loc_20B50E:
                lea     (BossInfoUnk1).l,a2
                move.b  $25(a0),d0
                adda.w  d0,a2
                tst.b   (a2)
                bge.s   loc_20B526
                move.b  #6,$25(a0)
                bra.s   loc_20B50E
; ---------------------------------------------------------------------------

loc_20B526:
                move.b  (a2)+,$24(a1)
                move.b  (a2),$2D(a1)

locret_20B52E:
                rts
; End of function BossMain_20B4C2


; =============== S U B R O U T I N E =======================================


; ---------------------------------------------------------------------------

BossInfoUnk1:
                dc.w $200
                dc.w $400
                dc.w $600
                dc.w $805
                dc.w $A06
                dc.w $C0A
                dc.w $80A
                dc.w $1032
                dc.w $A0A
                dc.w -1

; ---------------------------------------------------------------------------

BossMain_20B544:
                addq.b  #1,obj.USER_2B(a0)
                bsr.w   _bossDefeatedExplode
                cmpi.b  #$5E,obj.USER_2B(a0) ; '^'
                bne.s   loc_20B580
                move.w  obj.X(a0),obj.USER_3C(a0)
                move.w  obj.Y(a0),obj.XSpeed(a0)
                move.b  #3,obj.Anim(a0)
                clr.b   obj.Frame(a0)
                clr.b   obj.AnimFrame(a0)
                clr.b   obj.FrameTimer(a0)
                clr.b   obj.USER_1F(a0)
                movea.w obj.Child(a0),a1
                bset    #0,$2C(a1)

loc_20B580:
                cmpi.b  #$78,obj.USER_2B(a0) ; 'x'
                bcs.s   locret_20B59E
                clr.b   obj.USER_2B(a0)
                move.b  #8,obj.Action(a0)
                move.b  #$20,obj.Width(a0) ; ' '
                move.b  #$20,obj.YRad(a0) ; ' '

locret_20B59E:
                rts


; =============== S U B R O U T I N E =======================================


Boss_Defeated:
                tst.b   obj.SubAction(a0)
                beq.w   loc_20B5DA
                move.w  obj.field_38(a0),d0
                sub.w   d0,obj.Y(a0)
                addq.b  #3,obj.USER_2B(a0)
                move.b  obj.USER_2B(a0),d0
                jsr     (CalcSine).l
                asr.w   #5,d0
                move.w  d0,obj.field_38(a0)
                add.w   d0,obj.Y(a0)
                addi.l  #$28000,obj.X(a0)
                cmpi.w  #$CA0,obj.X(a0)
                bge.s   _bossReplayLevelMusic
                rts

loc_20B5DA:
                addq.b  #1,obj.USER_2B(a0)
                move.w  obj.X(a0),d0
                move.w  obj.Y(a0),d1
                movem.w d0-d1,-(sp)
                move.w  obj.USER_3C(a0),obj.X(a0)
                move.w  obj.XSpeed(a0),obj.Y(a0)
                bsr.w   _bossDefeatedExplode
                movem.w (sp)+,d0-d1
                move.w  d0,obj.X(a0)
                move.w  d1,obj.Y(a0)
                addi.l  #$8000,obj.X(a0)
                subi.l  #$20000,obj.Y(a0)
                cmpi.w  #$158,obj.Y(a0)
                bgt.s   locret_20B644
                addq.b  #1,obj.SubAction(a0)
                clr.b   obj.Frame(a0)
                clr.b   obj.AnimFrame(a0)
                clr.b   obj.FrameTimer(a0)
                clr.b   obj.USER_1F(a0)
                move.b  #4,obj.Anim(a0)
                move.b  #$40,obj.USER_2B(a0) ; '@'
                move.w  #8,obj.field_38(a0)

locret_20B644:
                rts
; ---------------------------------------------------------------------------

_bossReplayLevelMusic:
                clr.b   obj.USER_2B(a0)
                move.w  #$83,d0         ; Good Future music
                tst.b   (goodFuture).l
                beq.s   loc_20B65A
                move.w  #$83,d0         ; Bad Future music

loc_20B65A:
                jsr     (PlayFMSound).l
                clr.b   (bossFlags).w
                clr.b   (bossActive).w
                move.b  #$A,obj.Action(a0)

BossMain_20B66E:
                lea     (word_2025FA).l,a1
                move.w  (a1)+,d0
                move.w  (a1)+,d1
                addq.w  #6,(rightBound).w
                addq.w  #6,(destRightBound).w
                cmp.w   (rightBound).w,d1
                ble.s   loc_20B68A
                addq.l  #4,sp
                rts

loc_20B68A:
                move.w  d1,(rightBound).w
                move.w  d1,(destRightBound).w
                addq.l  #4,sp
                moveq   #4,d0	;	load signpost art
                jsr     (LoadPLC).l
                jmp     DeleteObject

; ---------------------------------------------------------------------------
; RELOCATED DATA FROM INITBOUNDS/LEVELSIZELOAD (0510)
;
; Boss uses these parameters for calculating camera-related things
; YOU MAY NEED TO ADJUST THESE OR POINT THEM OVER TO THE DATA AT ".CamBounds"
; IN "R11B Act 1 Past.asm"
; ---------------------------------------------------------------------------

;LevelInitBoundries:
                dc.w 4
word_2025FA:    dc.w 0
                dc.w $D97
                dc.w 0
                dc.w $310
                dc.w $60
word_202604:    dc.w $50
                dc.w $3B0
                dc.w $EA0
                dc.w $46C
                dc.w $1750
                dc.w $BD
                dc.w $A00
                dc.w $62C
                dc.w $BB0
                dc.w $4C
                dc.w $1570
                dc.w $16C
                dc.w $1B0
                dc.w $72C
                dc.w $1400
                dc.w $2AC

; ---------------------------------------------------------------------------


objBossBody:
                moveq   #0,d0
                move.b  obj.Action(a0),d0
                move.w  .Index(pc,d0.w),d0
                jsr     .Index(pc,d0.w)
                jmp     DrawObject
; ---------------------------------------------------------------------------
.Index:
                dc.w BossBody_Init-*
                dc.w BossBody_Fall-.Index
                dc.w BossBody_Duck-.Index
                dc.w BossBody_StartWalk-.Index
                dc.w BossBody_WalkForward-.Index
                dc.w BossBody_WalkBackward-.Index
                dc.w BossBody_StompGround-.Index
                dc.w loc_20BE0A-.Index
                dc.w BossBody_Pause-.Index
; ---------------------------------------------------------------------------

BossBody_Init:
                clr.b   obj.Status(a0)
                move.b  #2,obj.Action(a0)
                move.b  #4,obj.RenderFlags(a0)
                move.b  #$24,obj.Width(a0) ; '$'
                move.b  #$20,obj.YRad(a0) ; ' '
                move.w  #$359,obj.Tile(a0)
                move.l  #MapSpr_BossBody,obj.Map(a0)
                bsr.w   loc_20BB12
                rts
; ---------------------------------------------------------------------------

BossBody_Pause:
                subq.b  #1,obj.USER_2D(a0)
                bne.w   locret_20B708
                bsr.w   loc_20BB12
                bset    #0,obj.ChildType(a0)
                bclr    #1,obj.ChildType(a0)

locret_20B708:
                rts
; ---------------------------------------------------------------------------

BossBody_Fall:
                movea.w obj.USER_32(a0),a1
                move.b  #$10,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #4,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #$A,obj.Action(a1)
                movea.w obj.Child(a0),a1
                bsr.w   loc_20BE34
                btst    #4,obj.ChildType(a1)
                bne.s   loc_20B74E
                addi.l  #$18000,obj.Y(a0)
                movea.w obj.Parent(a0),a1
                addi.l  #$18000,obj.Y(a1)
                rts
; ---------------------------------------------------------------------------

loc_20B74E:
                bset    #0,obj.ChildType(a0)
                rts
; ---------------------------------------------------------------------------

BossBody_Duck:
                movea.w obj.USER_32(a0),a1
                bclr    #0,obj.ChildType(a1)
                movea.w obj.Child(a0),a1
                bclr    #0,obj.ChildType(a1)
                beq.s   locret_20B7C8
                cmpi.b  #$C,obj.Action(a1)
                beq.s   loc_20B7C0
                cmpi.b  #$A,obj.Action(a1)
                beq.s   loc_20B7B8
                move.b  #2,obj.Action(a1)
                bsr.w   loc_20BE58
                bsr.w   loc_20BEA0
                movea.w obj.USER_32(a0),a1
                move.b  #8,obj.Action(a1)
                bsr.w   loc_20BE34
                bsr.w   loc_20BE7C
                movea.w obj.Child(a1),a1
                move.b  #2,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #4,obj.Action(a1)
                bset    #0,obj.ChildType(a0)
                rts
; ---------------------------------------------------------------------------

loc_20B7B8:
                move.b  #$E,obj.Action(a1)
                rts
; ---------------------------------------------------------------------------

loc_20B7C0:
                move.b  #$A,obj.Action(a1)
                rts
; ---------------------------------------------------------------------------

locret_20B7C8:
                rts
; ---------------------------------------------------------------------------

BossBody_StartWalk:
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20B7D6
                bsr.w   loc_20B978

loc_20B7D6:
                movea.w obj.Child(a0),a1
                btst    #0,obj.ChildType(a1)
                beq.s   locret_20B800
                movea.w obj.USER_32(a0),a1
                btst    #0,obj.ChildType(a1)
                beq.s   locret_20B800
                bclr    #1,obj.ChildType(a0)
                bset    #6,obj.ChildType(a0)
                bset    #0,obj.ChildType(a0)

locret_20B800:
                rts
; ---------------------------------------------------------------------------

BossBody_WalkForward:
                btst    #6,obj.ChildType(a0)
                bne.s   loc_20B814
                movea.w obj.Child(a0),a1
                movea.w obj.USER_32(a0),a2
                bra.s   loc_20B81C
; ---------------------------------------------------------------------------

loc_20B814:
                movea.w obj.USER_32(a0),a1
                movea.w obj.Child(a0),a2

loc_20B81C:
                btst    #0,obj.ChildType(a1)
                beq.w   locret_20B900
                btst    #0,$2C(a2)
                beq.w   locret_20B900
                movea.w obj.Child(a1),a3
                movea.w $30(a3),a3
                movea.w $30(a2),a4
                movea.w $30(a2),a4
                bclr    #0,obj.ChildType(a1)
                bclr    #0,$2C(a3)
                bclr    #0,$2C(a2)
                bclr    #0,$2C(a4)
                cmpi.w  #$B58,obj.X(a0)
                bgt.s   loc_20B866
                move.b  #1,obj.USER_2D(a0)

loc_20B866:
                subq.b  #1,obj.USER_2D(a0)
                bne.w   loc_20B87C
                bset    #0,obj.ChildType(a0)
                bclr    #1,obj.ChildType(a0)
                rts
; ---------------------------------------------------------------------------

loc_20B87C:
                bchg    #6,obj.ChildType(a0)
                beq.w   loc_20B8C4
                movea.w obj.Child(a0),a1
                move.b  #8,obj.Action(a1)
                bsr.w   loc_20BE34
                bsr.w   loc_20BE7C
                movea.w obj.Child(a1),a1
                move.b  #6,obj.Action(a1)
                movea.w obj.USER_32(a0),a1
                move.b  #2,obj.Action(a1)
                bsr.w   loc_20BE58
                bsr.w   loc_20BEA0
                movea.w obj.Child(a1),a1
                move.b  #8,obj.Action(a1)
                bsr.w   _bossGetParentInfo2
                rts
; ---------------------------------------------------------------------------

loc_20B8C4:
                movea.w obj.Child(a0),a1
                move.b  #2,obj.Action(a1)
                bsr.w   loc_20BE58
                bsr.w   loc_20BEA0
                movea.w obj.Child(a1),a1
                move.b  #8,obj.Action(a1)
                movea.w obj.USER_32(a0),a1
                move.b  #8,obj.Action(a1)
                bsr.w   loc_20BE34
                bsr.w   loc_20BE7C
                movea.w obj.Child(a1),a1
                move.b  #6,obj.Action(a1)
                bsr.w   loc_20B978

locret_20B900:
                rts
; ---------------------------------------------------------------------------

_bossGetParentInfo2:
                movea.w obj.Parent(a0),a1
                movea.w obj.USER_32(a1),a2
                movea.w $32(a2),a1
                move.l  a1,d0
                beq.s   .NoUser32
                move.b  #2,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #8,obj.Action(a1)
                move.b  #0,obj.Frame(a1)
                movea.w obj.Child(a1),a3
                movea.w $30(a3),a1
                move.b  #2,obj.Action(a1)
                movea.w $32(a3),a1
                move.b  #2,obj.Action(a1)

.NoUser32:
                movea.w $30(a2),a1
                move.l  a1,d0
                beq.s   locret_20B976
                move.b  #6,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #6,obj.Action(a1)
                move.b  #0,obj.Frame(a1)
                movea.w obj.Child(a1),a3
                movea.w $30(a3),a1
                move.b  #4,obj.Action(a1)
                movea.w $32(a3),a1
                move.b  #4,obj.Action(a1)

locret_20B976:
                rts
; ---------------------------------------------------------------------------

loc_20B978:
                movea.w obj.Parent(a0),a1
                movea.w obj.USER_32(a1),a2
                movea.w $32(a2),a1
                move.l  a1,d0
                beq.s   loc_20B9B6
                move.b  #6,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #6,obj.Action(a1)
                move.b  #0,obj.Frame(a1)
                movea.w obj.Child(a1),a3
                movea.w $30(a3),a1
                move.b  #4,obj.Action(a1)
                movea.w $32(a3),a1
                move.b  #4,obj.Action(a1)

loc_20B9B6:
                movea.w $30(a2),a1
                move.l  a1,d0
                beq.s   locret_20B9EC
                move.b  #2,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #8,obj.Action(a1)
                move.b  #0,obj.Frame(a1)
                movea.w obj.Child(a1),a3
                movea.w $30(a3),a1
                move.b  #2,obj.Action(a1)
                movea.w $32(a3),a1
                move.b  #2,obj.Action(a1)

locret_20B9EC:
                rts
; ---------------------------------------------------------------------------

loc_20B9EE:
                movea.w obj.Parent(a0),a1
                movea.w obj.USER_32(a1),a2
                movea.w $32(a2),a1
                move.l  a1,d0
                beq.s   loc_20BA2C
                move.b  #2,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #$A,obj.Action(a1)
                move.b  #1,obj.Frame(a1)
                movea.w obj.Child(a1),a3
                movea.w $30(a3),a1
                move.b  #4,obj.Action(a1)
                movea.w $32(a3),a1
                move.b  #4,obj.Action(a1)

loc_20BA2C:
                movea.w $30(a2),a1
                move.l  a1,d0
                beq.s   locret_20BA62
                move.b  #2,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #$A,obj.Action(a1)
                move.b  #1,obj.Frame(a1)
                movea.w obj.Child(a1),a3
                movea.w $30(a3),a1
                move.b  #4,obj.Action(a1)
                movea.w $32(a3),a1
                move.b  #4,obj.Action(a1)

locret_20BA62:
                rts
; ---------------------------------------------------------------------------

loc_20BA64:
                movem.l a1,-(sp)
                movea.w obj.Child(a0),a1
                move.b  #8,obj.USER_3C(a1)
                movea.w obj.Child(a1),a1
                move.l  #$10000,obj.USER_3C(a1)
                move.l  #$8000,obj.XSpeed(a1)
                movea.w obj.Child(a1),a1
                move.l  #$C000,obj.USER_3C(a1)
                move.l  #$18000,obj.XSpeed(a1)
                movea.w obj.USER_32(a0),a1
                move.b  #8,obj.USER_3C(a1)
                movea.w obj.Child(a1),a1
                move.l  #$10000,obj.USER_3C(a1)
                move.l  #$8000,obj.XSpeed(a1)
                movea.w obj.Child(a1),a1
                move.l  #$C000,obj.USER_3C(a1)
                move.l  #$18000,obj.XSpeed(a1)
                movem.l (sp)+,a1
                movea.w obj.Parent(a0),a1
                movea.w obj.USER_32(a1),a2
                movea.w $32(a2),a1
                move.l  a1,d0
                beq.s   loc_20BAF4
                movea.w obj.Child(a1),a1
                bset    #7,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bset    #7,obj.ChildType(a1)

loc_20BAF4:
                movea.w $30(a2),a1
                move.l  a1,d0
                beq.s   locret_20BB10
                movea.w obj.Child(a1),a1
                bset    #7,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bset    #7,obj.ChildType(a1)

locret_20BB10:
                rts
; ---------------------------------------------------------------------------

loc_20BB12:
                movem.l a1,-(sp)
                movea.w obj.Child(a0),a1
                move.b  #2,obj.USER_3C(a1)
                movea.w obj.Child(a1),a1
                move.l  #$8000,obj.USER_3C(a1)
                move.l  #$4000,obj.XSpeed(a1)
                movea.w obj.Child(a1),a1
                move.l  #$4000,obj.USER_3C(a1)
                move.l  #$8000,obj.XSpeed(a1)
                movea.w obj.USER_32(a0),a1
                move.b  #2,obj.USER_3C(a1)
                movea.w obj.Child(a1),a1
                move.l  #$8000,obj.USER_3C(a1)
                move.l  #$4000,obj.XSpeed(a1)
                movea.w obj.Child(a1),a1
                move.l  #$4000,obj.USER_3C(a1)
                move.l  #$8000,obj.XSpeed(a1)
                movem.l (sp)+,a1
                movea.w obj.Parent(a0),a1
                movea.w obj.USER_32(a1),a2
                movea.w $32(a2),a1
                move.l  a1,d0
                beq.s   loc_20BBA2
                movea.w obj.Child(a1),a1
                bclr    #7,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bclr    #7,obj.ChildType(a1)

loc_20BBA2:
                movea.w $30(a2),a1
                move.l  a1,d0
                beq.s   locret_20BBBE
                movea.w obj.Child(a1),a1
                bclr    #7,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bclr    #7,obj.ChildType(a1)

locret_20BBBE:
                rts
; ---------------------------------------------------------------------------

BossBody_WalkBackward:
                btst    #6,obj.ChildType(a0)
                bne.s   loc_20BBD2
                movea.w obj.Child(a0),a1
                movea.w obj.USER_32(a0),a2
                bra.s   loc_20BBDA
; ---------------------------------------------------------------------------

loc_20BBD2:
                movea.w obj.USER_32(a0),a1
                movea.w obj.Child(a0),a2

loc_20BBDA:
                btst    #0,obj.ChildType(a1)
                beq.w   locret_20BCCE
                btst    #0,$2C(a2)
                beq.w   locret_20BCCE
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20BBFE
                bsr.w   loc_20BB12
                bra.w   loc_20BC4A
; ---------------------------------------------------------------------------

loc_20BBFE:
                movea.w obj.Child(a1),a3
                movea.w $30(a3),a3
                movea.w $30(a2),a4
                movea.w $30(a2),a4
                bclr    #0,obj.ChildType(a1)
                bclr    #0,$2C(a3)
                bclr    #0,$2C(a2)
                bclr    #0,$2C(a4)
                cmpi.w  #$BA0,obj.X(a0)
                blt.s   loc_20BC34
                move.b  #1,obj.USER_2D(a0)

loc_20BC34:
                subq.b  #1,obj.USER_2D(a0)
                bne.w   loc_20BC4A
                bclr    #1,obj.ChildType(a0)
                bset    #0,obj.ChildType(a0)
                rts
; ---------------------------------------------------------------------------

loc_20BC4A:
                bchg    #6,obj.ChildType(a0)
                beq.w   loc_20BC92
                movea.w obj.Child(a0),a1
                move.b  #$16,obj.Action(a1)
                bsr.w   loc_20BE34
                bsr.w   loc_20BE7C
                movea.w obj.Child(a1),a1
                move.b  #8,obj.Action(a1)
                movea.w obj.USER_32(a0),a1
                move.b  #$12,obj.Action(a1)
                bsr.w   loc_20BE58
                bsr.w   loc_20BEA0
                movea.w obj.Child(a1),a1
                move.b  #6,obj.Action(a1)
                bsr.w   loc_20B978
                rts
; ---------------------------------------------------------------------------

loc_20BC92:
                movea.w obj.Child(a0),a1
                move.b  #$12,obj.Action(a1)
                bsr.w   loc_20BE58
                bsr.w   loc_20BEA0
                movea.w obj.Child(a1),a1
                move.b  #6,obj.Action(a1)
                movea.w obj.USER_32(a0),a1
                move.b  #$16,obj.Action(a1)
                bsr.w   loc_20BE34
                bsr.w   loc_20BE7C
                movea.w obj.Child(a1),a1
                move.b  #8,obj.Action(a1)
                bsr.w   _bossGetParentInfo2

locret_20BCCE:
                rts
; ---------------------------------------------------------------------------

BossBody_StompGround:
                btst    #6,obj.ChildType(a0)
                bne.s   loc_20BCE2
                movea.w obj.Child(a0),a1
                movea.w obj.USER_32(a0),a2
                bra.s   loc_20BCEA
; ---------------------------------------------------------------------------

loc_20BCE2:
                movea.w obj.USER_32(a0),a1
                movea.w obj.Child(a0),a2

loc_20BCEA:
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20BCF6
                bsr.w   loc_20BA64

loc_20BCF6:
                cmpi.b  #4,obj.Action(a1)
                bne.s   loc_20BD12
                movea.w obj.Child(a1),a3
                move.b  #$A,$24(a3)
                movea.w $30(a2),a3
                move.b  #$C,$24(a3)

loc_20BD12:
                btst    #0,obj.ChildType(a1)
                beq.w   locret_20BE08
                btst    #0,$2C(a2)
                beq.w   locret_20BE08
                movea.w obj.Child(a1),a3
                movea.w $30(a3),a3
                movea.w $30(a2),a4
                movea.w $30(a2),a4
                bclr    #0,obj.ChildType(a1)
                bclr    #0,$2C(a3)
                bclr    #0,$2C(a2)
                bclr    #0,$2C(a4)
                subq.b  #1,obj.USER_2D(a0)
                bne.w   loc_20BD64
                bset    #0,obj.ChildType(a0)
                bclr    #1,obj.ChildType(a0)
                rts
; ---------------------------------------------------------------------------

loc_20BD64:
                bchg    #6,obj.ChildType(a0)
                beq.w   loc_20BDBC
                movea.w obj.Child(a0),a1
                bclr    #1,obj.ChildType(a1)
                bsr.w   loc_20BE34
                bsr.w   loc_20BE7C
                movea.w obj.Child(a1),a1
                move.b  #$A,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #2,obj.Action(a1)
                movea.w obj.USER_32(a0),a1
                bclr    #1,obj.ChildType(a1)
                move.b  #2,obj.Action(a1)
                bsr.w   loc_20BE58
                bsr.w   loc_20BEA0
                movea.w obj.Child(a1),a1
                move.b  #$C,obj.Action(a1)
                bsr.w   loc_20B9EE
                rts
; ---------------------------------------------------------------------------

loc_20BDBC:
                movea.w obj.Child(a0),a1
                bclr    #1,obj.ChildType(a1)
                move.b  #2,obj.Action(a1)
                bsr.w   loc_20BE58
                bsr.w   loc_20BEA0
                movea.w obj.Child(a1),a1
                move.b  #$C,obj.Action(a1)
                movea.w obj.USER_32(a0),a1
                bclr    #1,obj.ChildType(a1)
                bsr.w   loc_20BE34
                bsr.w   loc_20BE7C
                movea.w obj.Child(a1),a1
                move.b  #$A,obj.Action(a1)
                movea.w obj.Child(a1),a1
                move.b  #2,obj.Action(a1)
                bsr.w   loc_20B9EE

locret_20BE08:
                rts
; ---------------------------------------------------------------------------

loc_20BE0A:
                btst    #0,obj.ChildType(a0)
                bne.w   loc_20BE2C
                jsr     (CheckFloorEdge).l
                tst.w   d1
                ble.s   locret_20BE2A
                movea.w obj.Parent(a0),a1
                addq.w  #2,obj.Y(a0)
                addq.w  #2,obj.Y(a1)

locret_20BE2A:
                rts
; ---------------------------------------------------------------------------

loc_20BE2C:
                addq.l  #4,sp
                jmp     DeleteObject
; ---------------------------------------------------------------------------

loc_20BE34:
                movem.l a1,-(sp)
                bset    #5,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bset    #5,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bset    #5,obj.ChildType(a1)
                movem.l (sp)+,a1
                rts
; ---------------------------------------------------------------------------

loc_20BE58:
                movem.l a1,-(sp)
                bclr    #5,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bclr    #5,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bclr    #5,obj.ChildType(a1)
                movem.l (sp)+,a1
                rts
; ---------------------------------------------------------------------------

loc_20BE7C:
                movem.l a1,-(sp)
                bset    #4,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bset    #4,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bset    #4,obj.ChildType(a1)
                movem.l (sp)+,a1
                rts
; ---------------------------------------------------------------------------

loc_20BEA0:
                movem.l a1,-(sp)
                bclr    #4,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bclr    #4,obj.ChildType(a1)
                movea.w obj.Child(a1),a1
                bclr    #4,obj.ChildType(a1)
                movem.l (sp)+,a1
                rts
; End of function objBossBody


; =============== S U B R O U T I N E =======================================


_bossExplodeLimb:
                jsr     (FindObjSlot).l
                bne.s   .NoSlotFound
                st      obj.SubAction(a1)
                move.b  #$18,obj.ID(a1)
                move.w  obj.X(a0),obj.X(a1)
                move.w  obj.Y(a0),obj.Y(a1)
                move.w  #SFXExplosion,d0
                jsr     PlayFMSound

.NoSlotFound:
                rts
; End of function _bossExplodeLimb


; =============== S U B R O U T I N E =======================================


objBossShoulders:

; FUNCTION CHUNK AT 0000:0020CF3A SIZE 0000000E BYTES

                moveq   #0,d0
                move.b  obj.Action(a0),d0
                move.w  .Index(pc,d0.w),d0
                jsr     .Index(pc,d0.w)
                jmp     DrawObject
; ---------------------------------------------------------------------------
.Index:
                dc.w BossShoulders_Init-.Index
                dc.w loc_20BF32-.Index
                dc.w loc_20BF8E-.Index
; ---------------------------------------------------------------------------

BossShoulders_Init:
                clr.b   obj.Status(a0)
                move.b  #4,obj.RenderFlags(a0)
                move.b  #$10,obj.Width(a0)
                move.b  #$C,obj.YRad(a0)
                move.w  #$359,obj.Tile(a0)
                move.l  #MapSpr_BossShoulders,obj.Map(a0)
                move.b  #2,obj.Action(a0)

loc_20BF32:
                movea.w obj.Parent(a0),a1
                move.w  8(a1),obj.X(a0)
                addi.w  #$18,obj.X(a0)
                move.w  $C(a1),obj.Y(a0)
                addi.w  #-$C,obj.Y(a0)
                bclr    #6,obj.ChildType(a0)
                bne.s   loc_20BF76
                bclr    #5,obj.ChildType(a0)
                bne.s   loc_20BF60
                rts
; ---------------------------------------------------------------------------

loc_20BF60:
                movea.w obj.USER_32(a0),a1
                move.b  #$A,$24(a1)
                clr.w   obj.USER_32(a0)
                move.b  #0,$1A(a1)
                rts
; ---------------------------------------------------------------------------

loc_20BF76:
                movea.w obj.Child(a0),a1
                move.b  #$A,$24(a1)
                clr.w   obj.Child(a0)
                movea.w obj.USER_32(a0),a1
                movea.w $30(a1),a1
                rts
; ---------------------------------------------------------------------------

loc_20BF8E:
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20BFA8
                move.l  #$FFFF0000,obj.USER_3C(a0)
                move.l  #$FFFE0000,obj.XSpeed(a0)
                bra.s   loc_20BFB8
; ---------------------------------------------------------------------------

loc_20BFA8:
                addi.l  #-$600,obj.USER_3C(a0)
                addi.l  #$1800,obj.XSpeed(a0)

loc_20BFB8:
                move.l  obj.USER_3C(a0),d0
                add.l   d0,obj.X(a0)
                move.l  obj.XSpeed(a0),d0
                add.l   d0,obj.Y(a0)
                cmpi.w  #$240,obj.Y(a0)
                blt.s   loc_20BFD8
                addq.l  #4,sp
                jmp     DeleteObject
; ---------------------------------------------------------------------------

loc_20BFD8:
                bra.w   UNUSED_bossReturnStack
; End of function objBossShoulders


; =============== S U B R O U T I N E =======================================


objBossUpperArm:

; FUNCTION CHUNK AT 0000:0020CF3A SIZE 0000000E BYTES

                moveq   #0,d0
                move.b  obj.Action(a0),d0
                move.w  .Index(pc,d0.w),d0
                jsr     .Index(pc,d0.w)
                btst    #2,obj.ChildType(a0)
                bne.s   .NoRender
                jmp     DrawObject
; ---------------------------------------------------------------------------

.NoRender:
                rts
; ---------------------------------------------------------------------------
.Index:
                dc.w BossUpperArm_Init-*
                dc.w loc_20C030-.Index
                dc.w loc_20C070-.Index
                dc.w loc_20C04C-.Index
                dc.w loc_20C070-.Index
                dc.w loc_20C074-.Index
; ---------------------------------------------------------------------------

BossUpperArm_Init:
                clr.b   obj.Status(a0)
                move.b  #4,obj.RenderFlags(a0)
                move.b  #8,obj.Width(a0)
                move.b  #8,obj.YRad(a0)
                move.w  #$359,obj.Tile(a0)
                move.l  #MapSpr_BossUpperArm,obj.Map(a0)
                move.b  #6,obj.Action(a0)

loc_20C030:
                subq.b  #2,obj.USER_2A(a0)
                bhi.w   _bossGetParentInfo
                move.b  #4,obj.Action(a0)
                clr.b   obj.USER_2A(a0)
                bset    #0,obj.ChildType(a0)
                bra.w   _bossGetParentInfo
; ---------------------------------------------------------------------------

loc_20C04C:
                addq.b  #2,obj.USER_2A(a0)
                cmpi.b  #$40,obj.USER_2A(a0) ; '@'
                bcs.w   _bossGetParentInfo
                move.b  #8,obj.Action(a0)
                move.b  #$40,obj.USER_2A(a0) ; '@'
                bset    #0,obj.ChildType(a0)
                bra.w   _bossGetParentInfo
; ---------------------------------------------------------------------------

loc_20C070:
                bra.w   _bossGetParentInfo
; ---------------------------------------------------------------------------

loc_20C074:
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20C09E
                move.b  #0,obj.USER_2B(a0)
                move.l  #$10000,obj.USER_3C(a0)
                move.l  #$FFFE0000,obj.XSpeed(a0)
                movea.w obj.Child(a0),a1
                move.b  #4,$24(a1)
                bra.s   loc_20C0AE
; ---------------------------------------------------------------------------

loc_20C09E:
                addi.l  #$600,obj.USER_3C(a0)
                addi.l  #$1F00,obj.XSpeed(a0)

loc_20C0AE:
                move.l  obj.USER_3C(a0),d0
                add.l   d0,obj.X(a0)
                move.l  obj.XSpeed(a0),d0
                add.l   d0,obj.Y(a0)
                cmpi.w  #$240,obj.Y(a0)
                blt.s   loc_20C0CE
                addq.l  #4,sp
                jmp     DeleteObject
; ---------------------------------------------------------------------------

loc_20C0CE:
                bra.w   UNUSED_bossReturnStack
; ---------------------------------------------------------------------------

_bossGetParentInfo:
                movea.w obj.Parent(a0),a1
                move.w  obj.X(a1),obj.X(a0)
                move.w  obj.Y(a1),obj.Y(a0)
                moveq   #0,d0
                move.b  obj.USER_2A(a0),d0
                addi.b  #$18,d0
                jsr     (CalcSine).l
                asr.w   #4,d0
                asr.w   #4,d1
                add.w   d1,obj.X(a0)
                add.w   d0,obj.Y(a0)
                btst    #2,obj.ChildType(a0)
                beq.s   .IsRightArm
                addi.w  #-$A,obj.X(a0)

.IsRightArm:
                rts
; End of function objBossUpperArm


; =============== S U B R O U T I N E =======================================


objBossLowerArm:

; FUNCTION CHUNK AT 0000:0020CF3A SIZE 0000000E BYTES

                moveq   #0,d0
                move.b  $24(a0),d0
                move.w  off_20C122(pc,d0.w),d0
                jsr     off_20C122(pc,d0.w)
                jmp     DrawObject
; ---------------------------------------------------------------------------
off_20C122:     dc.w loc_20C12E-*
                dc.w loc_20C150-off_20C122
                dc.w loc_20C232-off_20C122
                dc.w loc_20C1B6-off_20C122
                dc.w loc_20C1C8-off_20C122
                dc.w loc_20C1DC-off_20C122
; ---------------------------------------------------------------------------

loc_20C12E:
                clr.b   $22(a0)
                move.b  #4,1(a0)
                move.b  #$20,$19(a0) ; ' '
                move.b  #8,$16(a0)
                move.w  #$359,2(a0)
                move.b  #2,$24(a0)

loc_20C150:
                movea.w $2E(a0),a1
                move.w  8(a1),8(a0)
                addi.w  #-$24,8(a0)
                move.w  $34(a0),d0
                add.w   d0,8(a0)
                move.w  $C(a1),$C(a0)
                addi.w  #0,$C(a0)
                btst    #7,$2C(a0)
                bne.s   loc_20C19C
                bsr.w   _bossGetPlayer
                move.w  $C(a1),d1
                cmp.w   $C(a0),d1
                bgt.s   loc_20C19C
                cmpi.w  #$FFF8,$38(a0)
                ble.s   loc_20C1AC
                subi.l  #$8000,$38(a0)
                bra.s   loc_20C1AC
; ---------------------------------------------------------------------------

loc_20C19C:
                cmpi.w  #8,$38(a0)
                bge.s   loc_20C1AC
                addi.l  #$8000,$38(a0)

loc_20C1AC:
                move.w  $38(a0),d0
                add.w   d0,$C(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C1B6:
                cmpi.w  #0,$34(a0)
                ble.s   loc_20C1C6
                subi.l  #$8000,$34(a0)

loc_20C1C6:
                bra.s   loc_20C150
; ---------------------------------------------------------------------------

loc_20C1C8:
                cmpi.w  #$10,$34(a0)
                bge.s   loc_20C1D8
                addi.l  #$8000,$34(a0)

loc_20C1D8:
                bra.w   loc_20C150
; ---------------------------------------------------------------------------

loc_20C1DC:
                cmpi.w  #$10,$34(a0)
                bge.s   loc_20C1EE
                addi.l  #$8000,$34(a0)
                bra.s   loc_20C1F4
; ---------------------------------------------------------------------------

loc_20C1EE:
                move.b  #2,$1A(a0)

loc_20C1F4:
                movea.w $2E(a0),a1
                move.w  8(a1),8(a0)
                addi.w  #-$24,8(a0)
                move.w  $34(a0),d0
                add.w   d0,8(a0)
                move.w  $C(a1),$C(a0)
                addi.w  #0,$C(a0)
                cmpi.w  #8,$38(a0)
                bge.s   loc_20C228
                addi.l  #$8000,$38(a0)

loc_20C228:
                move.w  $38(a0),d0
                add.w   d0,$C(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C232:
                bset    #1,$2C(a0)
                bne.s   loc_20C260
                move.b  #1,$2B(a0)
                clr.b   $2A(a0)
                move.l  #0,$3C(a0)
                move.l  #$10000,$10(a0)
                movea.w $30(a0),a1
                move.b  #4,$24(a1)
                bra.s   loc_20C270
; ---------------------------------------------------------------------------

loc_20C260:
                addi.l  #-$620,$3C(a0)
                addi.l  #$1220,$10(a0)

loc_20C270:
                move.l  $3C(a0),d0
                add.l   d0,8(a0)
                move.l  $10(a0),d0
                add.l   d0,$C(a0)
                cmpi.w  #$240,$C(a0)
                blt.s   loc_20C290
                addq.l  #4,sp
                jmp     DeleteObject
; ---------------------------------------------------------------------------

loc_20C290:
                addq.b  #1,$2A(a0)
                moveq   #0,d2
                move.b  $2A(a0),d2
                divu.w  #7,d2
                swap    d2
                tst.w   d2
                bne.s   .NoExplode
                bsr.w   _bossExplodeLimb

.NoExplode:
                bra.w   UNUSED_bossReturnStack
; End of function objBossLowerArm


; =============== S U B R O U T I N E =======================================


objBossHands:

; FUNCTION CHUNK AT 0000:0020CF3A SIZE 0000000E BYTES

                moveq   #0,d0
                move.b  obj.Action(a0),d0
                move.w  .Index(pc,d0.w),d0
                jsr     .Index(pc,d0.w)
                jmp     DrawObject
; ---------------------------------------------------------------------------
.Index:
                dc.w BossHand_Init-*
                dc.w BossHand_ACTION2-.Index
                dc.w BossHand_ACTION4-.Index
; ---------------------------------------------------------------------------

BossHand_Init:
                clr.b   obj.Status(a0)
                move.b  #4,obj.RenderFlags(a0)
                move.b  #$C,obj.Width(a0)
                move.b  #$C,obj.YRad(a0)
                move.w  #$359,obj.Tile(a0)
                move.l  #MapSpr_BossHand,obj.Map(a0)
                move.b  #2,obj.Action(a0)

BossHand_ACTION2:
                movea.w obj.Parent(a0),a1
                move.w  obj.X(a1),obj.X(a0)
                addi.w  #-$2A,obj.X(a0)
                move.w  obj.Y(a1),obj.Y(a0)
                tst.b   obj.Frame(a1)
                beq.s   loc_20C320
                cmpi.b  #1,obj.Frame(a1)
                bne.s   loc_20C31A
                addq.w  #8,obj.X(a0)
                bra.s   loc_20C320
; ---------------------------------------------------------------------------

loc_20C31A:
                addi.w  #$10,obj.X(a0)

loc_20C320:
                cmpi.b  #$A,obj.Action(a1)
                beq.w   loc_20C366
                btst    #7,obj.ChildType(a0)
                bne.w   loc_20C378
                bsr.w   _bossGetPlayer
                move.w  obj.Y(a1),d0
                sub.w   obj.Y(a0),d0
                bge.s   loc_20C344
                neg.w   d0

loc_20C344:
                cmpi.w  #$10,d0
                ble.s   loc_20C378
                move.w  obj.Y(a1),d0
                cmp.w   obj.Y(a0),d0
                bgt.s   loc_20C366
                move.b  #1,obj.Frame(a0)
                addq.w  #2,obj.X(a0)
                subi.w  #$C,obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C366:
                move.b  #2,obj.Frame(a0)
                addq.w  #2,obj.X(a0)
                addi.w  #$C,obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C378:
                move.b  #0,obj.Frame(a0)
                rts
; ---------------------------------------------------------------------------

BossHand_ACTION4:
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20C3BC
                move.b  #0,obj.USER_2B(a0)
                clr.b   obj.ColInfo(a0)
                clr.b   obj.ColStatus(a0)
                move.l  #0,obj.USER_3C(a0)
                move.l  #$FFFE8000,obj.XSpeed(a0)
                movea.w obj.Child(a0),a1
                move.b  #6,obj.Action(a1)
                movea.w obj.USER_32(a0),a1
                move.b  #6,obj.Action(a1)
                bra.s   loc_20C3CC
; ---------------------------------------------------------------------------

loc_20C3BC:
                addi.l  #-$500,obj.USER_3C(a0)
                addi.l  #$1800,obj.XSpeed(a0)

loc_20C3CC:
                move.l  obj.USER_3C(a0),d0
                add.l   d0,obj.X(a0)
                move.l  obj.XSpeed(a0),d0
                add.l   d0,obj.Y(a0)
                cmpi.w  #$240,obj.Y(a0)
                blt.s   loc_20C3EC
                addq.l  #4,sp
                jmp     DeleteObject
; ---------------------------------------------------------------------------

loc_20C3EC:
                lea     (AniSpr_BossHands).l,a1
                jsr     (AnimateObject).l
                bra.w   UNUSED_bossReturnStack
; End of function objBossHands


; =============== S U B R O U T I N E =======================================


objBossPincers:

; FUNCTION CHUNK AT 0000:0020CF3A SIZE 0000000E BYTES

                moveq   #0,d0
                move.b  obj.Action(a0),d0
                move.w  off_20C410(pc,d0.w),d0
                jsr     off_20C410(pc,d0.w)
                jmp     DrawObject
; ---------------------------------------------------------------------------
off_20C410:     dc.w loc_20C418-*
                dc.w loc_20C45A-off_20C410
                dc.w loc_20C47E-off_20C410
                dc.w loc_20C50E-off_20C410
; ---------------------------------------------------------------------------

loc_20C418:
                clr.b   obj.Status(a0)
                move.b  #4,obj.RenderFlags(a0)
                move.b  #8,obj.Width(a0)
                move.b  #8,obj.YRad(a0)
                move.w  #$359,obj.Tile(a0)
                move.b  #4,obj.Action(a0)
                btst    #4,obj.ChildType(a0)
                bne.s   loc_20C44E
                move.l  #MapSpr_BossPincersLeft,obj.Map(a0)
                bra.w   loc_20C45A
; ---------------------------------------------------------------------------

loc_20C44E:
                move.l  #MapSpr_BossPincersRight,obj.Map(a0)
                bra.w   *+4
; ---------------------------------------------------------------------------

loc_20C45A:
                cmpi.w  #6,obj.field_38(a0)
                bge.s   loc_20C472
                addi.l  #$8000,obj.field_38(a0)
                addi.l  #$5A82,obj.USER_34(a0)

loc_20C472:
                move.w  obj.USER_34(a0),d1
                move.w  obj.field_38(a0),d2
                bra.w   loc_20C4A2
; ---------------------------------------------------------------------------

loc_20C47E:
                cmpi.w  #0,obj.field_38(a0)
                ble.s   loc_20C496
                subi.l  #$8000,obj.field_38(a0)
                subi.l  #$5A82,obj.USER_34(a0)

loc_20C496:
                move.w  obj.USER_34(a0),d1
                move.w  obj.field_38(a0),d2
                bra.w   *+4
; ---------------------------------------------------------------------------

loc_20C4A2:
                movea.w obj.Parent(a0),a1
                move.w  8(a1),obj.X(a0)
                move.w  $C(a1),obj.Y(a0)
                move.b  $1A(a1),obj.Frame(a0)
                beq.w   loc_20C4FE
                cmpi.b  #2,obj.Frame(a0)
                beq.w   loc_20C4E2
                btst    #4,obj.ChildType(a0)
                bne.s   loc_20C4D8
                add.w   d1,obj.X(a0)
                sub.w   d1,obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C4D8:
                sub.w   d1,obj.X(a0)
                add.w   d1,obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C4E2:
                btst    #4,obj.ChildType(a0)
                bne.s   loc_20C4F4
                sub.w   d1,obj.X(a0)
                sub.w   d1,obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C4F4:
                add.w   d1,obj.X(a0)
                add.w   d1,obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C4FE:
                btst    #4,obj.ChildType(a0)
                bne.s   loc_20C508
                neg.w   d2

loc_20C508:
                add.w   d2,obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C50E:
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20C548
                move.b  #1,obj.USER_2B(a0)
                btst    #4,obj.ChildType(a0)
                bne.s   loc_20C536
                move.l  #0,obj.USER_3C(a0)
                move.l  #$FFFDD000,obj.XSpeed(a0)
                bra.s   loc_20C572
; ---------------------------------------------------------------------------

loc_20C536:
                move.l  #0,obj.USER_3C(a0)
                move.l  #$FFFDD000,obj.XSpeed(a0)
                bra.s   loc_20C572
; ---------------------------------------------------------------------------

loc_20C548:
                btst    #4,obj.ChildType(a0)
                bne.s   loc_20C562
                addi.l  #-$660,obj.USER_3C(a0)
                addi.l  #$1B60,obj.XSpeed(a0)
                bra.s   loc_20C572
; ---------------------------------------------------------------------------

loc_20C562:
                subi.l  #$FFFFF9A0,obj.USER_3C(a0)
                addi.l  #$1B60,obj.XSpeed(a0)

loc_20C572:
                move.l  obj.USER_3C(a0),d0
                add.l   d0,obj.X(a0)
                move.l  obj.XSpeed(a0),d0
                add.l   d0,obj.Y(a0)
                cmpi.w  #$240,obj.Y(a0)
                blt.s   loc_20C592
                addq.l  #4,sp
                jmp     DeleteObject
; ---------------------------------------------------------------------------

loc_20C592:
                btst    #4,obj.ChildType(a0)
                bne.s   .IsRightHand
                lea     (AniSpr_BossPincerLeft).l,a1
                bra.s   .DoAnimate
; ---------------------------------------------------------------------------

.IsRightHand:
                lea     (AniSpr_BossPincerRight).l,a1

.DoAnimate:
                jsr     (AnimateObject).l
                bra.w   UNUSED_bossReturnStack
; End of function objBossPincers


; =============== S U B R O U T I N E =======================================


objBossThighs:

; FUNCTION CHUNK AT 0000:0020CF3A SIZE 0000000E BYTES

                moveq   #0,d0
                move.b  obj.Action(a0),d0
                move.w  .Index(pc,d0.w),d0
                jsr     .Index(pc,d0.w)
                jmp     DrawObject
; ---------------------------------------------------------------------------
.Index:
                dc.w BossThighs_Init-*
                dc.w loc_20C618-.Index
                dc.w loc_20C674-.Index
                dc.w loc_20C6A2-.Index
                dc.w loc_20C6BC-.Index
                dc.w loc_20C6E4-.Index
                dc.w BossThighs_Start-.Index
                dc.w loc_20C778-.Index
                dc.w loc_20C7D8-.Index
                dc.w loc_20C7FA-.Index
                dc.w loc_20C84C-.Index
                dc.w loc_20C87A-.Index
                dc.w loc_20C958-.Index
; ---------------------------------------------------------------------------

BossThighs_Init:
                clr.b   obj.Status(a0)
                move.b  #4,obj.RenderFlags(a0)
                move.b  #8,obj.Width(a0)
                move.b  #8,obj.YRad(a0)
                move.w  #$359,obj.Tile(a0)
                move.l  #MapSpr_BossThighs,obj.Map(a0)
                move.b  #$C,obj.Action(a0)
                move.b  #$58,obj.USER_2A(a0) ; 'X'
                move.b  #2,obj.USER_3C(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C618:
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                cmpi.b  #6,obj.Action(a1)
                beq.s   loc_20C63C
                cmpi.b  #8,obj.Action(a1)
                beq.s   loc_20C63C
                bclr    #0,obj.ChildType(a1)
                move.b  #6,obj.Action(a1)

loc_20C63C:
                cmpi.b  #0,obj.USER_2A(a0)
                ble.s   loc_20C654
                move.b  obj.USER_3C(a0),d0
                sub.b   d0,obj.USER_2A(a0)
                cmpi.b  #0,obj.USER_2A(a0)
                bgt.s   loc_20C670

loc_20C654:
                move.b  #0,obj.USER_2A(a0)
                cmpi.b  #8,obj.Action(a1)
                beq.s   loc_20C66A
                bclr    #0,obj.ChildType(a1)
                beq.s   loc_20C670

loc_20C66A:
                move.b  #4,obj.Action(a0)

loc_20C670:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

loc_20C674:
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                move.b  obj.USER_3C(a0),d0
                add.b   d0,obj.USER_2A(a0)
                cmpi.b  #$58,obj.USER_2A(a0) ; 'X'
                bcs.s   loc_20C69E
                move.b  #$58,obj.USER_2A(a0) ; 'X'
                move.b  #6,obj.Action(a0)
                move.b  #2,obj.Action(a1)

loc_20C69E:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

loc_20C6A2:
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                btst    #4,obj.ChildType(a1)
                beq.s   loc_20C6B8
                bset    #0,obj.ChildType(a0)

loc_20C6B8:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

loc_20C6BC:
                btst    #0,obj.ChildType(a0)
                bne.s   loc_20C6E0
                move.b  obj.USER_3C(a0),d0
                sub.b   d0,obj.USER_2A(a0)
                cmpi.b  #$18,obj.USER_2A(a0)
                bcc.s   loc_20C6E0
                move.b  #$18,obj.USER_2A(a0)
                bset    #0,obj.ChildType(a0)

loc_20C6E0:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

loc_20C6E4:
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                cmpi.b  #8,obj.Action(a1)
                beq.s   loc_20C6FC
                move.b  #6,obj.Action(a1)
                bra.s   loc_20C706
; ---------------------------------------------------------------------------

loc_20C6FC:
                cmpi.b  #0,obj.USER_2A(a0)
                beq.w   loc_20C71C

loc_20C706:
                cmpi.b  #0,obj.USER_2A(a0)
                beq.w   loc_20C718
                move.b  obj.USER_3C(a0),d0
                sub.b   d0,obj.USER_2A(a0)

loc_20C718:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

loc_20C71C:
                bclr    #0,obj.ChildType(a1)
                beq.s   loc_20C72A
                bset    #0,obj.ChildType(a0)

loc_20C72A:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

BossThighs_Start:
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                cmpi.b  #4,obj.Action(a1)
                beq.s   loc_20C746
                move.b  #2,obj.Action(a1)
                bra.s   loc_20C750
; ---------------------------------------------------------------------------

loc_20C746:
                cmpi.b  #$58,obj.USER_2A(a0) ; 'X'
                bge.w   loc_20C766

loc_20C750:
                cmpi.b  #$58,obj.USER_2A(a0) ; 'X'
                bge.w   loc_20C762
                move.b  obj.USER_3C(a0),d0
                add.b   d0,obj.USER_2A(a0)

loc_20C762:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

loc_20C766:
                bclr    #0,obj.ChildType(a1)
                beq.s   loc_20C774
                bset    #0,obj.ChildType(a0)

loc_20C774:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

loc_20C778:
                cmpi.b  #$18,obj.USER_2A(a0)
                blt.s   loc_20C79C
                bgt.s   loc_20C7CC
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                btst    #0,obj.ChildType(a1)
                beq.s   loc_20C798
                bset    #0,obj.ChildType(a0)

loc_20C798:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

loc_20C79C:
                move.b  obj.USER_3C(a0),d0
                add.b   d0,obj.USER_2A(a0)
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                bset    #7,obj.ChildType(a1)
                movea.w obj.Parent(a0),a1
                movea.w obj.USER_32(a1),a1
                movea.w obj.Child(a1),a1
                movea.w obj.Child(a1),a1
                bset    #7,obj.ChildType(a1)
                bra.w   BossThighs_Start
; ---------------------------------------------------------------------------

loc_20C7CC:
                move.b  obj.USER_3C(a0),d0
                sub.b   d0,obj.USER_2A(a0)
                bra.w   loc_20C6E4
; ---------------------------------------------------------------------------

loc_20C7D8:
                movea.w obj.Parent(a0),a1
                movea.w obj.Child(a1),a1
                move.w  obj.X(a1),obj.X(a0)
                addi.w  #-$A,obj.X(a0)
                move.w  obj.Y(a1),obj.Y(a0)
                move.w  obj.USER_2A(a1),obj.USER_2A(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C7FA:
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                cmpi.b  #6,obj.Action(a1)
                beq.w   loc_20C848
                cmpi.b  #8,obj.Action(a1)
                beq.s   loc_20C824
                bclr    #0,obj.ChildType(a1)
                move.b  #6,obj.Action(a1)
                bra.w   loc_20C848
; ---------------------------------------------------------------------------

loc_20C824:
                cmpi.b  #$20,obj.USER_2A(a0) ; ' '
                beq.s   loc_20C836
                move.b  obj.USER_3C(a0),d0
                sub.b   d0,obj.USER_2A(a0)
                bgt.s   loc_20C848

loc_20C836:
                move.b  #$20,obj.USER_2A(a0) ; ' '
                bclr    #0,obj.ChildType(a1)
                move.b  #$14,obj.Action(a0)

loc_20C848:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

loc_20C84C:
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                move.b  obj.USER_3C(a0),d0
                add.b   d0,obj.USER_2A(a0)
                cmpi.b  #$30,obj.USER_2A(a0) ; '0'
                blt.s   loc_20C876
                move.b  #$30,obj.USER_2A(a0) ; '0'
                move.b  #6,obj.Action(a0)
                move.b  #2,obj.Action(a1)

loc_20C876:
                bra.w   loc_20C8BE
; ---------------------------------------------------------------------------

loc_20C87A:
                btst    #0,obj.ChildType(a0)
                bne.s   loc_20C8BA
                movea.w obj.Child(a0),a1
                movea.w obj.Child(a1),a1
                cmpi.b  #2,obj.Action(a1)
                beq.s   loc_20C8A0
                cmpi.b  #4,obj.Action(a1)
                beq.s   loc_20C8A4
                move.b  #2,obj.Action(a1)

loc_20C8A0:
                bra.w   loc_20C8BA
; ---------------------------------------------------------------------------

loc_20C8A4:
                move.b  obj.USER_3C(a0),d0
                add.b   d0,obj.USER_2A(a0)
                cmpi.b  #$50,obj.USER_2A(a0) ; 'P'
                blt.s   loc_20C8BA
                bset    #0,obj.ChildType(a0)

loc_20C8BA:
                bra.w   *+4
; ---------------------------------------------------------------------------

loc_20C8BE:
                moveq   #0,d0
                move.b  obj.USER_2A(a0),d0
                jsr     (CalcSine).l
                moveq   #0,d2
                moveq   #0,d3
                asr.w   #4,d0
                asr.w   #4,d1
                btst    #4,obj.ChildType(a0)
                beq.w   loc_20C924
                btst    #5,obj.ChildType(a0)
                beq.w   loc_20C92A
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20C8F6
                move.w  d1,obj.USER_34(a0)
                move.w  d0,obj.field_38(a0)

loc_20C8F6:
                move.w  d0,d2
                move.w  d1,d3
                sub.w   obj.USER_34(a0),d3
                sub.w   obj.field_38(a0),d2
                move.w  d1,obj.USER_34(a0)
                move.w  d0,obj.field_38(a0)
                movea.w obj.Parent(a0),a1
                sub.w   d3,obj.X(a1)
                sub.w   d2,obj.Y(a1)
                movea.w obj.Parent(a1),a1
                sub.w   d3,obj.X(a1)
                sub.w   d2,obj.Y(a1)
                rts
; ---------------------------------------------------------------------------

loc_20C924:
                bclr    #1,obj.ChildType(a0)

loc_20C92A:
                movea.w obj.Parent(a0),a1
                move.w  obj.X(a1),d2
                addi.w  #$C,d2
                add.w   d1,d2
                btst    #2,obj.ChildType(a0)
                beq.s   loc_20C944
                addi.w  #-$A,d2

loc_20C944:
                move.w  d2,obj.X(a0)
                move.w  obj.Y(a1),d2
                addi.w  #$14,d2
                add.w   d0,d2
                move.w  d2,obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20C958:
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20C98C
                btst    #4,obj.ChildType(a0)
                beq.s   loc_20C97A
                move.l  #0,obj.USER_3C(a0)
                move.l  #-$28000,obj.XSpeed(a0)
                bra.s   loc_20C9B6
; ---------------------------------------------------------------------------

loc_20C97A:
                move.l  #0,obj.USER_3C(a0)
                move.l  #-$28000,obj.XSpeed(a0)
                bra.s   loc_20C9B6
; ---------------------------------------------------------------------------

loc_20C98C:
                btst    #4,obj.ChildType(a0)
                beq.s   loc_20C9A6
                addi.l  #-$600,obj.USER_3C(a0)
                addi.l  #$1860,obj.XSpeed(a0)
                bra.s   loc_20C9B6
; ---------------------------------------------------------------------------

loc_20C9A6:
                subi.l  #-$600,obj.USER_3C(a0)
                addi.l  #$1860,obj.XSpeed(a0)

loc_20C9B6:
                move.l  obj.USER_3C(a0),d0
                add.l   d0,obj.X(a0)
                move.l  obj.XSpeed(a0),d0
                add.l   d0,obj.Y(a0)
                cmpi.w  #$240,obj.Y(a0)
                blt.s   loc_20C9D6
                addq.l  #4,sp
                jmp     DeleteObject
; ---------------------------------------------------------------------------

loc_20C9D6:
                bra.w   UNUSED_bossReturnStack
; End of function objBossThighs


; =============== S U B R O U T I N E =======================================


objBossLeg:

; FUNCTION CHUNK AT 0000:0020CF3A SIZE 0000000E BYTES

                moveq   #0,d0
                move.b  obj.Action(a0),d0
                move.w  .Index(pc,d0.w),d0
                jsr     .Index(pc,d0.w)
                jmp     DrawObject
; ---------------------------------------------------------------------------
.Index:
                dc.w loc_20C9FE-*
                dc.w loc_20CA3A-.Index
                dc.w loc_20CA56-.Index
                dc.w loc_20CA7A-.Index
                dc.w loc_20CA9E-.Index
                dc.w loc_20CAC6-.Index
                dc.w BossLeg_UnkC-.Index
                dc.w loc_20CB96-.Index
; ---------------------------------------------------------------------------

loc_20C9FE:
                clr.b   obj.Status(a0)
                move.b  #2,obj.Action(a0)
                move.b  #4,obj.RenderFlags(a0)
                move.b  #8,obj.Width(a0)
                move.b  #$14,obj.YRad(a0)
                move.w  #$359,obj.Tile(a0)
                move.l  #MapSpr_BossLeg,obj.Map(a0)
                move.l  #$8000,obj.USER_3C(a0)
                move.l  #$4000,obj.XSpeed(a0)
                rts
; ---------------------------------------------------------------------------

loc_20CA3A:
                movea.w obj.Parent(a0),a1
                move.w  8(a1),d2
                addq.w  #4,d2
                move.w  d2,obj.X(a0)
                move.w  $C(a1),d2
                addi.w  #$10,d2
                move.w  d2,obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20CA56:
                movea.w obj.Parent(a0),a1
                movea.w $2E(a1),a1
                movea.w $30(a1),a1
                movea.w $30(a1),a1
                move.w  8(a1),obj.X(a0)
                addi.w  #-$A,obj.X(a0)
                move.w  $C(a1),obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20CA7A:
                cmpi.w  #8,obj.USER_34(a0)
                bge.s   loc_20CA9A
                move.l  obj.USER_3C(a0),d1
                add.l   d1,obj.USER_34(a0)
                btst    #4,obj.ChildType(a0)
                beq.s   loc_20CA9A
                neg.l   d1
                moveq   #0,d2
                bra.w   loc_20CB38
; ---------------------------------------------------------------------------

loc_20CA9A:
                bra.w   loc_20CB6A
; ---------------------------------------------------------------------------

loc_20CA9E:
                move.w  #0,obj.field_38(a0)
                cmpi.w  #$FFF8,obj.USER_34(a0)
                ble.s   loc_20CAC2
                move.l  obj.USER_3C(a0),d1
                sub.l   d1,obj.USER_34(a0)
                btst    #4,obj.ChildType(a0)
                beq.s   loc_20CAC2
                moveq   #0,d2
                bra.w   loc_20CB38
; ---------------------------------------------------------------------------

loc_20CAC2:
                bra.w   loc_20CB6A
; ---------------------------------------------------------------------------

loc_20CAC6:
                cmpi.w  #$FFF8,obj.USER_34(a0)
                ble.s   .bossUnkLessthan
                move.l  obj.USER_3C(a0),d1
                sub.l   d1,obj.USER_34(a0)
                bra.s   loc_20CADA

.bossUnkLessthan:
                moveq   #0,d1

loc_20CADA:
                cmpi.w  #$FFFC,obj.field_38(a0)
                ble.s   loc_20CAEC
                move.l  obj.XSpeed(a0),d2
                sub.l   d2,obj.field_38(a0)
                bra.s   loc_20CAEE
; ---------------------------------------------------------------------------

loc_20CAEC:
                moveq   #0,d2

loc_20CAEE:
                btst    #4,obj.ChildType(a0)
                beq.s   loc_20CAFA
                bra.w   loc_20CB38
; ---------------------------------------------------------------------------

loc_20CAFA:
                bra.w   loc_20CB6A
; ---------------------------------------------------------------------------

BossLeg_UnkC:
                cmpi.w  #$FFF8,obj.USER_34(a0)
                ble.s   loc_20CB10
                move.l  obj.USER_3C(a0),d1
                sub.l   d1,obj.USER_34(a0)
                bra.s   loc_20CB12
; ---------------------------------------------------------------------------

loc_20CB10:
                moveq   #0,d1

loc_20CB12:
                cmpi.w  #4,obj.field_38(a0)
                bge.s   loc_20CB24
                move.l  obj.XSpeed(a0),d2
                add.l   d2,obj.field_38(a0)
                bra.s   loc_20CB26
; ---------------------------------------------------------------------------

loc_20CB24:
                moveq   #0,d2

loc_20CB26:
                btst    #4,obj.ChildType(a0)
                beq.s   .WrongChildType
                neg.l   d2
                bra.w   loc_20CB38

.WrongChildType:
                bra.w   loc_20CB6A
; ---------------------------------------------------------------------------

loc_20CB38:
                btst    #5,obj.ChildType(a0)
                bne.w   .WrongChildType2
                rts

.WrongChildType2:
                movea.w obj.Parent(a0),a3
                add.l   d1,8(a3)
                add.l   d2,$C(a3)
                movea.w $2E(a3),a3
                add.l   d1,8(a3)
                add.l   d2,$C(a3)
                movea.w $2E(a3),a3
                add.l   d1,8(a3)
                add.l   d2,$C(a3)
                rts
; ---------------------------------------------------------------------------

loc_20CB6A:
                movea.w obj.Parent(a0),a1
                move.w  8(a1),d0
                addq.w  #4,d0
                move.w  d0,obj.X(a0)
                move.w  obj.USER_34(a0),d0
                add.w   d0,obj.X(a0)
                move.w  $C(a1),d0
                addi.w  #$10,d0
                move.w  d0,obj.Y(a0)
                move.w  obj.field_38(a0),d0
                add.w   d0,obj.Y(a0)
                rts
; ---------------------------------------------------------------------------

loc_20CB96:
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20CBCA
                btst    #4,obj.ChildType(a0)
                bne.s   loc_20CBB8
                move.l  #0,obj.USER_3C(a0)
                move.l  #$FFFE0000,obj.XSpeed(a0)
                bra.s   loc_20CBF4
; ---------------------------------------------------------------------------

loc_20CBB8:
                move.l  #0,obj.USER_3C(a0)
                move.l  #$FFFE0000,obj.XSpeed(a0)
                bra.s   loc_20CBF4
; ---------------------------------------------------------------------------

loc_20CBCA:
                btst    #4,obj.ChildType(a0)
                bne.s   loc_20CBE4
                addi.l  #-$600,obj.USER_3C(a0)
                addi.l  #$1A60,obj.XSpeed(a0)
                bra.s   loc_20CBF4
; ---------------------------------------------------------------------------

loc_20CBE4:
                subi.l  #$FFFFFA00,obj.USER_3C(a0)
                addi.l  #$1A60,obj.XSpeed(a0)

loc_20CBF4:
                move.l  obj.USER_3C(a0),d0
                add.l   d0,obj.X(a0)
                move.l  obj.XSpeed(a0),d0
                add.l   d0,obj.Y(a0)
                cmpi.w  #$240,obj.Y(a0)
                blt.s   loc_20CC14
                addq.l  #4,sp
                jmp     DeleteObject
; ---------------------------------------------------------------------------

loc_20CC14:
                bra.w   UNUSED_bossReturnStack
; End of function objBossLeg


; =============== S U B R O U T I N E =======================================


objBossFeet:

                moveq   #0,d0
                move.b  obj.Action(a0),d0
                move.w  .Index(pc,d0.w),d0
                jsr     .Index(pc,d0.w)
                jmp     DrawObject
; ---------------------------------------------------------------------------
.Index:
                dc.w loc_20CC3A-*
                dc.w loc_20CC8A-.Index
                dc.w loc_20CD52-.Index
                dc.w loc_20CD16-.Index
                dc.w loc_20CD6E-.Index
                dc.w loc_20CD74-.Index
                dc.w loc_20CE34-.Index
; ---------------------------------------------------------------------------

loc_20CC3A:
                clr.b   obj.Status(a0)
                move.b  #4,obj.RenderFlags(a0)
                move.b  #$20,obj.Width(a0) ; ' '
                move.b  #$14,obj.YRad(a0)
                move.w  #$359,obj.Tile(a0)
                move.l  #MapSpr_BossFeet,obj.Map(a0)
                move.l  #$4000,obj.USER_3C(a0)
                move.l  #$8000,obj.XSpeed(a0)
                move.b  #4,obj.Action(a0)
                bset    #0,obj.ChildType(a0)
                move.w  #$FFF8,obj.USER_34(a0)
                move.w  #$10,obj.field_38(a0)
                bra.w   loc_20CE06
; ---------------------------------------------------------------------------

loc_20CC8A:
                move.l  obj.USER_3C(a0),d0
                sub.l   d0,obj.USER_34(a0)
                move.l  obj.XSpeed(a0),d0
                add.l   d0,obj.field_38(a0)
                btst    #4,obj.ChildType(a0)
                beq.s   loc_20CCB6
                btst    #7,obj.ChildType(a0)
                beq.s   loc_20CCB6
                cmpi.w  #$C,obj.field_38(a0)
                blt.s   loc_20CCC2
                bra.w   loc_20CCD4
; ---------------------------------------------------------------------------

loc_20CCB6:
                cmpi.w  #$10,obj.field_38(a0)
                blt.s   loc_20CCC2
                bra.w   loc_20CCD4
; ---------------------------------------------------------------------------

loc_20CCC2:
                bsr.w   loc_20CDAC
                jsr     (CheckFloorEdge).l
                tst.w   d1
                ble.w   loc_20CCE2
                rts
; ---------------------------------------------------------------------------

loc_20CCD4:
                bset    #0,obj.ChildType(a0)
                move.b  #4,obj.Action(a0)
                rts
; ---------------------------------------------------------------------------

loc_20CCE2:
                bset    #4,obj.ChildType(a0)
                movea.w obj.Parent(a0),a3
                bset    #4,$2C(a3)
                movea.w $2E(a3),a3
                bset    #4,$2C(a3)
                movea.w $2E(a3),a3
                movea.w $2E(a3),a3
                move.b  #8,$38(a3)
                move.w  #SFXPound,d0
                jsr     (PlayFMSound).l
                rts
; ---------------------------------------------------------------------------

loc_20CD16:
                move.l  obj.USER_3C(a0),d0
                add.l   d0,obj.USER_34(a0)
                move.l  obj.XSpeed(a0),d0
                sub.l   d0,obj.field_38(a0)
                cmpi.w  #0,obj.field_38(a0)
                bgt.s   loc_20CD4E
                move.w  #0,obj.USER_34(a0)
                clr.w   obj.field_36(a0)
                move.w  #0,obj.field_38(a0)
                clr.w   obj.field_3A(a0)
                bset    #0,obj.ChildType(a0)
                move.b  #8,obj.Action(a0)

loc_20CD4E:
                bra.w   loc_20CDAC
; ---------------------------------------------------------------------------

loc_20CD52:
                btst    #4,obj.ChildType(a0)
                bne.w   locret_20CD6C
                bsr.w   loc_20CE06
                jsr     (CheckFloorEdge).l
                tst.w   d1
                ble.w   loc_20CCE2

locret_20CD6C:
                rts
; ---------------------------------------------------------------------------

loc_20CD6E:
                bsr.w   loc_20CE06
                rts
; ---------------------------------------------------------------------------

loc_20CD74:
                movea.w obj.Parent(a0),a1
                movea.w obj.Parent(a1),a1
                movea.w obj.Parent(a1),a1
                movea.w obj.Child(a1),a1
                movea.w obj.Child(a1),a1
                movea.w obj.Child(a1),a1
                move.w  obj.X(a1),obj.X(a0)
                addi.w  #-$A,obj.X(a0)
                move.w  obj.Y(a1),obj.Y(a0)
                move.w  obj.USER_34(a1),obj.USER_34(a0)
                move.w  obj.field_38(a1),obj.field_38(a0)
                rts
; ---------------------------------------------------------------------------

loc_20CDAC:
                btst    #4,obj.ChildType(a0)
                beq.s   loc_20CE06
                btst    #5,obj.ChildType(a0)
                bne.w   loc_20CDC0
                rts
; ---------------------------------------------------------------------------

loc_20CDC0:
                move.l  obj.USER_3C(a0),d1
                move.l  obj.XSpeed(a0),d2
                cmpi.b  #6,obj.Action(a0)
                beq.s   loc_20CDD4
                neg.l   d1
                neg.l   d2

loc_20CDD4:
                movea.w obj.Parent(a0),a3
                sub.l   d1,8(a3)
                add.l   d2,$C(a3)
                movea.w $2E(a3),a3
                sub.l   d1,8(a3)
                add.l   d2,$C(a3)
                movea.w $2E(a3),a3
                sub.l   d1,8(a3)
                add.l   d2,$C(a3)
                movea.w $2E(a3),a3
                sub.l   d1,8(a3)
                add.l   d2,$C(a3)
                rts
; ---------------------------------------------------------------------------

loc_20CE06:
                movea.w obj.Parent(a0),a1
                move.w  obj.X(a1),d0
                addi.w  #-$B,d0
                move.w  d0,obj.X(a0)
                move.w  obj.USER_34(a0),d0
                add.w   d0,obj.X(a0)
                move.w  obj.Y(a1),d0
                addi.w  #$E,d0
                move.w  d0,obj.Y(a0)
                move.w  obj.field_38(a0),d0
                add.w   d0,obj.Y(a0)
                rts

loc_20CE34:
                bset    #1,obj.ChildType(a0)
                bne.s   loc_20CE68
                btst    #4,obj.ChildType(a0)
                beq.s   loc_20CE56
                move.l  #0,obj.USER_3C(a0)
                move.l  #$FFFDD000,obj.XSpeed(a0)
                bra.s   loc_20CE92

loc_20CE56:
                move.l  #0,obj.USER_3C(a0)
                move.l  #$FFFDD000,obj.XSpeed(a0)
                bra.s   loc_20CE92

loc_20CE68:
                btst    #4,obj.ChildType(a0)
                bne.s   loc_20CE82
                addi.l  #-$660,obj.USER_3C(a0)
                addi.l  #$1660,obj.XSpeed(a0)
                bra.s   loc_20CE92

loc_20CE82:
                subi.l  #$FFFFF9A0,obj.USER_3C(a0)
                addi.l  #$1660,obj.XSpeed(a0)

loc_20CE92:
                move.l  obj.USER_3C(a0),d0
                add.l   d0,obj.X(a0)
                move.l  obj.XSpeed(a0),d0
                add.l   d0,obj.Y(a0)
                cmpi.w  #$240,obj.Y(a0)
                blt.s   loc_20CEB2
                addq.l  #4,sp
                jmp     DeleteObject

loc_20CEB2:
                bra.w   UNUSED_bossReturnStack


; ---------------------------------------------------------------------------
; Spawns explosions
; ---------------------------------------------------------------------------

_bossDefeatedExplode:
                moveq   #0,d2
                move.b  obj.USER_2B(a0),d2
                divu.w  #4,d2
                swap    d2
                tst.w   d2
                bne.s   .Exit
                clr.w   d2
                swap    d2
                divu.w  #$A,d2
                swap    d2
                add.w   d2,d2
                add.w   d2,d2
                jsr     (FindObjSlot).l
                bne.s   .Exit
                st      obj.SubAction(a1)
                lea     (@ExplodePosOffs).l,a2
                adda.w  d2,a2
                move.b  #$18,obj.ID(a1)
                move.w  obj.X(a0),obj.X(a1)
                move.w  obj.Y(a0),obj.Y(a1)
                move.w  (a2)+,d0
                add.w   d0,obj.X(a1)
                move.w  (a2),d0
                add.w   d0,obj.Y(a1)
                move.w  #SFXExplosion,d0
                jsr     PlayFMSound

.Exit:
                rts

; ---------------------------------------------------------------------------

@ExplodePosOffs:
                dc.w -$30
                dc.w -$10
                dc.w $30
                dc.w $10
                dc.w -$10
                dc.w -$10
                dc.w $10
                dc.w $10
                dc.w -$20
                dc.w 0
                dc.w $30
                dc.w -$10
                dc.w -$30
                dc.w $10
                dc.w -$10
                dc.w $10
                dc.w $10
                dc.w -$10
                dc.w $20
                dc.w 0

; ---------------------------------------------------------------------------
; Some kind of nulled exit routine for an earlier implementation of the boss
; ---------------------------------------------------------------------------

UNUSED_bossReturnStack:
                rts
                eori.b  #1,obj.USER_2B(a0)
                bne.s   .Exit
                addq.l  #4,sp

.Exit:
                rts

; ---------------------------------------------------------------------------
; Check if we're player 1 or 2
; ---------------------------------------------------------------------------



_bossGetPlayer:
                tst.b   (usePlayer2).l
                bne.s   .IsPlayer2
                lea     (objPlayerSlot).w,a1
                rts

.IsPlayer2:
                lea     (objPlayerSlot2).w,a1
                rts

; ---------------------------------------------------------------------------
