;-------------------------------------------------------------------
; Procedure for calculating the P score of the user's guess.
; ----------------------------------
; - Registers used: AX, BX, CX, DX -         
;-------------------------------------------------------------------

CODE SEGMENT
    calculate_P PROC
        ; Reset the BX register for proper usage.
        XOR BX, BX

        ; Compare the user's guess with the magic number 
        LEA SI, user_guess
        LEA DI, random_number
        MOV CX, 4

        compare_P_loop:
            MOV AL, [si]
            CMP AL, [di]
            JE increment_P

            ; Move to the next digit in user_guess and the magic number
            INC SI
            INC DI
            LOOP compare_P_loop

            RET

        increment_P:
            INC BL  
            INC SI  
            INC DI  
            LOOP compare_P_loop

            RET
    calculate_P ENDP
ENDS CODE