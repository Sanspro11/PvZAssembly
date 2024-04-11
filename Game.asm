IDEAL
MODEL small
 
STACK 0f500h

SCREEN_WIDTH = 320  
 
Right equ 69+1 ; 69 is 1 pixel from flower
Floor1 equ 193	
Floor2 equ 144
Floor3 equ 93
Floor4 equ 44
Floor1Bullet equ 
PlantWidth equ 31
PlantHeight equ 31
FlowerWidth equ 30
FlowerHeight equ 36
BulletWidth equ 20 ; includes trail
BulletHeight equ 7
ZombieWidth equ 29 ; includes trail
ZombieHeight equ 43

Plant1 equ 51910 ; Floor1*320 - 320*PlantHeight + Right
Plant2 equ 36230 ; Floor2*320 - 320*PlantHeight + Right
Plant3 equ 19910 ; Floor3*320 - 320*PlantHeight + Right
Plant4 equ 4230 ; Floor4*320 - 320*PlantHeight + Right
Flowerx equ 37
Flower1y equ 157
Flower2y equ 108
Flower3y equ 57
Flower4y equ 9

NextBullet equ 6
NextZombie equ 8



DATASEG

    
   
    ScrLine 	db SCREEN_WIDTH dup (0)  ; One Color line read buffer

	;BMP File Data
    Plant db 'Assets/Plant.bmp' ,0
    PlantFire db 'Assets/PlanFire.bmp' ,0
	PlantIce db 'Assets/PlanIce.bmp' ,0
	PlantGray db 'Assets/PlanGray.bmp' ,0
    Bullet db 'Assets/Bullet.bmp' ,0
	BulletIce db 'Assets/BullIce.bmp' ,0
	BulletFire db 'Assets/BullFire.bmp' ,0
    Zombie db 'Assets/Zomb.bmp' ,0
	ZombieIce db 'Assets/ZombIce.bmp' ,0
	ZombieFire db 'Assets/ZombFire.bmp' ,0
	ZombieFireIce db 'Assets/ZombBoth.bmp' ,0
	ZombieCone db 'Assets/ZombCone.bmp' ,0
	ZombieConeIce db 'Assets/ZombCIce.bmp' ,0
	ZombieConeFire db 'Assets/ZombCFir.bmp' ,0
	ZombieConeFireIce db 'Assets/ZombCBot.bmp' ,0
	ZombieHit db 'Assets/ZombHit.bmp' ,0
	ZombieConeHit db 'Assets/ZombCHit.bmp' ,0
    Welcome db 'Assets/Welcome.bmp' ,0
	Map db 'Assets/Map.bmp' ,0
	GameOver db 'Assets/GameOver.bmp' ,0
	Menu db 'Assets/Menu.bmp' ,0
	HowPlay db 'Assets/HowPlay.bmp' ,0
	SettingsPic db 'Assets/Settings.bmp', 0
	Flower db 'Assets/Flower.bmp' ,0
	GoldenFlower db 'Assets/GoldFlow.bmp' ,0
	PausedPic db 'Assets/Paused.bmp' ,0
	Sky db 'Assets/Sky.bmp' ,0
	DarkSky db 'Assets/DarkSky.bmp' ,0
	SettingsSky db 'Assets/SettSky.bmp' ,0
	Arrow db 'Assets/Arrow.bmp' ,0
	GreenArrow db 'Assets/GreArrow.bmp' ,0
	
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 1024 dup (0)
		
	
	;BmpFileErrorMsg    	db 'Error At Opening Bmp File ',FILE_NAME_IN, 0dh, 0ah,'$'
	ErrorFile           db 0
		 
	BmpLeft dw ?
	BmpTop dw ?
	BmpWidth dw ?
	BmpHeight dw ?
	
	ScoreFileName db "Score", 0
	
	PlantFloor db 1 ; 0 is timeout 
	Bullets dw 0, 0, 0 ;1
            dw 0, 0, 0 ;2
			dw 0, 0, 0 ;3
			dw 0, 0, 0 ;4
			dw 0, 0, 0 ;5
			dw 0, 0, 0 ;6
			dw 0, 0, 0 ;7
            dw 0, 0, 0 ;8
			dw 0, 0, 0 ; up to 9 bullets at once (settings)
	;(each bullet is stored as X, Y, and State (0 Normal, 1 Fire, 2 Ice)
	Zombies dw 0, 0, 0, 0 ;1
	        dw 0, 0, 0, 0 ;2
			dw 0, 0, 0, 0 ;3
			dw 0, 0, 0, 0 ;4
			dw 0, 0, 0, 0 ;5
			dw 0, 0, 0, 0 ;6
			dw 0, 0, 0, 0 ;7
			dw 0, 0, 0, 0 ;8
			dw 0, 0, 0, 0 ;up to 9 zombies at once (settings)
	; X, Y, Health, State (0 Normal, 1 Fire, 2 Ice, 3 Fire and ice)
	LastMilSec db ? ; to know when a Millisecond has passed
	Settings dw offset ZombiesNum ; start of settings
	ZombiesNum	 dw 5 ; by default 5
	BulletsNum dw 5 ; by default 5
	Ticks dw 0 ; To pass word limit you need to play for 1 hour (65536/18.2=3600)
	Flowers db 0,0,0,0 ; 0 is normal, 1 is golden, 2 is dead
	PlantState db 0, 0 ; 0 is normal, 1 is fire, 2 is ice, 2nd 0 is timer
	Seconds dw 0
	Money dw 0
	Score dw 0
	ToParse dw 0 ; real number to be parsed to char number in "Parsed" var
	Parsed db "0000"
	TimeOutTick dw 0 
	ShootingNextTick dw 0 ; Short cooldown of shooting
	InvincibilityTickEnd dw 0 ; 1 second Invincibility after returning from TimeOut
	Alive db 0 ; 0 is alive, 1 is game over
	SettingPointer dw 0
	ZombiesNumNum dw 0 ; Max zombies currently in game
	BulletsNumNum dw 0
	OldHighScore dw 0
CODESEG
 
start:
	mov ax, @data
	mov ds, ax
	
	Call SetGraphic ; sets graphic mode
 
	mov dx, offset Welcome 
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpWidth], 320
	mov [BmpHeight] ,200
	Call OpenShowBmp ;opens Welcome Screen
    

WelcomeLoop:
    mov ah,0 ; "Wait for keystroke and read"
	int 16h ;int 16h is keyboard services
	cmp ax, 1C0Dh ; 1C0Dh is Enter
	je GoToMenuTag1
	jmp WelcomeLoop

GoToMenuTag1:
	jmp MenuTag
SettingsTag:
    mov dx, offset SettingsPic
    mov [BmpLeft], 0
	mov [BmpTop], 0 
	mov [BmpWidth], 320 ; fullscreen
	mov [BmpHeight], 200 ; fullscreen
	Call OpenShowBmp ; Print Settings
    mov [BmpLeft], 140
	mov [BmpWidth], 32 ; ArrowWidth
	mov [BmpHeight], 18 ; ArrowHeight
	mov [BmpTop], 35
	mov dx, offset Arrow
    Call OpenShowBmp ; Print Arrow
	mov [SettingPointer], 0

	
