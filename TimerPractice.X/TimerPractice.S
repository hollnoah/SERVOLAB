;NAME Noah Holloway
;COURSE 3371
;SEMESTER 5
;Program: SERVO LAB
;Git URL
    
;Devices
;Configuration
    
    ; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = XT		;Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
 
  
;Include Statements
  #include <xc.inc>
;Register/Variable Setup
  ;SOMEVALUE EQU 0x5f ;assign value to a variable
  
    W_SAVE	EQU 0x20
    STATUS_SAVE EQU 0x21
    ADDEDBITS	EQU 0x22
    TIME	EQU 0x23

 ;Start of Program
 ;Reset vector address
 PSECT resetVect,class=CODE,delta=2 ;-Wl,-presetVect=00h
 GOTO Start
 
 PSECT isrVect,class=CODE,delta=2
 GOTO Interrupt

 ;Setup Code that runs once at power up and at reset
 PSECT code,class=CODE,delta=2 ;-Wl,-pcode=08h
 
Start:
 
;BANK 3
    BSF STATUS,5    ;GO TO BANK 3
    BSF STATUS,6    ;GO TO BANK 3
    CLRF TRISB	    ;SETS PORTB AS OUTPUT
    CLRF ANSELH	    ;DIGITAL I/O
    MOVLW 0x80
    MOVWF OPTION_REG	;DISABLE PULL UPS
    MOVLW 0x01
    MOVWF ANSEL	    ;SETS AN0 AS INPUT
    
;BANK 2
    BSF STATUS,6    ;GO TO BANK 2
    BCF STATUS,5    ;GO TO BANK 2
    CLRF CM2CON1    ;SET ALL BITS TO 0
    
;BANK 1
    BSF STATUS,5    ;GO TO BANK 1
    BCF STATUS,6    ;GO TO BANK 1
    CLRF IOCB	    ;CLEARS INTERRUPTION CHANGE 
    CLRF PSTRCON
    CLRF TRISC	    ;CONFIGURES PORTC AS OUTPUTS
    CLRF ADCON1	    ;LEFT JUSTIFIED, VSS & VDD
    CLRF CCP1CON
    
;BANK 0
    BCF STATUS,5    ;GO TO BANK 0
    BCF STATUS,6    ;GO TO BANK 0
    CLRF PORTC	    ;PUTS PORT C INTO A KNOWN STATE
    CLRF PORTB	    ;PUTS PORT B INTO A KNOWN STATE
    CLRF CCPR1L    ;START WITH 0 DUTY
    
    
    ;INTERRUPT STUFF----------------------------------------------------------------------------------------------
    
    BSF STATUS, 5   ;BANK 1
    BCF STATUS, 6
    
    BSF PIE1, 1	    ;ENABLES TIMER 2 TO MATCH PR2 
    
    MOVLW 0xFF
    MOVWF PR2	    ;LOADING FF FOR MAX COUNT
    
    BCF STATUS, 5
    BCF STATUS, 6   ;BANK 0
    
    MOVLW 0x26
    MOVWF T2CON	    ;1:5 POST, ON, 1:16 PRE
    
    MOVLW 0x41
    MOVWF ADCON0    ;FOSC8, AN0, A/D NOT IN PROGRESS, A/D ENABLED
    
    BCF PIR1, 1	    ;CLEARS INTERRUPT FLAG
    
    MOVLW 0xC0
    MOVWF INTCON    ;ENABLE GLOBAL & PERIPHERAL INTERRUPTS
    
    ;END INTERRUPT STUFF-----------------------------------------------------------------------------------------
    
    GOTO MAINLOOP
   
MAINLOOP:    
    BSF ADCON0, 0
    BSF ADCON0, 1
    MOVF ADRESH, 0      ; read top 8 bits
    
    MOVWF PORTC         ; output to LEDs

    GOTO MAINLOOP

Interrupt:
    ;FOR TESTING PURPOSES
