;-------------------------------------------------------------------
; Procedure for calculating the N score of the user's guess.
; ----------------------------------
; - Registers used: AX, BX, CX, DX - 
;-------------------------------------------------------------------

CODE SEGMENT
    calculate_N PROC
        ; Reset the BX register for proper usage.
        XOR BX, BX
        
        ; load the two arrays aaddress into the si and di register for looping
        LEA SI, user_guess 
        LEA DI, random_number

        ; set your counter registers
        MOV CX, 4  
        MOV DX,4
        
        ;this will check if the current digit stored at si is at di if so it increments
        check_in_random_number:
            CMP CX,0
            JE end_check
            MOV al,[SI]
            CMP al,[di]
            JE increment_N
            INC DI
            DEC DX
            CMP DX,0
            JE move_on_to_next_user_digit 
            JMP check_in_random_number
            
            increment_N:
                INC BH
                INC SI
                DEC CX
                LEA DI,random_number
                MOV DX,4
                JMP check_in_random_number 
                
            ;this will only be done if the current user guess digit is not found in random_number
            move_on_to_next_user_digit:
                INC SI
                LEA DI,random_number
                DEC CX 
                MOV DX,4
                JMP check_in_random_number
        end_check:
        RET
    calculate_N ENDP
ENDS CODE