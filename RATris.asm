;---------------------------------------------------------------------
; An expanded "draw_dot" program that includes subrountines to draw
; vertical lines, horizontal lines, and a full background. 
; 
; As written, this programs does the following: 
;   1) draws a the background blue (draws all the tiles)
;   2) draws a red dot
;   3) draws a red horizontal lines
;   4) draws a red vertical line
;
; Author: Bridget Benson 
; Modifications: bryan mealy, samuel wong
; r7 - generally used for initial y coord
; r8 - generally used for initial x coord
; r6 - used for current color
; r10 - destination y coord
; r11 - destination x coord
; r18 - decides which block to spawn
; r12
;---------------------------------------------------------------------

.CSEG
.ORG 0x10

.EQU SSEG_ID = 0x81
.EQU VGA_HADD = 0x90
.EQU VGA_LADD = 0x91
.EQU VGA_COLOR = 0x92
.EQU VGA_READ = 0x93
.EQU LEDS = 0x40


.EQU RNG_PORT = 0x11

.EQU LDR = 0x10


.EQU BG_COLOR       = 0x00             ; Background:  black
.EQU WHITE			= 0xFF
.EQU YELLOW			= 0xFC
.EQU BLUE			= 0x03
.EQU GREEN			= 0x1B

.EQU LEFT_BORDER_X	= 0x02
.EQU LEFT_BORDER_XA1 = 0x03
.EQU RIGHT_BORDER_X	= 0x0D ;for standard tetris playspace, add 0x0B to LEFT_BORDER_X
.EQU TOP_BORDER_Y	= 0x05
.EQU BOTTOM_BORDER_Y = 0x1A ;for standard tetris playspace, add 0x15 to TOP_BORDER_Y




.EQU SP_O = 0x10
.EQU SP_I = 0x20
.EQU SP_S = 0x30
.EQU SP_Z = 0x40
.EQU SP_L = 0x50
.EQU SP_J = 0x60
.EQU SP_T = 0x70
;--------------------
;-these represent the 2x4 spawn area at the top
.EQU SP1X = 0x06
.EQU SP2X = 0x07
.EQU SP3X = 0x08
.EQU SP4X = 0x09
.EQU SP1Y = 0x05
.EQU SP2Y = 0x06
;--------------------
;
;r6 is used for color
;r7 is used for Y
;r8 is used for X
;r20-r27 stores coordinates of blocks
;---------------------------------------------------------------------
init:
		MOV R0, 0x00
         CALL   draw_background         ; draw using default color

         ;MOV    r7, 0x0F                ; generic Y coordinate
         ;MOV    r8, 0x14                ; generic X coordinate
         MOV    r6, 0xFF             ; color
         ;CALL   draw_dot                ; draw red pixel 

         MOV    r8,LEFT_BORDER_X                 ; starting x coordinate
         MOV    r7,BOTTOM_BORDER_Y                 ; start y coordinate
         MOV    r9,RIGHT_BORDER_X; ending x coordinate
         CALL   draw_horizontal_line

         MOV    r8,LEFT_BORDER_X                 ; starting x coordinate
         MOV    r7,TOP_BORDER_Y; start y coordinate
         MOV    r9,BOTTOM_BORDER_Y                 ; ending y coordinate
         CALL   draw_vertical_line

         MOV    r8,RIGHT_BORDER_X                 ; starting x coordinate
         MOV    r7,TOP_BORDER_Y                 ; start y coordinate
         MOV    r9,BOTTOM_BORDER_Y                 ; ending y coordinate
         CALL   draw_vertical_line


		BRN select
spawn_state:		MOV		r19,0x00
					MOV		r6, 0xFF
					MOV		r7, SP1Y
					MOV 	r8, SP2X
					CALL	move_dot_down
					

		 
main:    AND    r0, r0                  ; nop
         BRN    main                    ; continuous loop 
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;-	Subroutine: move dot down
;-	Parameters: (r8, r7)
;-	r8 = starting x-coord
;-	r7 = starting y-coord
;-	r6 = color of dot
;- 	Tweaked registers : r10, r11
;- ~SW
;--------------------------------------------------------------------
move_dot_down:	CALL draw_dot
				MOV R11, R8

