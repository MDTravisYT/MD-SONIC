
	
ym2612_a0:		equ $A04000
ym2612_d0:		equ $A04001
ym2612_a1:		equ $A04002
ym2612_d1:		equ $A04003

z80_ram:		equ $A00000	
z80_port_1_control:	equ $A10008
z80_expansion_control:	equ $A1000C
z80_dac3_pitch:		equ $A000EA
Z80_RESET		=	$A11200
z80_dac_status:		equ $A01FFD
z80_dac_sample:		equ $A01FFF
SEGATMSS		=	$A14000
psg_input: equ $C00011

; Sound driver constants
TrackPlaybackControl:	equ 0		; All tracks
TrackVoiceControl:	equ 1		; All tracks
TrackTempoDivider:	equ 2		; All tracks
TrackDataPointer:	equ 4		; All tracks (4 bytes)
TrackTranspose:		equ 8		; FM/PSG only (sometimes written to as a word, to include TrackVolume)
TrackVolume:		equ 9		; FM/PSG only
TrackAMSFMSPan:		equ $A		; FM/DAC only
TrackVoiceIndex:	equ $B		; FM/PSG only
TrackVolEnvIndex:	equ $C		; PSG only
TrackStackPointer:	equ $D		; All tracks
TrackDurationTimeout:	equ $E		; All tracks
TrackSavedDuration:	equ $F		; All tracks
TrackSavedDAC:		equ $10		; DAC only
TrackFreq:		equ $10		; FM/PSG only (2 bytes)
TrackNoteTimeout:	equ $12		; FM/PSG only
TrackNoteTimeoutMaster:equ $13		; FM/PSG only
TrackModulationPtr:	equ $14		; FM/PSG only (4 bytes)
TrackModulationWait:	equ $18		; FM/PSG only
TrackModulationSpeed:	equ $19		; FM/PSG only
TrackModulationDelta:	equ $1A		; FM/PSG only
TrackModulationSteps:	equ $1B		; FM/PSG only
TrackModulationVal:	equ $1C		; FM/PSG only (2 bytes)
TrackDetune:		equ $1E		; FM/PSG only
TrackPSGNoise:		equ $1F		; PSG only
TrackFeedbackAlgo:	equ $1F		; FM only
TrackVoicePtr:		equ $20		; FM SFX only (4 bytes)
TrackLoopCounters:	equ $24		; All tracks (multiple bytes)
TrackGoSubStack:	equ TrackSz	; All tracks (multiple bytes. This constant won't get to be used because of an optimisation that just uses TrackSz)

TrackSz:	equ $30

v_snddriver_ram	= 	$FFFFF000 

v_startofvariables:	equ $000
v_sndprio:		equ $000	; sound priority (priority of new music/SFX must be higher or equal to this value or it won't play; bit 7 of priority being set prevents this value from changing)
v_main_tempo_timeout:	equ $001	; Counts down to zero; when zero, resets to next value and delays song by 1 frame
v_main_tempo:		equ $002	; Used for music only
f_pausemusic:		equ $003	; flag set to stop music when paused
v_fadeout_counter:	equ $004

v_fadeout_delay:	equ $006
v_communication_byte:	equ $007	; used in Ristar to sync with a boss' attacks; unused here
f_updating_dac:		equ $008	; $80 if updating DAC, $00 otherwise
v_sound_id:		equ $009	; sound or music copied from below
v_soundqueue0:		equ $00A	; sound or music to play
v_soundqueue1:		equ $00B	; special sound to play
v_soundqueue2:		equ $00C	; unused sound to play

f_voice_selector:	equ $00E	; $00 = use music voice pointer; $40 = use special voice pointer; $80 = use track voice pointer

v_voice_ptr:		equ $018	; voice data pointer (4 bytes)

v_special_voice_ptr:	equ $020	; voice data pointer for special SFX ($D0-$DF) (4 bytes)

f_fadein_flag:		equ $024	; Flag for fade in
v_fadein_delay:		equ $025
v_fadein_counter:	equ $026	; Timer for fade in/out
f_1up_playing:		equ $027	; flag indicating 1-up song is playing
v_tempo_mod:		equ $028	; music - tempo modifier
v_speeduptempo:		equ $029	; music - tempo modifier with speed shoes
f_speedup:		equ $02A	; flag indicating whether speed shoes tempo is on ($80) or off ($00)
v_ring_speaker:		equ $02B	; which speaker the "ring" sound is played in (00 = right; 01 = left)
f_push_playing:		equ $02C	; if set, prevents further push sounds from playing

v_music_track_ram:	equ $040	; Start of music RAM

v_music_fmdac_tracks:	equ v_music_track_ram+TrackSz*0
v_music_dac_track:	equ v_music_fmdac_tracks+TrackSz*0
v_music_fm_tracks:	equ v_music_fmdac_tracks+TrackSz*1
v_music_fm1_track:	equ v_music_fm_tracks+TrackSz*0
v_music_fm2_track:	equ v_music_fm_tracks+TrackSz*1
v_music_fm3_track:	equ v_music_fm_tracks+TrackSz*2
v_music_fm4_track:	equ v_music_fm_tracks+TrackSz*3
v_music_fm5_track:	equ v_music_fm_tracks+TrackSz*4
v_music_fm6_track:	equ v_music_fm_tracks+TrackSz*5
v_music_fm_tracks_end:	equ v_music_fm_tracks+TrackSz*6
v_music_fmdac_tracks_end:	equ v_music_fm_tracks_end
v_music_psg_tracks:	equ v_music_fmdac_tracks_end
v_music_psg1_track:	equ v_music_psg_tracks+TrackSz*0
v_music_psg2_track:	equ v_music_psg_tracks+TrackSz*1
v_music_psg3_track:	equ v_music_psg_tracks+TrackSz*2
v_music_psg_tracks_end:	equ v_music_psg_tracks+TrackSz*3
v_music_track_ram_end:	equ v_music_psg_tracks_end

v_sfx_track_ram:	equ v_music_track_ram_end	; Start of SFX RAM, straight after the end of music RAM

v_sfx_fm_tracks:	equ v_sfx_track_ram+TrackSz*0
v_sfx_fm3_track:	equ v_sfx_fm_tracks+TrackSz*0
v_sfx_fm4_track:	equ v_sfx_fm_tracks+TrackSz*1
v_sfx_fm5_track:	equ v_sfx_fm_tracks+TrackSz*2
v_sfx_fm_tracks_end:	equ v_sfx_fm_tracks+TrackSz*3
v_sfx_psg_tracks:	equ v_sfx_fm_tracks_end
v_sfx_psg1_track:	equ v_sfx_psg_tracks+TrackSz*0
v_sfx_psg2_track:	equ v_sfx_psg_tracks+TrackSz*1
v_sfx_psg3_track:	equ v_sfx_psg_tracks+TrackSz*2
v_sfx_psg_tracks_end:	equ v_sfx_psg_tracks+TrackSz*3
v_sfx_track_ram_end:	equ v_sfx_psg_tracks_end

v_spcsfx_track_ram:	equ v_sfx_track_ram_end	; Start of special SFX RAM, straight after the end of SFX RAM

v_spcsfx_fm4_track:	equ v_spcsfx_track_ram+TrackSz*0
v_spcsfx_psg3_track:	equ v_spcsfx_track_ram+TrackSz*1
v_spcsfx_track_ram_end:	equ v_spcsfx_track_ram+TrackSz*2

v_1up_ram_copy:		equ v_spcsfx_track_ram_end

; Background music
bgm__First:	equ $81
bgm_GHZ:	equ ((ptr_mus81-MusicIndex)/4)+bgm__First
bgm_LZ:		equ ((ptr_mus82-MusicIndex)/4)+bgm__First
bgm_MZ:		equ ((ptr_mus83-MusicIndex)/4)+bgm__First
bgm_SLZ:	equ ((ptr_mus84-MusicIndex)/4)+bgm__First
bgm_SYZ:	equ ((ptr_mus85-MusicIndex)/4)+bgm__First
bgm_SBZ:	equ ((ptr_mus86-MusicIndex)/4)+bgm__First
bgm_Invincible:	equ ((ptr_mus87-MusicIndex)/4)+bgm__First
bgm_ExtraLife:	equ ((ptr_mus88-MusicIndex)/4)+bgm__First
bgm_SS:		equ ((ptr_mus89-MusicIndex)/4)+bgm__First
bgm_Title:	equ ((ptr_mus8A-MusicIndex)/4)+bgm__First
bgm_Ending:	equ ((ptr_mus8B-MusicIndex)/4)+bgm__First
bgm_Boss:	equ ((ptr_mus8C-MusicIndex)/4)+bgm__First
bgm_FZ:		equ ((ptr_mus8D-MusicIndex)/4)+bgm__First
bgm_GotThrough:	equ ((ptr_mus8E-MusicIndex)/4)+bgm__First
bgm_GameOver:	equ ((ptr_mus8F-MusicIndex)/4)+bgm__First
bgm_Continue:	equ ((ptr_mus90-MusicIndex)/4)+bgm__First
bgm_Credits:	equ ((ptr_mus91-MusicIndex)/4)+bgm__First
bgm_Drowning:	equ ((ptr_mus92-MusicIndex)/4)+bgm__First
bgm_Emerald:	equ ((ptr_mus93-MusicIndex)/4)+bgm__First
bgm__Last:	equ ((ptr_musend-MusicIndex-4)/4)+bgm__First

; Sound effects
sfx__First:	equ $A0
		rsset $A0
SFXSkid				rs.b 1
SFXDash				rs.b 1
SFXJump				rs.b 1
SFXDie				rs.b 1
SFXRingLoss			rs.b 1
SFXRingRight		rs.b 1
SFXDestroy			rs.b 1
SFXShield			rs.b 1
SFXSpring			rs.b 1
SFXButton			rs.b 1
SFXTally			rs.b 1
SFXRollFade			rs.b 1
SFXRollCont			rs.b 1
SFXSignpost			rs.b 1
SFXExplosion		rs.b 1
SFXPop				rs.b 1
SFXNoisePop			rs.b 1
SFXidk				rs.b 1
SFXWaterSplash		rs.b 1
SFXCrumble			rs.b 1
SFXDoor				rs.b 1
SFXUnused			rs.b 1
SFXWaterfall		rs.b 1
SFXThorn			rs.b 1
SFXRingLeft			rs.b 1
SFXTravel			rs.b 1
SFXRollJam			rs.b 1
SFXStop			rs.b 1
SFXBoing			rs.b 1
SFXPound			rs.b 1
		rsreset
sfx__Last:	equ ((ptr_sndend-SoundIndex-4)/4)+sfx__First

; Special sound effects
spec__First:	equ $D0
sfx_Waterfall:	equ ((ptr_sndD0-SpecSoundIndex)/4)+spec__First
spec__Last:	equ ((ptr_specend-SpecSoundIndex-4)/4)+spec__First

flg__First:	equ $E0
bgm_Fade:	equ ((ptr_flgE0-Sound_ExIndex)/4)+flg__First
sfx_Sega:	equ ((ptr_flgE1-Sound_ExIndex)/4)+flg__First
bgm_Speedup:	equ ((ptr_flgE2-Sound_ExIndex)/4)+flg__First
bgm_Slowdown:	equ ((ptr_flgE3-Sound_ExIndex)/4)+flg__First
bgm_Stop:	equ ((ptr_flgE4-Sound_ExIndex)/4)+flg__First
flg__Last:	equ ((ptr_flgend-Sound_ExIndex-4)/4)+flg__First