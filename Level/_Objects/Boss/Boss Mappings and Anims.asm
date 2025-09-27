; ---------------------------------------------------------------------------
; Boss Sprite and animation data (raw)
; ---------------------------------------------------------------------------

AniSpr_BossEggman:
		dc.w @bossegg_neut_chg0-AniSpr_BossEggman
                dc.w @bossegg_laugh_chg1-AniSpr_BossEggman
                dc.w @bossegg_hit_chg2-AniSpr_BossEggman
                dc.w @bossegg_esc1_chg3-AniSpr_BossEggman
                dc.w @bossegg_esc1_chg4-AniSpr_BossEggman

@bossegg_neut_chg0:	dc.b $3B,  0,$FF
@bossegg_laugh_chg1:	dc.b   7,  2,  3,$FF
@bossegg_hit_chg2:	dc.b   3,  1,  5,  4,  6,$FF
@bossegg_esc1_chg3:	dc.b   3,  7,  8,$FF
@bossegg_esc1_chg4:	dc.b   3,  9, $A,$FF,  0

; ---------------------------------------------------------------------------

MapSpr_BossEggman:
		dc.w @bossegg_neut_sp0-MapSpr_BossEggman
                dc.w @bossegg_hit1_sp1-MapSpr_BossEggman
                dc.w @bossegg_laug1_sp2-MapSpr_BossEggman
                dc.w @bossegg_laug2_sp3-MapSpr_BossEggman
                dc.w @bossegg_hit2_sp4-MapSpr_BossEggman
                dc.w @bossegg_hit3_sp5-MapSpr_BossEggman
                dc.w @bossegg_hit4_sp6-MapSpr_BossEggman
                dc.w @bossegg_ext1_sp7-MapSpr_BossEggman
                dc.w @bossegg_ext2_sp8-MapSpr_BossEggman
                dc.w @bossegg_ext3_sp9-MapSpr_BossEggman
                dc.w @bossegg_ext4_spA-MapSpr_BossEggman
@bossegg_neut_sp0:
		dc.b   2,$E8, $D,  0,  0,$E4,$E8,  1
		dc.b   0,  8,  4,  0
@bossegg_hit1_sp1:
		dc.b   3,$D8,  5,  8,$32,$E4,$E8, $D
                dc.b   0, $A,$E4,$E8,  1,  0,$12,  4
@bossegg_laug1_sp2:
		dc.b   2,$E8, $D,  0,$14,$E4,$E8,  1
                dc.b   0,$1C,  4,  0
@bossegg_laug2_sp3:
		dc.b   2,$E8, $D,  0,$1E,$E4,$E8,  1
                dc.b   0,$26,  4,  0
@bossegg_hit2_sp4:
		dc.b   3,$D8,  5,  8,$36,$E4,$E8, $D
                dc.b   0,$28,$E4,$E8,  1,  0,$30,  4
@bossegg_hit3_sp5:
		dc.b   2,$E8, $D,  0, $A,$E4,$E8,  1
                dc.b   0,$12,  4,  0
@bossegg_hit4_sp6:
		dc.b   2,$E8, $D,  0,$28,$E4,$E8,  1
                dc.b   0,$30,  4,  0
@bossegg_ext1_sp7:
		dc.b   4,$E8, $F,  0,$3A,$E8,$E8,  7
                dc.b   0,$4A,  8,  8, $E,  0,$52,$F0
                dc.b   8,  1,  0,$6D,$E4,  0
@bossegg_ext2_sp8:
		dc.b   4,$E8, $F,  0,$3A,$E8,$E8,  7
                dc.b   0,$4A,  8,  8, $E,  0,$52,$F0
                dc.b   8,  0,  0,$6F,$E4,  0
@bossegg_ext3_sp9:
		dc.b   5,$E8, $F,  0,$3A,$E8,$E8,  7
                dc.b   0,$4A,  8,  8, $E,  0,$5E,$E8
                dc.b   8,  2,  0,$6A,  8,  8,  1,  0
                dc.b $6D,$E4
