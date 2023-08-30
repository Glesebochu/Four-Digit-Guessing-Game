;-------------------------------------------------------------------
; Procedure for drawing a table for displaying the user's past guesses.
; ----------------------------------
; - Registers used: AX, BX, CX, DX -        
;-------------------------------------------------------------------

CODE SEGMENT
    table_generator PROC 
        MOV AH,09h
        LEA DX, new_line
        INT 21h
        
        LEA dx, header
        MOV ah, 9    
        INT 21h 

        MOV AH,09h
        LEA DX, new_line
        INT 21h

        XOR CX,CX
        MOV CL,guess_count
        MOV BX,0
        print_row:
            
            PUSH CX
            ;Printing the guess numbers one by one
            XOR CX,CX
            MOV CX,4H
            
            LEA SI, all_guesses
            MOV AX, BX
            MOV AH, 0
            MUL CX     
            add SI, AX

            MOV CX,4

            print_current_guess_num:
                
                MOV AH,02h
                MOV DL,[SI]
                ADD DX,'0'
                INT 21H

                INC SI

                LOOP print_current_guess_num

            POP CX

            ; Insert separator
            lea dx, separator
            MOV ah, 9    
            int 21h

            ; This prints the N score
            LEA SI, N_scores
            MOV AX, BX
            MOV AH, 0
            ADD SI, AX
            MOV AH, 02h
            MOV DX,[SI]
            ADD DX,'0'
            INT 21h

            ; Insert separator
            lea dx, separator
            MOV ah, 9    
            int 21h

            ; This prints the p socre
            LEA SI, P_scores
            MOV AX, BX
            MOV AH, 0
            ADD SI, AX
            MOV AH, 02h
            MOV DX,[SI]
            ADD DX,'0'
            INT 21h

            MOV AH,09H
            LEA DX, new_line
            int 21h
                                    
            INC BX
            DEC CX

            CMP CX,0
            JE end_table_generator  
            JNE print_row                        
        
        end_table_generator:

        RET
    table_generator ENDP

ENDS CODE