move_dot_down1:	MOV R10, R7 ;set destination y coord as initial
				ADD R10, 0x01 ;add 1 to destination y coord, going to be the point below the intitial
				CALL move_dot
				CMP R19, 0x01
				BREQ spawn_state
				ADD R7, 0x01 ;set initial y as the coord below
				CALL level_delay
				BRN move_dot_down1





level_delay:	CLI
				MOV R15, 0x30
				MOV R28, 0x00
BR1: 			SUB R15, 0x01
				CMP R15, 0x00
				BREQ BRN_RETID
				MOV R16, 0xFF
				ADD R28, 0x01
				CMP R28, 0x0A
				BREQ BRN_SEI
				BRN BR2
BR2: 			SUB R16, 0x01
				CMP R16, 0x00
				BREQ BR1
				MOV R17, 0xFF
				BRN BR3
BR3: 			SUB R17, 0x01
				CMP R17, 0x00
				BREQ BR2
				BRN BR3

BRN_SEI:		MOV R28, 0x00
				SEI
				BRN BR2
				
BRN_RETID:		RETID



BRN_RET:		RET
BRN_RETIE:		RETIE


;- check_lines_to_clear: remember this is a different game from tetris btw


;--------------------------------------------------------------------
;-  Subroutine: select
;-
;-  Selects random block based on pseudorandom number generator module. Increments a register
;- 	each cycle until it equals the random number. Can change frequency of each block based on the range
;-	given until it checks for the next block.
;- 	
;- 
;-  Parameters:
;-   r20 = number that is compared to r21 that will branch to block if equal, chosen by PRNG module
;-   r21 = number compared to r20 that will branch if equal, incremented every cycle
;-   r0	 = score that increments every time a block is selected, a count for every block on the screen
;-   
;- Tweaked registers: r12, r13, r14 (controls if block moves LEFT, DOWN, RIGHT respectively)
;- ~SW
;--------------------------------------------------------------------


select: 
        MOV R12, 0x00 ;clear left,down,right registers
        MOV R13, 0x00
        MOV R14, 0x00
        CLI
        MOV r21, 0x00
        IN R20, RNG_PORT
		ADD R0, 0x01
        OUT R0, SSEG_ID
		
select_O:
        CMP R20, R21
        BREQ set_O
        CMP R21, 0x3F ;-max range it will count to since last block, increase to make selection of this block more probable
        BREQ select_I
        ADD R21, 0x01
        BRN select_O

select_I:
        CMP R20, R21
        BREQ set_I
        CMP R21, 0x5F
        BREQ select_S
        ADD R21, 0x01
        BRN select_I

select_S:
        CMP R20, R21
        BREQ set_S
        CMP R21, 0x7F
        BREQ select_Z
        ADD R21, 0x01
        BRN select_S

select_Z:
        CMP R20, R21
        BREQ set_Z
        CMP R21, 0x9F
        BREQ select_L
        ADD R21, 0x01
        BRN select_Z

select_L:
        CMP R20, R21
        BREQ set_L
        CMP R21, 0xBF
        BREQ select_J
        ADD R21, 0x01
        BRN select_L

select_J:
        CMP R20, R21
        BREQ set_J
        CMP R21, 0xDF
        BREQ select_T
        ADD R21, 0x01
        BRN select_J

select_T:
        CMP R20, R21
        BREQ set_T
        CMP R21, 0xFF
        BREQ select_I
        ADD R21, 0x01
        BRN select_T


;--------------------------------------------------------------------
;-  Subroutine: set_"block"
;-
;-  Sets the coordinates for the corresponding "block" to spawn
;- 
;-
;- COORDINATES:
;-		[SP1X][SP2X][SP3X][SP4X]
;-[SP1Y}  []	[]    []    []
;-[SP2Y]  []    []    []    []
;-
;-  Parameters:
;-   r20, r21  = coordinate1 y, x
;-   r22, r23  = coordinate2 y, x
;-   r24, r25  = coordinate3 y, x
;-   r26, r27  = coordinate4 y, x
;- Tweaked registers: r18
;- ~SW
;--------------------------------------------------------------------
set_O:		
			MOV R18, SP_O
			MOV R20, SP1Y ;assign coordinates for each dot
			MOV R21, SP2X
			MOV R22, SP1Y
			MOV R23, SP3X
			MOV R24, SP2Y
			MOV R25, SP2X
			MOV R26, SP2Y
			MOV R27, SP3X
			BRN check_spawn_valid

