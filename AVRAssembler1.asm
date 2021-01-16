.INCLUDE "m2560def.inc"
.EQU ALL_PIN_OUT = 0xff
.EQU ALL_PIN_IN = 0x00
.EQU SET_TIME = 0x00
.DEF VAR_A = R16
.DEF VAR_B = R18
.DEF TMP = R17
.DEF VAR_C  = R19
.DEF INPUT = R20
.DEF SECRET = R21
																					
.CSEG
.ORG 0x000

START:	 ldi	VAR_A,ALL_PIN_OUT
		 out    DDRB,VAR_A
		 out    DDRC,VAR_A
		 out    DDRA,VAR_A
		 ; Setting PortA B C to Output 
		 ldi	VAR_A,ALL_PIN_IN
		 out    DDRD,VAR_A
		 ; Set PortD to in put
		 ldi    TMP,0x00
		 ldi	VAR_B,SET_TIME
		 ldi    VAR_C , 0x05
		 out    PORTA, VAR_C

SETTING:		in		INPUT,PIND
				andi    INPUT,0X0F
				cpi		INPUT ,0x0F
				breq	SETTING
				rjmp	GAME_SET

GAME_SET:       cpi  INPUT,0x07 //RED
				breq RED
				cpi  INPUT,0x0B
				breq YELLO //YELLO
				cpi  INPUT,0x0D
				breq GREEN
				cpi  INPUT,0x0E
				breq BLUE
				rjmp SETTING

RED:              ldi SECRET,0x0B //Yellow
				  rcall DELAY_1SEC
				  rjmp MAIN

YELLO:            ldi SECRET,0x07 //red
				  rcall DELAY_1SEC
				  rjmp MAIN

GREEN:            ldi SECRET,0x0E //blue
                  rcall DELAY_1SEC
				  rjmp MAIN

BLUE:             ldi SECRET,0x0D //green
				  rcall DELAY_1SEC
				  rjmp MAIN


MAIN:		
				ori VAR_B,0x01
				cpi VAR_B,0x7f
				breq STOP
				cpi VAR_B,0x0F
				breq CHANGE_COLOR
				brge CHANGE_COLOR
EXIT_CHANGE:	out PORTC,VAR_B
				LSL VAR_B
				ldi VAR_A,0x09
				out PORTC,VAR_B
LOOP:		
			andi INPUT,0X0F
			andi VAR_A,0x0F
			ldi ZL,low(TB_7SEGMENT*2)
			ldi ZH,high(TB_7SEGMENT*2)
			add ZL,VAR_A
			adc ZH,TMP
			lpm
			com R0
			out PORTB ,R0
			dec VAR_A
			rcall DELAY_1SEC
			in INPUT,PIND
			andi INPUT,0X0F
			in INPUT,PIND
			cpi INPUT,0x0F
			brne CHECK
EXIT_CHECK:
			cpi VAR_A,0x00
			breq LOOP
			brge LOOP
			rjmp MAIN

STOP:  ldi VAR_B,0x00
	   ldi VAR_C,0x00
	   out PORTC,VAR_B
	   out PORTA,VAR_C
	   rjmp EXIT

CHANGE_COLOR: ldi VAR_C ,0x03
			  out PORTA,VAR_C
			  rjmp EXIT_CHANGE

DELAY_1SEC:
	  ;Function Delay 1s
	 ;initialize counters
	ldi r23, 0xFF ; 255
	ldi r24, 0xD3 ; 211
	ldi r25, 0x30 ; 48
inner_loop:
	subi r23, 0x01 ; 1
	sbci r24, 0x00 ; 0
	sbci r25, 0x00 ; 0
	brne inner_loop
	ret

CHECK:		
			andi INPUT,0x0F
			cp INPUT,SECRET
			breq GAME_END
			ori VAR_B,0x01
			lsl VAR_B
			out PORTC,VAR_B
			rjmp EXIT_CHECK

GAME_END:	 ldi VAR_B,0xff
			 ldi VAR_C,0x06
			 out PORTC,VAR_B
			 out PORTA,VAR_C

			 rcall DELAY_1SEC
			 rcall DELAY_1SEC
			 rcall DELAY_1SEC
			 rcall DELAY_1SEC
			 rcall DELAY_1SEC

			 in INPUT,PIND
			 cpi INPUT ,0x0F
			 breq GAME_END 
			 rjmp START
		
EXIT: in INPUT,PIND
	  cpi INPUT ,0x0F
	  breq EXIT 
	  rjmp START

TB_7SEGMENT:	.DB 0b00111111, 0b00000110    ;0,1
				.DB 0b01011011, 0b01001111    ;2,3
				.DB 0b01100110, 0b01101101	  ;4,5	
				.DB 0b01111101, 0b00000111	  ;6,7		
				.DB 0b01111111, 0b01101111    ;8,9
.DSEG
.ESEG