;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000
nolist

;; TODO: Play 1 bit with various combos of noise etc
;; TODO: Play 8 bit sample with various combos etc
;; TODO: Toggle volume during tone (sid effect) (toggle others too)
;; TODO: h/w envelope with and without tone
;; TODO: Tone that matches frequency (44Khz etc) for aliasing
;; TODO: audio high tone (0,1 etc) - verify if 0 = 1 and to see how the audio playback actually handles it
;; TODO: audio low tone - how it handles it
;; TODO: audio high noise (0,1 etc) - verify if 0 = 1
;; TODO: audio low noise (0,1 etc) - verify if 0 = 1

start:

if SPEC=1
call init
call write_text_init
;;ld h,32
;;ld l,24
;;call set_dimensions
endif
if CPC=1
ld a,2
call &bc0e
endif
call cls
ld hl,message
call output_msg
call wait_key

call cls

;; b seems noticeable quieter when doing hw envelope

;; all volume values with bit 4 = 0
;; 
;; sound goes up to max and repeats.
ld hl,vol8_msg
call output_msg
call do_vol8  ;; volume channel a
ld hl,vol9_msg
call output_msg
call do_vol9  ;; volume channel b
ld hl,vol10_msg
call output_msg
call do_vol10  ;; volume channel c

;; all volume values with bit 4 = 1-1

;; always hw envelope
ld hl,hwenv8_msg
call output_msg
call do_hwenv8 ;; enable hw env channel a
ld hl,hwenv9_msg
call output_msg
call do_hwenv9 ;; enable hw env channel b
ld hl,hwenv10_msg
call output_msg
call do_hwenv10 ;; enable hw env channel c

ld hl,hw0a_msg
call output_msg
call do_wave_0a

ld hl,hw1a_msg
call output_msg
call do_wave_1a


ld hl,hw11a_msg
call output_msg
call do_wave_11a

ld hl,hw13a_msg
call output_msg
call do_wave_13a


ld hl,hw0_msg
call output_msg
call do_wave_0 ;; hw env shape 0 (and repeats)
ld hl,hw1_msg
call output_msg
call do_wave_1 ;; hw env shape 1 (and repeats)
ld hl,hw8_msg
call output_msg
call do_wave8 ;; hw env shape 8
ld hl,hw10_msg
call output_msg
call do_wave10 ;; hw env shape 10
ld hl,hw11_msg
call output_msg
call do_wave11 ;; hw env shape 11
ld hl,hw12_msg
call output_msg
call do_wave12 ;; hw env shape 12
ld hl,hw13_msg
call output_msg
call do_wave13 ;; hw env shape 13
ld hl,hw14_msg
call output_msg
call do_wave14	 ;; hw env shape 14

ld hl,noise_enable_msg
call output_msg
call do_noise_chans	;; enable noise on each channel
ld hl,noise_msg
call output_msg
call do_noise	;; go through noise range
ld hl,tone_enable_msg
call output_msg
call do_tone_chans ;; enable tone on each channel
ld hl,tone0_msg
call output_msg
call do_tone0 ;; go through tone range
ld hl,tone1_msg
call output_msg
call do_tone1 ;; go through tone range
ld hl,tone2_msg
call output_msg
call do_tone2 ;; go through tone range

ld hl,tone0_hammer_msg
call output_msg
call do_hammer_tone0
call do2_hammer_tone0

ld hl,noise_hammer_msg
call output_msg
call do_hammer_noise

ld hl,envelope_period_hammer_msg
call output_msg
call do_hammer_envelope_period
call do2_hammer_envelope_period

ld hl,mixer_hammer_msg
call output_msg
call do_hammer_mixer

ld hl,envelope_hammer_msg
call output_msg
call do_hammer_envelope

;; mix tone and noise on channel a 
ld hl,tone_noise8_msg
call output_msg
call do_mixer_8

;; mix tone and noise on channel b
ld hl,tone_noise9_msg
call output_msg
call do_mixer_9

;; mix tone and noise on channel c
ld hl,tone_noise10_msg
call output_msg
call do_mixer_10

;; Tone and noise mix all channels
ld hl,tone_noise_all_msg
call output_msg
call do_mixer_all