set_I:		
			MOV R18, SP_I
			MOV R20, SP1Y ;assign coordinates for each dot
			MOV R21, SP1X
			MOV R22, SP1Y
			MOV R23, SP2X
			MOV R24, SP1Y
			MOV R25, SP3X
			MOV R26, SP1Y
			MOV R27, SP4X
			BRN check_spawn_valid

set_S:		
			MOV R18, SP_S
			MOV R20, SP2Y ;assign coordinates for each dot
			MOV R21, SP2X
			MOV R22, SP2Y
			MOV R23, SP3X
			MOV R24, SP1Y
			MOV R25, SP3X
			MOV R26, SP1Y
			MOV R27, SP4X
			BRN check_spawn_valid

set_Z:		
			MOV R18, SP_Z
			MOV R20, SP1Y ;assign coordinates for each dot
			MOV R21, SP2X
			MOV R22, SP1Y
			MOV R23, SP3X
			MOV R24, SP2Y
			MOV R25, SP3X
			MOV R26, SP2Y
			MOV R27, SP4X
			BRN check_spawn_valid

set_L:		MOV R15, 0x30
			MOV R18, SP_L
			MOV R20, SP2Y ;assign coordinates for each dot
			MOV R21, SP2X
			MOV R22, SP1Y
			MOV R23, SP2X
			MOV R24, SP1Y
			MOV R25, SP3X
			MOV R26, SP1Y
			MOV R27, SP4X
			BRN check_spawn_valid

set_J:		
			MOV R18, SP_J
			MOV R20, SP1Y ;assign coordinates for each dot
			MOV R21, SP2X
			MOV R22, SP1Y
			MOV R23, SP3X
			MOV R24, SP1Y
			MOV R25, SP4X
			MOV R26, SP2Y
			MOV R27, SP4X
			BRN check_spawn_valid

set_T:		
			MOV R18, SP_T
			MOV R20, SP2Y ;assign coordinates for each dot
			MOV R21, SP3X
			MOV R22, SP1Y
			MOV R23, SP2X
			MOV R24, SP1Y
			MOV R25, SP3X
			MOV R26, SP1Y
			MOV R27, SP4X
			BRN check_spawn_valid

;--------------------------------------------------------------------
;-  Subroutine: check_spawn_valid
;-
;-  Checks if the area covered by the spawn location of the block
;-  only consists of the background color, making it legal to spawn.
;-
;- COORDINATES:
;-		[SP1X][SP2X][SP3X][SP4X]
;-[SP1Y}  []	[]    []    []
;-[SP2Y]  []    []    []    []
;-
;-  Parameters:
;-   r20, r21  = coordinate1 y, x
;-   r22, r23  = coordinate2 y, x
;-   r24, r25  = coordinate3 y, x
;-   r26, r27  = coordinate4 y, x
;- Tweaked registers: r10, r11, r6
;- ~SW
;--------------------------------------------------------------------
check_spawn_valid:	
			MOV R10, R20
			MOV R11, R21
			CALL read_dot
			CMP R6, BG_COLOR
			BRNE game_over
			MOV R10, R22
			MOV R11, R23
			CALL read_dot
			CMP R6, BG_COLOR
			BRNE game_over
			MOV R10, R24
			MOV R11, R25
			CALL read_dot
			CMP R6, BG_COLOR
			BRNE game_over
			MOV R10, R26
			MOV R11, R27
			CALL read_dot
			CMP R6, BG_COLOR
			BRNE game_over
			BRN spawn

spawn:		;spawn the block from registers set by the prior set_"block" subroutine		
			MOV R6, 0xFC
			MOV R7, R20
			MOV R8, R21
			CALL draw_dot
			MOV R7, R22
			MOV R8, R23
			CALL draw_dot
			MOV R7, R24
			MOV R8, R25
			CALL draw_dot
			MOV R7, R26
			MOV R8, R27
			CALL draw_dot
			BRN which_block
			
which_block: ;will check which of the 7 blocks to check for down, handled in the drop state
			
			CMP R18, SP_O
			BREQ check_O_down_valid
			CMP R18, SP_I
			BREQ check_I_down_valid
			CMP R18, SP_S
			BREQ check_S_down_valid
			CMP R18, SP_Z
			BREQ check_Z_down_valid
			CMP R18, SP_J
			BREQ check_J_down_valid
			CMP R18, SP_L
			BREQ check_L_down_valid
			CMP R18, SP_T
			BREQ check_T_down_valid
			
