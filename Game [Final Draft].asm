.MODEL large

;***********************************************************************
; Data segment of the program.
;***********************************************************************
DATA SEGMENT

    ;===================================================================
    ; Constants
    ;===================================================================
    DATA_CONSTANTS SEGMENT
        ; The maximum number of guesses allowed.
        max_guess_count EQU 10
        
        ; The maximum length of each guess.
        max_guess_length EQU 5

        ; The width of each column on the display table.
        col_width EQU 7

        ; For the pseudo random number generator
        ARBITRARY_NUM_1 equ 0x6C07h
        ARBITRARY_NUM_2 equ 0xAAA5h
        
    DATA_CONSTANTS ENDS
    ;===================================================================
    ; Arrays
    ;===================================================================
    DATA_ARRAYS SEGMENT
        ; An array to store all the guesses the user has previously made.
            /*
            Size Calculation
            1 byte for holding how many elements the array can hold at max capacity.
            1 byte for holding how much of the memory space given to the array is actually occupied.
            1 byte for holding the terminating symbol.
            4 bytes for holding each guess. 4 x 10 (for all the possible guesses) = 40 bytes = 20 words.
            (1 + 1 + 1) bytes + 20 words = 22 words.
            */
        all_guesses DW 22 dup(?)

        ; An array to store all the N scores of each guess.
            /*
            Size Calculation
            1 byte for holding how many elements the array can hold at max capacity.
            1 byte for holding how much of the memory space given to the array is actually occupied.
            1 byte for holding the terminating symbol.
            1 byte for holding each N score. 1 x 10 (for all the possible guesses) = 10 bytes.
            (1 + 1 + 1 + 10) bytes = 13 bytes.
            */
        N_scores DB 13 dup(?)

        ; An array to store all the P scores of each guess.
            /*
            Size Calculation
            1 byte for holding how many elements the array can hold at max capacity.
            1 byte for holding how much of the memory space given to the array is actually occupied.
            1 byte for holding the terminating symbol.
            1 byte for holding each P score. 1 x 10 (for all the possible guesses) = 10 bytes.
            (1 + 1 + 1 + 10) bytes = 13 bytes.
            */
        P_scores DB 13 dup(?)
    DATA_ARRAYS ENDS

    ;===================================================================
    ; Variables
    ;===================================================================
    DATA_VARIABLES SEGMENT
        ; A variable to store the user's current guess.
        user_guess DW 1

        ; A variable to store the magic number.
        magic_number DW 1

        ; A variable for storing the number of guesses the user has made.
        guess_count DB 1

        ; A variable that holds information about whether or not the number has been found.
        found DW "False$"

        ; A variable for storing a number before it is validated.
            ;store the input of max 5 characters + '$' terminator
        to_be_validated DB 10    

        ; For the pseudo random number generator.
        seed DW 0
        random_number DW 0

        ; For the table generator.
        separator DB '//$'   
        header DB 'Guess|N//P$', 0;

    DATA_VARIABLES ENDS
    ;===================================================================
    ; Text
    ;===================================================================
    DATA_TEXT SEGMENT
        ; Rules and overall explanation.
        display_text_1 DW "Hello! Welcome to our number guessing game!$"
        display_text_2 DW "You have to guess a four digit number that we will randomly generate. After every attempt, you will see the score.$"
        display_text_3 DW "Rules of the game -You cannot repeat digits in your guess and Your guess must be exactly 4 digits long.$"
        display_text_4 DW "N tells you how many digits you guessed correctly.$"
        display_text_5 DW "P tells you how many of the correctly guessed digits are in the right position.$"
        display_text_6 DW "The goal is to get a score of 4 for both N and P$"

        ; During interaction with the user.
        display_text_7 DW "Enter a four digit number: $"
        display_text_8 DW "Invalid. Try again.$"

        display_text_9 DW "CONGRATS! You have found the number.$"
        display_text_10 DW "You've reached the maximum of 10 guesses. Try again, sletebelah(sh).$"
    DATA_TEXT ENDS

DATA ENDS