;; H/W Envelope, Noise and Tone mix all channels
ld hl,hw_env_nt_nn_msg
call output_msg
call do_hwenv_enable_nt_nn
ld hl,hw_env_nt_yn_msg
call output_msg
call do_hwenv_enable_nt_yn
ld hl,hw_env_yt_nn_msg
call output_msg
call do_hwenv_enable_yt_nn
ld hl,hw_env_yt_yn_msg
call output_msg
call do_hwenv_enable_yt_yn

;; H/W envelope period effect on each shape
;; all h/w envelope period values
ld hl,hw_env0_period_msg
call output_msg
call do_hwenv0_period
ld hl,hw_env8_period_msg
call output_msg
call do_hwenv8_period
ld hl,hw_env9_period_msg
call output_msg
call do_hwenv9_period
ld hl,hw_env10_period_msg
call output_msg
call do_hwenv10_period
ld hl,hw_env11_period_msg
call output_msg
call do_hwenv11_period
ld hl,hw_env12_period_msg
call output_msg
call do_hwenv12_period
ld hl,hw_env13_period_msg
call output_msg
call do_hwenv13_period
ld hl,hw_env14_period_msg
call output_msg
call do_hwenv14_period
ld hl,hw_env15_period_msg
call output_msg
call do_hwenv15_period

ld hl,noise_restart_msg
call output_msg
call do_noise_restart


ld hl,tone_restart_msg
call output_msg
call do_tone_restart

ld hl,hwenv_restart_msg
call output_msg
call do_hwenv_restart

ld hl,mix_all_vol_msg
call output_msg
call mix_all_vol

;; TODO: program just one byte of tone and one byte of h/w env period
;; TODO: Sample playback using h/w envelope
;; tone using vol register
;; play tone and then use vol register to module it like sid.

;; sample playback
call play_sample8
call play_sample9
call play_sample10
call play_1bit_sample8
call play_1bit_sample9
call play_1bit_sample10

ld hl,tests_done
call output_msg
call wait_key
rst 0

if CPC=1
;; this method used by Titus the Fox.
write_method1:
push bc
ld bc,&f782 
out (c),c
pop bc
ld b,&f4
out (c),a
ld b,&f6
in a,(c)
or &c0
out (c),a
and &3f
out (c),a
ld b,&f4
out (c),c
ld b,&f6
ld c,a
or &80
out (c),a
out (c),c
ld bc,&f792
out (c),c
ret
endif

;;  super hang on sets a h/w envelope on channel a and b
;; but one that ends up with zero volume
;; it then toggles channel c volume between 7 and f to do a buzzer sound.
;; this uses tone too.
;; empty tummy does similar to super hang on but no tone.
;; robocop 


vol8_msg:
defb "vol8 (all vol values bit 4 = 0, sound go to maximum, then back to 0 and repeat)",13,0
vol9_msg:
defb "vol9 (all vol values bit 4 = 0, sound go to maximum, then back to 0 and repeat; quieter on CPC stereo than 8,10)",13,0
vol10_msg:
defb "vol10 (all vol values bit 4 = 0, sound go to maximum, then back to 0 and repeat)",13,0
hwenv8_msg:
defb "hwenv8 (all vol values bit 4 = 1, hardware envelope all the time)",13,0
hwenv9_msg:
defb "hwenv9  (all vol values bit 4 = 1, hardware envelope all the time; quieter on cpc stereo than 8,10)",13,0
hwenv10_msg:
defb "hwenv10  (all vol values bit 4 = 1, hardware envelope all the time)",13,0


hw0a_msg:
defb "hw shape 0 \_______ - play then silent (no repeat)",13,0
hw1a_msg:
defb "hw shape 1 /|_______ - play then silent  (no repeat)",13,0

hw11a_msg:
defb "hw shape 11 \|------ - play then max volume (no repeat)",13,0

hw13a_msg:
defb "hw shape 13 /------- - play then max volume (no repeat)",13,0


hw0_msg:
defb "hw shape 0 (0,1,2,3,9)  \_______ - all possible '0' waveforms",13,0
hw1_msg:
defb "hw shape 1 (4,5,6,7, 15) /|_______ - all possible '1' waveforms",13,0
hw8_msg:
defb "hw shape 8 \|\|\|\|\|\|",13,0
hw10_msg:
defb "hw shape 10 \/\/\/\/\/ ",13,0
hw11_msg:
defb "hw shape 11 \|-------- ",13,0
hw12_msg:
defb "hw shape 12 /|/|/|/|/|/|/|/ ",13,0
hw13_msg:
defb "hw shape 13 /---------- ",13,0
hw14_msg:
defb "hw shape 14 /\/\/\/\/\/\/\/ ",13,0

