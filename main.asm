; game by Denis Grachev
    
GS_GAMEPLAY = 0
GS_SCRIPT = 1
GS_RESTART_LEVEL = 2
GS_MAIN_MENU = 3
GS_WIN_GAME = 4

START_LEVEL = 1

;	define PENTAGON
;	define DEBOUNCER

	device ZXSPECTRUM48	

	page 0
	org 16384
loadingScreen:
	incbin "loading/scr.scr"

DEBUG=0

	page 0
	org 24700	
start:
	di	
	ld sp,24699
	xor a : out (254),a	
	ei
	;ei : call kempstonTest : ei
	ld b,150;50
1:
	halt
	djnz 1b
	call fadeOut
	di	
	ld hl,16384 : ld de,16385 : ld bc,6912-1 : ld (hl),0 : ldir	
	di
	ld hl,mainInterrupt : call IMON

	;start game
	jp startGame	

gameState: db GS_MAIN_MENU
	include "game/mapsList.a80"	

	
	display "FREE SPACE TILL 32768: ",/d,32768-$
;============================================================================
;32768 - 48830
;============================================================================
	page 0
	org 32768		
	include "engine/sys.a80"	
	include "engine/camera.a80"
	include "engine/sound.a80"	
	include "engine/sprites.a80"	
;===========================================
	include "engine/render.a80"		
	include "engine/animations.a80"
;===========================================
	include "game/hero.a80"
	include "game/chicken.a80"	
	include "game/particle.a80"
	include "game/script.a80"		

	;start game
startGame:	
	call intro
	;depack game tiles
	;ld hl,packedBaseTiles : ld de,tiles : call depack
	;init state	
	;call initLevel		

	;ld ix,testString : call drawString
	call initSprites
	call initChickens
	call initCamera
	;first render flag
	;ld a,1 : ld (firstRender+1),a ;: ld (laserSwitch+1),a
	;ld a,2 : ld (intFirstRender),a	
	;call initLevelWithoutUnpack
	ld ix,pushFireString : call drawString

mainLoop:
	halt	
;============================================================	
	call processMap0
mainLoopNoProcessMap:	
;============================================================		
	call doControls		
	call doSpritesAnimations
;=============================================
firstRender: ld a,1
	or a : jr nz,1f
    call restoreSprites
1:
	xor a : ld (firstRender+1),a;reset first render flag	

	;hide blocks by default
	ld hl,doHideBlocks : ld (doTmpBlocks+1),hl

	call doParticles		
	call doChickens

	//call animateTiles

;=============================================
	ld a,(gameState)
;=============================================	
	CP GS_GAMEPLAY : jp nz,8f		

	ld de,(heroPosition) : inc d : inc d : call getTile : cp TILE_BUTTON : jr nz,1f
	ld hl,doShowBlocks : ld (doTmpBlocks+1),hl
1:

	call doTmpBlocks	
;check dead on laser	
	ld a,(laserSwitch+1) : or a : jr z,1f
	ld de,(heroPosition) : inc e : call getTile : cp TILE_LASER : jr z,killHero

	ld de,(heroPosition) : inc d : call getTile : cp TILE_LASER_H : jr z,killHero	
	ld de,(heroPosition) : inc d : inc d :  call getTile : cp TILE_LASER_H : jr z,killHero	
1:	
	;check dead under lava
	ld de,(heroPosition) : inc d : inc d : inc d : call getTile
	cp TILE_LAVA : jr z,killHero
	cp TILE_LAVA+1 : jr nz,1f
killHero:	
	ld hl,(heroPosition) : ld (mapObjects+OBJECT.X),hl
	ld ix,mapObjects : ld hl,restartLevelScript : call playScript
	jp endStateLoop
1:
	call doHero	
1:
	;check if no chickens
	ld a,(chickensList+0*4+3) : cp 48 : jr nz,1f
	ld a,(chickensList+1*4+3) : cp 48 : jr nz,1f
	ld a,(chickensList+2*4+3) : cp 48 : jr nz,1f
	ld a,(chickensList+3*4+3) : cp 48 : jr z,winWin
1:	
	;cheat key
	ld a,(cheatKey) : or a : jp z,1f
winWin:	
	ld hl,(heroPosition) : ld (mapObjects+OBJECT.X),hl
	ld ix,mapObjects : ld hl,winLevelScript : call playScript
	jp endStateLoop
1:
	;restart key
	ld a,(restartKey) : or a : jp z,endStateLoop
	ld hl,(heroPosition) : ld (mapObjects+OBJECT.X),hl
	ld ix,mapObjects : ld hl,restartLevelScript : call playScript
	jp endStateLoop
8:
;=============================================
	CP GS_SCRIPT : jr nz,8f
	 	call doScript
	jp endStateLoop
8:
;=============================================
	CP GS_RESTART_LEVEL : jr nz,8f
	 	call initLevel
	jp endStateLoop2
8:
;=============================================	
	CP GS_MAIN_MENU : jr nz,8f
		call doBlink
		ld a,(fireKey) : or a : jp z,endStateLoop
		;fire pushed
		;ld a,GS_RESTART_LEVEL : ld (gameState),a
		;jp killHero
		ld hl,startGameScript : call playScript
	jp endStateLoop
8:
;=============================================	
	CP GS_WIN_GAME : jp nz,8f	 		
		;halt
	;jp mainLoopNoProcessMap
	;	block 256,0
	jp outro
8:
;=============================================	

endStateLoop:		
;=============================================	
	;call doChickens		
	call doSprites	
	call doCamera
	call animateTiles
	ld a,DEBUG : out (254),a
	ld bc,448 : call DELAY
	xor a : out (254),a
;============================================================
endStateLoop2:
	ld hl,int_frame_0 : ld (intProc+1),hl		
	halt
;============================================================	
	ld hl,int_frame_1 : ld (intProc+1),hl	
;============================================================	
	halt
	call processMap1
;============================================================	
	ld hl,nullProc : ld (intProc+1),hl
;============================================================
;	xor a : out (254),a
	jp mainLoop


	include "engine/map.a80"	
;expomizer	
depack:
	include "engine/deexoopt.asm"

	display "FREE SPACE IN MAIN PAGE: ",/d,48640-$

	page 0
	org 49152
	include "engine/tiles.a80"	
tiles_page_2:
	incbin "maps/tiles.scr",2048,2048
tiles_page_2_color:
	incbin "maps/tiles.scr",6144+256,256	
tiles_page_3:
	incbin "maps/tiles.scr",4096,2048
tiles_page_3_color:
	incbin "maps/tiles.scr",6144+512,256		
		
;keyboard lib
	include "engine/controlsDebounce.a80"	
;other maps	
	include "game/mapsList2.a80"	
;=================================================
	include "engine/text.a80"
	include "game/outro.a80"		
	display "FREE SPACE IN TILES PAGE: ",/d,65536-$
;============================================================================
;	savebin "game.bin",start,$-start
	savetap "main.tap",start	

;	IF (_ERRORS = 0)                                 					
			SHELLEXEC "main.tap"	
;	ENDIF
;============================================================================