move_block:
			MOV R6, BG_COLOR ;these four BG_color draws will erase the current block and 
			MOV R7, R26
			MOV R8, R27
			CALL draw_dot
			MOV R6, BG_COLOR
			MOV R7, R24
			MOV R8, R25
			CALL draw_dot			
			MOV R6, BG_COLOR
			MOV R7, R22
			MOV R8, R23
			CALL draw_dot
			MOV R6, BG_COLOR
			MOV R7, R20
			MOV R8, R21
			CALL draw_dot
			ADD R26, R13 ;will translate down if down_valid
			ADD R27, R14 ;will translate right if right_valid
			SUB R27, R12 ;will translate left if left_valid
			
			ADD R24, R13;repeat above for other registers representing block's coordinates
			ADD R25, R14 
			SUB R25, R12

			ADD R22, R13
			ADD R23, R14 
			SUB R23, R12 

			ADD R20, R13
			ADD R21, R14 
			SUB R21, R12 
			MOV R6, 0xFC ;replace with a new function to select color based on block
			MOV R7, R26
			MOV R8, R27
			CALL draw_dot
			MOV R7, R24
			MOV R8, R25
			CALL draw_dot			
			MOV R7, R22
			MOV R8, R23
			CALL draw_dot
			MOV R7, R20
			MOV R8, R21
			CALL draw_dot

			MOV R12, 0x00 ;clear direction registers to prevent direction bugs
			MOV R13, 0x00
			MOV R14, 0x00
			RET


;--------------------------------------------------------------------
;-  Subroutine: check_"BLOCK"_"DIRECTION"_valid
;-
;-  Will check if it's valid to move to the direction specified. It is valid if the
;- next colliding spaces are not anything but the background color.
;- If valid, a register will be set corresponding to the direction being checked.
;- It will call the move_block function if valid, which is an arithmetic function
;- that will add the set register to the current coordinates of the block.
;-
;- COORDINATES:
;-		[SP1X][SP2X][SP3X][SP4X]
;-[SP1Y}  []	[]    []    []
;-[SP2Y]  []    []    []    []
;-
;-  Parameters:
;-   r20, r21  = coordinate1 y, x
;-   r22, r23  = coordinate2 y, x
;-   r24, r25  = coordinate3 y, x
;-   r26, r27  = coordinate4 y, x
;- Tweaked registers: r10, r11, r6
;- ~SW
;--------------------------------------------------------------------
check_O_down_valid:	

			CALL level_delay			;check if two pixels under block are valid
			MOV R10, R24
			MOV R11, R25
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R11, R27
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			ADD r13, 0x01
			CALL move_block
			BRN check_O_down_valid
check_I_down_valid:
			CALL level_delay			;check if 4 pixels under block are valid
			MOV R10, R20
			MOV R11, R21
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R22
			MOV R11, R23
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R24
			MOV R11, R25
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R26
			MOV R11, R27
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			ADD r13, 0x01
			CALL move_block
			BRN check_I_down_valid

check_S_down_valid:
			CALL level_delay			;check if 3 pixels under block are valid
			MOV R10, R20
			MOV R11, R21
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R22
			MOV R11, R23
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R26
			MOV R11, R27
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			ADD r13, 0x01
			CALL move_block
			BRN check_S_down_valid
			
check_Z_down_valid:
			CALL level_delay			;check if 3 pixels under block are valid
			MOV R10, R20
			MOV R11, R21
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R24
			MOV R11, R25
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R26
			MOV R11, R27
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			ADD r13, 0x01
			CALL move_block
			BRN check_Z_down_valid
			
check_J_down_valid:
			CALL level_delay			;check if 3 pixels under block are valid
			MOV R10, R20
			MOV R11, R21
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R22
			MOV R11, R23
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R26
			MOV R11, R27
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			ADD r13, 0x01
			CALL move_block
			BRN check_J_down_valid
			
check_L_down_valid:
			CALL level_delay			;check if 3 pixels under block are valid
			MOV R10, R20
			MOV R11, R21
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R24
			MOV R11, R25
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R26
			MOV R11, R27
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			ADD r13, 0x01
			CALL move_block
			BRN check_L_down_valid	
		