noise_enable_msg:
defb "Enable noise on each channel in turn",13,0
noise_hammer_msg:
defb "Repeatidly set noise period value *while* playing",13,0
mixer_hammer_msg:
defb "Repeatidly set mixer value *while* playing",13,0
envelope_hammer_msg:
defb "Repeatidly set envelope value *while* playing",13,0
noise_msg:
defb "Go through all possible noise values",13,0
tone_enable_msg:
defb "Enable tone on each channel in turn",13,0
tone0_msg:
defb "Go through all possible tone values for channel a",13,0
tone0_hammer_msg:
defb "Repeatidly set tone period value *while* playing",13,0
envelope_period_hammer_msg:
defb "Repeatidly set hardware envelope period vaue *while* playing",13,0

tone1_msg:
defb "Go through all possible tone values for channel b",13,0
tone2_msg:
defb "Go through all possible tone values for channel c",13,0
tone_noise8_msg:
defb "Go through all possible tone and noise enables for channel a",13,0
tone_noise9_msg:
defb "Go through all possible tone and noise enables for channel b",13,0
tone_noise10_msg:
defb "Go through all possible tone and noise enables for channel c",13,0
tone_noise_all_msg:
defb "All tone and noise enables for all channels",13,0
hw_env_nt_nn_msg:
defb "enable env on each channel, H/W Envelope, No tone, no noise",13,0
hw_env_nt_yn_msg:
defb "enable env on each channel, H/W Envelope, No tone, yes noise",13,0
hw_env_yt_nn_msg:
defb "enable env on each channel, H/W Envelope, Yes tone, no noise",13,0
hw_env_yt_yn_msg:
defb "enable env on each channel, H/W Envelope, Yes tone, yes noise",13,0

hw_env0_period_msg:
defb "H/W Envelope 0 - all period",13,0
hw_env8_period_msg:
defb "H/W Envelope 8 - all period",13,0
hw_env9_period_msg:
defb "H/W Envelope 9 - all period",13,0
hw_env10_period_msg:
defb "H/W Envelope 10 - all period",13,0
hw_env11_period_msg:
defb "H/W Envelope 11 - all period",13,0
hw_env12_period_msg:
defb "H/W Envelope 12 - all period",13,0
hw_env13_period_msg:
defb "H/W Envelope 13 - all period",13,0
hw_env14_period_msg:
defb "H/W Envelope 14 - all period",13,0
hw_env15_period_msg:
defb "H/W Envelope 15 - all period",13,0

noise_restart_msg:
defb "Noise restart",13,0

tone_restart_msg:
defb "Tone restart",13,0

hwenv_restart_msg:
defb "H/W Envelope restart",13,0

mix_all_vol_msg:
defb "Mix all volumes (all channels)",13,0


do_noise_chans:
di
call reset_psg

;; set vols for all channels
ld c,8
ld a,7
call write_psg_reg
ld c,9
ld a,7
call write_psg_reg
ld c,10
ld a,7
call write_psg_reg

;; set noise
ld c,6
ld a,16
call write_psg_reg

;; go through all mixer enables for noise (a only, b only, a and b etc)
ld e,0
dn2:
ld c,7
ld a,e
add a,a
add a,a
add a,a
or %00000111
call write_psg_reg

call wait_env

inc e
ld a,e
cp 8
jr nz,dn2
ei
ret

do_mixer_8:
ld hl,mixer8
ld d,0
ld e,8
jp do_mixer_chan

do_mixer_9:
ld hl,mixer9
ld d,2
ld e,9
jp do_mixer_chan

do_mixer_10:
ld hl,mixer10
ld d,4
ld e,10
jp do_mixer_chan

mixer8:
defb %00111111
defb %00111110
defb %00110111
defb %00110110

mixer9:
defb %00111111
defb %00111101
defb %00101111
defb %00101101

mixer10:
defb %00111111
defb %00111011
defb %00011111
defb %00011011




do_mixer_chan:
di
call reset_psg


ld hl,444

;; set tone for channel
ld c,d
ld a,l
call write_psg_reg
ld c,d
inc c
ld a,h
call write_psg_reg

;; set noise
ld a,8
ld c,6
call write_psg_reg

;; set mixer
ld c,e
ld a,7
call write_psg_reg

