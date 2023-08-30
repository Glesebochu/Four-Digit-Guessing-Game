;-------------------------------------------------------------------
; Procedures for generating a random number.
; ----------------------------------
; - Registers used: AX, BX, CX, DX -        
;-------------------------------------------------------------------

CODE SEGMENT
    pseudo_random_number_generator PROC

        LEA SI, random_number
        MOV CX, 4               

        populate_random_number_by_digits_loop: 
        
            ; Save the counter variable on the stack.
            PUSH CX
            
            ; For each digit, generate the current milisecond and convert to a single digit.
            ; The system time is returned in CH (hours), CL (minutes), DH (seconds), and DL (milliseconds)
            MOV AH, 2Ch  ; Getting system time
            INT 21h
            
            ; Store the current milisecond on AL.
            XOR AX, AX
            MOV AL, DL
            
            ; Clear BX and store the value 10 on BL.
            XOR BX, BX
            MOV BL, 0AH

            ; Divide AL by BL (the value 10).
            DIV BL
            
            ; Take the random digit (which is less than 10) to wherever SI is pointing at.
            MOV [SI], AL
            INC SI 
            
            ; Obtain the counter variable from the stack.
            POP CX 
            LOOP populate_random_number_by_digits_loop
            
        RET

    pseudo_random_number_generator ENDP

ENDS CODE