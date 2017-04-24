;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; Programmer: Anjaney Chirag Mahajan
; Class: ECE 109
; Section: 405
;
;       				monaco.asm
;
; Submitted: 03/28/2017
;
;
; The program user will be able to direct their block through
; a race course, checking for crashes, and will be able to change 
; the color of the block which is being moved.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.ORIG x3000
	
PYLON_Draw		JSR PYLON_Draw_1
	
Start_Line		JSR START_Line_1
	
	
	LD  R6, ISPOT   ; R6 is display address
	LD  R5, WHT	; R5 is color
	ST R5, CurrentColor		;Save Color

	
	AND R0, R0, #0
	ADD R0, R0, #1		; set skip flag
	ST R0, EraseFlag	;
	JSR DRAW			; Draw initial box
	
	
LOOP	GETC    ; get command character

	
; based on character, either move or change color


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

QUIT	LD  R1, QCHAR
		ADD R1, R1, R0
		BRnp UP
		HALT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UP			LD  R1, WCHAR
			ADD R1, R1, R0
			BRnp DOWN
			
			ST R6, TempR6
			ST R4, TempR4
			LD R4, Mem_Neg_128
			LD R1, Mem_Neg_640
			ADD R6, R6, R1
			ST R6, TempR6_2
			ST R6, TempR6_3
			JSR UP_Down_Test
			
			LD  R1, MVUP
			ADD R3, R6, R1
			LD  R2, LOW
			ADD R2, R2, R3  ; check top boundary
			BRn LOOP	; skip if violated
			ADD R6, R3, #0  ; change position if not
			JSR DRAW

DOWN		LD  R1, SCHAR
			ADD R1, R1, R0
			BRnp LEFT
			
			ST R6, TempR6
			ST R4, TempR4
			LD R4, Mem_128
			LD R1, MVDN
			ADD R6, R6, R1
			ST R6, TempR6_2
			ST R6, TempR6_3
			JSR UP_Down_Test
					
			LD  R1, MVDN
			ADD R3, R6, R1
			LD  R2, HIGH
			ADD R2, R2, R3  ; check bottom boundary
			BRzp LOOP       ; skip if violated
			ADD R6, R3, #0  ; change position if not
			JSR DRAW

LEFT		LD  R1, ACHAR
			ADD R1, R1, R0
			BRnp RIGHT
			
			JSR Left_Test
			
			LD  R2, HMASK   ; check left boundary
			AND R2, R2, R6
			BRz LOOP        ; skip if violated
			ADD R6, R6, #-8 ; change position if not
			JSR DRAW

RIGHT		LD  R1, DCHAR
			ADD R1, R1, R0
			BRnp PRED
			
			JSR Right_Test
			
			ADD R3, R6, #8
			LD  R2, HMASK   ; check right boundary
			AND R2, R2, R3
			BRz LOOP   ; skip if violated
			ADD R6, R3, #0  ; change position if not
			JSR DRAW

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
PRED	LD R1, Flag1
	ST R1, EraseFlag
	
	LD  R1, RCHAR
	ADD R1, R1, R0
	BRnp PYLO
	LD  R5, RED
	JSR DRAW

PYLO	LD  R1, YCHAR
	ADD R1, R1, R0
	BRnp PBLU
	LD  R5, YLOW
	JSR DRAW

PBLU	LD  R1, BCHAR
	ADD R1, R1, R0
	BRnp PGRN
	LD  R5, BLUE
	JSR DRAW

PGRN	LD  R1, GCHAR
	ADD R1, R1, R0
	BRnp PWHT
	LD R5, GRN
	JSR DRAW

PWHT    LD  R1, SP
	ADD R1, R1, R0
	BRnp DRAW
	LD  R5, WHT
	JSR DRAW
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

ISPOT			.FILL xF730   	; starting location
TOPLFT			.FILL xC000     ; top left corner   

HMASK			.FILL x7F	; to prevent running off the edge
LOW				.FILL x4000     ; negative of xC000  required for larger blocks
HIGH			.FILL x0640	; negative of xFE00 - tuned
NextRow			.FILL #128 
CurrentColor	.BLKW 1
OldBlock		.FILL xDF40
EraseFlag		.FILL x0000
Flag1			.FILL x0001
 
RED				.FILL x7C00
BLUE			.FILL x001F
GRN				.FILL x03E0
YLOW			.FILL x7FED
WHT				.FILL x7FFF
ORA				.FILL x7DA0
Neg_ORA			.FILL x8260