;; set noise
ld c,6
ld a,16
call write_psg_reg

;; go through each noise and tone combination (none, tone only, noise only and both)
ld e,4
dm1:
ld a,(hl)
inc hl
ld c,7
call write_psg_reg

call wait_env
dec e
jr nz,dm1
ei
ret


do_mixer_all:
di
call reset_psg

ld hl,444

;; tone a
ld c,0
ld a,l
call write_psg_reg
ld c,1
ld a,h
call write_psg_reg

;; tone b
ld c,2
ld a,l
call write_psg_reg
ld c,3
ld a,h
call write_psg_reg

;; tone c
ld c,4
ld a,l
call write_psg_reg
ld c,5
ld a,h
call write_psg_reg

;; noise
ld a,8
ld c,6
call write_psg_reg

;; vol a
ld a,8
ld c,8
call write_psg_reg
;; vol b
ld a,8
ld c,9
call write_psg_reg
;; vol c
ld a,8
ld c,10
call write_psg_reg

;; go through all noise and tone for all channels, trying all possible values
ld e,0
dm1a:
push de
ld a,e
or %11000000
ld c,7
call write_psg_reg

call wait_env
pop de
inc e
ld a,e
cp %1000000
jr nz,dm1a
ei
ret



do_tone_chans:
di
call reset_psg

;; vol a
ld c,8
ld a,7
call write_psg_reg
;; vol b
ld c,9
ld a,7
call write_psg_reg
;; vol c
ld c,10
ld a,7
call write_psg_reg


ld hl,444

;; tone a
ld c,0
ld a,l
call write_psg_reg
ld c,1
ld a,h
call write_psg_reg

;; tone b
ld c,2
ld a,l
call write_psg_reg
ld c,3
ld a,h
call write_psg_reg

;; tone c
ld c,4
ld a,l
call write_psg_reg
ld c,5
ld a,h
call write_psg_reg

ld e,0
dt2:
ld c,7
ld a,e
or %00111000
call write_psg_reg

call wait_env

inc e
ld a,e
cp 8
jr nz,dt2
ei
ret


do_noise:
di
call reset_psg

;; set vol channel a
ld c,8
ld a,7
call write_psg_reg

;; enable noise channel a
ld c,7
ld a,%0110111
call write_psg_reg

;; do all noise values
ld e,0
dn1:
ld c,6
ld a,e
call write_psg_reg

call wait_env

inc e
jr nz,dn1
ei
ret

do_tone0:
ld de,0
jr do_tone

do_tone1:
ld de,2
jr do_tone

do_tone2:
ld de,4
jr do_tone

do_tone:
di
push de
call reset_psg

;; set vol channel a
ld c,8
ld a,7
call write_psg_reg

;; enable tone channel a
ld c,7
ld a,%0111110
call write_psg_reg
pop de
ld hl,0
dt1:
push hl
push de
ld c,e
ld a,l
call write_psg_reg
ld c,d
ld a,h
call write_psg_reg

call wait_env
pop de
pop hl
inc hl
ld a,h
or l
jr nz,dt1
ei
ret


do_hammer_tone0:
ld de,0
jr do_hammer_tone

do_hammer_tone1:
ld de,2
jr do_hammer_tone

do_hammer_tone2:
ld de,4
jr do_hammer_tone

do_hammer_tone:
di
push de
call reset_psg

;; set vol channel a
ld c,8
ld a,7
call write_psg_reg

;; enable tone channel a
ld c,7
ld a,%0111110
call write_psg_reg

ld hl,&aaa

pop de
ld bc,0
dht1:
push hl
push de
push bc
ld c,e
ld a,l
call write_psg_reg
ld c,d
ld a,h
call write_psg_reg
pop bc
pop de
pop hl
dec bc
ld a,b
or c
jr nz,dht1
ei
ret



do2_hammer_tone0:
ld de,0
jr do2_hammer_tone

do2_hammer2_tone1:
ld de,2
jr do2_hammer_tone

do2_hammer2_tone2:
ld de,4
jr do2_hammer_tone

do2_hammer_tone:
di
push de
call reset_psg

;; set vol channel a
ld c,8
ld a,7
call write_psg_reg

;; enable tone channel a
ld c,7
ld a,%0111110
call write_psg_reg

ld hl,&aaa

