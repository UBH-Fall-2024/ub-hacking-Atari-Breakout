    .data

    .global board

offsetPaddle:  .word 0x35C		; starting position for the paddle
offsetBall:  	.word 0x31D		; starting position for the ball


board:  .string "+------------------------------------------------------------+", 0xA, 0xD
        .string "||___||___||___||___||___||___||___||___||___||___||___||___||", 0xA, 0xD  ; 59x14 0-indexed
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                            *                               |", 0xA, 0xD
        .string "|                           ___                              |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "+------------------------------------------------------------+", 0xA, 0xD, 0x0

map:

player: 		.string 27, "[14;", 0x32, 0x39, "H", 27, "[40m___", 27, "[3D", 0x00
ball:			.string 27, "[13;30H", 27, "[40m*", 0x00
clearball:		.string 27, "[13;30H", 27, "[40m ", 0x00
playerPos1:		.byte 0x33
playerPos2: 	.byte 0x33
hideCursor: 	.string 27, "[?25l", 0x00
showCursor: 	.string 27, "[?25H", 0x00
restoreCursor:  .string 27, "[u", 0x0
saveCursor:     .string 27, "[s", 0x0

cursorForward: 	.string 27, "[3C", 0x00
cursorBackward: .string 27, "[3D", 0x00

clearPlayer: 	.string 27, "[K", 0x00

restoreBorder: 	.string 27, "[14;62H", "|", 0x00

endgame:		.byte 0x00

pause:			.byte 0x00

paddlePos: 	.byte 29 ;--> x position only since y doesnt change

ball_x: 	.byte 30
ball_y:		.byte 1
direction:	.byte 5		; initial direction is downward

numX:		.byte 0x00

prev_move:	.byte 0x02 ; 1 means left, 2 is middle and 3 is right

timer: 		.word 0x000

pausePrompt:	.string 27, "[18;25H", 27, "[40mGAME PAUSED", 27, "[19;18H", 27, "[40mPRESS SW1 TO UNPAUSE GAME", 27, "[20;18H", 27, "[40mPRESS 'X' to QUIT GAME", 0x00
erasePause:		.string 27, "[18;25H", 27, "[K", 0x00

pregamePrompt:	.string 27, "[7;10H", 27, "[40mWELCOME TO MANZI's BREAKOUT", 27, "[10;8H", 27, "[40mPRESS 1 TO START OR 'X' TO QUIT", 0x00
pregameFlag:	.byte 0x00

nextDown:	.byte 0x04
nextUp:		.byte 0x01

livesPrompt:	.string 27, "[18;1H", 27, "[40mLives: ", 0x33, 0x00

endGamePrompt:	.string 27, "[7;25H", 27, "[40mGAME OVER", 0x00

topRow:        	.string 27, "[2;2H", 27, "[41m      ", 27, "[2;8H", 27, "[41m      ", 27, "[2;14H", 27, "[41m      ", 27, "[2;20H", 27, "[41m      ", 27, "[2;26H", 27, "[41m      ", 27, "[2;32H", 27, "[41m      ", 27, "[2;38H", 27, "[41m      ", 27, "[2;44H", 27, "[41m      ", 27, "[2;50H", 27, "[41m      ", 27, "[2;56H", 27, "[41m      ", 0x00


    .text

    .global uart_interrupt_init
    .global gpio_interrupt_init
    .global UART0_Handler
    .global Switch_Handler
    .global Timer_Handler
    .global simple_read_character
    .global output_character
    .global read_string
    .global output_string
    .global uart_init
    .global simple_read_character
    .global div_and_mod
    .global int2string
    .global breakout
    .global read_from_push_btns
    .global gpio_btn_and_LED_init