;***********************************************************************
; Code segment of the program.
;***********************************************************************
CODE SEGMENT
    ;-------------------------------------------------------------------
    ; Import all the necessary procedures.
    ; INCLUDE pseudo_random_number_generator.asm
    ; INCLUDE calculate_N.asm
    ; INCLUDE calculate_P.asm
    ; INCLUDE table_generator.asm
    ; INCLUDE validate_number.asm

    ;-------------------------------------------------------------------
    ; Define data segment.
    MOV AX, @data
    MOV DS, AX 

    ;-------------------------------------------------------------------
    ; Generate a valid random number and store it on "magic_number."
    validating_random_number_loop:
        ; Generate a random number. The generated number is stored on DX.
        CALL pseudo_random_number_generator

        ; Check if the random number (stored in DX) is valid.
        CALL validate_number

        ; Check if the "validate_number" procedure returned true.
        CMP AX, "True"
        
        ; Do the loop again if the number is not valid.
        JNZ validating_random_number_loop

    MOV magic_number, [DX]
    
    ;-------------------------------------------------------------------
    ; Display the rules of the game.
    LEA DX, display_text_1 + 2
    CALL print_string
    LEA DX, display_text_2 + 2
    CALL print_string
    LEA DX, display_text_3 + 2
    CALL print_string
    LEA DX, display_text_4 + 2
    CALL print_string
    LEA DX, display_text_5 + 2
    CALL print_string
    LEA DX, display_text_6 + 2
    CALL print_string

    ;-------------------------------------------------------------------
    ; Loop the game until the number is found or the maximum guess count is reached.
    game_loop:
        ;-------------------------------------------------------------------
        ; Take input from the user and validate it.
        validating_user_guess_loop:
            ; Display the prompt.
            LEA DX, display_text_7 + 2
            CALL print_string

            ; Take the user's guess and store it in "user_guess."
            MOV DX, offset user_guess
            MOV AH, 0Ah
            INT 21h

            ; Store a copy of the user's guess on DX so that the "validate_number" procedure can access it.
            MOV DX, user_guess
            CALL validate_number

            ; Check if the "validate_number" procedure returned true.
            CMP AX, "True"

            ; Display error message if the number isn't valid.
            JNZ invalid_user_guess
            
            ; Do the loop again if the number is not valid.
            JMP validating_user_guess_loop

        ; A display message for when the user's guess is invalid.
        invalid_user_guess:
            LEA DX, display_text_8 + 2
            CALL print_string
            RET
        
        ;-------------------------------------------------------------------
        ; Add the user's guess to "all_guesses."
        MOV SI, offset guesses
        ADD SI, guess_count
        MOV BYTE PTR [SI], user_guess

        ;-------------------------------------------------------------------
        ; Compare the user's guess with the magic number.
        ; The magic number is stored in BX so that calculate_N and calculate_P can access it.
        MOV BX, magic_number

        ; Calculate the N score and store it in AX.
        MOV DX, user_guess
        CALL calculate_N

        ; Add the N score to the N_scores array.
        MOV SI, offset N_scores
        ADD SI, guess_count
        MOV BYTE PTR [SI], AX

        ; Calculate the P score and store it in AX.
        MOV DX, user_guess
        CALL calculate_P
        
        ; Add the P score to the P_scores array.
        MOV SI, offset P_scores
        ADD SI, guess_count
        MOV BYTE PTR [SI], AX
        
        ;-------------------------------------------------------------------
        ; Display a history of all the user's guesses and their scores.

        MOV AX, offset guesses
        MOV BX, offset N_scores
        MOV CX, offset P_scores

        CALL table_generator

        ;-------------------------------------------------------------------
        ; Check if the number has been found.
        CMP 4, N_scores[guess_count]
        JZ correct_label

        correct_label:
            CMP 4, P_scores[guess_count]
            JZ found_label

        found_label:
            MOV found, "True"
            LEA DX, display_text_9 + 2
            CALL print_string
            JMP end_program_label

        ;-------------------------------------------------------------------
        ; Increment "guess_count" and check if the maximum number of guesses 
        ; has been reached.
        INC guess_count
        CMP guess_count, max_guess_count
        JZ maximum_guesses_label

        maximum_guesses_label:
            LEA DX, display_text_10 + 2
            CALL print_string
            JMP end_program_label

        JMP game_loop
    
    ;-------------------------------------------------------------------
    ; End the program.
    end_program_label:
        MOV ah, 4Ch
        INT 21h

    ;===================================================================
    ; Custom procedures.
    ;===================================================================
    CODE_CUSTOM_PROCS SEGMENT
        ;-------------------------------------------------------------------
        ; Procedure for easily printing text out on the screen.
        ;-------------------------------------------------------------------
        print_string PROC
            MOV AH, 09h
            INT 21h
            RET
        print_string ENDP

        ;-------------------------------------------------------------------
        ; Procedure for easily finding the size of an array.
        ;-------------------------------------------------------------------
        ; find_array_size PROC
        ;     CMP BYTE PTR [array+SI], 0   ; Check if element is null
        ;     JE return_to_caller
        ;     INC SI                        ; Move to the next element
        ;     INC CX                        ; Increment count
        ;     JMP find_array_size

        ;     return_to_caller:
        ;         RET
        ; find_array_size ENDP

        ;-------------------------------------------------------------------
        ; Procedure for validating a number.
        ;-------------------------------------------------------------------
        validate_number PROC
            ; Move the number to be validated to from DX to to_be_validated
            mov to_be_validated, [dx]
            
            ; checks if the input value has greater than 4 characters excluding the end of line character if so returns false
            
            mov cl,[to_be_validated+1] ; Get the length of the input string    
            dec cl  ; decrement cx by one to exclude the end of line character
            cmp cl, 3 ;compare to check if the loop reached the end of the string
            jg not_valid ;if greater than jump and call the not_valid procedure

            ;checks if all the characters of the input value are digits if not returns false
        
            check_digit_characters: 
                mov dl,[to_be_validated+2] ;set dl to the 1st character   
                inc dl        
                cmp dl,'0'              ; Check if it's a valid digit (ASCII '0' to '9')
                jb not_valid              ; Jump if it's not a valid digit (before '0' in ASCII table)
                cmp dl, '9'
                ja not_valid              ; Jump if it's not a valid digit (after '9' in ASCII table)

            ;checks if the input value has repeating digits and if there are any returns false
            mov di,bx ;initalizes the inner loop
            
            check_repeating_digits_loop:
                inc di                   ; Move to the next character
                cmp di, #5               ; Check if we reached the end of the input string
                jae valid                 ; If yes, the input is valid (no repeating digits)
                mov ah, 0                 ; Clear AH to compare the two characters without shifting
                mov al, [to_be_validated+2+bx] ; Get the first character for comparison
                cmp al, [to_be_validated+2+di] ; Compare with the character at the next index
                je not_valid              ; Jump if the characters are equal
                jmp check_repeating_digits_loop ; Continue checking the rest of the characters until the terminator is reached
                                                                                            
            ;a custom procedure to exit the program 
            end_program:
                mov ah, 4Ch
                int 21h                                                                                  
            
            ;a custom procedure to display "False" for invalid input
            not_valid:
                mov ax, 'False'
                jmp end_program
            
            ;a custom procedure to display "True" for valid input
            valid:
                mov ax, 'True'
                jmp end_program
            
        valid_number ENDP

        ;-------------------------------------------------------------------
        ; Procedures for generating a random number.
        ;-------------------------------------------------------------------
        pseudo_random_number_generator PROC

            CALL InitializeRandom  

            CALL GenerateRandomNumber  

            MOV DX, random_number
            RET

        pseudo_random_number_generator ENDP

        ; Initializing the random number generator with the system time as the seed value
        InitializeRandom PROC  
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

        ; Generating the random 4-digit number using XORshift algorithm
        GenerateRandomNumber PROC  
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

        ;-------------------------------------------------------------------
        ; Procedure for calculating the N score of the user's guess.
        ;-------------------------------------------------------------------
        calculate_N PROC
            ; load the two arrays aaddress into the si and di register for looping
            lea si, user_guess ; [4,3,2,1]
            lea di, magic_number ; [1,2,3,4]

            ; set your counter register
            mov cx, 4

            check_existance:
                mov al, [si] ; al = 4
                cmp al, [di] ; 4 == 1 => false
                je increment_N

                ; save the previous value of the cx register to prevent cx from being rest 
                push cx

                lea si, magic_number
                mov cx, 4

            ; check for the current users input in the rest of the magic's number array
            compare_current_input_loop:
                cmp al, [si]
                je increment_N_val
                inc si
                loop compare_current_input_loop

            increment_N_val:
                pop cx
                inc bh
                jmp continue_N_comparison

            increment_N:
                inc bh
                jmp continue_N_comparison

            continue_N_comparison:
                inc si      ; Move to the next digit in user_guess
                inc di      ; Move to the next digit in magic_number
                loop check_existance

            ret
        calculate_N ENDP

        ;-------------------------------------------------------------------
        ; Procedure for calculating the P score of the user's guess.
        ;-------------------------------------------------------------------
        calculate_P PROC
            ; Compare the user's guess with the magic number 
            lea si, user_guess
            lea di, magic_number
            mov cx, 4

            compare_P_loop:
                mov al, [si]
                cmp al, [di]
                je increment_P

                ; Move to the next digit in user_guess and the magic number
                inc si
                inc di
                loop compare_P_loop

                ret

            increment_P:
                inc bl  
                inc si  
                inc di  
                loop compare_P_loop

                ret
        calculate_P ENDP

        ;-------------------------------------------------------------------
        ; Procedure for drawing a table for displaying the user's past guesses.
        ;-------------------------------------------------------------------
        table_generator PROC  
            LEA SI, all_guesses                                            
            LEA BX, N_scores                                  
            LEA DI, P_scores 

            LEA dx, header
            MOV ah, 9    
            INT 21h  
                    
            ; Go to a new line
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
                            
                            
            ; Go to a new line
            MOV DL, 0Dh     ; ASCII value for carriage return
            MOV AH, 02h     
            INT 21h

            MOV DL, 0Ah     ; ASCII value for line feed
            MOV AH, 02h    
            INT 21h  
            
            ; Increment registers used to access the arrays.
            INC DI
            INC BX                          
            INC SI            ; Move to the next string in the array

            CMP BYTE PTR [SI], '$'   ; Check if the next character is the array terminator
            JNE PrintLoop            ; If it is not, jump back to PrintLoop

            RET
        table_generator ENDP

    CODE_CUSTOM_PROCS ENDS

CODE ENDS