pop de
ld bc,0
dht12:
push hl
push de
push bc
ld c,d
ld a,h
call write_psg_reg

ld c,e
ld a,l
call write_psg_reg

pop bc
pop de
pop hl
dec bc
ld a,b
or c
jr nz,dht12
ei
ret

do_hammer_mixer:
di
call reset_psg

;; set vol channel a
ld c,8
ld a,7
call write_psg_reg

;; set tone channel a
ld de,&aaa

ld c,0
ld a,e
call write_psg_reg

ld c,1
ld a,d
call write_psg_reg

ld bc,0
dhm1:
push bc
ld c,7
ld a,%0111001
call write_psg_reg
pop bc
dec bc
ld a,b
or c
jr nz,dhm1
ei
ret

do_hammer_envelope:
di
call reset_psg

;; set vol channel a
ld c,8
ld a,16
call write_psg_reg

ld c,7
ld a,%0111111
call write_psg_reg

ld bc,0
dhe1:
push bc
ld c,13
ld a,10
call write_psg_reg
pop bc
dec bc
ld a,b
or c
jr nz,dhe1
ei
ret

do_hammer_noise:
di
call reset_psg

;; set vol channel a
ld c,8
ld a,7
call write_psg_reg

;; enable noise channel a
ld c,7
ld a,%0110111
call write_psg_reg

ld bc,0
dhn1:
push bc
ld c,6
ld a,15
call write_psg_reg
pop bc
dec bc
ld a,b
or c
jr nz,dhn1
ei
ret

do_hammer_envelope_period:
di
call reset_psg

;; set vol channel a
ld c,8
ld a,16
call write_psg_reg

ld c,13
ld a,10
call write_psg_reg

ld hl,&aaa
ld de,11

ld bc,0
dhee1:
push hl
push de
push bc
ld c,e
ld a,l
call write_psg_reg
ld c,d
ld a,h
call write_psg_reg
pop bc
pop de
pop hl
dec bc
ld a,b
or c
jr nz,dhee1
ei
ret

do2_hammer_envelope_period:
di
call reset_psg

;; set vol channel a
ld c,8
ld a,16
call write_psg_reg

ld c,13
ld a,10
call write_psg_reg

ld hl,&aaa
ld de,11

ld bc,0
dhe12:
push hl
push de
push bc
ld c,d
ld a,h
call write_psg_reg
ld c,e
ld a,l
call write_psg_reg

pop bc
pop de
pop hl
dec bc
ld a,b
or c
jr nz,dhe12
ei
ret

play_1bit_sample8:
ld c,8
jr play_1bit_sample

play_1bit_sample9:
ld c,9
jr play_1bit_sample

play_1bit_sample10:
ld c,10
jr play_1bit_sample


play_1bit_sample:
push bc
call reset_psg


pop bc


call set_psg_select_register

if SPEC=1
ld bc,&bffd
endif
if CPC=1
ld bc,&f680
out (c),c

ld b,&f4
endif
ld hl,sample_1bit
ld de,end_sample_1bit-sample_1bit

loop_1bit:
ld a,(hl)
inc hl
rept 8
rlca			;; [1]
;; nc->0
;; c->ff
sbc a,a 		;; [1]
and &f			;; [2]
out (c),a		;; [4]
defs 64-4-2-1-1
endm
dec de
ld a,d
or e
jp nz,loop_1bit
ret

sample_1bit:
include "sample2.asm"
end_sample_1bit:

;; sample no tone
;; sample with tone
;; sample using h/w envelope (high and low one).

play_sample8:
ld c,8
jr play_sample

play_sample9:
ld c,9
jr play_sample

play_sample10:
ld c,10
jr play_sample

play_sample:
push bc
call reset_psg
pop bc

;; select psg register
call set_psg_select_register

if CPC=1
;; write data
ld bc,&f680
out (c),c
;; register to write
ld b,&f4
endif
if SPEC=1
ld bc,&bffd
endif
ld hl,sample_4bit
ld de,end_sample_4bit-sample_4bit
loop_4bit:
ld a,(hl)	;; [2]
inc hl		;; [2]
rrca		;; [1]
rrca		;; [1]	
rrca		;; [1]	
rrca		;; [1]	
and &f		;; [2]
out (c),a	;; [4]
defs 64-4-2-1-1-1-1-2-2