TempR1			.FILL	x5000 
TempR2			.FILL	x5001
TempR3			.FILL	x5002
TempR4			.FILL 	x5003
TempR5			.FILL	x5004
TempR6			.FILL	x5005
TempR6_2		.FILL	x5006
TempR6_3		.FILL	x5007

WCHAR			.FILL 	#-119  
ACHAR			.FILL 	#-97  
SCHAR			.FILL 	#-115  
DCHAR   		.FILL 	#-100
QCHAR			.FILL 	#-113


RCHAR			.FILL 	#-114
YCHAR			.FILL 	#-121
BCHAR			.FILL 	#-98
GCHAR   		.FILL 	#-103
SP				.FILL	 #-32

MVUP			.FILL 	#-1024
MVDN			.FILL 	#1024 
Mem_128			.FILL	#128
Mem_Neg_128		.FILL	#-128
Mem_16			.FILL	#16
Neg_Mem_16		.FILL	#-16
Mem_Neg_640		.FILL 	#-640
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DRAW    
		
		
Resume	AND R2, R2, #0	; clear R2
		ADD R2, R2, #8	; set to Y counter 8 
		ADD R3, R6, #0	; Save R6 into R3
		ST R6, TempR6	; Save in temp storage
		ST R5, CurrentColor	; Get Color
		
YLoop	AND R4, R4, #0	; clear R4
		ADD R4, R4, #8	; set to X counter 8 


XLoop	STR R5, R6, #0	; draw a pixel
		ADD R6, R6, #1	; inc pixel XLoop
		ADD R4, R4, #-1	; dec X counter
		BRp XLoop
		
		ADD R6, R3, #0	; Move R3 old address to R6
		LD R0, NextRow	; get 128 offset
		ADD R3, R3, R0	; Next Row
		ADD R6, R3, #0	; Save in R6 pointer
		ADD R2, R2, #-1	; dec Y counter
		BRp YLoop

;		LD R6, TempR6
		
		LD R1, EraseFlag
		BRp ALMOST
		
		;  Erase Old Block
		
ERASE	LD R6, OldBlock
		AND R2, R2, #0	; clear R2
		ADD R2, R2, #8	; set to Y counter 8 
		ADD R3, R6, #0	; Save R6 into R3
		AND R5, R5, #0	; Get R5 Color to Black
		
YLoop2	AND R4, R4, #0	; clear R4
		ADD R4, R4, #8	; set to X counter 8 

XLoop2	STR R5, R6, #0	; draw a pixel
		ADD R6, R6, #1	; inc pixel XLoop
		ADD R4, R4, #-1	; dec X counter
		BRp XLoop2
		
		ADD R6, R3, #0	; Move R3 old address to R6
		LD R0, NextRow	; get 128 offset
		ADD R3, R3, R0	; Next Row
		ADD R6, R3, #0	; Save in R6 pointer
		ADD R2, R2, #-1	; dec Y counter
		BRp YLoop2

ALMOST	LD R6, TempR6
		ST R6, OldBlock
		LD R5, CurrentColor	; Get Color
		
		AND R1, R1, #0
		ST R1, EraseFlag
		
		JSR START_Line_1
		
OTHER	BRnzp LOOP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UP_Down_Test
			ST R1, TempR1
			ST R2, TempR2
			ST R3, TempR3
	

			AND R1, R1, #0
			ADD R1, R1, #8
			AND R2, R2, #0
			ADD R2, R2, #8
			LD R3, Neg_ORA
			LD R6, TempR6_2
UP_DownY		
		UP_DownX
			LD R6, TempR6_3
			ADD R6, R6, R2
			ST R6, TempR6_2
			LDI R6, TempR6_2
			ADD R6, R6, R3
			brz FAIL
			ADD R2, R2, #-1
			brp UP_DownX
			
			LD R6, TempR6_3			
			ADD R6, R6, R4
			ST R6, TempR6_3
			ADD R2, R2, #8
			ADD R1, R1, #-1
			brp UP_DownY
			
			LD R1, TempR1
			LD R2, TempR2
			LD R3, TempR3
			LD R4, TempR4
			LD R6, TempR6
			
			RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Right_Test
			ST R1, TempR1
			ST R2, TempR2
			ST R3, TempR3
			ST R4, TempR4
			ST R6, TempR6
			ST R6, TempR6_2
			ST R6, TempR6_3
			
			AND R1, R1, #0
			ADD R1, R1, #8
			LD R2, Mem_16
			LD R3, Neg_ORA
			LD R4, Mem_128
			LD R6, TempR6_2
