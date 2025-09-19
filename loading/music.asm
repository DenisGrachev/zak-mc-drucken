

	;test code

begin

	ld hl,music_data
	call play
	ret
	
	
	
;Squeeker Plus
;ZX Spectrum beeper engine by utz
;based on Squeeker by zilogat0r

BORDER equ #ff



;HL = add counter ch1
;DE = add counter ch2
;IX = add counter ch3
;IY = add counter ch4
;BC = basefreq ch1-4
;SP = buffer pointer

	
play

	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (mLoopVar),de
	ld (seqpntr),hl
	
	ei			;detect kempston
	halt
	in a,(#1f)
	inc a
	jr nz,_skip
	ld (maskKempston),a
_skip	
	di
	exx
	push hl			;preserve HL' for return to BASIC
	ld (oldSP),sp

;******************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0
	
	;jp exit		;uncomment to disable looping
	
mLoopVar=$+1
	ld sp,0		;get loop point
	jr rdseq+3

;******************************************************************
rdptn0
	;ld (ptnpntr),de
	ex de,hl
	ld sp,hl
	ld iy,0
rdptn
	in a,(#1f)		;read joystick
maskKempston equ $+1
	and #1f
	ld c,a
	in a,(#fe)		;read kbd
	cpl
	or c
	and #1f
	jp nz,exit


;ptnpntr equ $+1
;	ld sp,0	
	
	pop af
	jr z,rdseq
	
	ld i,a
	
	exx
	
	pop hl
	ld a,h
	ld (noise1),a
	ld a,l
	ld (noise2),a
	
	jr c,ld2
	pop hl
	ld (fch1),hl
	pop hl
	ld (envset1),hl
	ld a,(hl)
	ld (duty1),a
	exx
	ld hl,0
	exx
ld2	
	jp pe,ld3
	pop hl
	ld (fch2),hl
	pop hl
	ld (envset2),hl
	ld a,(hl)
	ld (duty2),a
	exx
	ld de,0
	exx
ld3
	jp m,ld4	
	pop hl
	ld (fch3),hl
	pop hl
	ld (envset3),hl
	ld a,(hl)
	ld (duty3),a
	ld ix,0
ld4	
	pop af
	jr z,ldx
	pop hl
	ld (fch4),hl		;freq 4
	ld iy,0
	ld de,0

	ld a,slideskip-jrcalc1
	jr nc,nokick
	ld a,d			;A=0
	ex de,hl
nokick
	ld (jrcalc),a
	pop hl
	ld (envset4),hl
	ld a,(hl)
	ld (duty4),a

ldx	
	jp pe,drum1
	jp m,drum2
	xor a
	ld c,a
drumret
	ex af,af'	
	

		
	;ld (ptnpntr),sp
	ld b,#80
	
	exx
	
;******************************************************************
playNote

fch1 equ $+1
	ld bc,0			;10
	add hl,bc		;11
noise1
	db #00,#04		;8	;replaced with cb 04 (rlc h) for noise
					; - 04 is inc b, which has no effect
duty1 equ $+1
	ld a,0			;7
	add a,h			;4
	exx			;4
	rl c			;8
	exx			;4
	
	ex de,hl		;4
fch2 equ $+1
	ld bc,0			;10
	add hl,bc		;11
noise2
	db #00,#04		;8
duty2 equ $+1
	ld a,0			;7
	add a,h			;4
	ex de,hl		;4
	exx			;4
	rl c			;8
	exx			;4

fch3 equ $+1
	ld bc,0			;10
	add ix,bc		;15
	
duty3 equ $+1
	ld a,0			;7
	add a,ixh		;8
	exx			;4
	rl c			;8
	exx			;4
				;176

fch4 equ $+1
	ld bc,0			;10
	add iy,bc		;15
duty4 equ $+1
	ld a,0			;7
	add a,iyh		;8
	
	exx			;4
	ld a,#f			;7
	adc a,c			;4
	ld c,0			;7
	exx			;4
	
	and BORDER		;7
	out (#fe),a		;11
	
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	
	jp playNote		;10
				;368

;******************************************************************
updateTimer
	ex af,af'
	
	exx
	
envset1 equ $+1			;update duty envelope pointers
	ld hl,0
	inc hl
	ld a,(hl)
	cp b			;check for envelope end (b = #80)
	jr z,e2
	ld (duty1),a
	ld (envset1),hl
e2	
envset2 equ $+1
	ld hl,0
	inc hl
	ld a,(hl)
	cp b
	jr z,e3
	ld (duty2),a
	ld (envset2),hl
e3
envset3 equ $+1
	ld hl,0
	inc hl
	ld a,(hl)
	cp b
	jr z,e4
	ld (duty3),a
	ld (envset3),hl
e4	
envset4 equ $+1
	ld hl,0
	inc hl
	ld a,(hl)
	cp b
	jr z,eex
	ld (duty4),a
	ld (envset4),hl

eex
jrcalc equ $+1
	jr slideskip		;
jrcalc1
	ld hl,(fch4)		;update ch4 pitch
	srl d			;if pitch slide is enabled, de = freq.ch4
	rr e			;else, de = 0
	
	sbc hl,de		;thus, freq.ch4 = freq.ch4 - int(freq.ch4/2)
	ld (fch4),hl		;if pitch slide is enabled, else no change
 	
	ld iy,0			;reset add counter ch4 so it isn't accidentally

slideskip			;left in a 'high' state
	
	exx
	
	ld a,i
	dec a
	jp z,rdptn
	ld i,a
	jp playNote

;******************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************
drum2
	ld hl,hat1
	ld b,hat1end-hat1
	jr drentry
drum1
	ld hl,kick1		;10
	ld b,kick1end-kick1	;7
drentry
	xor a			;4
_s2	
	xor BORDER		;7
	ld c,(hl)		;7
	inc hl			;6
_s1	
	out (#fe),a		;11
	dec c			;4
	jr nz,_s1		;12/7    
	
	djnz _s2		;13/8
	ld a,#6d		;7	;correct tempo
	jp drumret		;10
	
kick1					;27*16*4 + 27*32*4 + 27*64*4 + 27*128*4 + 27*256*4 = 53568, + 20*33 = 53568 -> -147,4 loops -> AF' = #6D
	ds 4,#10
	ds 4,#20
	ds 4,#40
	ds 4,#80
	ds 4,0
kick1end

hat1
	db 16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3,16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3
	db 12,8,1,24,6,7,4,9,18,12,8,3,11,7,5,8,3,17,9,15,22,6,5,8,11,13,4,8,12,9,2,4,7,8,12,6,7,4,19,22,1,9,6,27,4,3,11
	db 5,8,14,2,11,13,5,9,2,17,10,3,7,19,4,3,8,2,9,11,4,17,6,4,9,14,2,22,8,4,19,2,3,5,11,1,16,20,4,7
	db 8,9,4,12,2,8,14,3,7,7,13,9,15,1,8,4,17,3,22,4,8,11,4,21,9,6,12,4,3,8,7,17,5,9,2,11,17,4,9,3,2
	db 22,4,7,3,8,9,4,11,8,5,9,2,6,2,8,8,3,11,5,3,9,6,7,4,8
hat1end

env0
	db 0,#80

;compiled music data

music_data
	dw .loop
	dw .pattern1
.loop:
	dw .pattern2
	dw 0
.pattern1
	db #40
.pattern2
	dw #600,#0,#dd,env1,#1b2,env5,#0,env1,#5,#706,env10
	dw #385,#0,#40
	dw #680,#0,#1be,env2,#375,env6,#c0
	dw #380,#0,#0,env2,#0,env6,#40
	dw #685,#0,#5,#706,env10
	dw #385,#0,#40
	dw #680,#0,#1be,env2,#375,env6,#c0
	dw #385,#0,#40
	dw #680,#0,#213,env3,#41b,env7,#5,#706,env10
	dw #380,#0,#0,env3,#0,env7,#40
	dw #680,#0,#213,env3,#41b,env7,#c0
	dw #380,#0,#1f5,env4,#3df,env8,#5,#706,env10
	dw #680,#0,#0,env4,#0,env8,#5,#706,env10
	dw #380,#0,#1f5,env4,#3db,env8,#40
	dw #680,#0,#1d9,env4,#3a2,env8,#5,#706,env10
	dw #380,#0,#0,env4,#0,env8,#c0
	dw #680,#0,#dd,env1,#1b2,env5,#5,#706,env10
	dw #385,#0,#40
	dw #680,#0,#1be,env2,#375,env6,#c0
	dw #380,#0,#0,env2,#0,env6,#40
	dw #685,#0,#5,#706,env10
	dw #385,#0,#40
	dw #680,#0,#1be,env2,#375,env6,#c0
	dw #385,#0,#40
	dw #680,#0,#213,env3,#41b,env7,#5,#706,env10
	dw #380,#0,#0,env3,#0,env7,#40
	dw #680,#0,#213,env3,#41b,env7,#c0
	dw #380,#0,#1f5,env4,#3df,env8,#c0
	dw #680,#cb,#0,env4,#3852,env4,#5,#706,env10
	dw #384,#cb,#1f5,env4,#5,#706,env10
	dw #680,#0,#1d9,env4,#3a2,env8,#5,#706,env10
	dw #380,#0,#0,env4,#0,env8,#40
	dw #680,#0,#dd,env1,#1b2,env5,#5,#706,env10
	dw #385,#0,#40
	dw #680,#0,#1be,env2,#375,env6,#c0
	dw #380,#0,#0,env2,#0,env6,#40
	dw #681,#cb,#3852,env4,#5,#706,env10
	dw #381,#0,#0,env4,#40
	dw #680,#0,#1be,env2,#371,env6,#c0
	dw #385,#0,#40
	dw #680,#0,#213,env3,#41b,env7,#5,#706,env10
	dw #380,#0,#0,env3,#0,env7,#40
	dw #680,#0,#213,env3,#41b,env7,#c0
	dw #380,#0,#1f5,env4,#3db,env8,#c0
	dw #680,#cb,#0,env4,#3852,env4,#5,#706,env10
	dw #384,#cb,#1f5,env4,#5,#706,env10
	dw #680,#0,#1d9,env4,#3a2,env8,#5,#706,env10
	dw #380,#0,#0,env4,#0,env8,#40
	dw #680,#0,#1be,env11,#361,env2,#5,#706,env10
	dw #385,#0,#40
	dw #680,#0,#dd,env1,#1b2,env5,#40
	dw #385,#0,#40
	dw #680,#0,#1a5,env11,#332,env3,#5,#706,env10
	dw #385,#0,#40
	dw #680,#0,#dd,env2,#1ae,env6,#40
	dw #385,#0,#40
	dw #680,#cb,#18d,env3,#3852,env4,#5,#706,env10
	dw #384,#cb,#0,env3,#5,#706,env10
	dw #680,#0,#18d,env3,#307,env4,#5,#706,env10
	dw #385,#0,#5,#706,env10
	dw #680,#cb,#176,env4,#3852,env4,#5,#706,env10
	dw #381,#0,#0,env4,#40
	dw #680,#0,#14d,env4,#28b,env5,#40
	dw #385,#0,#40
	dw #680,#0,#dd,env1,#1b2,env5,#5,#706,env10
	dw #385,#0,#40
	dw #680,#0,#1be,env2,#375,env6,#c0
	dw #380,#0,#0,env2,#0,env6,#40
	dw #681,#cb,#3852,env4,#5,#706,env10
	dw #301,#0,#0,env4,#6fa,env9,#40
	dw #600,#0,#dd,env3,#1ae,env67,#536,env13,#c0
	dw #385,#0,#5,#706,env10
	dw #600,#0,#1be,env3,#371,env7,#84b,env14,#5,#706,env10
	dw #300,#0,#0,env3,#0,env7,#0,env14,#40
	dw #680,#0,#dd,env4,#1ae,env8,#c0
	dw #305,#0,#952,env15,#c0
	dw #600,#cb,#107,env4,#3852,env4,#0,env15,#5,#706,env10
	dw #381,#0,#0,env4,#40
	dw #600,#0,#213,env5,#417,env6,#a75,env16,#5,#706,env10
	dw #300,#0,#0,env5,#0,env6,#0,env16,#c0
	dw #680,#0,#dd,env1,#1b2,env5,#5,#706,env10
	dw #385,#0,#40
	dw #680,#0,#1be,env2,#375,env6,#c0
	dw #380,#0,#0,env2,#0,env6,#40
	dw #681,#cb,#3852,env4,#5,#706,env10
	dw #301,#0,#0,env4,#a79,env17,#40
	dw #600,#0,#dd,env3,#1ae,env6,#952,env17,#c0
	dw #305,#0,#c74,env18,#5,#706,env10
	dw #600,#0,#1be,env3,#371,env6,#a75,env18,#5,#706,env10
	dw #300,#0,#0,env3,#0,env6,#0,env18,#40
	dw #600,#0,#dd,env4,#1ae,env7,#a71,env19,#c0
	dw #305,#0,#843,env1,#c0
	dw #600,#cb,#107,env4,#3852,env4,#946,env19,#5,#706,env10
	dw #301,#0,#0,env4,#a6d,env2,#40
	dw #600,#0,#213,env5,#417,env8,#843,env18,#5,#706,env10
	dw #300,#0,#0,env5,#0,env8,#0,env18,#c0
	dw #600,#0,#dd,env1,#1b2,env4,#6f2,env17,#5,#706,env10
	dw #305,#0,#0,env17,#40
	dw #680,#0,#1be,env2,#371,env3,#c0
	dw #380,#0,#0,env2,#0,env3,#40
	dw #681,#cb,#3852,env4,#5,#706,env10
	dw #301,#0,#0,env4,#6fa,env16,#40
	dw #600,#0,#dd,env3,#1ae,env3,#c78,env3,#c0
	dw #305,#0,#0,env3,#5,#706,env10
	dw #600,#0,#1be,env3,#36d,env2,#c74,env15,#5,#706,env10
	dw #300,#0,#0,env3,#0,env2,#a75,env4,#40
	dw #600,#0,#dd,env4,#1aa,env2,#0,env4,#c0
	dw #305,#0,#a8d,env14,#c0
	dw #600,#cb,#107,env4,#3852,env4,#c74,env3,#5,#706,env10
	dw #301,#0,#0,env4,#0,env3,#40
	dw #600,#0,#213,env5,#413,env3,#a71,env13,#5,#706,env10
	dw #300,#0,#0,env5,#0,env3,#94e,env2,#c0
	dw #600,#0,#dd,env6,#1ae,env4,#0,env2,#5,#706,env10
	dw #305,#0,#a79,env9,#40
	dw #600,#0,#1be,env6,#371,env5,#952,env1,#c0
	dw #300,#0,#0,env6,#0,env5,#0,env1,#40
	dw #685,#0,#5,#706,env10
	dw #385,#0,#40
	dw #680,#0,#dd,env5,#1aa,env5,#c0
	dw #305,#0,#952,env9,#5,#706,env10
	dw #600,#0,#1be,env4,#36d,env6,#c74,env13,#5,#706,env10
	dw #300,#0,#0,env4,#0,env6,#0,env14,#40
	dw #600,#0,#dd,env3,#1a6,env6,#c74,env15,#c0
	dw #305,#0,#a71,env15,#c0
	dw #600,#cb,#107,env2,#3852,env4,#c70,env16,#5,#706,env10
	dw #301,#0,#0,env4,#0,env16,#40
	dw #600,#0,#213,env1,#40f,env7,#d2b,env17,#5,#706,env10
	dw #300,#0,#0,env1,#0,env7,#df1,env18,#c0
	dw #600,#0,#dd,env1,#1b2,env5,#0,env18,#5,#706,env10
	dw #385,#0,#40
	dw #600,#0,#1be,env1,#375,env5,#10b3,env19,#c0
	dw #300,#0,#0,env1,#0,env5,#12cc,env1,#40
	dw #600,#cb,#128,env2,#3852,env4,#e05,env18,#5,#706,env10
	dw #300,#0,#255,env2,#4a3,env5,#0,env18,#40
	dw #600,#0,#dd,env3,#1b2,env6,#a7d,env18,#c0
	dw #305,#0,#c7c,env17,#5,#706,env10
	dw #600,#0,#1be,env3,#371,env6,#0,env17,#5,#706,env10
	dw #300,#0,#0,env3,#0,env6,#c78,env2,#40
	dw #600,#0,#dd,env3,#1ae,env6,#0,env2,#c0
	dw #305,#0,#a79,env16,#c0
	dw #600,#cb,#128,env3,#3852,env4,#c78,env19,#5,#706,env10
	dw #300,#0,#255,env4,#49f,env7,#0,env19,#40
	dw #600,#0,#213,env4,#41b,env7,#d37,env15,#5,#706,env10
	dw #300,#0,#0,env4,#0,env7,#e01,env14,#c0
	dw #600,#0,#dd,env4,#1aa,env7,#0,env14,#5,#706,env10
	dw #385,#0,#40
	dw #600,#0,#1be,env4,#36d,env7,#10a7,env13,#c0
	dw #300,#0,#0,env4,#0,env7,#12b4,env9,#40
	dw #600,#cb,#128,env5,#3852,env4,#13d3,env15,#5,#706,env10
	dw #300,#0,#255,env5,#49b,env7,#1502,env15,#40
	dw #600,#0,#dd,env5,#1aa,env7,#12b4,env1,#c0
	dw #305,#0,#0,env1,#5,#706,env10
	dw #600,#0,#1be,env6,#369,env8,#12b0,env16,#5,#706,env10
	dw #300,#0,#0,env6,#0,env8,#df9,env1,#40
	dw #600,#0,#dd,env5,#1aa,env7,#0,env1,#c0
	dw #305,#0,#10a7,env17,#c0
	dw #600,#cb,#18d,env4,#3852,env4,#dfd,env15,#5,#706,env10
	dw #300,#0,#31f,env3,#632,env6,#0,env15,#40
	dw #600,#0,#213,env2,#41b,env5,#c78,env18,#5,#706,env10
	dw #300,#0,#0,env2,#0,env5,#e01,env2,#c0
	dw #600,#0,#dd,env1,#1b2,env5,#0,env2,#5,#706,env10
	dw #305,#0,#12bc,env19,#40
	dw #600,#0,#1be,env1,#375,env5,#e05,env1,#c0
	dw #300,#0,#0,env1,#0,env5,#a81,env17,#40
	dw #600,#cb,#128,env2,#3852,env4,#c84,env16,#5,#706,env10
	dw #300,#0,#255,env2,#4b3,env5,#a81,env1,#40
	dw #600,#0,#dd,env2,#1b2,env5,#956,env15,#c0
	dw #305,#0,#10af,env1,#5,#706,env10
	dw #600,#0,#1be,env3,#375,env6,#e05,env14,#5,#706,env10
	dw #300,#0,#0,env3,#0,env6,#c7c,env1,#40
	dw #600,#0,#dd,env3,#1ae,env6,#e01,env13,#c0
	dw #305,#0,#c78,env1,#c0
	dw #600,#cb,#107,env3,#3852,env4,#a79,env16,#5,#706,env10
	dw #301,#0,#0,env4,#0,env16,#40
	dw #600,#0,#213,env4,#41b,env6,#c78,env2,#5,#706,env10
	dw #300,#0,#0,env4,#0,env6,#0,env2,#c0
	dw #600,#0,#dd,env4,#1aa,env6,#12b4,env12,#5,#706,env10
	dw #385,#0,#40
	dw #600,#0,#1be,env4,#371,env5,#11a6,env12,#c0
	dw #380,#0,#0,env4,#0,env5,#40
	dw #605,#0,#10ab,env12,#5,#706,env10
	dw #385,#0,#40
	dw #600,#0,#dd,env5,#1ae,env5,#e01,env12,#c0
	dw #385,#0,#5,#706,env10
	dw #600,#0,#1be,env6,#371,env4,#c78,env9,#5,#706,env10
	dw #300,#0,#0,env6,#0,env4,#a79,env13,#40
	dw #600,#0,#dd,env5,#1b2,env4,#956,env14,#c0
	dw #305,#0,#84f,env15,#c0
	dw #600,#cb,#107,env4,#3852,env4,#95a,env16,#5,#706,env10
	dw #301,#0,#0,env4,#a7d,env17,#40
	dw #600,#0,#213,env3,#41f,env4,#84f,env18,#5,#706,env10
	dw #300,#0,#0,env3,#0,env4,#0,env18,#c0
	dw #600,#0,#dd,env1,#1b2,env4,#6fa,env9,#5,#706,env10
	dw #305,#0,#0,env9,#40
	dw #680,#0,#1be,env1,#375,env4,#c0
	dw #380,#0,#0,env1,#0,env4,#40
	dw #605,#0,#e05,env12,#5,#706,env10
	dw #305,#0,#c7c,env12,#40
	dw #600,#0,#1be,env1,#375,env4,#a7d,env12,#c0
	dw #305,#0,#10af,env12,#40
	dw #600,#0,#213,env2,#41b,env5,#e01,env12,#5,#706,env10
	dw #300,#0,#0,env2,#0,env5,#c78,env12,#40
	dw #600,#0,#213,env2,#41b,env5,#12b8,env12,#c0
	dw #300,#0,#1f5,env2,#3df,env5,#10ab,env12,#5,#706,env10
	dw #600,#0,#0,env2,#0,env5,#e01,env12,#5,#706,env10
	dw #300,#0,#1f5,env3,#3df,env5,#a79,env12,#40
	dw #600,#0,#1d9,env3,#3a6,env5,#c78,env12,#5,#706,env10
	dw #300,#0,#0,env3,#0,env5,#e01,env12,#c0
	dw #600,#0,#dd,env4,#1aa,env6,#6f2,env13,#5,#706,env10
	dw #305,#0,#0,env13,#40
	dw #680,#0,#1be,env4,#36d,env6,#c0
	dw #380,#0,#0,env4,#0,env6,#40
	dw #605,#0,#12b4,env12,#5,#706,env10
	dw #305,#0,#13d3,env12,#40
	dw #600,#0,#1be,env4,#36d,env6,#1502,env12,#c0
	dw #305,#0,#12b4,env12,#40
	dw #600,#0,#213,env5,#417,env6,#10a7,env12,#5,#706,env10
	dw #300,#0,#0,env5,#0,env6,#12b4,env12,#40
	dw #600,#0,#213,env5,#417,env7,#dfd,env12,#c0
	dw #300,#0,#1f5,env5,#3db,env7,#0,env12,#c0
	dw #600,#cb,#0,env5,#3852,env4,#c78,env14,#5,#706,env10
	dw #304,#cb,#1f5,env6,#e01,env15,#5,#706,env10
	dw #600,#0,#1d9,env6,#3a2,env7,#0,env15,#5,#706,env10
	dw #300,#0,#0,env6,#0,env7,#e01,env1,#40
	dw #600,#0,#dd,env5,#1aa,env6,#6f6,env13,#5,#706,env10
	dw #305,#0,#0,env13,#40
	dw #680,#0,#1be,env5,#36d,env6,#c0
	dw #300,#0,#0,env5,#0,env6,#10ab,env14,#40
	dw #601,#cb,#3852,env4,#6f6,env1,#5,#706,env10
	dw #301,#0,#0,env4,#0,env1,#40
	dw #600,#0,#1be,env5,#371,env6,#12b8,env14,#c0
	dw #305,#0,#10ab,env15,#40
	dw #600,#0,#213,env4,#41b,env6,#6f6,env13,#5,#706,env10
	dw #300,#0,#0,env4,#0,env6,#0,env13,#40
	dw #600,#0,#213,env4,#41b,env6,#13d7,env16,#c0
	dw #300,#0,#1f5,env4,#3f3,env6,#12b8,env13,#c0
	dw #600,#cb,#0,env4,#3852,env4,#70a,env13,#5,#706,env10
	dw #304,#cb,#1f5,env3,#0,env13,#5,#706,env10
	dw #600,#0,#1d9,env3,#3a6,env5,#12b8,env17,#5,#706,env10
	dw #300,#0,#0,env3,#0,env5,#13d7,env9,#40
	dw #600,#0,#1be,env3,#371,env5,#6f6,env1,#5,#706,env10
	dw #305,#0,#0,env1,#40
	dw #600,#0,#dd,env2,#1ae,env5,#6f6,env1,#40
	dw #305,#0,#0,env1,#40
	dw #600,#0,#1a5,env2,#342,env4,#84f,env2,#5,#706,env10
	dw #305,#0,#0,env2,#40
	dw #600,#0,#dd,env2,#1b2,env4,#84f,env3,#40
	dw #305,#0,#0,env3,#40
	dw #600,#cb,#18d,env1,#3852,env4,#956,env4,#5,#706,env10
	dw #304,#cb,#0,env1,#a7d,env4,#5,#706,env10
	dw #600,#0,#18d,env1,#313,env4,#c7c,env5,#5,#706,env10
	dw #305,#0,#0,env5,#5,#706,env10
	dw #600,#cb,#176,env1,#3852,env4,#e05,env12,#5,#706,env10
	dw #381,#0,#0,env4,#40
	dw #600,#0,#14d,env1,#293,env4,#0,env12,#40
	dw #385,#0,#40
	dw #680,#0,#dd,env1,#0,env4,#5,#706,env10
	dw #385,#0,#40
	dw #684,#0,#1be,env1,#c0
	dw #384,#0,#0,env1,#40
	dw #605,#0,#6ee,env7,#c0
	dw #304,#0,#1be,env1,#0,env7,#40
	dw #684,#0,#0,env1,#c0
	dw #384,#0,#1be,env2,#40
	dw #604,#0,#0,env2,#6ee,env6,#5,#706,env10
	dw #305,#0,#0,env6,#40
	dw #684,#0,#1be,env2,#c0
	dw #304,#0,#0,env2,#6f2,env6,#5,#706,env10
	dw #605,#0,#0,env6,#5,#706,env10
	dw #384,#0,#1be,env2,#40
	dw #604,#0,#0,env2,#6f2,env5,#5,#706,env10
	dw #304,#0,#1be,env2,#0,env5,#c0
	dw #684,#0,#107,env3,#5,#706,env10
	dw #385,#0,#40
	dw #604,#0,#213,env3,#632,env5,#c0
	dw #304,#0,#0,env3,#0,env5,#40
	dw #605,#0,#632,env5,#5,#706,env10
	dw #304,#0,#213,env3,#6fa,env4,#40
	dw #604,#0,#0,env3,#0,env4,#c0
	dw #384,#0,#213,env3,#40
	dw #604,#0,#128,env4,#636,env4,#5,#706,env10
	dw #305,#0,#0,env4,#40
	dw #604,#0,#255,env4,#636,env4,#c0
	dw #304,#0,#0,env4,#6fe,env3,#c0
	dw #601,#cb,#3852,env4,#0,env3,#5,#706,env10
	dw #304,#cb,#29f,env4,#6fe,env3,#5,#706,env10
	dw #600,#0,#255,env5,#0,env4,#857,env2,#5,#706,env10
	dw #304,#0,#213,env4,#0,env2,#40
	dw #684,#0,#dd,env4,#5,#706,env10
	dw #385,#0,#40
	dw #684,#0,#1be,env4,#c0
	dw #384,#0,#0,env4,#40
	dw #601,#cb,#3852,env4,#a81,env9,#5,#706,env10
	dw #300,#0,#1be,env4,#0,env4,#0,env9,#40
	dw #684,#0,#0,env4,#c0
	dw #384,#0,#1be,env4,#40
	dw #600,#0,#213,env3,#70a,env4,#a81,env13,#5,#706,env10
	dw #300,#0,#18d,env3,#0,env4,#0,env13,#40
	dw #684,#0,#1be,env3,#c0
	dw #300,#0,#0,env3,#70a,env4,#a7d,env14,#c0
	dw #601,#cb,#3852,env4,#0,env14,#5,#706,env10
	dw #384,#cb,#1be,env3,#5,#706,env10
	dw #600,#0,#0,env3,#706,env4,#956,env15,#5,#706,env10
	dw #300,#0,#1be,env3,#0,env4,#0,env15,#40
	dw #684,#0,#107,env3,#5,#706,env10
	dw #385,#0,#40
	dw #600,#0,#213,env4,#642,env4,#a7d,env15,#c0
	dw #300,#0,#0,env4,#0,env4,#0,env15,#40
	dw #601,#0,#642,env4,#a7d,env15,#5,#706,env10
	dw #300,#0,#213,env44,#706,env4,#952,env16,#40
	dw #600,#0,#0,env44,#0,env4,#0,env16,#c0
	dw #384,#0,#213,env5,#c0
	dw #600,#cb,#128,env4,#3852,env4,#a79,env16,#5,#706,env10
	dw #305,#cb,#0,env16,#5,#706,env10
	dw #600,#0,#255,env3,#642,env4,#a79,env17,#5,#706,env10
	dw #300,#0,#0,env3,#706,env4,#952,env18,#5,#706,env10
	dw #600,#cb,#29f,env2,#3852,env4,#0,env18,#5,#706,env10
	dw #304,#cb,#255,env2,#94e,env18,#40
	dw #600,#0,#213,env1,#85b,env4,#a75,env19,#c0
	dw #300,#0,#18d,env1,#0,env4,#0,env19,#c0
	dw #684,#0,#dd,env1,#5,#706,env10
	dw #385,#0,#40
	dw #684,#0,#1be,env1,#c0
	dw #384,#0,#0,env1,#40
	dw #600,#cb,#381,env2,#3852,env4,#c88,env13,#5,#706,env10
	dw #300,#0,#1be,env2,#0,env4,#0,env13,#40
	dw #684,#0,#0,env2,#c0
	dw #384,#0,#14d,env2,#5,#706,env10
	dw #600,#0,#381,env3,#85b,env4,#c84,env13,#5,#706,env10
	dw #300,#0,#dd,env3,#0,env4,#0,env13,#40
	dw #684,#0,#381,env4,#c0
	dw #300,#0,#1be,env4,#85b,env4,#c84,env13,#c0
	dw #600,#cb,#42b,env5,#3852,env4,#0,env13,#5,#706,env10
	dw #380,#0,#3ef,env5,#0,env4,#40
	dw #600,#0,#381,env4,#706,env5,#a81,env14,#5,#706,env10
	dw #300,#0,#29f,env4,#0,env5,#0,env14,#c0
	dw #684,#0,#128,env3,#5,#706,env10
	dw #385,#0,#40
	dw #600,#0,#255,env1,#85b,env5,#c80,env14,#c0
	dw #300,#0,#0,env1,#0,env5,#0,env14,#40
	dw #600,#cb,#381,env1,#3852,env4,#c80,env14,#5,#706,env10
	dw #300,#0,#255,env2,#706,env5,#a81,env15,#40
	dw #600,#0,#0,env2,#0,env5,#0,env15,#c0
	dw #384,#0,#14d,env2,#5,#706,env10
	dw #600,#0,#29f,env3,#962,env6,#c7c,env15,#5,#706,env10
	dw #300,#0,#0,env3,#0,env6,#0,env15,#40
	dw #600,#0,#29f,env3,#962,env6,#c7c,env15,#c0
	dw #300,#0,#31f,env4,#7e3,env6,#a7d,env16,#c0
	dw #600,#cb,#0,env4,#3852,env4,#0,env16,#5,#706,env10
	dw #300,#0,#29f,env4,#962,env5,#c7c,env16,#40
	dw #600,#0,#31f,env5,#a89,env5,#e01,env17,#5,#706,env10
	dw #300,#0,#381,env6,#0,env5,#0,env17,#c0
	dw #600,#0,#dd,env4,#706,env4,#10ab,env1,#5,#706,env10
	dw #301,#0,#0,env4,#fba,env2,#40
	dw #604,#0,#381,env1,#dfd,env3,#c0
	dw #304,#0,#0,env1,#0,env3,#40
	dw #600,#cb,#1be,env1,#3852,env4,#c74,env15,#5,#706,env10
	dw #300,#0,#381,env2,#0,env4,#a75,env1,#40
	dw #604,#0,#0,env2,#0,env1,#c0
	dw #300,#0,#42b,env2,#85b,env4,#c74,env3,#5,#706,env10
	dw #600,#0,#3ef,env2,#0,env4,#df9,env1,#5,#706,env10
	dw #304,#0,#381,env3,#0,env1,#40
	dw #600,#0,#31f,env3,#706,env5,#10a3,env9,#c0
	dw #300,#0,#14d,env4,#0,env5,#df9,env13,#c0
	dw #600,#cb,#29f,env4,#3852,env4,#0,env13,#5,#706,env10
	dw #300,#0,#14d,env5,#0,env4,#dfd,env13,#40
	dw #600,#0,#279,env5,#642,env5,#10a7,env13,#5,#706,env10
	dw #300,#0,#128,env4,#0,env5,#12b8,env14,#c0
	dw #600,#0,#255,env1,#706,env5,#13d7,env14,#5,#706,env10
	dw #300,#0,#0,env1,#0,env5,#1506,env15,#40
	dw #605,#0,#12bc,env15,#c0
	dw #305,#0,#10af,env14,#c0
	dw #600,#cb,#255,env2,#3852,env4,#12c0,env14,#5,#706,env10
	dw #300,#0,#0,env2,#0,env4,#e09,env13,#40
	dw #605,#0,#0,env13,#c0
	dw #300,#0,#128,env3,#642,env5,#e09,env14,#5,#706,env10
	dw #600,#0,#29f,env3,#0,env5,#fbe,env13,#5,#706,env10
	dw #304,#0,#0,env3,#0,env13,#40
	dw #600,#0,#29f,env4,#642,env4,#a7d,env14,#c0
	dw #300,#0,#0,env4,#0,env4,#c78,env13,#c0
	dw #600,#cb,#255,env4,#3852,env4,#0,env13,#5,#706,env10
	dw #300,#0,#29f,env5,#0,env4,#c78,env9,#40
	dw #600,#0,#31f,env6,#642,env4,#e01,env1,#5,#706,env10
	dw #300,#0,#29f,env5,#0,env4,#fb6,env2,#c0
	dw #600,#0,#dd,env4,#706,env4,#10a3,env3,#5,#706,env10
	dw #301,#0,#0,env4,#fb2,env2,#40
	dw #604,#0,#1be,env1,#dfd,env1,#c0
	dw #304,#0,#0,env1,#0,env1,#40
	dw #600,#cb,#381,env2,#3852,env4,#c74,env9,#5,#706,env10
	dw #300,#0,#1be,env2,#0,env4,#a75,env9,#40
	dw #604,#0,#0,env2,#0,env9,#c0
	dw #300,#0,#14d,env2,#85b,env4,#a75,env13,#5,#706,env10
	dw #600,#0,#381,env3,#0,env4,#c78,env1,#5,#706,env10
	dw #304,#0,#dd,env3,#0,env1,#40
	dw #600,#0,#381,env4,#706,env4,#a79,env3,#c0
	dw #300,#0,#1be,env4,#0,env4,#c78,env14,#c0
	dw #600,#cb,#42b,env4,#3852,env4,#0,env14,#5,#706,env10
	dw #300,#0,#3ef,env5,#0,env4,#e05,env14,#40
	dw #680,#0,#381,env5,#642,env3,#5,#706,env10
	dw #300,#0,#29f,env4,#0,env3,#10af,env15,#c0
	dw #600,#0,#128,env3,#706,env3,#0,env15,#5,#706,env10
	dw #301,#0,#0,env3,#12b8,env16,#40
	dw #604,#0,#255,env1,#10ab,env17,#c0
	dw #304,#0,#0,env1,#0,env17,#40
	dw #600,#cb,#381,env1,#3852,env4,#12b8,env17,#5,#706,env10
	dw #300,#0,#255,env2,#0,env4,#10a7,env18,#40
	dw #604,#0,#0,env2,#0,env18,#c0
	dw #300,#0,#14d,env2,#642,env3,#1502,env1,#5,#706,env10
	dw #600,#0,#29f,env3,#0,env3,#12b4,env17,#5,#706,env10
	dw #304,#0,#0,env3,#fb6,env16,#40
	dw #600,#0,#29f,env3,#642,env3,#c70,env3,#c0
	dw #300,#0,#31f,env4,#0,env3,#a71,env16,#c0
	dw #600,#cb,#0,env4,#3852,env4,#c74,env1,#5,#706,env10
	dw #300,#0,#29f,env4,#0,env4,#0,env1,#40
	dw #680,#0,#31f,env5,#642,env2,#5,#706,env10
	dw #380,#0,#381,env6,#0,env2,#c0
	dw #604,#0,#dd,env4,#dfd,env15,#5,#706,env10
	dw #305,#0,#10ab,env1,#40
	dw #600,#0,#381,env1,#642,env2,#fba,env14,#c0
	dw #300,#0,#0,env1,#0,env2,#c7c,env3,#40
	dw #600,#cb,#1be,env1,#3852,env4,#e05,env13,#5,#706,env10
	dw #300,#0,#381,env2,#0,env4,#0,env13,#40
	dw #680,#0,#0,env2,#642,env3,#c0
	dw #380,#0,#42b,env2,#0,env3,#5,#706,env10
	dw #604,#0,#3ef,env2,#e09,env3,#5,#706,env10
	dw #304,#0,#381,env3,#10af,env15,#40
	dw #600,#0,#31f,env3,#642,env3,#fbe,env16,#c0
	dw #300,#0,#14d,env4,#0,env3,#c78,env1,#c0
	dw #600,#cb,#29f,env5,#3852,env4,#e01,env17,#5,#706,env10
	dw #300,#0,#14d,env5,#0,env4,#0,env17,#40
	dw #680,#0,#279,env5,#642,env4,#5,#706,env10
	dw #380,#0,#128,env4,#0,env4,#c0
	dw #604,#0,#255,env1,#e01,env18,#5,#706,env10
	dw #304,#0,#0,env1,#a79,env2,#40
	dw #601,#0,#542,env4,#c74,env1,#c0
	dw #301,#0,#0,env4,#d33,env16,#40
	dw #604,#0,#255,env2,#df9,env15,#5,#706,env10
	dw #304,#0,#0,env2,#a71,env1,#40
	dw #601,#0,#542,env5,#c70,env15,#c0
	dw #300,#0,#128,env3,#0,env5,#dfd,env14,#5,#706,env10
	dw #604,#0,#29f,env3,#fb6,env13,#5,#706,env10
	dw #304,#0,#0,env3,#10ab,env9,#40
	dw #600,#0,#29f,env4,#3ef,env5,#12b8,env1,#c0
	dw #300,#0,#0,env4,#0,env5,#fbe,env2,#c0
	dw #600,#cb,#255,env4,#3852,env4,#c7c,env9,#5,#706,env10
	dw #300,#0,#213,env5,#0,env4,#0,env9,#40
	dw #604,#0,#1be,env4,#d3f,env2,#5,#706,env10
	dw #304,#0,#213,env3,#0,env2,#c0
	dw #604,#0,#dd,env2,#e09,env15,#5,#706,env10
	dw #305,#0,#10b3,env13,#40
	dw #600,#0,#1be,env1,#642,env4,#fbe,env2,#c0
	dw #300,#0,#0,env1,#0,env4,#c7c,env13,#40
	dw #600,#cb,#381,env2,#3852,env4,#e01,env9,#5,#706,env10
	dw #300,#0,#1be,env2,#0,env4,#0,env9,#40
	dw #680,#0,#0,env2,#642,env4,#c0
	dw #380,#0,#14d,env3,#0,env4,#5,#706,env10
	dw #604,#0,#381,env3,#e01,env2,#5,#706,env10
	dw #304,#0,#dd,env3,#10ab,env15,#40
	dw #600,#0,#381,env4,#642,env3,#fb6,env16,#c0
	dw #300,#0,#1be,env4,#0,env3,#c74,env17,#c0
	dw #600,#cb,#42b,env4,#3852,env4,#df9,env18,#5,#706,env10
	dw #300,#0,#3ef,env4,#0,env4,#0,env18,#40
	dw #680,#0,#381,env5,#642,env3,#5,#706,env10
	dw #380,#0,#29f,env5,#0,env3,#c0
	dw #604,#0,#128,env3,#10a3,env19,#5,#706,env10
	dw #305,#0,#fb2,env1,#40
	dw #600,#0,#255,env1,#706,env4,#c70,env18,#c0
	dw #300,#0,#0,env1,#0,env4,#dfd,env17,#40
	dw #600,#cb,#381,env1,#3852,env4,#10a7,env16,#5,#706,env10
	dw #300,#0,#255,env1,#0,env4,#fb6,env15,#40
	dw #600,#0,#0,env1,#706,env4,#c78,env14,#c0
	dw #300,#0,#14d,env2,#0,env4,#e01,env13,#5,#706,env10
	dw #604,#0,#29f,env2,#12bc,env19,#5,#706,env10
	dw #304,#0,#0,env2,#10af,env1,#40
	dw #600,#0,#29f,env3,#7e3,env5,#12c0,env9,#c0
	dw #300,#0,#31f,env3,#0,env5,#150e,env13,#c0
	dw #600,#cb,#0,env3,#3852,env4,#12c0,env14,#5,#706,env10
	dw #300,#0,#29f,env4,#0,env4,#10af,env15,#40
	dw #600,#0,#31f,env4,#7e3,env5,#e05,env16,#5,#706,env10
	dw #300,#0,#381,env5,#0,env5,#c7c,env17,#c0
	dw #604,#0,#dd,env3,#e01,env1,#5,#706,env10
	dw #305,#0,#0,env1,#40
	dw #680,#0,#381,env1,#642,env4,#c0
	dw #300,#0,#0,env1,#0,env4,#e05,env2,#40
	dw #600,#cb,#1be,env1,#3852,env4,#0,env2,#5,#706,env10
	dw #300,#0,#381,env2,#0,env4,#e09,env2,#40
	dw #600,#0,#0,env2,#642,env4,#0,env2,#c0
	dw #380,#0,#42b,env2,#0,env4,#5,#706,env10
	dw #604,#0,#3ef,env2,#e0d,env3,#5,#706,env10
	dw #304,#0,#381,env2,#0,env3,#40
	dw #680,#0,#31f,env3,#642,env4,#c0
	dw #300,#0,#14d,env3,#0,env4,#e11,env4,#c0
	dw #600,#cb,#29f,env4,#3852,env4,#0,env4,#5,#706,env10
	dw #300,#0,#14d,env4,#0,env4,#e11,env5,#40
	dw #600,#0,#279,env5,#642,env5,#0,env5,#5,#706,env10
	dw #380,#0,#128,env4,#0,env5,#c0
	dw #684,#0,#255,env1,#5,#706,env10
	dw #384,#0,#0,env1,#40
	dw #681,#0,#542,env6,#c0
	dw #381,#0,#0,env6,#40
	dw #684,#0,#255,env2,#5,#706,env10
	dw #384,#0,#0,env2,#40
	dw #681,#0,#542,env7,#c0
	dw #380,#0,#128,env2,#0,env7,#5,#706,env10
	dw #684,#0,#29f,env3,#5,#706,env10
	dw #384,#0,#0,env3,#40
	dw #684,#0,#29f,env3,#5,#706,env10
	dw #384,#0,#0,env3,#c0
	dw #684,#0,#255,env4,#5,#706,env10
	dw #384,#0,#213,env4,#40
	dw #684,#0,#1be,env5,#c0
	dw #384,#0,#213,env3,#c0
	db #40
env1
	db #20,#80
env2
	db #1c,#80
env3
	db #18,#80
env4
	db #14,#80
env5
	db #10,#80
env6
	db #c,#80
env7
	db #8,#80
env8
	db #4,#80
env9
	db #20,#20,#1c,#1c,#18,#18,#14,#14,#10,#10,#c,#c,#8,#8,#4,#4,#80
env10
	db #3c,#3c,#3c,#2c,#2c,#2c,#24,#24,#24,#20,#20,#20,#1c,#1c,#1c,#18,#18,#18,#18,#18,#18,#14,#14,#14,#80
env11
	db #3c,#30,#24,#18,#c,#0,#3c,#30,#24,#18,#c,#0,#3c,#30,#24,#18,#c,#0,#80
env12
	db #3c,#34,#0,#3c,#34,#0,#3c,#34,#0,#3c,#34,#0,#3c,#34,#0,#3c,#34,#0,#80
env13
	db #24,#24,#20,#20,#1c,#1c,#18,#18,#14,#14,#10,#10,#c,#c,#8,#8,#80
env14
	db #28,#28,#24,#24,#20,#20,#1c,#1c,#18,#18,#14,#14,#10,#10,#c,#c,#80
env15
	db #2c,#2c,#28,#28,#24,#24,#20,#20,#1c,#1c,#18,#18,#14,#14,#10,#10,#80
env16
	db #30,#30,#2c,#2c,#28,#28,#24,#24,#20,#20,#1c,#1c,#18,#18,#14,#14,#80
env17
	db #34,#34,#30,#30,#2c,#2c,#28,#28,#24,#24,#20,#20,#1c,#1c,#18,#18,#80
env18
	db #38,#38,#34,#34,#30,#30,#2c,#2c,#28,#28,#24,#24,#20,#20,#1c,#1c,#80
env19
	db #3c,#3c,#38,#38,#34,#34,#30,#30,#2c,#2c,#28,#28,#24,#24,#20,#20,#80
env44
	db #20,#80
env67
	db #20,#80