ld a,(hl)	;; [2]
and &f		;; [2]
out (c),a	;; [4]
defs 64-4-2-2-1-1-2-3
dec de		;; [2]
ld a,d		;; [1]
or e		;; [1]
jp nz,loop_4bit ;; [3]
ret

sample_4bit:
include "sample1.asm"
end_sample_4bit:



do_vol8:
ld d,0
ld e,%111110
ld c,8
jr do_vol

do_vol9:
ld d,2
ld e,%111101
ld c,9
jr do_vol

do_vol10:
ld d,4
ld e,%111011
ld c,10
jr do_vol

do_vol:
di
push bc
push de
call reset_psg
pop de
ld c,7
ld a,e
call write_psg_reg

ld hl,444

ld a,l
ld c,d
call write_psg_reg
ld a,h
ld c,d
inc c
call write_psg_reg
pop bc

ld e,0
dv1:
ld a,e
and %11101111
push bc
call write_psg_reg

call wait_vol
pop bc

inc e
jr nz,dv1
ei
ret

do_hwenv8:
ld c,8
jr do_hwenv

do_hwenv9:
ld c,9
jr do_hwenv

do_hwenv10:
ld c,10
jr do_hwenv

do_hwenv:
di
push bc
call reset_psg

call set_hw_env_period

ld c,13
ld a,%1110
call write_psg_reg

pop bc

ld e,0
dhv1:
ld a,e
or %10000
push bc
call write_psg_reg

call wait_env_short
pop bc

inc e
jr nz,dhv1
ei
ret

do_hwenv_enable_nt_nn:
ld d,0
ld e,0
jr do_hwenv_enable

do_hwenv_enable_nt_yn:
ld d,0
ld e,1
jr do_hwenv_enable

do_hwenv_enable_yt_nn:
ld d,1
ld e,0
jr do_hwenv_enable

do_hwenv_enable_yt_yn:
ld d,1
ld e,1
jr do_hwenv_enable

mixer:
defb 0

do_hwenv_enable:
di
push de
call reset_psg
pop de

ld a,&ff
ld (mixer),a

push de
ld a,d
or a
jp z,dhve2
ld hl,444
ld c,0
ld a,l
call write_psg_reg
ld c,1
ld a,h
call write_psg_reg
ld c,2
ld a,l
call write_psg_reg
ld c,3
ld a,h
call write_psg_reg
ld c,4
ld a,l
call write_psg_reg
ld c,5
ld a,h
call write_psg_reg
ld a,(mixer)
and %11111000
ld (mixer),a

dhve2:
pop de
ld a,e
or a
jp nz,dhve3
ld c,6
ld a,5
call write_psg_reg
ld a,(mixer)
and %11000111
ld (mixer),a
dhve3:
call set_hw_env_period

ld a,(mixer)
ld c,7
call write_psg_reg

ld c,13
ld a,%1110
call write_psg_reg

ld e,0
dhve1:
push de
bit 0,e
ld a,0
jr z,dhve1a
ld a,%10000
dhve1a:
ld c,8
call write_psg_reg

bit 1,e
ld a,0
jr z,dhve1b
ld a,%10000
dhve1b:
ld c,9
call write_psg_reg

bit 2,e
ld a,0
jr z,dhve1c
ld a,%10000
dhve1c:
ld c,8
call write_psg_reg

call wait_env_short
pop de
inc e
ld a,e
cp 8
jr nz,dhve1
ei
ret

do_hwenv0_period:
ld c,0
ld hl,444
jr do_hwenv_period

do_hwenv8_period:
ld c,8
ld hl,444
jr do_hwenv_period

do_hwenv9_period:
ld c,9
ld hl,444
jr do_hwenv_period

do_hwenv10_period:
ld c,10
ld hl,444
jr do_hwenv_period

do_hwenv11_period:
ld c,11
ld hl,444
jr do_hwenv_period

do_hwenv12_period:
ld c,12
ld hl,444
jr do_hwenv_period


do_hwenv13_period:
ld c,13
ld hl,444
jr do_hwenv_period

do_hwenv14_period:
ld c,14
ld hl,444
jr do_hwenv_period

do_hwenv15_period:
ld c,15
ld hl,444
jr do_hwenv_period

;; HL = tone period
;; C = envelope shape
do_hwenv_period:
di
push bc
push hl
call reset_psg
pop hl
;; tone chan a
ld c,0
ld a,l
call write_psg_reg
ld c,1
ld a,h
call write_psg_reg
;; vol
ld c,8
ld a,16
call write_psg_reg
pop bc