//    MOVLW 0x02	    ;SETTING PORTRB BIT 1
//    XORWF PORTB, 1  ;XORING
    
    MOVWF W_SAVE
    MOVF STATUS,0
    MOVWF STATUS_SAVE   ;Saving our location when interrupted
    
    BCF PIR1,1	    ;Clears TMR2 Interrupt flag
    
    BTFSC ADRESH,4	;CALLS BIT4 IF BIT 4 SET
    CALL BIT4
    
    BTFSC ADRESH,5	;CALLS BIT5 IF BIT 5 SET
    CALL BIT5
    
    BTFSC ADRESH,6	;CALLS BIT6 IF BIT 6 SET
    CALL BIT6
    
    BTFSC ADRESH,7	;CALLS BIT7 IF BIT 7 SET
    CALL BIT7
    
    MOVF ADDEDBITS,0
    GOTO SERVO
    
    
    ;NOT USING THE LSB'S, JUST THE MSB'S TO ONLY CHECK 16 COMBINATIONS INSTEAD OF 256
    BIT4:
	MOVLW 0x01
	ADDWF ADDEDBITS	 ;SHIFTS LSB'S TO MSB'S
	RETURN
    
    BIT5:
	MOVLW 0x02
	ADDWF ADDEDBITS	;SHIFTS LSB'S TO MSB'S
	RETURN
    
    BIT6:
	MOVLW 0x04
	ADDWF ADDEDBITS	;SHIFTS LSB'S TO MSB'S
	RETURN
    
    BIT7:
	MOVLW 0x08
	ADDWF ADDEDBITS	;SHIFTS LSB'S TO MSB'S
	RETURN
	
	;BASED ON WHICH MSB LEDS ARE LIT, IT WILL CORRESPOND TO A SERVO POSITION 
    SERVO:
	ADDWF PCL,1
	GOTO POS1
	GOTO POS2
	GOTO POS3
	GOTO POS4
	GOTO POS5
	GOTO POS6
	GOTO POS7
	GOTO POS8
	GOTO POS9
	GOTO POS10
	GOTO POS11
	GOTO POS12
	GOTO POS13
	GOTO POS14
	GOTO POS15
	GOTO POS16

	
	;HEX VALUE CORRESPONDANT TO THE 100 MICRO SECOND INCRAMENT OVER THE 15 POSITIONS IS MOVED INTO THE TIME REGISTER
	;AND PORTB BIT 0 IS SET (SERVO SIGNAL PIN)
    POS1:
	MOVLW 0x32
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS2:
	MOVLW 0x3F
	MOVWF TIME
	BSF PORTB,0
	GOTO PW  
    POS3:
	MOVLW 0x4C
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS4:
	MOVLW 0x59
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS5:
	MOVLW 0x66
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS6:
	MOVLW 0x73
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS7:
	MOVLW 0x80
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS8:
	MOVLW 0x8D
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS9:
	MOVLW 0x9A
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS10:
	MOVLW 0xA7
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS11:
	MOVLW 0xB4
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS12:
	MOVLW 0xC1
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS13:
	MOVLW 0xCE
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS14:
	MOVLW 0xDB
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS15:
	MOVLW 0xE8
	MOVWF TIME
	BSF PORTB,0
	GOTO PW
    POS16:
	MOVLW 0xFA
	MOVWF TIME
	BSF PORTB,0
	GOTO PW

    PW:
	NOP		;PADDING FOR ACCURATE DELAY
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ TIME	;DECRAMENT THE AMOUNT OF TIME DETERMINED BY LED AMOUNT
	GOTO PW		;THIS TIME IS CONVERTED TO THE PW OF THE SERVO
	GOTO RESETREG	
	
			;REGISTERS RESET ALLOWING FOR A CLEAN SLATE
    RESETREG:
	BCF PORTB,0
	MOVLW 0x00
	MOVWF ADDEDBITS
	
	MOVF STATUS_SAVE,0
	MOVWF STATUS
	MOVF W_SAVE,0
	
	RETFIE		;RETURN TO MAINLOOP
    
END
    
   
    
    
 
    