@bossegg_ext4_spA:
		dc.b   5,$E8, $F,  0,$3A,$E8,$E8,  7
                dc.b   0,$4A,  8,  8, $E,  0,$5E,$E8
                dc.b   8,  2,  0,$6A,  8,  8,  0,  0
                dc.b $6F,$E4

; ---------------------------------------------------------------------------

MapSpr_BossBody:dc.w @bossbody_sp0-MapSpr_BossBody

@bossbody_sp0:
		dc.b   8,  8, $A,$20,$39,  0,$E0,  8
                dc.b   0,  0,$F4,$E0, $B,  0,  3, $C
                dc.b   0, $B,  0, $F, $C,$F8, $F,  0
                dc.b $1B,$DC,$F8,  7,  0,$2B,$FC,$18
                dc.b  $C,  0,$33,$DC,$18,  4,  0,$37
                dc.b $FC,  0

; ---------------------------------------------------------------------------

MapSpr_BossThighs:
		dc.w @bossthighs_sp0-MapSpr_BossThighs
@bossthighs_sp0:
		dc.b   1,$F8,  5,$20,$42,$F8

; ---------------------------------------------------------------------------

MapSpr_BossLeg:
		dc.w @bossleg_sp0-MapSpr_BossLeg
@bossleg_sp0:
		dc.b   2,$EC, $B,$20,$46,$F4, $C,  8
		dc.b $20,$52,$F4,  0

; ---------------------------------------------------------------------------

MapSpr_BossFeet:
		dc.w @bossfeet_sp0-MapSpr_BossFeet
@bossfeet_sp0:
		dc.b   4,$EC, $F,$20,$55,$E0,$EC, $F
                dc.b $20,$65,  0, $C, $C,$20,$75,$E0
                dc.b  $C, $C,$20,$79,  0,  0

; ---------------------------------------------------------------------------

MapSpr_BossShoulders:
		dc.w @bossshoulder_sp0-MapSpr_BossShoulders
@bossshoulder_sp0:
		dc.b   1,$F4, $E,$20,$A7,$EC

; ---------------------------------------------------------------------------

MapSpr_BossUpperArm:
		dc.w @bossuparm_sp0-MapSpr_BossUpperArm
@bossuparm_sp0:
		dc.b   1,$F8,  5,$20,$99,$F8

; ---------------------------------------------------------------------------

MapSpr_BossArm1:dc.w @bossarm1_sp0-MapSpr_BossArm1
                dc.w @bossarm1_sp1-MapSpr_BossArm1
                dc.w @bossarm1_sp2-MapSpr_BossArm1
@bossarm1_sp0:  dc.b   3,$F8,  9,$20,$A1, $A,$FC, $C
                dc.b $20,$9D,$EE,$F8,  5,$20,$99,$E2
@bossarm1_sp1:  dc.b   3,$F8,  9,$20,$A1, $A,$FC,  8
                dc.b $20,$B3,$F6,$F8,  5,$20,$99,$EA
@bossarm1_sp2:  dc.b   3,$F8,  9,$20,$A1, $A,$FC,  4
                dc.b $20,$B6,$FE,$F8,  5,$20,$99,$F2

; ---------------------------------------------------------------------------

MapSpr_BossArm2:dc.w @bossarm2_sp0-MapSpr_BossArm2
                dc.w @bossarm2_sp1-MapSpr_BossArm2
                dc.w @bossarm2_sp2-MapSpr_BossArm2
@bossarm2_sp0:  dc.b   2,$FC, $C,$20,$9D,$EE,$F8,  5
                dc.b $20,$99,$E2,  0
@bossarm2_sp1:  dc.b   2,$FC,  8,$20,$B3,$F6,$F8,  5
                dc.b $20,$99,$EA,  0
@bossarm2_sp2:  dc.b   2,$FC,  4,$20,$B6,$FE,$F8,  5
                dc.b $20,$99,$F2,  0

