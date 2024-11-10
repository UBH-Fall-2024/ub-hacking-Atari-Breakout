    .data

    .global board

offset:  .word 0x35C

board:  .string "+------------------------------------------------------------+", 0xA, 0xD
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
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                           ___                              |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "|                                                            |", 0xA, 0xD
        .string "+------------------------------------------------------------+", 0xA, 0xD, 0x0

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


paddlePos: 	.byte 29 ;--> x position only since y doesnt change

ball_x: 	.byte 30
ball_y:		.byte 13
direction:	.byte 5		; initial direction is downward

topRow:        .string 27, "[2;2H", 27, "[41m|____|", 27, "[2;8H", 27, "[41m|____|", 27, "[2;14H", 27, "[41m|____|", 27, "[2;20H", 27, "[41m|____|", 27, "[2;26H", 27, "[41m|____|", 27, "[2;32H", 27, "[41m|____|", 27, "[2;38H", 27, "[41m|____|", 27, "[2;44H", 27, "[41m|____|", 27, "[2;50H", 27, "[41m|____|", 27, "[2;56H", 27, "[41m|____|", 0x00

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
ptr_to_offset:			.word offset

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

	MOV r8, #0x1200
	MOVT r8, #0x007A
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

    ldr r0, ptr_to_board        ; prints the board
    BL output_string

    ldr r0, ptr_to_topRow
    BL output_string

	ldr r0, ptr_to_ball
    BL output_string

    ldr r0, ptr_to_player       ; moves cursor to position and displays player
    BL output_string



gameLoop:

	ldr r0, ptr_to_endgame
	LDRB r4, [r0]
	CMP r4, #0
	BNE end

	B gameLoop

end:

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

check_x:
    CMP r10, #120                	; is read_character == 'x'
    BNE check_d

	MOV r5, #0x01
	ldr r0, ptr_to_endgame
	STRB r5, [r0]

    B leaveUartHandler

check_d:
    CMP r10, #100               	; is read_character == 'd'
    BNE check_a

	BL updatePaddleRight

    B leaveUartHandler


check_a:
    CMP r10, #97                	; is read_character == 'a'
    BNE leaveUartHandler

    BL updatePaddleLeft




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

    POP {r4-r12,lr}                 ; Restore registers from stack
    BX lr


Timer_Handler:

    PUSH {r4-r12,lr}

    MOV r4, #0x0000             ; load Timer 0 base address
    MOVT r4, #0x4003

    LDRB r5, [r4, #0x024]       ; load GPTMICR offset
    ORR r5, r5, #0x01           ; Write a '1' to TATOCINT to clear interrupt
    STRB r5, [r4, #0x024]


    MOV r0, #0xC
    BL output_character         ; clear previous board

    ldr r0, ptr_to_board        ; prints the board
    BL output_string

    POP {r4-r12,lr}             ; Restore registers from stack
    BX lr                       ; Return

updatePaddleLeft:
  	PUSH {r4-r12,lr}

  	ldr r0, ptr_to_paddlePos
  	LDRB r1, [r0]

  	SUB r1, r1, #3
  	CMP r1, #1
	BLT leavePaddleLeft

	ldr r7, ptr_to_offset		; address where the paddle position is stored
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

	ldr r7, ptr_to_offset		; address where the paddle position is stored
	LDRH r6, [r7]

	SUB r6, r6, #3
	STRH r6, [r7]

	ldr r0, ptr_to_paddlePos
  	LDRB r1, [r0]
  	SUB r1, r1, #3
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

	ldr r7, ptr_to_offset		; address where the paddle position is stored
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

	ldr r7, ptr_to_offset		; address where the paddle position is stored
	LDRH r6, [r7]

	ADD r6, r6, #3
	STRH r6, [r7]

	ldr r0, ptr_to_paddlePos
  	LDRB r1, [r0]
  	ADD r1, r1, #3
  	STRB r1, [r0]

leavePaddleRight:

    POP {r4-r12,lr}
    MOV pc, lr


    .end