check_T_down_valid:
			CALL level_delay			;check if 3 pixels under block are valid
			MOV R10, R20
			MOV R11, R21
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R22
			MOV R11, R23
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			MOV R10, R26
			MOV R11, R27
			ADD R10, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE select
			ADD r13, 0x01
			CALL move_block
			BRN check_T_down_valid			



check_O_right_valid:
			MOV R10, R22
			MOV R11, R23
			ADD R11, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE BRN_RETID
			MOV R10, R26
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE BRN_RETID
			ADD R14, 0x01
			CALL move_block
			RETID
check_I_right_valid:
		 MOV R10, R26
		 MOV R11, R27
		 ADD R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R14, 0x01
         CALL move_block
         RETID
check_S_right_valid:
		 MOV R10, R26
		 MOV R11, R27
		 ADD R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
		 MOV R10, R22
		 MOV R11, R23
		 ADD R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R14, 0x01
         CALL move_block
         RETID
check_Z_right_valid:
		 MOV R10, R26
		 MOV R11, R27
		 ADD R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
		 MOV R10, R22
		 MOV R11, R23
		 ADD R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R14, 0x01
         CALL move_block
         RETID
check_J_right_valid:
		 MOV R10, R24
		 MOV R11, R25
		 ADD R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
		 MOV R10, R26
		 MOV R11, R27
		 ADD R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R14, 0x01
         CALL move_block
         RETID
check_L_right_valid:
		 MOV R10, R20
		 MOV R11, R21
		 ADD R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
		 MOV R10, R26
		 MOV R11, R27
		 ADD R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R14, 0x01
         CALL move_block
         RETID
check_T_right_valid:
         MOV R10, R20
         MOV R11, R21
         ADD R11, 0x01
         CALL read_dot
         CMP r6, BG_COLOR
         BRNE BRN_RETID
         MOV R10, R26
         MOV R11, R27
         ADD R11, 0x01
         CALL read_dot
         CMP r6, BG_COLOR
         BRNE BRN_RETID
         ADD R14, 0x01
         CALL move_block
         RETID


check_O_left_valid:
			MOV R10, R20
			MOV R11, R21
			SUB R11, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE BRN_RETID
			MOV R10, R24
			MOV R11, R25
			SUB R11, 0x01
			CALL read_dot
			CMP r6, BG_COLOR
			BRNE BRN_RETID
			ADD R12, 0x01
			CALL move_block
			RETID
check_I_left_valid:
		 MOV R10, R20
		 MOV R11, R21
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R12, 0x01
         CALL move_block
         RETID
check_S_left_valid:
		 MOV R10, R20
		 MOV R11, R21
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
		 MOV R10, R24
		 MOV R11, R25
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R12, 0x01
         CALL move_block
         RETID
check_Z_left_valid:
		 MOV R10, R20
		 MOV R11, R21
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
		 MOV R10, R24
		 MOV R11, R25
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R12, 0x01
         CALL move_block
         RETID
check_J_left_valid:
		 MOV R10, R20
		 MOV R11, R21
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
		 MOV R10, R26
		 MOV R11, R27
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R12, 0x01
         CALL move_block
         RETID
check_L_left_valid:
		 MOV R10, R20
		 MOV R11, R21
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
		 MOV R10, R22
		 MOV R11, R23
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R12, 0x01
         CALL move_block
         RETID
check_T_left_valid:
		 MOV R10, R20
		 MOV R11, R21
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
		 MOV R10, R22
		 MOV R11, R23
		 SUB R11, 0x01
		 CALL read_dot
		 CMP r6, BG_COLOR
		 BRNE BRN_RETID
         ADD R12, 0x01
         CALL move_block
         RETID

;--------------------------------------------------------------------
;-  Subroutine: draw_horizontal_line
;-
;-  Draws a horizontal line from (r8,r7) to (r9,r7) using color in r6
;-
;-  Parameters:
;-   r8  = starting x-coordinate
;-   r7  = y-coordinate
;-   r9  = ending x-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r8,r9
;--------------------------------------------------------------------
draw_horizontal_line:
        ADD    r9,0x01          ; go from r8 to r15 inclusive

draw_horiz1:
        CALL   draw_dot         ; 
        ADD    r8,0x01
        CMP    r8,r9
        BRNE   draw_horiz1
        RET