SettingsLoop:
    Call UpdateNumsAtSettings
	mov dx, offset Arrow
	Call OpenShowBmp 
	mov ah,0 ; "Wait for keystroke and read"
	int 16h ;int 16h is keyboard services
	cmp ax, 4800h ; 4800h is up arrow
	je UpSettingArrow
	cmp ax, 5000h ; 5000h is down arrow
	je DownSettingArrow
	cmp ax, 1C0Dh ; 1C0Dh is Enter
	je EnterSettingLoop
	cmp ax, 4D00h ; 4D00h is right arrow
	je EnterSettingLoop
	cmp ax, 011Bh ; 011B is 'Esc'
	je GoToMenuTag1
	cmp ax, 4B00h ; 4B00h is left arrow
	je GoToMenuTag1
    jmp SettingsLoop

UpSettingArrow:
	cmp [SettingPointer], 0 ; Dont go down from setting 0
	jle SettingsLoop
	dec [SettingPointer]
	
	mov dx, offset SettingsSky
	Call OpenShowBmp ; delete arrow
	sub [BmpTop], 24
	mov dx, offset Arrow
	Call OpenShowBmp  ; print arrow at the correct location
	jmp SettingsLoop
DownSettingArrow:
	cmp [SettingPointer], 1 ; Dont go up from setting 1
	jge SettingsLoop
	inc [SettingPointer]
	
	mov dx, offset SettingsSky
	Call OpenShowBmp ; delete arrow
	add [BmpTop], 24
	mov dx, offset Arrow 
	Call OpenShowBmp ; print arrow at the correct location
    jmp SettingsLoop

EnterSettingLoop:
    Call UpdateNumsAtSettings
	mov bx, [Settings] ; start of settings
    add bx, [SettingPointer] ; to point on the setting needed
    add bx, [SettingPointer] ; twice because we are pointing on words
	push bx
	mov dx, offset GreenArrow
	Call OpenShowBmp
	pop bx
	mov ah,0 ; "Wait for keystroke and read"
	int 16h ;int 16h is keyboard services
	cmp ax, 4800h ; 4800h is up arrow
	je RaiseSetting
	cmp ax, 5000h ; 5000h is down arrow
	je LowerSetting
	cmp ax, 4D00h ; 4D00h is right arrow
	je GoToSettingsLoop
	cmp ax, 1C0Dh ; 1C0Dh is Enter
	je GoToSettingsLoop
	cmp ax, 011Bh ; 011B is 'Esc'
	je GoToSettingsLoop
	cmp ax, 4B00h ; 4B00h is left arrow
	je GoToSettingsLoop
    jmp EnterSettingLoop
GoToSettingsLoop:
	jmp SettingsLoop
	
RaiseSetting:
    cmp [word bx], 9 ; dont go above 9 for each setting
	jge EnterSettingLoop
	cmp [word bx], 0
	jle EnterSettingLoop
	inc [word bx] ; inc only if its 1-9
	jmp EnterSettingLoop
LowerSetting:
    cmp [word bx], 10
	jge EnterSettingLoop
	cmp [word bx], 1 ; dont go below 1 for each setting
	jle EnterSettingLoop
	dec [word bx] ; dec only if its 1-9
	jmp EnterSettingLoop

	
MenuTag:
    mov dx, offset Menu
    mov [BmpLeft], 0
	mov [BmpTop], 0 
	mov [BmpWidth], 320 ; fullscreen
	mov [BmpHeight], 200 ; fullscreen
	Call OpenShowBmp ; Print Menu
	Call PutScoreInAx
	mov [Word ToParse], ax
	Call Parse
    mov ah, 13h ; Write String
	mov al, 00000001b  ; Write Mode, chars only, attributes in Bl, cursor not moved
	mov bh, 0 ;Video page num
	mov bl, 00110011b  ; attribute for color, 00110011b is Green
	mov cx, 4 ; Length of string 
	mov dx, ds ; make es point to ds cuz
	mov es, dx ; pointer to string is "ES:BP"
	mov dh, 2 ; row coordinate
	mov dl, 17 ; column coordinate	 
	mov bp, offset Parsed ; pointer to string is "ES:BP"
	int 10h ; Write OldHighScore on menu


MenuLoop:
    mov ah,0 ; "Wait for keystroke and read"
	int 16h ;int 16h is keyboard services
	cmp ax, 1C0Dh ; 1C0Dh is Enter
	je StartGame
	cmp ax, 5000h ; 5000h is down arrow
	je StartGame
	cmp ax, 4B00h ; 4B00h is left arrow
	je HowPlayTag
	cmp ax, 4D00h ; 4D00h is right arrow
	je GoToSettingsTag
	cmp ax, 011Bh ; 011B is 'Esc'
	je GoToExit
	jmp MenuLoop
GoToExit:
	jmp exit
GoToSettingsTag:
	jmp SettingsTag

HowPlayTag:
    mov dx, offset HowPlay
    mov [BmpLeft], 0
	mov [BmpTop], 0 
	mov [BmpWidth], 320 ; fullscreen
	mov [BmpHeight], 200 ; fullscreen
	Call OpenShowBmp ; Print Menu
    
HowPlayLoop:
	mov ah,0 ; "Wait for keystroke and read"
	int 16h ;int 16h is keyboard services
	cmp ax, 011Bh ; 011B is 'Esc'
	je GoToMenuTag
	cmp ax, 4D00h ; 4D00h is right arrow
	je GoToMenuTag
    jmp HowPlayLoop

GoToMenuTag:
	jmp MenuTag
StartGame:
    mov [PlantFloor], 1
	mov [Ticks], 0
	mov [LastMilSec], 1 
	mov [Money], 0
	mov [Seconds], 0
	mov [Score], 0
	mov [word PlantState], 0
	mov [Alive], 0
	mov [TimeOutTick], 0
	mov [InvincibilityTickEnd], 0
	mov [word Flowers], 0
	mov [word Flowers+2], 0
	mov [word ShootingNextTick], 0
    mov dx, offset Map 
	Call OpenShowBmp ; open the map
    mov al, [byte ZombiesNum]
	mov bl, NextZombie
	mul bl ; have NextZombie*ZombiesNum in ZombiesNumNum for word jumps
	mov [ZombiesNumNum], ax
	mov al, [byte BulletsNum]
	mov bl, NextBullet
	mul bl ; have NextBullet*ZombiesNum in ZombiesNumNum for word jumps
	mov [BulletsNumNum], ax
    
	
	Call PrintPlant
	
    mov bx, 0	
ResetBullets: ; resets bullets when the game is started or retried
    mov [Bullets+bx], 0
	add bx, 2
	cmp bx, [word BulletsNumNum] ; Bullets max * next bullets pointer
	jge ResetZombies
	Jmp ResetBullets

ResetZombies:
    mov bx, 0
ResetZombiesLoop: ; reserts zombies when the game is started or retried
    mov [Zombies+bx], 0
	add bx, 2
	cmp bx, [ZombiesNumNum]
    jge GameKeyLoop
	Jmp ResetZombiesLoop


PauseMenu:
    mov dx, offset PausedPic
    mov [BmpLeft], 0
	mov [BmpTop], 80 
	mov [BmpWidth], 36 ; width of the "הושעה" message
	mov [BmpHeight], 8 ; height of the "הושעה" message
	Call OpenShowBmp ; Print "הושעה"


    mov ah,0 ; "Wait for keystroke and read"
    int 16h ;int 16h is keyboard services
	cmp ax, 3920h ; 3920h is space bar
	jne PauseMenu
	mov dx, offset Sky
    mov [BmpLeft], 0
	mov [BmpTop], 80 
	mov [BmpWidth], 36 ; width of the "הושעה" message
	mov [BmpHeight], 8 ; height of the "הושעה" message
	Call OpenShowBmp ; Delete "הושעה"