ld hl,0
dhv1p:
push bc
push hl
ld a,c
ld c,13
call write_psg_reg

ld c,11
ld a,l
call write_psg_reg
ld c,12
ld a,h
call write_psg_reg

call wait_env_short
pop hl
pop bc
inc hl
ld a,h
or l
jr nz,dhv1p
ei
ret

do_hwenv_restart:
di
push hl
call reset_psg
pop hl

ld hl,444

ld c,0
ld a,l
call write_psg_reg
ld c,1
ld a,h
call write_psg_reg

ld c,8
ld a,16
call write_psg_reg


ld hl,1000
ld c,11
ld a,l
call write_psg_reg
ld c,12
ld a,l
call write_psg_reg

ld c,7
ld a,%11111110
call write_psg_reg

ld hl,dher2
ld (dher2+1),a
ld bc,4096
dher1:
push bc
;; start hw env
ld c,13
ld a,10
call write_psg_reg

dher2:
jp dher3
defs 64
dher3:

ld c,13
ld a,10
call write_psg_reg

call wait_env

ld hl,(dher2+1)
dec hl
ld (dher2+1),hl

pop bc
ld a,b
or c
jp nz,dher1

ei
ret


mix_all_vol:
di
push hl
call reset_psg
pop hl

ld hl,444

ld c,0
ld a,l
call write_psg_reg
ld c,1
ld a,h
call write_psg_reg
ld c,2
ld a,l
call write_psg_reg
ld c,3
ld a,h
call write_psg_reg
ld c,4
ld a,l
call write_psg_reg
ld c,5
ld a,h
call write_psg_reg

ld de,0
miv:
push de
ld a,e
and &f
ld c,8
call write_psg_reg
ld a,e
srl a
srl a
srl a
srl a
and &f
ld c,9
call write_psg_reg
ld a,d
and &f
ld c,10
call write_psg_reg

call wait_env

pop de
inc de
ld l,e
ld h,d
ld bc,4096
or a
sbc hl,bc
ld a,h
or l
jr nz,miv
ei
ret

do_noise_restart:
di
push hl
call reset_psg
pop hl

ld hl,444

ld c,0
ld a,l
call write_psg_reg
ld c,1
ld a,h
call write_psg_reg

ld c,8
ld a,16
call write_psg_reg

ld c,7
ld a,%11110111
call write_psg_reg

ld c,6
ld a,8
call write_psg_reg


ld hl,dnr2
ld (dnr2+1),a
ld bc,4096
dnr1:
push bc
ld c,6
ld a,8
call write_psg_reg

dnr2:
jp dnr3
defs 63
dnr3:

ld c,6
ld a,8
call write_psg_reg
call wait_env


ld hl,(dnr2+1)
dec hl
ld (dnr2+1),hl

pop bc
ld a,b
or c
jp nz,dnr1

ei
ret


do_tone_restart:
di
push hl
call reset_psg
pop hl

ld hl,444

ld c,0
ld a,l
call write_psg_reg
ld c,1
ld a,h
call write_psg_reg

ld c,8
ld a,16
call write_psg_reg

ld c,7
ld a,%11110111
call write_psg_reg


ld hl,dtr2
ld (dtr2+1),a
ld bc,62
dtr1:
push bc
ld hl,444
ld c,0
ld a,l
call write_psg_reg
ld c,1
ld a,h
call write_psg_reg

dtr2:
jp dtr3
defs 63
dtr3:

ld hl,444
ld c,0
ld a,l
call write_psg_reg
ld c,1
ld a,h
call write_psg_reg

call wait_env

ld hl,(dtr2+1)
dec hl
ld (dtr2+1),hl

pop bc
ld a,b
or c
jp nz,dtr1

ei
ret


reset_psg:
ld e,16
ld c,0
rp1:
xor a
push bc
call write_psg_reg
pop bc
inc c
dec e
jr nz,rp1
ld a,&38
ld c,7
call write_psg_reg
ret

; \____________________
do_wave_0:
di
push bc
call reset_psg


call set_hw_env_period

ld a,%10000
ld c,8
call write_psg_reg

pop bc

ld e,0

wave0:
ld c,13
ld a,e
and &f
cp %1001
jr z,dw0
ld a,e
and %11110011
or %0000
dw0:
call write_psg_reg

call wait_env