;--------------------------------------------------------------------


;---------------------------------------------------------------------
;-  Subroutine: draw_vertical_line
;-
;-  Draws a horizontal line from (r8,r7) to (r8,r9) using color in r6
;-
;-  Parameters:
;-   r8  = x-coordinate
;-   r7  = starting y-coordinate
;-   r9  = ending y-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r7,r9
;--------------------------------------------------------------------
draw_vertical_line:
         ADD    r9,0x01

draw_vert1:          
         CALL   draw_dot
         ADD    r7,0x01
         CMP    r7,R9
         BRNE   draw_vert1
         RET
;--------------------------------------------------------------------

;---------------------------------------------------------------------
;-  Subroutine: draw_background
;-
;-  Fills the 30x40 grid with one color using successive calls to 
;-  draw_horizontal_line subroutine. 
;- 
;-  Tweaked registers: r13,r7,r8,r9
;----------------------------------------------------------------------
draw_background: 
         MOV   r6,BG_COLOR              ; use default color
         MOV   r13,0x00                 ; r13 keeps track of rows
start:   MOV   r7,r13                   ; load current row count 
         MOV   r8,0x00                  ; restart x coordinates
         MOV   r9,0x27 
 
         CALL  draw_horizontal_line
         ADD   r13,0x01                 ; increment row count
         CMP   r13,0x1D                 ; see if more rows to draw
         BRNE  start                    ; branch to draw more rows
         RET
;---------------------------------------------------------------------
    
;---------------------------------------------------------------------
;- Subrountine: draw_dot
;- 
;- This subroutine draws a dot on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  
;- 
;- Tweaked registers: r4,r5
;---------------------------------------------------------------------
draw_dot: 
           MOV   r4,r7         ; copy Y coordinate
           MOV   r5,r8         ; copy X coordinate

           AND   r5,0x3F       ; make sure top 2 bits cleared
           AND   r4,0x1F       ; make sure top 3 bits cleared
           LSR   r4             ; need to get the bot 2 bits of r4 into sA
           BRCS  dd_add40
t1:        LSR   r4
           BRCS  dd_add80

dd_out:    OUT   r5,VGA_LADD   ; write bot 8 address bits to register
           OUT   r4,VGA_HADD   ; write top 3 address bits to register
           OUT   r6,VGA_COLOR  ; write data to frame buffer
           RET

dd_add40:  OR    r5,0x40       ; set bit if needed
           CLC                  ; freshen bit
           BRN   t1             

dd_add80:  OR    r5,0x80       ; set bit if needed
           BRN   dd_out
; --------------------------------------------------------------------
;---------------------------------------------------------------------
;- Subrountine: read_dot
;- 
;- This subroutine reads a dot on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  
;- 
;- Tweaked registers: r4,r5
;---------------------------------------------------------------------
read_dot: 
           MOV   r4,r10         ; copy Y coordinate
           MOV   r5,r11        ; copy X coordinate

           AND   r5,0x3F       ; make sure top 2 bits cleared
           AND   r4,0x1F       ; make sure top 3 bits cleared
           LSR   r4             ; need to get the bot 2 bits of r4 into sA
           BRCS  dd_add40r
t1r:        LSR   r4
           BRCS  dd_add80r

dd_outr:    OUT   r5,VGA_LADD   ; write bot 8 address bits to register
           OUT   r4,VGA_HADD   ; write top 3 address bits to register
           IN	 r6,VGA_READ	; write data to frame buffer
           RET

dd_add40r:  OR    r5,0x40       ; set bit if needed
           CLC                  ; freshen bit
           BRN   t1r             

dd_add80r:  OR    r5,0x80       ; set bit if needed
           BRN   dd_outr
; --------------------------------------------------------------------
;---------------------------------------------------------------------
;- Subrountine: move_dot
;- 
;- This subroutine reads a dot on the display the given coordinates (swaps the colors of 2 pixels): 
;- This will also check for a valid 
;- (Xi,Yi) = (r8,r7)  
;- (Xf,Yf) = (r11,r10)
;-
;- Tweaked registers: r4,r5,r6(to be stored)
;---------------------------------------------------------------------