;the real game starts here
GameKeyLoop:
    Call FlushKBandGetLastKey
	mov ax, bx

	jz CheckKeyPressed ; "ZF = 0 if a key pressed (even Ctrl-Break)"
	jmp ButtonEnd

CheckKeyPressed:
    cmp ax, 4800h ; 4800h is up arrow
	je MoveUp
	cmp ax, 5000h ; 5000h is down arrow
	je MoveDown
	cmp ax, 4B00h ; 4B00h is left arrow
	je CollectGoldTag
	cmp ax, 4D00h ; 4D00h is right arrow
	je ShootRight
	cmp ax, 3920h ; 3920h is space bar
	je PauseMenu
	cmp ax, 0231h ; 0231h is 1
	je BuyFireTag
	cmp ax, 0332h ; 0332h is 2
	je BuyIceTag
	cmp ax, 011Bh ; 011Bh is 'Esc'
	je GoToGameOver
    jmp ButtonEnd
GoToGameOver:
    jmp GameOverTag

MoveUp:
    Call MovePlantUp
	mov ax, 0
	jmp ButtonEnd

MoveDown:
    Call MovePlantDown
	mov ax, 0
	jmp ButtonEnd

ShootRight: 
    mov ax, [Ticks]
    Cmp ax, [ShootingNextTick] ; check if enough time has passed from last shot
	jl ShootRightEnd
	add ax, 3 ; 3 ticks cooldown for shooting
	mov [ShootingNextTick], ax
    Call Shoot
	mov ax, 0
ShootRightEnd:
	jmp ButtonEnd

CollectGoldTag:
    Call CollectGold
	mov ax, 0
	jmp ButtonEnd

BuyFireTag:
    Call BuyFire
	mov ax, 0
	jmp ButtonEnd
	
BuyIceTag:
    Call BuyIce
	mov ax, 0
	jmp ButtonEnd

ButtonEnd: ; Tick Check
	
    mov ah, 2Ch ; "Get Time" CH = hour (0-23) CL = minutes (0-59)
	int 21h ;DH = seconds (0-59) DL = hundredths (0-99)
	cmp [byte LastMilSec], dl ; check if last hundredth passed
	je GetToGameLoop ; if last hundredth didnt pass, skip
	mov [byte LastMilSec], dl ; save current hundredth
; Down here are stuff that happen every tick
    Call UpdateBullets
    Call UpdatePlant
	Call UpdateTimerMoneyScore
	Call UpdateFlowers
	Call UpdateZombies
	Call PrintPlant
	inc [word Ticks]
	cmp [Alive], 1 ; 1 is gameover
	je GameOverTag


AfterTick:
    mov ax, [Ticks]
	mov dx, 0
	mov bx, 25 ; every X ticks do it
	div bx 
	cmp dx, 0 ; check if the ticks cnt is divideable by 25
	jne FlowerGold
	Call PutZombie	
	
FlowerGold:
    mov ax, [Ticks]
	mov dx, 0
	mov bx, 70 ; every X ticks do it
	div bx 
	cmp dx, 0 ; check if the ticks cnt is divideable by 70
	jne UpdateSeconds
    Call MakeFlowerGold
	
UpdateSeconds:
    mov ax, [Ticks]
	mov dx, 0
	mov bx, 18 ; about a second cuz it updates 18.2 times in a sec
	div bx 
	cmp dx, 0 ; check if the ticks cnt is divideable by 18
	jne GetToGameLoop
    inc [Seconds]
	cmp [byte PlantState+1], 0
	je GetToGameLoop
	dec [byte PlantState+1] ; dec powerup timer
	

GetToGameLoop:
	jmp GameKeyLoop

GameOverTag:
    mov ax, 0
    mov dx, offset GameOver
    mov [BmpLeft], 0
	mov [BmpTop], 0 
	mov [BmpWidth], 320 ; fullscreen
	mov [BmpHeight], 200 ; fullscreen
	Call OpenShowBmp ; Print Game over
	
	mov ax, [Seconds]
    mov [Word ToParse], ax
	Call Parse
    mov ah, 13h ; Write String
	mov al, 00000001b  ; Write Mode, chars only, attributes in Bl, cursor not moved
	mov bh, 0 ;Video page num
	mov bl, 11111111b  ; attribute for color, 11111111b is White
	mov cx, 4 ; Length of string 
	mov dx, ds ; make es point to ds cuz
	mov es, dx ; pointer to string is "ES:BP"
	mov dh, 9 ; row coordinate
	mov dl, 28 ; column coordinate	 
	mov bp, offset Parsed
	int 10h ; Write Seconds at game over
	
    mov ax, [Score]
    mov [Word ToParse], ax
	Call Parse
    mov ah, 13h ; Write String
	mov bl, 00110011b  ; attribute for color, 00110011b is Green
	mov cx, 4 ; Length of string 
	mov dh, 12 ; row coordinate
	mov dl, 28 ; column coordinate	 
	int 10h ; Write Score at game over
	
	Call PutScoreInAx ; read score from file
	mov [Word ToParse], ax 
	push ax
	Call Parse ; parse the current score in file 
	pop ax
    cmp [Word Score], ax ; check if the score right now is better than the current high score
	jl AfterHighScore; jump if lower score
	Call PutScoreInScoreFile
	mov ax, [Word Score]
	mov [Word ToParse], ax
	Call Parse
	
AfterHighScore:
	mov ah, 13h ; Write String
	mov al, 00000001b  ; Write Mode, chars only, attributes in Bl, cursor not moved
	mov bh, 0 ;Video page num
	mov bl, 00110011b  ; attribute for color, 00110011b is Green
	mov cx, 4 ; Length of string 
	mov dx, ds ; make es point to ds cuz
	mov es, dx ; pointer to string is "ES:BP"
	mov dh, 8 ; row coordinate
	mov dl, 1 ; column coordinate	 
	int 10h ; Write High Score at game over

	
GameOverKey:
	mov ah,0 ; "Wait for keystroke and read"
	int 16h ;int 16h is keyboard services
    cmp ax, 1372h ; 1372 is 'r'
	je GoToStartGame
	cmp ax, 1352h ; 1352h is 'R'
	je GoToStartGame
	cmp ax, 011Bh ; 011B is 'Esc'
	je exit
	cmp ax, 326Dh ; 326D is 'm'
	je GoToMenuTag2
	cmp ax, 324Dh ; 324D is 'M'
	je GoToMenuTag2
	jmp GameOverKey

GoToStartGame:
    jmp StartGame
GoToMenuTag2:
    jmp MenuTag
