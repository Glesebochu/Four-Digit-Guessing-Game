.MODEL small
.STACK 100h

.DATA
    all_guesses DB '1234$','8795$',"3553$","1874$","7564$","$"   
    N_scores DB 1, 2, 3, 4, 5
    P_scores DB 1, 2, 3, 4, 5 
    separator DB '//$'   
    header DB 'Guess|N//P$', 0;
    

.CODE
    MAIN PROC
        MOV AX, @DATA
        MOV DS, AX

        CALL table_generator     

        MOV AH, 4Ch         
        INT 21h
    MAIN ENDP  

    table_generator PROC  
        LEA SI, all_guesses                                            
        LEA BX, N_scores                                  
        LEA DI, P_scores 

        lea dx, header
        mov ah, 9    
        int 21h  
                
        ;go to a new line
        MOV DL, 0Dh     ; ASCII value for carriage return
        MOV AH, 02h     
        INT 21h

        MOV DL, 0Ah     ; ASCII value for line feed
        MOV AH, 02h     
        INT 21h 
        
        PrintLoop:            
            MOV CX, 0          

        
        LengthLoop:
            CMP BYTE PTR [SI], '$'   ; Check if the current character is the string terminator
            JE PrintString           ; If it is, jump to PrintString

            INC SI                   ; Move to the next character
            INC CX                   ; Increment the length counter
            JMP LengthLoop           ; Repeat until the string terminator is found

        PrintString:
            MOV AH, 09h       ; Set AH to 09h for printing string
            MOV DX, SI        ; Load the address of the current string into DX
            SUB DX, CX        ; Subtract the length of the string from DX to get the starting address
            INT 21h           
                
        ;insert separator 
        lea dx, separator
        mov ah, 9    
        int 21h
        
        ;the N array display            
        MOV AL, [BX]        
        ADD AL, 30h        
        MOV DL, AL         

        MOV AH, 02h        
        INT 21h
            
        ;insert separator
        lea dx, separator
        mov ah, 9    
        int 21h
        
	    ;the P array diaplay      
        MOV AL, [DI]        
        ADD AL, 30h        
        MOV DL, AL        

        MOV AH, 02h        
        INT 21h
                         
                         
                         
        ;go to a new line
        MOV DL, 0Dh     ; ASCII value for carriage return
        MOV AH, 02h     
        INT 21h

        MOV DL, 0Ah     ; ASCII value for line feed
        MOV AH, 02h    
        INT 21h  
        
           
           
       
        INC DI
        INC BX                          
        INC SI            ; Move to the next string in the array

        CMP BYTE PTR [SI], '$'   ; Check if the next character is the array terminator
        JNE PrintLoop            ; If it is not, jump back to PrintLoop

        RET
    table_generator ENDP

END MAIN
       