move_dot:	
			CALL read_dot ;read destination color
			PUSH R6 ;store destination coordinate's color
			PUSH R10 ;store destination y coordinate
			PUSH R11 ;store destination x coordinate
			MOV	R10, R7 ;prepare initial y for reading
			MOV R11, R8 ;prepare initial x for reading
			CALL read_dot ;read initial color
			POP R8 ;set destination x coord for writing
			POP R7 ;set destination y coord for writing
			CALL draw_dot
			MOV R8, R11	;set initial x coord for writing
			MOV R7, R10	;set initial y coord for writing
			POP R6	;set destination's color
			CALL draw_dot
			RET

next_block:	MOV R19, 0x01
			RET

; --------------------------------------------------------------------

;---------------------------------------------------------------------
;- ISR - check and move Left, Down, or Right
;- 
;- If either left or right input high, trigger INT
;- then read which direction caused the interrupt, symbolized by 3 different bits
;- from port LDR.
;-
;-
;- 
;---------------------------------------------------------------------

ISR:
			            ;MOV r29, DOWN ;mov down into reg, will implement later
            IN r31, LDR ;mov left into reg

check_dir   
            CMP r31, 0x01 ;check if right is high
            BREQ mov_right
			CMP r31, 0x04 ;check if left is high
            BREQ mov_left
			CMP r31, 0x02 ;check if down
			BREQ no_delay

            RETID

no_delay:	MOV R15, 0x01 ;if down, when returning to the level_delay function, will quickly return since R15 is a lower value now
			RETID

mov_left:	;selects which check_left to branch to, depending on current block
			CMP R18, SP_O
			BREQ check_O_left_valid
			CMP R18, SP_I
			BREQ check_I_left_valid
			CMP R18, SP_S
			BREQ check_S_left_valid
			CMP R18, SP_Z
			BREQ check_Z_left_valid
			CMP R18, SP_J
			BREQ check_J_left_valid
			CMP R18, SP_L
			BREQ check_L_left_valid
			CMP R18, SP_T
			BREQ check_T_left_valid

            RETID

mov_right:	;same as above, but branches to corresponding check_right
			CMP R18, SP_O
			BREQ check_O_right_valid
			CMP R18, SP_I
			BREQ check_I_right_valid
			CMP R18, SP_S
			BREQ check_S_right_valid
			CMP R18, SP_Z
			BREQ check_Z_right_valid
			CMP R18, SP_J
			BREQ check_J_right_valid
			CMP R18, SP_L
			BREQ check_L_right_valid
			CMP R18, SP_T
			BREQ check_T_right_valid

            RETID