exit:	
	mov ax,2 ; Return to not graphic
	int 10h ; (Apparently in stanislavs' its graphic mode - Set cursor position)

	mov ax, 4c00h ; "Terminate process with return code"
	int 21h ; int 21h is files (function request services)
	

;==========================
;==========================
;===== Procedures  Area ===
;==========================
;==========================

; move the Plant one floor up
proc MovePlantUp

    cmp [PlantFloor], 4 ; if already at top floor, skip all
	je @@EndUp
	cmp [PlantFloor], 0 ; if at timeout, skip all
	je @@EndUp
    
	Call DeletePlant
    inc [byte PlantFloor]
	Call PrintPlant
@@EndUp:
    ret
endp MovePlantUp


;Move the plant one floor down
proc MovePlantDown

    cmp [PlantFloor], 1 ; if already at bottom floor, skip all
	je @@EndDown
	cmp [PlantFloor], 0 ; if at timeout, skip all
	je @@EndDown

	Call DeletePlant
    dec [byte PlantFloor]
	Call PrintPlant
@@EndDown:
    ret
endp MovePlantDown

; Add one bullet at the current location of the plant
proc Shoot
    cmp [PlantFloor], 0 ; skip if at timeout
	je @@End
    mov bx, 0
@@CheckLoop:
    cmp [Bullets+bx], 0 ; check if one of the bullet variables is empty
	je @@Continue ; empty found
	add bx, NextBullet
	cmp bx, [BulletsNumNum] ; Bullets max * next bullets pointer, all  bullets are used 
	je @@End
	jmp @@CheckLoop
     
@@Continue:
    cmp [PlantFloor], 1
	je @@Put1Height
	cmp [PlantFloor], 2
	je @@Put2Height
    cmp [PlantFloor], 3
	je @@Put3Height
    
@@Put4Height:	
    mov dx, Floor4-PlantHeight+2
	jmp @@Continue2
@@Put1Height:	
	mov dx, Floor1-PlantHeight+2
	jmp @@Continue2
@@Put2Height:
    mov dx, Floor2-PlantHeight+2
	jmp @@Continue2
@@Put3Height: 
    mov dx, Floor3-PlantHeight+2

@@Continue2:
    
    mov [Bullets+bx], Right + PlantWidth-8 
	mov [Bullets+bx+2], dx
	cmp [byte PlantState], 1 ; check if plant fire
	je @@PutFireBullet
	cmp [byte PlantState], 2 ; check if plant ice
    je @@PutIceBullet
	mov [Bullets+bx+4], 0 ; if not ice or fire then normal
    jmp @@End
@@PutFireBullet:
    mov [Bullets+bx+4], 1 ; put fire bullet
	jmp @@End
@@PutIceBullet:
    mov [Bullets+bx+4], 2 ; put ice bullet
@@End:
    mov bx, 0
    ret
endp Shoot

; Update the plant (if hit, if needs to comeback from timeout)
proc UpdatePlant 
    cmp [PlantFloor], 0 ; if already dead
	je @@GoToNoHit
	mov dx, [Ticks]
	cmp [InvincibilityTickEnd], dx ; if invincibility still didnt end
	jg @@GoToNoHit
	jmp @@LoopCheckZombieHitPlantStart

@@LoopCheckZombieHitPlantStart:
    mov bx, 0
@@LoopCheckZombieHitPlant:
    push bx
    cmp [Zombies+bx], Right+PlantWidth
	jle @@AlsoCheckY
@@ContinueChecking:
    pop bx
	add bx, NextZombie ; 8
	cmp bx, [ZombiesNumNum] ; zombies max * next zombie pointer
	je @@GoToNoHit
	jmp @@LoopCheckZombieHitPlant
	
@@GoToNoHit:
    jmp @@NoHit
@@GoToEnd:
    jmp @@End
@@AlsoCheckY:
    cmp [PlantFloor], 1 ; check if plant at floor 1
	je @@Put1Height
    cmp [PlantFloor], 2 ; check if plant at floor 2
	je @@Put2Height
    cmp [PlantFloor], 3 ; check if plant at floor 3
	je @@Put3Height
    
@@Put4Height:	; put Y at floor 4 if not at 1,2,3
    mov dx, Floor4-ZombieHeight
	mov [BmpTop], Floor4-PlantHeight ; in case there is a hit
	jmp @@Continue2
	
@@Put1Height:	
	mov dx, Floor1-ZombieHeight
	mov [BmpTop], Floor1-PlantHeight ; in case there is a hit
	jmp @@Continue2
	 
@@Put2Height:
    mov dx, Floor2-ZombieHeight
	mov [BmpTop], Floor2-PlantHeight ; in case there is a hit

	jmp @@Continue2
    
@@Put3Height: 
    mov dx, Floor3-ZombieHeight
	mov [BmpTop], Floor3-PlantHeight
; all of the above puts the plants Y coordinates in dx
; as the same height as the zombies level for easier checking
    
@@Continue2:	
    cmp [Zombies+bx+2], dx ; check zombie's Y and plants Y
	je @@Hit
	jmp @@ContinueChecking
	
@@Hit:
    mov [PlantFloor], 0 ; floor 0 is timeout
	mov dx, [Ticks]
	add dx, 36 ; 2 seconds timeout
	mov [word TimeOutTick], dx ; put the time needed to get out of timeout
    add dx, 18 ; 1 second invincibility
	mov [InvincibilityTickEnd], dx
    mov [BmpLeft], Right
	mov [BmpWidth], PlantWidth
	mov [BmpHeight], PlantHeight
	mov dx, offset Sky 
	Call OpenShowBmp ; erase plant
	
	mov [BmpWidth], PlantWidth
	mov [BmpHeight], PlantHeight
	mov [BmpLeft], 0
	mov [BmpTop], 100
    mov dx, offset PlantGray
    Call OpenShowBmp  ; print the gray plant (timeout)
	jmp @@ContinueChecking
	
@@NoHit:
    cmp [PlantFloor], 0 ; if at timeout, skip
	jne @@PowerUpCheck
	mov dx, [Ticks]
	cmp dx, [word TimeOutTick]
	jle @@PowerUpCheck ; if timeout isn't finished, skip
	mov [PlantFloor], 1 ; put the plant at floor 1
	mov [BmpWidth], PlantWidth
	mov [BmpHeight], PlantHeight
	mov [BmpLeft], 0
	mov [BmpTop], 100
    mov dx, offset Sky ; erase gray plant
    Call OpenShowBmp	
	
@@PowerUpCheck:
	cmp [byte PlantState], 0 ; if normal plant, skip
	je @@PrintPlantTag
	cmp [byte PlantState+1], 1 ; check if duration is done, clear powerup
	je @@PowerUpDone
	jmp @@PrintPlantTag
	
@@PowerUpDone:
	mov [byte PlantState], 0
	mov [byte PlantState+1], 0
	
@@PrintPlantTag:
	Call PrintPlant
@@End:
    ret
endp UpdatePlant



; Make a flower golden
proc MakeFlowerGold
    mov bx, 0
@@CheckLoop:
    cmp [Flowers+bx], 0 ; check if the flowers are normal (and not dead)
	je @@Continue ; normal flower found
    inc bx
	cmp bx, 4  ; all 4 flowers are golden/dead
	jge @@End
	jmp @@CheckLoop
    
@@Continue:
	cmp bx, 0
	je @@Put1Height
	cmp bx, 1
	je @@Put2Height
	cmp bx, 2
	je @@Put3Height
    
@@Put4Height:	
    mov bx, 3
    mov ax, Flower4y
	jmp @@Continue2
	
@@Put1Height:	
    mov bx, 0
	mov ax, Flower1y
	jmp @@Continue2
	 
@@Put2Height:
    mov bx, 1
    mov ax, Flower2y
	jmp @@Continue2
    
@@Put3Height: 
    mov bx, 2
    mov ax, Flower3y


@@Continue2:
    cmp [Flowers+bx], 1 ; if the chosen flower is golden, skip
	je @@End
    mov [Flowers+bx], 1 ; 0 is alive, 1 is golden, 2 is dead

@@DrawGolden:
	mov dx, offset GoldenFlower
    mov [word BmpLeft], Flowerx
	mov [BmpTop], ax
	mov [BmpWidth], FlowerWidth ; 30
	mov [BmpHeight], FlowerHeight ; 36
	Call OpenShowBmp
@@End:
    ret
endp MakeFlowerGold

; If the plant is on a platform with a golden flower, collect it
proc CollectGold
    cmp [PlantFloor], 0
	je @@End
    mov bh, 0
    mov bl, [byte PlantFloor]
	dec bx ; floors are 1-4, pointers to flowers array are 0-3
	cmp [Flowers+bx], 1 
	jne @@End ; if flower not golden, skip
	add [word Money], 25 ; flowers adds 25 coins
	mov [Flowers+bx], 0 ;make flower normal again
	cmp bx, 0
	je @@Put1Height
	cmp bx, 1
	je @@Put2Height
	cmp bx, 2
	je @@Put3Height
    
@@Put4Height:	
    mov ax, Flower4y
	jmp @@Continue2
	
@@Put1Height:	
	mov ax, Flower1y
	jmp @@Continue2
	 
@@Put2Height:
    mov ax, Flower2y
	jmp @@Continue2
    
@@Put3Height: 
    mov ax, Flower3y


@@Continue2:
	mov dx, offset Flower
    mov [word BmpLeft], Flowerx
	mov [BmpTop], ax
	mov [BmpWidth], FlowerWidth ; 36
	mov [BmpHeight], FlowerHeight ; 30
	Call OpenShowBmp
	
@@End:
	mov bx, 0
    ret
endp CollectGold

; Print the plant
proc PrintPlant
    cmp [PlantFloor], 0
	je @@End ; if at timeout, skip
	
	cmp [PlantFloor], 2  ; check what floor
	je @@AtFloor2
	cmp [PlantFloor], 3  
	je @@AtFloor3
	cmp [PlantFloor], 4
	je @@AtFloor4
	
@@AtFloor1:
	mov [BmpTop], Floor1-PlantHeight
	jmp @@KeepPlanting
@@AtFloor2:
	mov [BmpTop], Floor2-PlantHeight
	jmp @@KeepPlanting
@@AtFloor3:
    mov [BmpTop], Floor3-PlantHeight
	jmp @@KeepPlanting
@@AtFloor4:
    mov [BmpTop], Floor4-PlantHeight
@@KeepPlanting:	
	
    cmp [byte PlantState], 1 ; if plant is fire
	je @@PutFirePlant
	cmp [byte PlantState], 2 ; if plant is ice
	je @@PutIcePlant
	mov dx, offset Plant ; if its not fire or ice then normal
	jmp @@ContinuePrintingPlant
	
@@PutFirePlant:
    mov dx, offset PlantFire
	jmp @@ContinuePrintingPlant
@@PutIcePlant:
    mov dx, offset PlantIce
	
@@ContinuePrintingPlant:
    mov [BmpLeft], Right ; 70
	mov [BmpWidth], PlantWidth ;31
	mov [BmpHeight], PlantHeight ;31
	Call OpenShowBmp ; Print the Plant
@@End:
    ret
endp PrintPlant

proc DeletePlant 
	cmp [PlantFloor], 2  ; check what floor
	je @@AtFloor2
	cmp [PlantFloor], 3  
	je @@AtFloor3
	cmp [PlantFloor], 4
	je @@AtFloor4
	
@@AtFloor1:
    mov bx, Plant1 
	jmp @@KeepDeleting
@@AtFloor2:
    mov bx, Plant2
	jmp @@KeepDeleting
@@AtFloor3:
    mov bx, Plant3
	jmp @@KeepDeleting
@@AtFloor4:
    mov bx, Plant4
@@KeepDeleting:
	
; This kind of deleting is done because its a bit faster, but more difficult
; to figure out the value of the color, only done on plant
	mov ax, 0a000h  ; graphic area address
	mov es, ax
    mov cx, PlantHeight ; 31
@@LoopBig:
    push cx
	mov cx, PlantWidth/2+1 ; 31/2 (cuz each time we put a word)
@@LoopSmall: ; this loop erases the plant (a bit faster then Calling a blank picture over the plant)
	mov [word ptr es:bx],0E8E8h ; Its sky color
	add bx, 2
	loop @@LoopSmall
	add bx, 320-32 ; 288, go down one row
	pop cx
	loop @@LoopBig
	
	ret
endp DeletePlant

; Buy the fire powerup if you got more than 100 money
proc BuyFire
    cmp [Money], 100
	jl @@End ; if not enough money, skip
	cmp [PlantFloor], 0 ; check if dead
	je @@End ; if dead, skip
	sub [Money], 100
	mov [byte PlantState], 1 ; fire mode
	mov [byte PlantState+1], 11 ; 10 seconds, powerup stops at 1 second
	
    Call PrintPlant
    
@@End:
    ret
endp BuyFire

; Buy the Ice powerup if you got more than 100 money
proc BuyIce
    cmp [Money], 100
	jl @@End ; if not enough money, skip
	cmp [PlantFloor], 0 ; check if dead
	je @@End ; if dead, skip
	sub [Money], 100
	mov [byte PlantState], 2 ; ice mode
	mov [byte PlantState+1], 11 ; 10 seconds
	
    Call PrintPlant
	
@@End:
    ret
endp BuyIce

; Updatetheflowers (kill if a zombie gets near)
proc UpdateFlowers
    mov bx, 0
@@LoopCheckZombieHitFlower:
    push bx
    cmp [Zombies+bx], Right
	je @@AlsoCheckY
	
@@ContinueChecking:
    pop bx
	add bx, NextZombie ; 8
	cmp bx, [ZombiesNumNum] ; zombies max * next zombie pointer
	je @@GoToEnd
	jmp @@LoopCheckZombieHitFlower
@@GoToEnd:
    jmp @@End

; Checking like this is done since each floor has a different
; height value so you cant just it in a loop
@@AlsoCheckY:
    cmp [Zombies+bx+2], Floor1-FlowerHeight-7 ; check Y
	jne @@Floor2Check
	cmp [Flowers], 2 ; if flower already dead, continue checking
	je @@ContinueChecking 
	mov [Flowers], 2 ; kill flower 1
	mov [BmpTop], Flower1y
	jmp @@Continue
	
@@Floor2Check:	
	cmp [Zombies+bx+2], Floor2-FlowerHeight-7 ; check Y
	jne @@Floor3Check 
	cmp [Flowers+1], 2 ; if flower already dead, continue checking
	je @@ContinueChecking
	mov [Flowers+1], 2 ; kill flower 2
	mov [BmpTop], Flower2y
	jmp @@Continue
	
@@Floor3Check:
    cmp [Zombies+bx+2], Floor3-FlowerHeight-7 ; check Y
	jne @@Floor4Check
	cmp [Flowers+2], 2 ; if flower already dead, continue checking
	je @@ContinueChecking
	mov [Flowers+2], 2 ; kill flower 3
	mov [BmpTop], Flower3y
	jmp @@Continue
	
@@Floor4Check:
    cmp [Zombies+bx+2], Floor4-FlowerHeight-7 ; check Y
    jne @@ContinueChecking
	cmp [Flowers+3], 2 ; if flower already dead, continue checking
	je @@ContinueChecking
	mov [Flowers+3], 2 ; kill flower 4
	mov [BmpTop], Flower4y
	
@@Continue:
	mov [Zombies+bx+4], 0 ; kill zombie
	mov [BmpLeft], Right-FlowerWidth-3
	mov [BmpWidth], FlowerWidth
	mov [BmpHeight], FlowerHeight
	mov dx, offset Sky
	Call OpenShowBmp
	jmp @@ContinueChecking
@@End:
    ret
endp UpdateFlowers

; Put a zombie at at a lane
proc PutZombie
    mov bx, 0
@@CheckLoop:
    cmp [Zombies+bx], 0 ; check if one of the zombies variables is empty
	je @@Continue ; empty found
	add bx, NextZombie 
	cmp bx, [ZombiesNumNum] ; zombies max * next zombie pointer
	jge @@End
	jmp @@CheckLoop
     
@@Continue:
    mov ah, 2Ch ; "Get Time" CH = hour (0-23) CL = minutes (0-59)
	int 21h ;DH = seconds (0-59) DL = hundredths (0-99)
    xor ax, ax
	mov al, dh
	mov dh, 10
	div dh ; ah is mod, al is num
	inc ah ; so no 0
    mov [byte Zombies+bx+4], ah ; put random hp 1-10
    mov ah, 2Ch ; "Get Time" CH = hour (0-23) CL = minutes (0-59)
	int 21h ;DH = seconds (0-59) DL = hundredths (0-99)
    xor ax, ax
	mov al, dh
	mov dh, 4
	div dh ; ah is mod, al is num
	cmp ah, 0
	je @@Put1Height
	cmp ah, 1
	je @@Put2Height
	cmp ah, 2
	je @@Put3Height
    
@@Put4Height:	
    mov dx, Floor4-ZombieHeight
	jmp @@Continue2
@@Put1Height:	
	mov dx, Floor1-ZombieHeight
	jmp @@Continue2
@@Put2Height:
    mov dx, Floor2-ZombieHeight
	jmp @@Continue2
@@Put3Height: 
    mov dx, Floor3-ZombieHeight

@@Continue2:

    mov [Zombies+bx], SCREEN_WIDTH - ZombieWidth ; 320 - 30 = 290, X
	mov [Zombies+bx+2], dx ; Y 

@@End:
    mov bx, 0
    ret
endp PutZombie



proc UpdateZombies ; longest function because it has ALOT to check per zombie
; Check hit ,If fire/ice, if got hurt, forward each zombie, forward at different speed if ice,
; Deal fire damage every second ,Print with all of the different states.
    mov bx, 0 ; pointer for zombie
@@LoopCheck:
	push bx
	cmp [Zombies+bx], 0 ; check if the zombie is active
	jne @@UpdateZombie ; if active, jump into updating
@@ContinueChecking:
    pop bx
	add bx, NextZombie
	cmp bx, [ZombiesNumNum] ; zombies max * next zombie pointer, if not above the 5 zombie limit (5*8=40)
	jge @@JumpToZombieEnd ; All zombies done 
    jmp @@LoopCheck ; check again untill above zombie limit
	
@@JumpToZombieEnd:
    jmp @@End	
@@GoToKillZombie:
    jmp @@KillZombie
@@GameOverHit:
    pop bx
    mov [Alive], 1
	jmp @@End
@@UpdateZombie:
    cmp [Zombies+bx], 40 ; left side
    jl @@GameOverHit ; if got to end, game over 
	cmp [Zombies+bx+4], 0 ; check if zombie's life is 0
	je @@GoToKillZombie
    cmp [Zombies+bx+6], 2 ; check if only ice
    je @@IceZombieSpeed
    cmp [Zombies+bx+6], 3 ; check if ice and fire
	je @@IceZombieSpeed ; first go into ice speed, then there-
	; -is another check for fire
	cmp [Zombies+bx+6], 1 ; check if only fire
	je @@FireDamage
	jmp @@ForwardZombie ; if normal or just fire
@@IceZombieSpeed:
    mov ax, [Ticks]
	mov dx, 0
	mov cx, 3 ; every X ticks dont do it (33.333% speed reduction)
	div cx
	cmp dx, 0 ; check if the ticks cnt is divideable by 3
    jne @@ForwardZombieIce
	cmp [Zombies+bx+6], 3 ; check if also fire
	je @@FireDamage
	jmp @@CheckHitLoopStart
@@ForwardZombieIce:
    dec [Zombies+bx] ; move zombie, speed
	cmp [Zombies+bx+6], 3 ; check if also fire
	je @@FireDamage
	jmp @@CheckHitLoopStart
	
@@FireDamage:
    mov ax, [Ticks]
	mov dx, 0
	mov cx, 18 ; every X ticks do it 
	div cx
	cmp dx, 0 ; check if the ticks cnt is divideable by 18 (about a second)
	je @@DoFireDamage
	cmp [Zombies+bx+6], 3 ;check if fire and ice, then skip forwarding
	je @@CheckHitLoopStart
	jmp @@ForwardZombie ; forward zombie without fire damage
	
@@DoFireDamage:	
	dec [Zombies+bx+4] ; hit zombie once
	cmp [zombies+bx+4], 0
	jle @@GoToKillZombie2 ; if dead
	Jmp @@GoToDrawHitZombie
	

   	
@@ForwardZombie:
		dec [Zombies+bx] ; move zombie, speed
	jmp @@CheckHitLoopStart

	
@@GoToDrawHitZombie:
    jmp @@DrawHitZombie

@@CheckHitLoopStart:
    xor dx, dx
@@CheckHitLoop:
    push dx
	push bx
    push bx ; save zombie ptr (to point on bullet ptr)
    mov bx, Offset Bullets
	add bx, dx
    mov ax, [bx] ; put X in ax
	mov cx, [bx+2] ; put Y in cx
	pop bx ; point at zombies
	cmp ax, [Zombies+bx]
	jge @@CheckAlsoY
@@ReturnFromY:
	add dx, NextBullet ; 6
	cmp dx, [BulletsNumNum] ; Bullets max * next bullets pointer
	jge @@GoToDrawZombie ; if all bullets didnt hit the zombie, draw it
	jmp @@KeepCheckingHits


@@GoToDrawZombie:
    jmp @@DrawZombie
@@KeepCheckingHits:
    pop bx
	pop dx
	add dx, NextBullet ; 6
	jmp @@CheckHitLoop

@@CheckAlsoY:
    sub cx, 14 ; get from 42 above floor (zombie height) to bullet height (28)
    cmp cx, [Zombies+bx+2]
	je @@ZombieBulletHit
	Jmp @@ReturnFromY

@@GoToKillZombie2:
    jmp @@KillZombie	

@@ZombieBulletHit:
    pop bx ; to clear the stack out of the 2 pushes done before-
	pop dx ; -in case the bullet does hit
	push bx ; to save zombie pointer
    mov bx, Offset Bullets ; start pointing on bullets
	add bx, dx
	mov ax, [word bx] ; get X of bullet
	mov [BmpLeft], ax
	mov ax, [word bx+2] ; get Y of bullet
	mov [BmpTop], ax
	mov [word bx], 0 ; reset X of bullet
	mov [word bx+2], 0 ; reset Y of bullet
    mov cx, [word bx+4] ; move hit type to cx
	pop bx ; return to point on zombies
	push bx ; save zombie ptr for after openbmp
	cmp cx, 0 ; if bullet hit is normal 
	je @@ContinueRemovingBullet
	cmp cx, 2 ; if bullet hit is ice
	je @@MakeZombieIce
	; if its not normal or ice then its fire
	
@@MakeZombieFire:
    cmp [Zombies+bx+6], 2 ; check if also ice
	je @@MakeZombieFireIce
    cmp [Zombies+bx+6], 3 ; check if also fire and ice
	je @@MakeZombieFireIce
	mov [Zombies+bx+6], 1 ; make zombie fire
	jmp @@ContinueRemovingBullet
@@MakeZombieIce:
    cmp [Zombies+bx+6], 1 ; check if also fire 
	je @@MakeZombieFireIce
	cmp [Zombies+bx+6], 3 ; check if also fire and ice
	je @@MakeZombieFireIce
	mov [Zombies+bx+6], 2 ; make zombie ice
	jmp @@ContinueRemovingBullet
@@MakeZombieFireIce:
    mov [Zombies+bx+6], 3 ; make zombie fire and ice
	

@@ContinueRemovingBullet:
    mov [BmpWidth], BulletWidth ; 20
	mov [BmpHeight] ,BulletHeight ; 7
	mov dx, offset Sky
	Call OpenShowBmp
	pop bx
    dec [Zombies+bx+4] ; dec one hp from the zombie
	cmp [Zombies+bx+4], 0
	jle @@GoToKillZombie2
	jmp @@DrawHitZombie
	
	
@@DrawZombie:
    pop bx ; to clear the stack out of the 2 pushes done before-
	pop dx ; -in case the bullet doesn't hit
	cmp [Zombies+bx+6], 2 ; if ice
	je @@PutIce
	cmp [Zombies+bx+6], 1 ; if fire
	je @@PutFire
	cmp [Zombies+bx+6], 3 ; if ice and fire
	je @@PutFireIce
	cmp [Zombies+bx+4], 5 ; if more than 5 hp
	jge @@PutCone
	mov dx, offset Zombie
	jmp @@ContinueDrawing
@@PutCone:
	mov dx, offset ZombieCone
	jmp @@ContinueDrawing
	
@@PutIce:
    cmp [Zombies+bx+4], 5 ; if more than 5 hp
	jge @@PutIceCone
    mov dx, offset ZombieIce
    jmp @@ContinueDrawing
@@PutIceCone:
	mov dx, offset ZombieConeIce
	jmp @@ContinueDrawing
@@PutFire:
    cmp [Zombies+bx+4], 5 ; if more than 5 hp
	jge @@PutFireCone
    mov dx, offset ZombieFire
    jmp @@ContinueDrawing
@@PutFireCone:
	mov dx, offset ZombieConeFire
	jmp @@ContinueDrawing
@@PutFireIce:
    cmp [Zombies+bx+4], 5 ; if more than 5 hp
	jge @@PutFireIceCone
    mov dx, offset ZombieFireIce
	jmp @@ContinueDrawing
@@PutFireIceCone:
	mov dx, offset ZombieConeFireIce


@@ContinueDrawing:
    mov ax, [Zombies+bx]	
	mov [BmpLeft], ax
	mov ax, [Zombies+bx+2]
	mov [BmpTop],ax
	mov [BmpWidth], ZombieWidth ; 30
	mov [BmpHeight] ,ZombieHeight ; 42
	Call OpenShowBmp
    jmp @@ContinueChecking

@@DrawHitZombie: 
    cmp [Zombies+bx+4], 4 ; if more than 5 hp
	jge @@ZombieConeHitTag
	mov dx, offset ZombieHit
	jmp @@ContinueHitting
@@ZombieConeHitTag:
	mov dx, offset ZombieConeHit
@@ContinueHitting:
    mov ax, [Zombies+bx] ; x
	mov [BmpLeft], ax
	mov ax, [Zombies+bx+2] ; y
	mov [BmpTop],ax
	mov [BmpWidth], ZombieWidth ; 29
	mov [BmpHeight] ,ZombieHeight ; 42
	Call OpenShowBmp
    jmp @@ContinueChecking

   
@@KillZombie:
	mov dx, offset Sky
    mov ax, [Zombies+bx]	
	mov [BmpLeft], ax
	mov ax, [Zombies+bx+2]
	mov [Zombies+bx], 0 ; Reset X
	mov [Zombies+bx+2], 0 ; Reset Y
	mov [Zombies+bx+4], 0 ; Reset Health
	mov [Zombies+bx+6], 0 ; Reset State
	mov [BmpTop],ax
	mov [BmpWidth], ZombieWidth ; 29
	mov [BmpHeight] ,ZombieHeight ; 42
	Call OpenShowBmp
	add [Score], 5
	add [Money], 3
    jmp @@ContinueChecking

@@End:
    mov bx, 0
     ret
endp UpdateZombies


; Update the Timer, Money, And score values
proc UpdateTimerMoneyScore
@@PrintTimer:
    mov ax, [Seconds]
    mov [Word ToParse], ax
	Call Parse
    mov ah, 13h ; Write String
	mov al, 00000001b  ; Write Mode, chars only, attributes in Bl, cursor not moved
	mov bh, 0 ;Video page num
	mov bl, 11111111b  ; attribute for color, 11111111b is White
	mov cx, 4 ; Length of string 
	mov dx, ds ; make es point to ds cuz
	mov es, dx ; pointer to string is "ES:BP"
	mov dh, 1 ; row coordinate
	mov dl, 0 ; column coordinate	 
	mov bp, offset Parsed
	int 10h
	
@@PrintMoney: 
    mov ax, [Money]
    mov [Word ToParse], ax
	Call Parse
	mov ah, 13h ; Write String
	mov al, 00000000b  ; Write Mode, chars only, attributes in Bl, cursor not moved
	mov bh, 0 ;Video page num
	mov bl, 00111111b  ; attribute for color, 00111111b is Yellow
	mov cx, 4 ; Length of string 
	mov dx, ds ; make es point to ds cuz
	mov es, dx ; pointer to string is "ES:BP"
	mov dh, 3 ; row coordinate
	mov dl, 0 ; column coordinate	 
	mov bp, offset Parsed
	int 10h
@@PrintScore:
    mov ax, [Score]
    mov [Word ToParse], ax
	Call Parse	
	mov ah, 13h ; Write String
	mov al, 00000000b  ; Write Mode, chars only, attributes in Bl, cursor not moved
	mov bh, 0 ;Video page num
	mov bl, 00110011b  ; attribute for color, 00110011b is Green
	mov cx, 4 ; Length of string 
	mov dx, ds ; make es point to ds cuz
	mov es, dx ; pointer to string is "ES:BP"
	mov dh, 5 ; row coordinate
	mov dl, 0 ; column coordinate	 
	mov bp, offset Parsed
	int 10h
     
     ret
endp UpdateTimerMoneyScore


    ; Parses the real num from "ToParse" to char num in "Parsed"
proc Parse
    mov ax, [ToParse]
	mov cx, 4 ; will end after 4 loops 
	mov bx, offset Parsed ; the loop cnt pointer
	add bx, 3 ; point at Parsed end
	mov dx, 0 ; reset dx
@@Loop:
    push cx
	mov cx, 10 ; to divide by 10
	div cx ; ax is num, dx is mod
	add dx, '0' ; make the mod num a char
	mov [byte bx], dl
	dec bx ; point at next num
	mov dx, 0
	pop cx
	loop @@Loop
@@End:
    ret
endp Parse

; Put the current score in the score file (done if there is a new record)
proc PutScoreInScoreFile
    mov ah, 3Dh ; Open File Using Handle
	mov al, 2 ; Read and write
	mov dx, offset ScoreFileName ; "Score"
	int 21h ; Open File Using Handle
	jnc @@Opened ; if file opened, jump
	
	mov ah, 3Ch ; Create File Using Handle
	mov cx, 00000000b ; file attributes, nothing
	int 21h ; Create File Using Handle
	mov ah, 3Dh ; Open File Using Handle
	mov al, 2 ; Read and write
	int 21h ; Open File Using Handle

@@Opened:
	mov bx, ax ; move handle to bx
	mov ah, 40h ; Write to File Using Handle
	mov cx, 2 ; 2 bytes to write
	mov dx, offset Score ; pointer to write buffer
	int 21h ; Write to File Using Handle
	
	mov ah, 3Eh ; Close File Using Handle
	int 21h ; Close File Using Handle
	ret
endp

; Put the score from the score file into Ax
proc PutScoreInAx
	mov ah, 3Dh ; Open File Using Handle
	mov al, 2 ; Read and write
	mov dx, offset ScoreFileName ; "Score"
	int 21h ; Open File Using Handle
	jnc @@Opened ; if file opened, jump
	
	mov ah, 3Ch ; Create File Using Handle
	mov cx, 00000000b ; file attributes, nothing
	int 21h ; Create File Using Handle
	mov ah, 3Dh ; Open File Using Handle
	mov al, 2 ; Read and write
	int 21h ; Open File Using Handle

@@Opened:
	mov bx, ax ; move handle to bx
    mov ah, 3Fh ; Read From File Using Handle
	mov cx, 2 ; 2 bytes to read
	mov dx, offset OldHighScore
	int 21h ; Read From File Using Handle
	mov ah, 3Eh ; Close File Using Handle
	int 21h ; Close File Using Handle
	mov ax, [word OldHighScore]
	ret
endp

; Update the Nums at the settings (ZombiesNum and BulletsNum)
proc UpdateNumsAtSettings
    mov ax, [ZombiesNum]
    mov [word ToParse], ax
	Call Parse
	mov ah, 13h ; Write String
	mov al, 00000001b  ; Write Mode, chars only, attributes in Bl, cursor not moved
	mov bh, 0 ;Video page num
	mov bl, 11111111b  ; attribute for color, 11111111b is White
	mov cx, 1 ; Length of string 
	mov dx, ds ; make es point to ds cuz
	mov es, dx ; pointer to string is "ES:BP"
	mov dh, 5 ; row coordinate
	mov dl, 22 ; column coordinate	 
	mov bp, offset Parsed
	add bp, 3
	int 10h ; Write ZombiesNum at settings
	mov ax, [BulletsNum]
	mov [word ToParse], ax
	Call Parse
    mov ah, 13h ; Write String
	mov al, 00000001b  ; Write Mode, chars only, attributes in Bl, cursor not moved
	mov bh, 0 ;Video page num
	mov bl, 11111111b  ; attribute for color, 11111111b is White
	mov cx, 1 ; Length of string 
	mov dx, ds ; make es point to ds cuz
	mov es, dx ; pointer to string is "ES:BP"
	mov dh, 8 ; row coordinate
	mov dl, 22 ; column coordinate	 
	mov bp, offset Parsed
	add bp, 3
	int 10h ; Write BulletsNum at settings
	ret
endp

; Forward each bullet, erase and print with the corresponding states.
proc UpdateBullets
    mov bx, 0 ; pointer for bullets
@@LoopCheck:
	cmp [Bullets+bx], 0 ; check if the bullet is active
	push bx
	jne @@UpdateBullet ; if active, jump into checking
@@ContinueChecking:
    pop bx
	add bx, NextBullet
	cmp bx, [word BulletsNumNum] ; Bullets max * next bullets pointer, if not above the bullet limit 
	jge @@End ; All bullets done or none needed updating
    jmp @@LoopCheck ; check again untill above bullet limit
	
@@UpdateBullet:
    cmp [Bullets+bx], 320-BulletWidth ; 307, to check if its not outside the screen
    jg @@KillBullet ; if outside screen, delete bullet
	add [Bullets+bx], 8 ; speed
	cmp [Bullets+bx+4], 1 ; check if fire bullet
	je @@PutFireBullet
    cmp [Bullets+bx+4], 2 ; check if ice bullet
	je @@PutIceBullet
	mov dx, offset Bullet
	jmp @@Continue
	
@@PutFireBullet:
    mov dx, offset BulletFire
    jmp @@Continue
@@PutIceBullet:
    mov dx, offset BulletIce
@@Continue:

    mov ax, [Bullets+bx]	
	mov [BmpLeft], ax
	mov ax, [Bullets+bx+2]
	mov [BmpTop],ax
	mov [BmpWidth], BulletWidth ; 20
	mov [BmpHeight] ,BulletHeight ; 7
	Call OpenShowBmp
    jmp @@ContinueChecking
    
@@KillBullet:
	mov dx, offset Sky
    mov ax, [Bullets+bx]	
	mov [BmpLeft], ax
	mov ax, [Bullets+bx+2]
	mov [Bullets+bx], 0 ; Reset X
	mov [Bullets+bx+2], 0 ; Reset Y
	mov [BmpTop],ax
	mov [BmpWidth], BulletWidth ; 20
	mov [BmpHeight] ,BulletHeight ; 7
	Call OpenShowBmp
    jmp @@ContinueChecking

@@End:
    mov bx, 0
     ret
endp UpdateBullets

; Get the last key pressed and flush the keyboard so there wont be more than 1
proc FlushKBandGetLastKey
	push ax
	xor bx,bx
CheckBuffer:
	mov ah ,1
	int 16h
	jz @@return ; if no press
	mov ah ,0
	int 16h
	mov bx,ax
	jmp CheckBuffer
@@return:
	pop ax
	ret
endp FlushKBandGetLastKey

; Print a bmp
proc OpenShowBmp near
	
	 
	Call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	Call ReadBmpHeader
	
	Call ReadBmpPalette
	
	Call CopyBmpPalette
	
	Call ShowBMP
	
	 
	Call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp

 
; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile
 



proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile



; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader

proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,1024
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h, put al in ptr dx
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette

 

proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic

 
 
proc ShowBMP
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpHeight lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	push es
	mov es, ax
	
 
	mov ax,[BmpWidth] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	mov bp, 0
	and ax, 3
	cmp ax, 0 
	jz @@row_ok
	mov bp,4
	sub bp,ax

@@row_ok:	
	mov cx,[BmpHeight]
    dec cx
	add cx,[BmpTop] ; add the Y on entire screen
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	add di,[BmpLeft]
	cld ; Clear direction flag, for movsb forward
	
	mov cx, [BmpHeight]
@@NextLine:
	push cx
 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpWidth]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory es:di
	mov cx,[BmpWidth]  
	mov si,offset ScrLine
@@KeepCopying:
	cmp [ScrLine+si], 0FFh ; check if white (white is always FF and black is always 0)
	je @@White ; jmp if white
	movsb ; Copy line to the screen
    jmp @@Finished
@@White:
    inc di ; point next color
	inc si ; point next color
@@Finished:
	loop @@KeepCopying
	sub di,[BmpWidth]            ; return to left bmp
	sub di,SCREEN_WIDTH  ; jump one screen line up
	
	pop cx
	loop @@NextLine
	
	pop cx
	pop es
	ret
endp ShowBMP

END start