inc e
jr nz,wave0
ei
ret

do_wave_0a:
di
push bc
call reset_psg

ld hl,444

ld a,l
ld c,0
call write_psg_reg
ld a,h
ld c,1
call write_psg_reg

call set_hw_env_period
ld a,%10000
ld c,8
call write_psg_reg

ld a,0
ld c,13
call write_psg_reg

call wait_env

pop bc
ei
ret


do_wave_1a:
di
push bc
call reset_psg

ld hl,444

ld a,l
ld c,0
call write_psg_reg
ld a,h
ld c,1
call write_psg_reg

call set_hw_env_period
ld a,%10000
ld c,8
call write_psg_reg

ld a,1
ld c,13
call write_psg_reg

call wait_env

pop bc
ei
ret



do_wave_13a:
di
push bc
call reset_psg

ld hl,444

ld a,l
ld c,0
call write_psg_reg
ld a,h
ld c,1
call write_psg_reg

call set_hw_env_period
ld a,%10000
ld c,8
call write_psg_reg

ld a,13
ld c,13
call write_psg_reg

call wait_env

pop bc
ei
ret



do_wave_11a:
di
push bc
call reset_psg

ld hl,444

ld a,l
ld c,0
call write_psg_reg
ld a,h
ld c,1
call write_psg_reg

call set_hw_env_period
ld a,%10000
ld c,8
call write_psg_reg

ld a,11
ld c,13
call write_psg_reg

call wait_env

pop bc
ei
ret

; /|________________________
do_wave_1:
di
push bc
call reset_psg

call set_hw_env_period
ld a,%10000
ld c,8
call write_psg_reg

pop bc

ld e,0
wave1:
ld c,13
ld a,e
and &f
cp &f
ld a,e
jr z,dw1
ld a,e
and %11110011
or %0100
dw1:
call write_psg_reg

call wait_env

inc e
jr nz,wave1
ei
ret

; \|\|\|\|\|\|\|\|

do_wave8:

ld d,%1000
call do_wave_x
ret

; \/\/\/\/\/\/\/\/\/\/\/\

do_wave10:
ld d,%1010
call do_wave_x
ret

;;   _____________
;; \|
do_wave11:
ld d,%1011
call do_wave_x
ret

;; /|/|/|/|/|/|/|/|/
do_wave12:
ld d,%1100
call do_wave_x
ret

;;  __________
;; /
do_wave13:
ld d,%1101
call do_wave_x
ret

;; /\/\/\/\/\/\/\/\/
do_wave14:
ld d,%1110
call do_wave_x
ret


do_wave_x:
push bc
call reset_psg


call set_hw_env_period
ld a,%1000
ld c,8
call write_psg_reg

pop bc

ld e,0
wavex:
ld c,13
ld a,e
add a,a
add a,a
add a,a
add a,a
or d
call write_psg_reg

call wait_env

inc e
ld a,e
cp 16
jr nz,wavex
ret




wait_vol:
push bc
ld bc,3
jr wait_frames




wait_env_short:
push bc
ld bc,12
jr wait_frames

wait_env:
push bc
ld bc,25
jr wait_frames

wait_frames:
we1:
push bc
call vsync_sync
pop bc
dec bc
ld a,b
or c
jr nz,we1

pop bc
ret


set_hw_env_period:
ld hl,5

ld c,11
ld a,l
call write_psg_reg
ld c,12
ld a,h
call write_psg_reg
ret


tests_done:
defb "Tests complete",0



message:
defb "This is an audible test.",13,13
defb "This test produces sound using the PSG and ",13
defb "tests all the registers in different combinations",13,13
defb "Run this test in mono (through speaker) and stereo",13,13
defb "Press a key to start",0

include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/outputdec.asm"
include "../lib/output.asm"
include "../lib/hw/fdc.asm"
if CPC=1
include "../lib/hw/psg.asm"
include "../lib/fw/output.asm"
include "../lib/hw/cpc.asm"
include "../lib/hw/crtc.asm"
endif
if SPEC=1
include "../lib/spec/psg.asm"
include "../lib/spec/init.asm"
include "../lib/spec/keyfn.asm"
include "../lib/spec/printtext.asm"
include "../lib/spec/readkeys.asm"
include "../lib/spec/scr.asm"
include "../lib/spec/writetext.asm"

sysfont:
incbin "../lib/spec/font.bin"

endif

end start