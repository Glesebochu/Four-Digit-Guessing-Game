.MODEL small
.STACK 100h

.DATA  
    seed DW 0
    random_number DW 0
    ARBITRARY_NUM_1 equ 0x6C07h
    ARBITRARY_NUM_2 equ 0xAAA5h

.CODE
    pseudo_random_number_generator PROC
        MOV AX, @DATA
        MOV DS, AX

        CALL InitializeRandom  

        CALL GenerateRandomNumber  

        MOV DX, random_number
        RET

    pseudo_random_number_generator ENDP


    InitializeRandom PROC  ; Initializing the random number generator with the system time as the seed value
        MOV AH, 2Ch  ; Getting system time
        INT 21h

        ; The system time is returned in CH (hours), CL (minutes), DH (seconds), and DL (milliseconds) and we combine them by shifting to set the seed value

        MOV AX, CX
        SHL AX, 8           
        ADD AX, CX          
        SHL AX, 8          
        ADD AX, DX         
        SHL AX, 8          
        ADD AX, DX        

        MOV seed, AX

        RET
    InitializeRandom ENDP


    GenerateRandomNumber PROC  ; Generating the random 4-digit number using XORshift algorithm
        MOV AX, seed    

        XOR AX, ARBITRARY_NUM_1     
        SHL AX, 7           
        XOR AX, ARBITRARY_NUM_2    
        SHR AX, 7          

        ; Dividing the repseudo_random_number_generatorder by 9000 to obtain a 4-digit random number between 1000 and 9999
        MOV BX, 9000
        DIV BX  ; DX:AX = DX:AX / BX (repseudo_random_number_generatorder will be stored in AX)

        ADD AX, 1000  ; AddING 1000 to the repseudo_random_number_generatorder to get a number between 1000 and 9999
        MOV random_number, AX

        RET
    GenerateRandomNumber ENDP

END pseudo_random_number_generator