; ---------------------------------------------------------------------------

AniSpr_BossHands:
		dc.w @bosshand_chg0-AniSpr_BossHands

@bosshand_chg0: dc.b   6,  0,  1,  4,  3,  5,  2,$FF

; ---------------------------------------------------------------------------

MapSpr_BossHand:dc.w @bosshand_sp0-MapSpr_BossHand
                dc.w @bosshand_sp1-MapSpr_BossHand
                dc.w @bosshand_sp2-MapSpr_BossHand
                dc.w @bosshand_sp3-MapSpr_BossHand
                dc.w @bosshand_sp4-MapSpr_BossHand
                dc.w @bosshand_sp5-MapSpr_BossHand
@bosshand_sp0:  dc.b   1,$F4, $A,$20,$87,$FC
@bosshand_sp1:  dc.b   1,$F8, $A,$20,$90,$FC
@bosshand_sp2:  dc.b   1,$F0, $A,$30,$90,$FC
@bosshand_sp3:  dc.b   1,$F4, $A,$28,$87,$FC
@bosshand_sp4:  dc.b   1,$F8, $A,$28,$90,$FC
@bosshand_sp5:  dc.b   1,$F0, $A,$38,$90,$FC

; ---------------------------------------------------------------------------

AniSpr_BossPincerLeft:dc.w @bosspincerl_chg0-AniSpr_BossPincerLeft
@bosspincerl_chg0:dc.b   6,  0,  1,  4,  3,  5,  2,$FF

; ---------------------------------------------------------------------------

MapSpr_BossPincersLeft:dc.w @bosspincerl_sp0-MapSpr_BossPincersLeft
                dc.w @bosspincerl_sp1-MapSpr_BossPincersLeft
                dc.w @bosspincerl_sp2-MapSpr_BossPincersLeft
                dc.w @bosspincerl_sp3-MapSpr_BossPincersLeft
                dc.w @bosspincerl_sp4-MapSpr_BossPincersLeft
                dc.w @bosspincerl_sp5-MapSpr_BossPincersLeft
@bosspincerl_sp0:dc.b   1,$F9,  4,$20,$7D,$F3
@bosspincerl_sp1:dc.b   1,$F0,  5,$20,$7F,$FA
@bosspincerl_sp2:dc.b   1,$FA,  5,$30,$83,$F3
@bosspincerl_sp3:dc.b   1,$F9,  4,$28,$7D,$F3
@bosspincerl_sp4:dc.b   1,$F0,  5,$28,$7F,$FA
@bosspincerl_sp5:dc.b   1,$FA,  5,$38,$83,$F3

; ---------------------------------------------------------------------------

AniSpr_BossPincerRight:dc.w @bosspincerr_chg0-AniSpr_BossPincerRight
@bosspincerr_chg0:dc.b   6,  0,  1,  4,  3,  5,  2,$FF

; ---------------------------------------------------------------------------

MapSpr_BossPincersRight:dc.w @bosspincerr_sp0-MapSpr_BossPincersRight
                dc.w @bosspincerr_sp1-MapSpr_BossPincersRight
                dc.w @bosspincerr_sp2-MapSpr_BossPincersRight
                dc.w @bosspincerr_sp3-MapSpr_BossPincersRight
                dc.w @bosspincerr_sp4-MapSpr_BossPincersRight
                dc.w @bosspincerr_sp5-MapSpr_BossPincersRight
@bosspincerr_sp0:dc.b   1,  0,  4,$30,$7D,$F3
@bosspincerr_sp1:dc.b   1,$F5,  5,$20,$83,$F4
@bosspincerr_sp2:dc.b   1,  0,  5,$30,$7F,$F8
@bosspincerr_sp3:dc.b   1,  0,  4,$38,$7D,$F3
@bosspincerr_sp4:dc.b   1,$F5,  5,$28,$83,$F4
@bosspincerr_sp5:dc.b   1,  0,  5,$38,$7F,$F8