RIGHTY		
		RIGHTX
			LD R6, TempR6_3
			ADD R6, R6, R2
			ST R6, TempR6_2
			LDI R6, TempR6_2
			ADD R6, R6, R3
			brz FAIL
			ADD R2, R2, #-1
			brp RIGHTX
			
			LD R6, TempR6_3			
			ADD R6, R6, R4
			ST R6, TempR6_3
			LD R2, Mem_16
			ADD R1, R1, #-1
			brp RIGHTY
			
			LD R1, TempR1
			LD R2, TempR2
			LD R3, TempR3
			LD R4, TempR4
			LD R6, TempR6
			
			RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Left_Test
			ST R1, TempR1
			ST R2, TempR2
			ST R3, TempR3
			ST R4, TempR4
			ST R6, TempR6
			ST R6, TempR6_2
			ST R6, TempR6_3
			
			AND R1, R1, #0
			ADD R1, R1, #8
			AND R2, R2, #0
			ADD R2, R2, #-8
			LD R3, Neg_ORA
			LD R4, Mem_128
			LD R6, TempR6_2
LEFTY		
		LEFTX
			LD R6, TempR6_3
			ADD R6, R6, R2
			ST R6, TempR6_2
			LDI R6, TempR6_2
			ADD R6, R6, R3
			brz FAIL
			ADD R2, R2, #1
			brn LEFTX
			
			LD R6, TempR6_3			
			ADD R6, R6, R4
			ST R6, TempR6_3
			AND R2, R2, #0
			ADD R2, R2, #-8
			ADD R1, R1, #-1
			brp LEFTY
			
			LD R1, TempR1
			LD R2, TempR2
			LD R3, TempR3
			LD R4, TempR4
			LD R6, TempR6
			
			RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FAIL
		LEA R0, LOSE_TEXT
		PUTS
		HALT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PYLON_Draw_1

	LD R1, Pixel1
	LD R2, ORA
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel2
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel3
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel4
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel5
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel6
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel7
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel8
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel9
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel10
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel11
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel12
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel13
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, PixeL14
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel15
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	LD R1, Pixel16
	STR	R2, R1, #0
	JSR	PYLON_Draw_2
	
	JSR Start_Line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PYLON_Draw_2

	ADD R1, R1, #-1
	STR	R2, R1, #0
	ADD R1, R1, #1


	ADD R1, R1, #1
	STR	R2, R1, #0
	ADD R1, R1, #-1

	LD R3, Mem_128
	LD R4, Mem_Neg_128
	
	ADD R1, R1, R3
	STR	R2, R1, #0
	ADD R1, R1, R4
	
	ADD R1, R1, R4
	STR	R2, R1, #0
	ADD R1, R1, R3
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START_Line_1	
				ST R1, TempR1
				ST R2, TempR2
				ST R3, TempR3
				ST R5, TempR5
				ST R6, TempR6
				
				AND R5, R5, #0
				
				LD R6, Mem_16
				LD R3, Mem_128
				ADD R5, R5, R6
				LD R1, Pixel9
				LD R2, WHT
		Line_Y	
				STR	R2, R1, #0
				
				ADD R1, R1, R3
				ADD R5, R5, #-1
				brp	Line_Y
				
				LD R1, TempR1
				LD R2, TempR2
				LD R3, TempR3
				LD R5, TempR5
				LD R6, TempR6
				
				RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	


	.END
	
	
LOSE_TEXT	.STRINGZ	"CRASH!! GAME OVER !!! \n \n \n"

Pixel1	.FILL xC081
Pixel2	.FILL xDF09
Pixel3	.FILL xFD01
Pixel4	.FILL xC892
Pixel5	.FILL xDF1A
Pixel6	.FILL xF512
Pixel7	.FILL xC0C0
Pixel8	.FILL xC8C0
Pixel9	.FILL xF540
Pixel10	.FILL xFD40
Pixel11	.FILL xC8E9
Pixel12	.FILL xDF61
Pixel13	.FILL xF569
Pixel14	.FILL xC0FE
Pixel15	.FILL xDF76
Pixel16	.FILL xFD7E


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