ptr_to_board:           .word board
ptr_to_player:			.word player
ptr_to_hideCursor:		.word hideCursor
ptr_to_showCursor:		.word showCursor
ptr_to_playerPos1:		.word playerPos1
ptr_to_playerPos2:		.word playerPos2
ptr_to_foward:			.word cursorForward
ptr_to_backward:		.word cursorBackward
ptr_to_clearPlayer:		.word clearPlayer
ptr_to_restoreBorder:	.word restoreBorder
ptr_to_saveCursor:		.word saveCursor
ptr_to_restoreCursor:	.word restoreCursor
ptr_to_endgame:			.word endgame
ptr_to_topRow:			.word topRow
ptr_to_ball_x:			.word ball_x
ptr_to_ball_y:			.word ball_y
ptr_to_paddlePos:		.word paddlePos
ptr_to_ball:			.word ball
ptr_to_clearball:		.word clearball
ptr_to_offsetPaddle:	.word offsetPaddle
ptr_to_offsetBall:		.word offsetBall
ptr_to_direction:		.word direction
ptr_to_timer:			.word timer
ptr_to_pause:			.word pause
ptr_to_pausePrompt:		.word pausePrompt
ptr_to_erasePause:		.word erasePause
ptr_to_pregamePrompt:	.word pregamePrompt
ptr_to_pregameFlag:		.word pregameFlag
ptr_to_nextUp:			.word nextUp
ptr_to_nextDown:		.word nextDown
ptr_to_livesPrompt:		.word livesPrompt
ptr_to_endGamePrompt:	.word endGamePrompt
ptr_to_prevMove:		.word prev_move
ptr_to_numX:			.word numX