;-------------------------------------------------------------------
;-game over screen - draws game over and loops to create a scanline effect. uses existing 
;-draw_lines functions
game_over:
			CALL draw_background ;draws background

			MOV r8, 0x0A ;top of 'G'
			MOV r9, 0x0D
			MOV r7, 0x04
			MOV r6, 0xFF
			CALL draw_horizontal_line
			MOV r8, 0x0A
			MOV r9, 0x0D
			MOV r7, 0x09 ;bottom of 'G'
			CALL draw_horizontal_line
			MOV r7, 0x05 ; left side of 'G'
			MOV r9, 0x08
			MOV r8, 0x09
			CALL draw_vertical_line
			MOV r8, 0x0C
			MOV r7, 0x07
			MOV r9, 0x08
			CALL draw_dot
			MOV r8, 0x0D
			MOV r7, 0x07
			MOV r9, 0x08
			CALL draw_dot
			MOV r7, 0x08
			MOV r9, 0x08
			MOV r8, 0x0D
			CALL draw_dot

			MOV r8, 0x0F ; center of 'A'
			MOV r9, 0x13
			MOV r7, 0x08
			CALL draw_horizontal_line
			MOV r7, 0x07;left of 'A'
			MOV r9, 0x09
			MOV r8 , 0x0F
			CALL draw_vertical_line
			MOV r8, 0x13; right of 'A'
			MOV r7, 0x07
			MOV r9, 0x09
			CALL draw_vertical_line
			MOV r7, 0x05 ;upper left of 'A'
			MOV r9, 0x06
			MOV r8, 0x10
			CALL draw_vertical_line
			MOV r8, 0x12 ;upper right of 'A'
			MOV r7, 0x05 
			MOV r9, 0x06
			CALL draw_vertical_line
			MOV r8, 0x11
			MOV r7, 0x04
			MOV r9, 0x06
			CALL draw_dot
			
			MOV r7, 0x04 ;left of 'M'
			MOV r9, 0x09
			MOV r8, 0x15
			CALL draw_vertical_line
			MOV r7, 0x04 ;right of 'M'
			MOV r9, 0x09
			MOV r8, 0x1B
			CALL draw_vertical_line
			MOV r7, 0x05 ;middle-left of 'M'
			MOV r9, 0x08
			MOV r8, 0x17
			CALL draw_vertical_line
			MOV r7, 0x05 ;middle-right of 'M'
			MOV r9, 0x08
			MOV r8, 0x19
			CALL draw_vertical_line
			MOV r8, 0x16 ;upper-left dot
			MOV r7, 0x04
			CALL draw_dot
			MOV r8, 0x1A ;upper-right dot
			MOV r7, 0x04
			CALL draw_dot		
			MOV r8, 0x18 ;bottom-middle dot
			MOV r7, 0x09
			CALL draw_dot			
			
			MOV r8, 0x1D ;left of 'E'
			MOV r9, 0x09
			MOV r7, 0x04
			CALL draw_vertical_line
			MOV r8, 0x1D ; top of 'E'
			MOV r9, 0x20
			MOV r7, 0x04
			CALL draw_horizontal_line
			MOV r8, 0x1D ; bottom of 'E'
			MOV r9, 0x20
			MOV r7, 0x09
			CALL draw_horizontal_line	
			MOV r8, 0x1D ; center of 'E'
			MOV r9, 0x1F
			MOV r7, 0x06
			CALL draw_horizontal_line	

			MOV r8, 0x09
			MOV r9, 0x0D
			MOV r7, 0x14 ;top of 'O'
			CALL draw_horizontal_line
			MOV r8, 0x09
			MOV r9, 0x0D
			MOV r7, 0x19 ;bottom of 'O'
			CALL draw_horizontal_line
			MOV r7, 0x14 ;left of 'O'
			MOV r9, 0x19
			MOV r8, 0x09
			CALL draw_vertical_line
			MOV r7, 0x14 ;right of 'O'
			MOV r9, 0x19
			MOV r8, 0x0D
			CALL draw_vertical_line

			MOV r7, 0x14 ; top-left of 'V'
			MOV r9, 0x16
			MOV r8, 0x0F
			CALL draw_vertical_line
			MOV r7, 0x17 ; center-left of 'V'
			MOV r9, 0x18
			MOV r8, 0x10
			CALL draw_vertical_line
			MOV r7, 0x14 ; top-right of 'V'
			MOV r9, 0x16
			MOV r8, 0x13
			CALL draw_vertical_line
			MOV r7, 0x17 ; center-right of 'V'
			MOV r9, 0x18
			MOV r8, 0x12
			CALL draw_vertical_line
			MOV r8, 0x11
			MOV r7, 0x19
			CALL draw_dot

			MOV r8, 0x15 ;left of 'E'
			MOV r9, 0x19
			MOV r7, 0x14
			CALL draw_vertical_line
			MOV r8, 0x15 ; top of 'E'
			MOV r9, 0x18
			MOV r7, 0x14
			CALL draw_horizontal_line
			MOV r8, 0x15 ; bottom of 'E'
			MOV r9, 0x18
			MOV r7, 0x19
			CALL draw_horizontal_line	
			MOV r8, 0x15 ; center of 'E'
			MOV r9, 0x17
			MOV r7, 0x16
			CALL draw_horizontal_line	
			
			MOV r7, 0x14 ;left of 'R'
			MOV r9, 0x19
			MOV r8, 0x1A
			CALL draw_vertical_line
			MOV r8, 0x1A ;top of 'R'
			MOV r9, 0x1D
			MOV r7, 0x14
			CALL draw_horizontal_line
			MOV r8, 0x1A ;middle of 'R'
			MOV r9, 0x1D
			MOV r7, 0x16
			CALL draw_horizontal_line
			MOV r8, 0x1D
			MOV r7, 0x15
			CALL draw_dot
			MOV r8, 0x1B
			MOV r7, 0x17
			CALL draw_dot
			MOV r8, 0x1C
			MOV r7, 0x18
			CALL draw_dot
			MOV r8, 0x1D
			MOV r7, 0x19
			CALL draw_dot
			BRN game_over

.ORG 0x3FF
	BRN ISR

