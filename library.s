	.text
	.global uart_init
	.global gpio_btn_and_LED_init
	.global output_character
	.global read_character
	.global read_string
	.global output_string
	.global read_from_push_btns
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global read_tiva_push_button
	.global div_and_mod
	.global int2string
	.global string2int
	.global simple_read_character
	.global uart_interrupt_init
	.global gpio_interrupt_init


uart_interrupt_init:
    PUSH {r4-r12,lr}

    MOV r0, #0xC000
    MOVT r0, #0x4000
                                ; Enable Interrupt mask for Recieve (4)
                                ; (UARTIM)
    LDRB r1, [r0, #0x038]
    ORR r1, r1, #0x10           ; 0001 0000
    STRB r1, [r0, #0x038]
                                ; enable interrupt on processor for UART (EN0)
    MOV r0, #0xE000
    MOVT r0, #0xE000
    LDRB r1, [r0, #0x100]
    ORR r1, r1, #0x20           ; 0010 0000
    STRB r1, [r0, #0x100]

    POP {r4-r12,lr}         ; Restore registers from stack
    MOV pc, lr

gpio_interrupt_init:
    PUSH {r4-r12, lr}

    ;------TIVA INIT-----------------------------------------------------------------------------------------------
    MOV r4, #0xE000         ; Base value for Enabling the clock
    MOVT r4, #0x400F

    LDRB r1, [r4, #0x608]   ; Address for GPIO ports
    ORR r1, r1, #0x20       ; Set a 1 to Port F bit to enable clock
    STRB r1, [r4, #0x608]   ; Store correct byte back into memory

;------PORT F--------------------------------------------------------------------------------------------------
    MOV r4, #0x5000         ; Load GPIO Port F base address into r4
    MOVT r4, #0x4002

    LDRB r1, [r4, #0x510]   ; load GPIOPUR effective address
    ORR r1, r1, #0x10       ; pin 4 pull up resistor
    STRB r1, [r4, #0x510]   ; Store correct byte back into memory

    LDRB r1, [r4, #0x400]   ; Load GPIODIR effective address
    BIC r1, r1, #0x10       ; set pin 4 to 0 (Input)
    STRB r1, [r4, #0x400]   ; store correct byte back into memory

    LDRB r1, [r4, #0x51C]   ; load GPIODEN effective address
    ORR r1, r1, #0x10       ; set pin 4 to 1 (Digital Enable)
    STRB r1, [r4, #0x51C]   ; store correct byte back into memory

    MOV r4, #0x5000             ; Port F base address
    MOVT r4, #0x4002

    LDRB r1, [r4, #0x404]       ; GPIOIS Offset effective address
    BIC r1, r1, #0x10           ; Set pin 4 to 0
    STRB r1, [r4, #0x404]

    LDRB r1, [r4, #0x408]       ; GPIOIBE Offset effective address
    BIC r1, r1, #0x10           ; Set pin 4 to 0
    STRB r1, [r4, #0x408]

    LDRB r1, [r4, #0x40C]       ; GPIOEV Offset effective address
    BIC r1, r1, #0x10           ; Set pin 4 to 0
    STRB r1, [r4, #0x40C]

    LDRB r1, [r4, #0x410]       ; GPIOIM Offset effective address
    ORR r1, r1, #0x10           ; Set pin 4 to 1
    STRB r1, [r4, #0x410]

    MOV r4, #0xE000             ; load EN0 base address
    MOVT r4, #0xE000

    LDR r1, [r4, #0x100]        ; EN0 effective address
    ORR r1, r1, #0x40000000     ; set bit 30 to 1
    STR r1, [r4, #0x100]

    POP {r4-r12,lr}             ; Restore registers from stack
    MOV pc, lr


uart_init:
	PUSH {r4-r12,lr}		; Spill registers to stack

	MOV r0, #0xE618
	MOVT r0, #0x400F
	MOV r1, #1				; Provide clock to UART0
	STR r1, [r0]

	MOV r0, #0xE608
	MOVT r0, #0x400F
	MOV r1, #1				; Enable clock to PortA
	STR r1, [r0]

	MOV r0, #0xC030
	MOVT r0, #0x4000
	MOV r1, #0				; Disable UART0 Control
	STR r1, [r0]

	MOV r0, #0xC024
	MOVT r0, #0x4000
	MOV r1, #8 				; Set UART0_IBRD_R for 115200 baud
	STR r1, [r0]

	MOV r0, #0xC028
	MOVT r0, #0x4000
	MOV r1, #40 			; Set UART0_FBRD_R for 115200 baud
	STR r1, [r0]

	MOV r0, #0xCFC8
	MOVT r0, #0x4000
	MOV r1, #0				; Use system clock
	STR r1, [r0]

	MOV r0, #0xC02C
	MOVT r0, #0x4000
	MOV r1, #0x60 			; Use 8 bit word length, 1 stop bit, no parity
	STR r1, [r0]

	MOV r0, #0xC030
	MOVT r0, #0x4000
	MOV r1, #0x301	 		; Enable UART0 Control
	STR r1, [r0]

	MOV r0, #0x451C
	MOVT r0, #0x4000
	LDR r1, [r0]
	ORR r1, r1, #0x03
	STR r1, [r0] 		 	; Make PA0 and PA1 as Digital Ports

	MOV r0, #0x4420
	MOVT r0, #0x4000
	LDR r1, [r0]
	ORR r1, r1, #0x03
	STR r1, [r0] 			; Change PA0 and PA1 to use an alternate function

	MOV r0, #0x452C
	MOVT r0, #0x4000
	LDR r1, [r0]
	ORR r1, r1, #0x11 		; Configure PA0 and PA1 for UART
	STR r1, [r0]


	POP {r4-r12,lr}  		; Restore registers from stack
	MOV pc, lr

gpio_btn_and_LED_init:
	PUSH {r4-r12,lr}		; Spill registers to stack

;------TIVA INIT-----------------------------------------------------------------------------------------------
    MOV r4, #0xE000			; Base value for Enabling the clock
    MOVT r4, #0x400F

	LDRB r1, [r4, #0x608]	; Address for GPIO ports
	ORR r1, r1, #0x20		; Set a 1 to Port F bit to enable clock
	STRB r1, [r4, #0x608]	; Store correct byte back into memory

;------PORT F--------------------------------------------------------------------------------------------------
	MOV r4, #0x5000 		; Load GPIO Port F base address into r4
	MOVT r4, #0x4002

	LDRB r1, [r4, #0x400]	; load GPIODIR effective address
	ORR r1, r1, #0x0E		; set pins 1,2,3 to 1 for output (bits 1, 2, 3)
	STRB r1, [r4, #0x400]	; Store correct byte back into memory

	LDRB r1, [r4, #0x51C]	; load GPIODEN effective address
	ORR r1, r1, #0x0E		; set pins 1,2,3 to 1 for digital configuration (bits 1, 2, 3)
	STRB r1, [r4, #0x51C]	; Store correct byte back into memory

	LDRB r1, [r4, #0x510]	; load GPIOPUR effective address
	ORR r1, r1, #0x10 		; pin 4 pull up resistor
	STRB r1, [r4, #0x510]	; Store correct byte back into memory

	LDRB r1, [r4, #0x400]	; Load GPIODIR effective address
	BIC r1, r1, #0x10		; set pin 4 to 0 (Input)
	STRB r1, [r4, #0x400]	; store correct byte back into memory

	LDRB r1, [r4, #0x51C]	; load GPIODEN effective address
	ORR r1, r1, #0x10 		; set pin 4 to 1 (Digital Enable)
	STRB r1, [r4, #0x51C]	; store correct byte back into memory

;------ALICE EDUBASE INIT--------------------------------------------------------------------------------------
    MOV r4, #0xE000			; load SYSCTL_RCGC_GPIO Base address
    MOVT r4, #0x400F

    LDRB r1, [r4, #0x608]	; Load SYSCTL_RCGC_GPIO effective address
    ORR r1, r1, #0x0A		; write a 1 to ports B and D to enable Clock
    STRB r1, [r4, #0x608]

;------PORT B--------------------------------------------------------------------------------------------------
    MOV r4, #0x5000			; load port B address
    MOVT r4, #0x4000

    LDRB r1, [r4, #0x400]	; load port B GPIO Data Direction Register (GPIODIR) effective address
    ORR r1, r1, #0x0F		; Set pins 0-3 to 1 to configure as Output
	STRB r1, [r4, #0x400]

	LDRB r1, [r4, #0x51C]	; load port B GPIO Digital Enable Register (GPIODEN) effective address
	ORR r1, r1, #0x0F		; write a 1 to pins 0-3 to enable digital functions
	STRB r1, [r4, #0x51C]

;------PORT D--------------------------------------------------------------------------------------------------
	MOV r4, #0x7000			; load port D address
	MOVT r4, #0x4000

	LDRB r1, [r4, #0x400]	; Load GPIODIR effective address
	BIC r1, r1, #0x0F		; Set pins 0-3 to 0 (Input) (we mask with F here because we want to ensure these bits are all 0)
	STRB r1, [r4, #0x400]

	LDRB r1, [r4, #0x51C]	; load GPIODEN effective address
	ORR r1, r1, #0x0F		; write a 1 to pins 0-3 to enable digital functions
	STRB r1, [r4, #0x51C]

	POP {r4-r12,lr}  		; Restore registers from stack
	MOV pc, lr

output_character:
	PUSH {r4-r12,lr} 		; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
							; routine calls another routine.
	MOV r8, #0xC000
	MOVT r8, #0x4000 		; UART DATA address

outputcharL1:
	MOV r1, #0
	LDRB r1, [r8, #0x18]	; load flags
	AND r1, r1, #0x20 		; isolate TXFF flag
	CMP r1, #0
	BNE outputcharL1 		; check again if TXFF is 1, transmitter is full

	STRB r0, [r8] 			; store character in UART Data

	POP {r4-r12,lr}   		; Restore registers all registers preserved in the
	mov pc, lr

read_character:
	PUSH {r4-r12,lr} 		; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
							; routine calls another routine.

	MOV r8, #0xC000			; lower 4 bits of address
	MOVT r8, #0x4000		; upper 4 bits of address

readcharL1:
	LDRB r1, [r8, #0x18]	; offset
	AND r1, r1, #0x10		; bit mask to select RxFE bit

	CMP r1, #0				; check if the reciever is empty
	BNE readcharL1			; if not empty, loop back and check again
							; if empty, fall through
	LDRB r0, [r8]			; store byte from trasnmit register

	POP {r4-r12,lr}   		; Restore registers all registers preserved in the
	mov pc, lr


read_string:
	PUSH {r4-r12,lr} 		; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
							; routine calls another routine.

	MOV r5, r0				; Move address from r0 to r5 for r5 to be incrememnted
	MOV r6, r0 				; stores base address of r0 into r6
	MOV r4, #0xD			; stores decimal value for new line ;0xD is Carriage Return
readstringL1:
	BL read_character		; calls read_character subroutine which reads char from UART and returns it in r0
	STRB r0, [r5]			; load byte from read character into memory address at r5
	ADD r5, r5, #1			; increment address by 1
	CMP r4, r0				; is r4 = r0?
	BNE readstringL1		; if not we loop back up

	SUB r5, r5, #1			; backtrack 1 byte to the enter key
	MOV r7, #0x00			; stores null character in r7
	STRB r7, [r5]			; replaced enter key with null

	MOV r0, r6 				; stores base address back into r0

	POP {r4-r12,lr}   		; Restore registers all registers preserved in the
	mov pc, lr

output_string:
	PUSH {r4-r12,lr} 		; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
							; routine calls another routine.

	MOV r4, r0 	 			; save input string address
outputstringL1:
	LDRB r0, [r4]


	BL output_character 	; print character
nextChar:
	ADD r4, r4, #1
	CMP r0, #0
	BNE outputstringL1 		; if character is null, return

	POP {r4-r12,lr}   		; Restore registers all registers preserved in the
	mov pc, lr

read_from_push_btns:
	PUSH {r4-r12,lr}		; Spill registers to stack

	MOV r4, #0x7000 		; Load GPIO Port D base address into r4
	MOVT r4, #0x4000

	LDRB r0, [r4, #0x3FC] 	; load Data Port D GPIODATA register effective address
	AND r0, r0, #0x0F		; Mask; we only want the lower 4

	POP {r4-r12,lr}  		; Restore registers from stack
	MOV pc, lr

illuminate_LEDs:
	PUSH {r4-r12,lr}		; Spill registers to stack

	MOV r4, #0x5000			; load Port B address
    MOVT r4, #0x4000

    LDRB r1, [r4, #0x3FC]	; load Port B GPIO Data Register
    BFI r1, r0, #0, #4		; Insert the 4 bits passed in, into the GPIODATA bit field
	STRB r1, [r4, #0x3FC]

	POP {r4-r12,lr}  		; Restore registers from stack
	MOV pc, lr

illuminate_RGB_LED:
	PUSH {r4-r12,lr}		; Spill registers to stack

	MOV r4, #0x5000 		; Load GPIO Port F base address into r4
	MOVT r4, #0x4002

	LDRB r5, [r4, #0x3FC]	; load GPIODATA effective address
	BFI r5, r0, #0, #4			; OR with input bits to set pins accordingly
	STRB r5, [r4, #0x3FC]	; Store correct byte back into memory

	POP {r4-r12,lr}  		; Restore registers from stack
	MOV pc, lr



read_tiva_push_button:
	PUSH {r4-r12, lr}

	MOV r4, #0x5000 		; Load GPIO Port F base address into r4
	MOVT r4, #0x4002

	LDRB r0, [r4, #0x3FC] 	; load Data Port F
	AND r0, r0, #0x10		; mask all bits except the 4th pin bit
	LSR r0, r0, #4			; get bit to bit position 0
	EOR r0, r0, #0x1

	POP {r4-r12, lr}
	mov pc, lr

div_and_mod:
	PUSH {r4-r12,lr} 		; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
							; routine calls another routine.

	MOV r2, #0
	MOV r3, #0
	MOV r5, #0

	EOR r5, r5, r0
	EOR r5, r5, r1 			; the sign of the quotient is the sign of r5

	CMP r0, #0				; absolute value of dividend
	BGE dividendPositive
	RSB r0, r0, #0
dividendPositive:
	CMP r1, #0				; absolute value of divisor
	BGE divmodloop1
	RSB r1, r1, #0


divmodloop1:
	CMP r3, #32
	BGE divmodend			; end if r3 >= 32 : all bits have been shifted in the dividend

	LSL r2, r2, #1			; shift both r2 and r0 to the left, the effect is to treat r2 and r0
	LSR r4, r0, #31			; as a single, two word register
	AND r4, r4, #1			; so that r0 is shifted "into" r2
	ORR r2, r2, r4
	LSL r0, r0, #1

	CMP r2, r1				; if dividend is less than divisor, then skip
	BLT divmodb1
	SUB r2, r2, r1  		; if dividend is greater that divisor, then subtract divisor from dividend, and set last bit of r0 to 1
	ORR r0, r0, #1
divmodb1:
	ADD r3, r3, #1			; increment cumulator
	B divmodloop1

divmodend:
	MOV r1, r2				; at this point, r0 is the quotient, r2 is the remainder, so set r1 to r2

	CMP r5, #0				; make quotient negative if one of divisor or dividend was negative
	BGE positiveQuotient
	RSB r0, r0, #0
positiveQuotient:

	POP {r4-r12,lr}   		; Restore registers all registers preserved in the
	mov pc, lr


string2int:
	PUSH {r4-r12,lr} 		; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
	MOV r6, #0				; routine calls another routine.
	MOV r5, r0
	MOV r3, #10
	MOV r0, #0
	LDRB r1, [r5]
	CMP r1, #0x2D 			; '-' char
	BNE string2intL1
	MOV r6, #1
	ADD r5, r5, #1

string2intL1:
	LDRB r1, [r5] 			;load next byte of string
	CMP r1, #0
	BEQ string2intend 		;end if loaded null
	MUL r0, r0, r3 			;shift decimals left
	SUB r1, r1, #0x30 		; ascii to integer conversion
	ADD r0, r0, r1    		; add decimal to sum
	ADD r5, r5, #1	  		;increment address
	B string2intL1

string2intend:

	CMP r6, #0       		;switch to negative if minus sign was present
	BEQ string2intpos
	RSB r0, r0, #0
string2intpos:

	POP {r4-r12,lr}   		; Restore registers all registers preserved in the
	mov pc, lr

int2string:
	PUSH {r4-r12,lr} 		; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
							; routine calls another routine.
	MOV r10, #0
	CMP r1, #0
	BGE int2stringposcheck ; set r10 to 1 if integer is negative
	MOV r10, #1
int2stringposcheck:

	MOV r4, r0 				; base address
	MOV r0, r1 				; int to translate

	MOV r6, r4 				; last byte

	MOV r1, #0
	STRB r1, [r4] 			; set first byte to null

int2stringL1:
	MOV r1, #10				; dividend: r0, divisor: 10
	BL div_and_mod

	ADD r6, r6, #1 			; r6 is the address of the null character
	MOV r7, r6
	MOV r8, r6

int2stringL2:				; this effectively shifts all characters in the string one address higher
	SUB r7, r7, #1 			; move back through address
	LDRB r9, [r7]
	STRB r9, [r8] 			; move value in memory foward
	SUB r8, r8, #1
	CMP r7, r4
	BNE int2stringL2

	ADD r1, r1, #0x30		; convert int to character
	STRB r1, [r4]			; store most significant digit at 0th character
	CMP r0, #0				; if quotient was not 0, then repeat
	BNE int2stringL1

	CMP r10, #1				; end procedure, check if negative, if so, then loop through
	ADD r10, r10, r10		; routine one more time, effectivley moving all characters one forward in memory
	BEQ int2stringL1

	CMP r10, #0
	BEQ int2stringpos
	MOV r1, #0x2D			; if it was negative, then place '-' in string's first character
	STRB r1, [r4]

int2stringpos:

	POP {r4-r12,lr}   		; Restore registers all registers preserved in the
	mov pc, lr

simple_read_character:
	PUSH {r4-r12,lr} 		; Store any registers in the range of r4 through r12

	MOV r4, #0xC000
	MOVT r4, #0x4000

	LDRB r0, [r4]

	POP {r4-r12,lr}   		; Restore registers all registers preserved in the
	MOV pc, lr

	.end