breakout:
    PUSH {r4-r12,lr}            ; Preserve registers to adhere to the AAPCS

    bl uart_init
    bl uart_interrupt_init
    bl gpio_interrupt_init
    bl gpio_btn_and_LED_init

    MOV r4, #0xE000             ; load base address
    MOVT r4, #0x400F

    LDRB r5, [r4, #0x604]       ; load byte from RCGCTIMER offset
    ORR r5, r5, #0x01           ; write a '1' to bit 0
    STRB r5, [r4, #0x604]

    MOV r4, #0x0000             ; load timer 0 base address
    MOVT r4, #0x4003

    LDRB r5, [r4, #0x00C]       ; load byte from GPTMCTL offset
    BIC r5, r5, #0x01           ; write a '0' to the first bit (TAEN)
    STRB r5, [r4, #0x00C]

    LDRB r5, [r4, #0x000]       ; load byte from GPTMCFG offset
    BIC r5, r5, #0x07           ; write a '0' to the first two bits
    STRB r5, [r4, #0x000]

    LDRB r5, [r4, #0x004]       ; load byte from GPTMTAMR offset
    ORR r5, r5, #0x02           ; write a '2' to TAMR
    STRB r5, [r4, #0x004]

    LDRB r5, [r4, #0x018]       ; load byte from GPTMIMR offset
    ORR r5, r5, #0x01           ; write a '1' to TATOIM
    STRB r5, [r4, #0x018]

	MOV r8, #0xB2C0
	MOVT r8, #0x0040
	;MOV r8, #0x129B
	;MOVT r8, #0x0008
    ldr r5, [r4, #0x028]        ; load byte from GPTMTAILR offset
    MOV r5, r8                  ; store 1,333,600 for the interval  <-- timer interrupt frequency is here
    str r5, [r4, #0x028]

    MOV r4, #0xE000             ; load EN0 base address
    MOVT r4, #0xE000

    MOV r6, #0x0000
    MOVT r6, #0x0008
    ldr r5, [r4, #0x100]        ; load register at EN0 offset
    ORR r5, r5, r6              ; set 19th bit
    str r5, [r4, #0x100]

    MOV r4, #0x0000             ; load timer 0 base address
    MOVT r4, #0x4003

    LDRB r5, [r4, #0x00C]       ; load byte from GPTMCTL offset
    ORR r5, r5, #0x01           ; write a '1' to the first bit (TAEN) to enable timer A
    STRB r5, [r4, #0x00C]

    ldr r0, ptr_to_hideCursor   ; hides cursor on the screen
    BL output_string

    MOV r0, #0xC
    BL output_character         ; clear previous board

   	ldr r0, ptr_to_pregamePrompt   ; shows pregame menu
    BL output_string

pregameLobby:
	ldr r0, ptr_to_endgame			; check if user ended the game
	LDRB r4, [r0]
	CMP r4, #0
	BNE end

	ldr r0, ptr_to_pregameFlag		; loads and checks pregame flag
	LDRB r1, [r0]
	CMP r1, #0x00					; will not start until user presses 1
	BEQ pregameLobby

startGame:

    MOV r0, #0xC
    BL output_character         ; clear previous board

    ldr r0, ptr_to_board        ; prints the board
    BL output_string

    ldr r0, ptr_to_livesPrompt	; displays players lives
    BL output_string

    ;ldr r0, ptr_to_topRow
    ;BL output_string


gameLoop:

	ldr r0, ptr_to_endgame
	LDRB r4, [r0]
	CMP r4, #0
	BNE end

	B gameLoop

end:

    ldr r0, ptr_to_endGamePrompt
    BL output_string



    POP {r4-r12,lr}         	; Restore registers from stack
    MOV pc, lr




UART0_Handler:
    PUSH {r4-r12,lr}

    ; Clear Interrupt
    MOV r4, #0xC000
    MOVT r4, #0x4000
    LDRB r5, [r4, #0x044]
    ORR r5, r5, #0x10
    STRB r5, [r4, #0x044]

    BL simple_read_character    	; Read char
    MOV r10, r0

    ldr r0, ptr_to_pregameFlag		; loads and checks pregame flag
	LDRB r1, [r0]
	CMP r1, #0x00					; do nothing unless game has started
	BEQ handlePregame

    ldr r0, ptr_to_pause			; loads and checks pause flag
	LDRB r1, [r0]
	CMP r1, #0x00					; do nothing if game is paused
	BNE handlePause

check_d:
    CMP r10, #100               	; is read_character == 'd'
    BNE check_a

	BL updatePaddleRight			; update paddle moving right

    B leaveUartHandler


check_a:
    CMP r10, #97                	; is read_character == 'a'
    BNE leaveUartHandler

    BL updatePaddleLeft				; update paddle moving left

	B leaveUartHandler

handlePause:						; handle the paused state
	CMP r10, #120                	; is read_character == 'x'
    BNE leaveUartHandler

	MOV r5, #0x01					; set end game flag to True
	ldr r0, ptr_to_endgame
	STRB r5, [r0]

	B leaveUartHandler

handlePregame:
	CMP r10, #49                	; is read_character == '1'
	BNE check_x						; if not check if the user pressed X to quit

	ldr r0, ptr_to_pregameFlag		; load effective address to pregame flag
	MOV r1, #0x01					; set the flag to 1
	STRB r1, [r0]					; store it

	B leaveUartHandler				; exit

check_x:
	CMP r10, #120                	; is read_character == 'x'
    BNE leaveUartHandler

	MOV r5, #0x01					; set end game flag to True
	ldr r0, ptr_to_endgame
	STRB r5, [r0]

	B leaveUartHandler

leaveUartHandler:

    POP {r4-r12,lr}                 ; Restore registers from stack
    BX lr                           ; Return

Switch_Handler:

    PUSH {r4-r12,lr}

    MOV r4, #0x5000                 ; port f base address
    MOVT r4, #0x4002

    LDRB r5, [r4, #0x41C]           ; load GPIOICR Offset
    ORR r5, r5, #0x10               ; set pin 4 to 1 to clear the interrupt
    STRB r5, [r4, #0x41C]           ; load byte back into memory

	ldr r9, ptr_to_pause            ; load ptr to pause
    LDRB r10, [r9]

    CMP r10, #1                     ; is the game currently paused?
    BEQ unpauseGame

pauseGame:

    ldr r0, ptr_to_saveCursor       ; save current cursor position
    BL output_string

    ldr r0, ptr_to_pausePrompt      ; display paused prompt info
    BL output_string

    ldr r0, ptr_to_restoreCursor    ; restore cursor
    BL output_string


    B leaveSwitchHandler

unpauseGame:

    ldr r0, ptr_to_saveCursor       ; save current cursor position
    BL output_string

    ldr r0, ptr_to_erasePause       ; erase the pause menu
    BL output_string

    ldr r0, ptr_to_restoreCursor    ; restores cursor
    BL output_string

leaveSwitchHandler:
    EOR r10, #1                     ; if currently paused this will unpause, if not it will pause.
    STRB r10, [r9]

    POP {r4-r12,lr}                 ; Restore registers from stack
    BX lr


Timer_Handler:

    PUSH {r4-r12,lr}

    MOV r4, #0x0000             ; load Timer 0 base address
    MOVT r4, #0x4003

    LDRB r5, [r4, #0x024]       ; load GPTMICR offset
    ORR r5, r5, #0x01           ; Write a '1' to TATOCINT to clear interrupt
    STRB r5, [r4, #0x024]

	ldr r0, ptr_to_timer		; increment timer value by 1
	ldr r1, [r0]
	ADD r1, r1, #1
	str r1, [r0]

    ldr r0, ptr_to_pause		; check pause flag
    LDRB r1, [r0]
    CMP r1, #0x01
    BEQ leaveTimerHandler		; leave handler if we are paused

    ldr r0, ptr_to_pregameFlag	; check pregame flag
    LDRB r1, [r0]
    CMP r1, #0x00
    BEQ leaveTimerHandler		; exit handler if we are in pregame

	BL updateBall				; update ball position

    MOV r0, #0xC
    BL output_character         ; clear previous board

    ldr r0, ptr_to_board        ; prints updated board
    BL output_string

    ;ldr r0, ptr_to_topRow
    ;BL output_string

    ldr r0, ptr_to_direction
	LDRB r1, [r0]				; grab the current direction

   	ldr r2, ptr_to_ball_x
	LDRB r3, [r2]				; grab the balls x position

	CMP r1, #1					; is the ball moving left?
	IT EQ
	SUBEQ r3, r3, #1
	CMP r1, #3					; is the ball moving right?
	IT EQ
	ADDEQ r3, r3, #1
	CMP r1, #4					; is the ball moving left?
	IT EQ
	SUBEQ r3, r3, #1
	CMP r1, #6					; is the ball moving right?
	IT EQ
	ADDEQ r3, r3, #1
	STRB r3, [r2]

	ldr r2, ptr_to_ball_y
	LDRB r3, [r2]				; grab the balls y position

	CMP r1, #3					; is the ball going up or down?
	ITE LE
	ADDLE r3, r3, #1			; if the ball is going up (direction is 1-3), increment the ball height by 1
	SUBGT r3, r3, #1			; if the ball is going down (direction is 4-6), decrement the ball height by 1
	STRB r3, [r2]

	ldr r0, ptr_to_livesPrompt
	LDRB r1, [r0, #19]		; grab lives from lives prompt

    CMP r3, #0				; checks if we reached below the paddle
    IT LT
    SUBLT r1, r1, #1		; update lives as neccessary
    STRB r1, [r0, #19]		; store updated value back in prompt

	MOV r7, #0x00

    CMP r1, #0x30			; if we've reached 0 lives
    IT EQ
	MOVEQ r7, #0x01

	ldr r6, ptr_to_endgame
    STRB r7, [r6]			; end the game

    ldr r0, ptr_to_livesPrompt  ; prints updated lives string
    BL output_string

leaveTimerHandler:
    POP {r4-r12,lr}             ; Restore registers from stack
    BX lr                       ; Return

updatePaddleLeft:
  	PUSH {r4-r12,lr}

  	ldr r0, ptr_to_paddlePos
  	LDRB r1, [r0]

  	SUB r1, r1, #3
  	CMP r1, #1
	BLT leavePaddleLeft

	ldr r7, ptr_to_offsetPaddle		; address where the paddle position is stored
	LDRH r6, [r7]

    ldr r0, ptr_to_board		; find the specific part in memory where the paddle is
    MOV r1, #0x20
    ADD r0, r0, r6
	STRB r1, [r0], #1
    STRB r1, [r0], #1
    STRB r1, [r0]

	SUB r0, r0, #5
	MOV r1, #0x5F
	STRB r1, [r0], #1
    STRB r1, [r0], #1
    STRB r1, [r0]

	ldr r7, ptr_to_offsetPaddle		; address where the paddle position is stored
	LDRH r6, [r7]

	SUB r6, r6, #3
	STRH r6, [r7]

	ldr r0, ptr_to_paddlePos
  	LDRB r1, [r0]
  	SUB r1, r1, #3
  	STRB r1, [r0]

  	ldr r0, ptr_to_prevMove
  	MOV r1, #1
  	STRB r1, [r0]

leavePaddleLeft:

    POP {r4-r12,lr}
    MOV pc, lr


updatePaddleRight:
  	PUSH {r4-r12,lr}

  	ldr r0, ptr_to_paddlePos
  	LDRB r1, [r0]

  	ADD r1, r1, #3
  	CMP r1, #60
	BGT leavePaddleRight

	ldr r7, ptr_to_offsetPaddle		; address where the paddle position is stored
	LDRH r6, [r7]

    ldr r0, ptr_to_board		; find the specific part in memory where the paddle is
    MOV r1, #0x20
    ADD r0, r0, r6
	STRB r1, [r0], #1
    STRB r1, [r0], #1
    STRB r1, [r0]

	ADD r0, r0, #1
	MOV r1, #0x5F
	STRB r1, [r0], #1
    STRB r1, [r0], #1
    STRB r1, [r0]

	ldr r7, ptr_to_offsetPaddle		; address where the paddle position is stored
	LDRH r6, [r7]

	ADD r6, r6, #3
	STRH r6, [r7]

	ldr r0, ptr_to_paddlePos
  	LDRB r1, [r0]
  	ADD r1, r1, #3
  	STRB r1, [r0]

  	ldr r0, ptr_to_prevMove
  	MOV r1, #3
  	STRB r1, [r0]


leavePaddleRight:

    POP {r4-r12,lr}
    MOV pc, lr

updateBall:
	PUSH {r4-r12, lr}

	ldr r0, ptr_to_board			; load the ptr to the board
	ldr r1, ptr_to_direction		; load the ptr to the direction the ball is going
	ldr r2, ptr_to_offsetBall
	LDRH r3, [r2]					; grab offset from effective address

	ADD r5, r0, r3					; current ball position

	LDRB r4, [r1]					; grab byte direction
	CMP r4, #1
	BEQ handle1
	CMP r4, #2
	BEQ handle2
	CMP r4, #3
	BEQ handle3
	CMP r4, #4
	BEQ handle4
	CMP r4, #5
	BEQ handle5
	CMP r4, #6
	BEQ handle6

handle1:
	LDRB r0, [r5, #-0x41]	; grabs location to the top left of the ball

	CMP r0, #0x7C			; is this space the wall?
	BEQ handleWallHit		; handle wall hit

	CMP r0, #0x20			; is this space the paddle?
	BNE handlePaddleHit		; handle paddle hit


	ldr r0, ptr_to_board		; load effective address of the board
	ldr r2, ptr_to_offsetBall	; load effective address of where the offset of the ball is stored within the game board
	LDRH r3, [r2]				; store offset value in r3

	ADD r5, r0, r3			; r5 now has the memory address where the ball is

	MOV r1, #0x20			; empty space char
	STRB r1, [r5]			; replace ball with empty space


	MOV r1, #0x2A				; asteric char
	STRB r1, [r5, #-0x41]			; replace new ball location with asteric

	ldr r2, ptr_to_offsetBall	; now we want to update the stored offset of where the ball can be found
	LDRH r3, [r2]				; update new offset value
	SUB r3, r3, #0x41
	STRH r3, [r2]				; store new value

	B leaveUpdateBall
handle2:
	LDRB r0, [r5, #-0x40]	; grabs location right above the ball

	CMP r0, #0x20			; is this space empty?
	BNE handlePaddleHit		; if not handle elsewhere

	ldr r0, ptr_to_board
	ldr r2, ptr_to_offsetBall
	LDRH r3, [r2]

	ADD r5, r0, r3		; r5 now has the memory address where the ball is

	MOV r1, #0x20		; empty space char
	STRB r1, [r5]		; replace ball with empty space


	MOV r1, #0x2A		; asteric char
	STRB r1, [r5, #-0x40]	; replace new ball location with asteric

	ldr r2, ptr_to_offsetBall	; now we want to update the stored offset of where the ball can be found
	LDRH r3, [r2]
	SUB r3, r3, #0x40
	STRH r3, [r2]

	B leaveUpdateBall
handle3:
	LDRB r0, [r5, #-0x3F]	; grabs location to the top right

	CMP r0, #0x7C			; is this space the wall?
	BEQ handleWallHit		; handle wall hit

	CMP r0, #0x20			; is this space empty?
	BNE handlePaddleHit		; if not handle elsewhere

	ldr r0, ptr_to_board
	ldr r2, ptr_to_offsetBall
	LDRH r3, [r2]

	ADD r5, r0, r3				; r5 now has the memory address where the ball is

	MOV r1, #0x20				; empty space char
	STRB r1, [r5]				; replace ball with empty space


	MOV r1, #0x2A				; asteric char
	STRB r1, [r5, #-0x3F]		; replace new ball location with asteric

	ldr r2, ptr_to_offsetBall	; now we want to update the stored offset of where the ball can be found
	LDRH r3, [r2]
	SUB r3, r3, #0x3F
	STRH r3, [r2]

	B leaveUpdateBall
handle4:
	LDRB r0, [r5, #0x3F]	; bottom left of the ball

	CMP r0, #0x7C			; is this space the wall?
	BEQ handleWallHit		; handle wall hit

	CMP r0, #0x20			; is this space empty?
	BNE handlePaddleHit		; if not handle elsewhere

	ldr r0, ptr_to_board
	ldr r2, ptr_to_offsetBall
	LDRH r3, [r2]

	ADD r5, r0, r3		; r5 now has the memory address where the ball is

	MOV r1, #0x20		; empty space char
	STRB r1, [r5]		; replace ball with empty space


	MOV r1, #0x2A		; asteric char
	STRB r1, [r5, #0x3F]	; replace new ball location with asteric

	ldr r2, ptr_to_offsetBall	; now we want to update the stored offset of where the ball can be found
	LDRH r3, [r2]
	ADD r3, r3, #0x3F
	STRH r3, [r2]

	B leaveUpdateBall
handle5:
	LDRB r0, [r5, #0x40]	;grabs the byte directly below ball

	CMP r0, #0x20			; is this space empty?
	BNE handlePaddleHit		; if not handle elsewhere

	ldr r0, ptr_to_board
	ldr r2, ptr_to_offsetBall
	LDRH r3, [r2]

	ADD r5, r0, r3

	MOV r1, #0x20		; empty space char
	STRB r1, [r5]		; replace ball with empty space


	MOV r1, #0x2A		; asteric char
	STRB r1, [r5, #0x40]

	ldr r2, ptr_to_offsetBall
	LDRH r3, [r2]
	ADD r3, r3, #0x40
	STRH r3, [r2]

	B leaveUpdateBall
handle6:
	LDRB r0, [r5, #0x41]	; bottom right of the ball

	CMP r0, #0x7C			; is this space the wall?
	BEQ handleWallHit		; handle wall hit

	CMP r0, #0x20			; is this space empty?
	BNE handlePaddleHit		; if not handle elsewhere

	ldr r0, ptr_to_board
	ldr r2, ptr_to_offsetBall
	LDRH r3, [r2]

	ADD r5, r0, r3		; r5 now has the memory address where the ball is

	MOV r1, #0x20		; empty space char
	STRB r1, [r5]		; replace ball with empty space


	MOV r1, #0x2A		; asteric char
	STRB r1, [r5, #0x41]	; replace new ball location with asteric

	ldr r2, ptr_to_offsetBall	; now we want to update the stored offset of where the ball can be found
	LDRH r3, [r2]
	ADD r3, r3, #0x41
	STRH r3, [r2]

	B leaveUpdateBall

handleWallHit:
	ldr r0, ptr_to_board			; load the ptr to the board
	ldr r1, ptr_to_direction		; load the ptr to the direction the ball is going
	ldr r2, ptr_to_offsetBall
	LDRH r3, [r2]					; grab offset from effective address

	ADD r5, r0, r3					; current ball position

	LDRB r6, [r1]					; store direction in which it came from

	CMP r6, #1
	IT EQ
	MOVEQ r2, #3	; since it came from 1, we need to send it 3

	CMP r6, #3
	IT EQ
	MOVEQ r2, #1	; since it came from 3, we need to send it 1

	CMP r6, #4
	IT EQ
	MOVEQ r2, #6	; since it came from 4, we need to send it 6

	CMP r6, #6
	IT EQ
	MOVEQ r2, #4	; since it came from 6, we need to send it 4

	STRB r2, [r1]

	B leaveUpdateBall

handlePaddleHit:
	ldr r0, ptr_to_board			; load the ptr to the board
	ldr r1, ptr_to_direction		; load the ptr to the direction the ball is going
	ldr r2, ptr_to_offsetBall
	LDRH r3, [r2]					; grab offset from effective address

	ADD r5, r0, r3					; current ball position

	LDRB r6, [r1]					; store direction in which it came from

	CMP r6, #4
	BEQ handleCameFromUp
	CMP r6, #5
	BEQ handleCameFromUp
	CMP r6, #6
	BEQ handleCameFromUp

	CMP r6, #1
	BEQ handleCameFromDown
	CMP r6, #2
	BEQ handleCameFromDown
	CMP r6, #3
	BEQ handleCameFromDown

handleCameFromUp:
	;ldr r0, ptr_to_nextUp			; grab next up direction
	;LDRB r1, [r0]

	ldr r0, ptr_to_prevMove
	LDRB r1, [r0]

	CMP r1, #1
	IT EQ
	MOVEQ r1, #3
	CMP r1, #2
	IT EQ
	MOVEQ r1, #2
	CMP r1, #3
	IT EQ
	MOVEQ r1, #1

	ldr r2, ptr_to_direction		; load the ptr to the direction the ball is going
	STRB r1, [r2]

	;CMP r1, #3						; check if we've reached max up direction
	;ITE EQ
	;MOVEQ r1, #1					; if we have, reset back to 1
	;ADDNE r1, r1, #1				; if we haven't, increment by 1
	;STRB r1, [r0]					; store new value

	B leaveUpdateBall

handleCameFromDown:  				; THIS IS WHEN IT HITS THE BRICK
	ldr r0, ptr_to_ball_y
	LDRB r1, [r0]
	CMP r1, #0
	BLT handleUnderPaddleHit

	ldr r0, ptr_to_ball_x
	LDRB r1, [r0]

	BL updateBricks

handleUnderPaddleHit:
	ldr r0, ptr_to_nextDown			; grab next down direction
	LDRB r1, [r0]

	ldr r2, ptr_to_direction		; load the ptr to the direction the ball is going
	STRB r1, [r2]

	CMP r1, #6						; check if we've reached max up direction
	ITE EQ
	MOVEQ r1, #4					; if we have, reset back to 4
	ADDNE r1, r1, #1				; if we haven't, increment by 1
	STRB r1, [r0]					; store new value



leaveUpdateBall:

    POP {r4-r12,lr}
    MOV pc, lr


updateBricks:
	PUSH {r4-r12, lr}

	; r1 is passed in with the x position
	ldr r0, ptr_to_board
	ldr r6, ptr_to_numX
	LDRB r7, [r6]

	CMP r1, #5
	BLE handleBrick1
	CMP r1, #10
	BLE handleBrick2
	CMP r1, #15
	BLE handleBrick3
	CMP r1, #20
	BLE handleBrick4
	CMP r1, #25
	BLE handleBrick5
	CMP r1, #30
	BLE handleBrick6
	CMP r1, #35
	BLE handleBrick7
	CMP r1, #40
	BLE handleBrick8
	CMP r1, #45
	BLE handleBrick9
	CMP r1, #40
	BLE handleBrick10
	CMP r1, #55
	BLE handleBrick11
	CMP r1, #60
	BLE handleBrick12

handleBrick1:
	MOV r1, #0x58
	STRB r1, [r0, #0x43]
	B leaveBricks
handleBrick2:
	MOV r1, #0x58
	STRB r1, [r0, #0x48]
	B leaveBricks

handleBrick3:
	MOV r1, #0x58
	STRB r1, [r0, #0x4D]
	B leaveBricks

handleBrick4:
	MOV r1, #0x58
	STRB r1, [r0, #0x52]
	B leaveBricks

handleBrick5:
	MOV r1, #0x58
	STRB r1, [r0, #0x57]
	B leaveBricks

handleBrick6:
	MOV r1, #0x58
	STRB r1, [r0, #0x5C]
	B leaveBricks

handleBrick7:
	MOV r1, #0x58
	STRB r1, [r0, #0x61]
	B leaveBricks

handleBrick8:
	MOV r1, #0x58
	STRB r1, [r0, #0x66]
	B leaveBricks

handleBrick9:
	MOV r1, #0x58
	STRB r1, [r0, #0x6B]
	B leaveBricks

handleBrick10:
	MOV r1, #0x58
	STRB r1, [r0, #0x70]
	B leaveBricks

handleBrick11:
	MOV r1, #0x58
	STRB r1, [r0, #0x75]
	B leaveBricks

handleBrick12:
	MOV r1, #0x58
	STRB r1, [r0, #0x7A]

leaveBricks:
	ADD r7, r7, #1
	STRB r7, [r6]

	ldr r5, ptr_to_endgame
	LDRB r4, [r5]

	CMP r7, #12
	IT EQ
	MOVEQ r4, #0x01
	STRB r4, [r5]


	POP {r4-r12,lr}
    MOV pc, lr



    .end
