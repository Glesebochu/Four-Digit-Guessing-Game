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
        
    ENDS DATA_CONSTANTS
    ;===================================================================
    ; Arrays
    ;===================================================================
    DATA_ARRAYS SEGMENT
        ; An array to store all the guesses the user has previously made.
            ; Size Calculation
            ; 4 bytes for holding each guess. 4 x 10 (for all the possible guesses) = 40 bytes.
        all_guesses DB 40 dup(?)

        ; An array to store all the N scores of each guess.
            ; Size Calculation
            ; 1 byte for holding each N score. 1 x 10 (for all the possible guesses) = 10 bytes.
        N_scores DB 10 dup(?)

        ; An array to store all the P scores of each guess.
            ; Size Calculation
            ; 1 byte for holding each P score. 1 x 10 (for all the possible guesses) = 10 bytes.
        P_scores DB 10 dup(?)
    ENDS DATA_ARRAYS

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
        found DB 0

        ; A variable that holds information about whether or not a number is valid.
        is_valid DB 0

        ; A variable for storing a number before it is validated.
        to_be_validated DW 1   

        ; For checking if there are repeating digits in the number to be validated.
        to_be_validated_duplicate DW 1

        ; For the pseudo random number generator.
        seed DW 0
        random_number DW 1

        ; For the table generator.
        separator DB '//$'   
        header DB 'Guess|N//P$', 0;

    ENDS DATA_VARIABLES
    
    ;===================================================================
    ; Text
    ;===================================================================
    DATA_TEXT SEGMENT
        ; Rules and overall explanation.
        display_text_1 DW "Hello! Welcome to our number guessing game!$"
        display_text_2 DW "You have to guess a four digit number that we will randomly generate. After every attempt, you will see the score.$"
        display_text_3 DW "Rules of the game - You cannot repeat digits in your guess and Your guess must be exactly 4 digits long.$"
        display_text_4 DW "N tells you how many digits you guessed correctly.$"
        display_text_5 DW "P tells you how many of the correctly guessed digits are in the right position.$"
        display_text_6 DW "The goal is to get a score of 4 for both N and P.$"

        ; During interaction with the user.
        display_text_7 DW "Enter a four digit number: $"
        display_text_8 DW "Invalid. Try again.$"

        display_text_9 DW "CONGRATS! You have found the number.$"
        display_text_10 DW "You've reached the maximum of 10 guesses. Try again, sletebelah(sh).$"
    ENDS DATA_TEXT

ENDS DATA

;***********************************************************************
; Code segment of the program.
;***********************************************************************
CODE SEGMENT
    ;-------------------------------------------------------------------
    ; Define data segment.
    MOV AX, @DATA
    MOV DS, AX 

    ;-------------------------------------------------------------------
    ; Generate a valid random number and store it on "magic_number."
    validating_random_number_loop:
        ; Generate a random number. The generated number is stored on DX.
        CALL pseudo_random_number_generator

        ; Copy the values in 'random_number' to 'to_be_validated.'
        LEA DI, to_be_validated
        LEA SI, random_number
        CALL make_duplicate

        ; Check if the random number (stored in to_be_validated) is valid.
        CALL validate_number

        ; Check if the "validate_number" procedure returned true (1).
        CMP is_valid, 1
        
        ; Do the loop again if the number is not valid.
        JNE validating_random_number_loop

    ; Copy the values in 'to_be_validated' to 'magic_number.'
    LEA DI, magic_number
    LEA SI, to_be_validated
    CALL make_duplicate
    
    ;-------------------------------------------------------------------
    ; Display the rules of the game.
    LEA DX, display_text_1
    CALL print_string
    LEA DX, display_text_2
    CALL print_string
    LEA DX, display_text_3
    CALL print_string
    LEA DX, display_text_4
    CALL print_string
    LEA DX, display_text_5
    CALL print_string
    LEA DX, display_text_6
    CALL print_string

    ;-------------------------------------------------------------------
    ; Loop the game until the number is found or the maximum guess count is reached.
    game_loop:
        ;-------------------------------------------------------------------
        ; Take input from the user and validate it.
        validating_user_guess_loop:
            ; Display the prompt.
            LEA DX, display_text_7
            CALL print_string

            ; Take the user's guess and store it in "user_guess."
            LEA SI, user_guess
            ; Set the starting value for the counter register to 4.
            ; This is the number of characters we want to take from the user.
            MOV CX, 4
            input_loop:
                ; Take the "character input instruction" to AH.
                MOV AH, 01h 
                INT 21h
                ; Change whatever character was in AL to an actual integer.
                SUB AL, '0'
                ; Store that integer to the memory location specified by the address in SI.
                MOV [SI], AL
                INC SI
                ; Each LOOP instruction decrements CX by 1.
                LOOP input_loop

            ; Store a copy of the user's guess on 'to_be_validated' so that "validate_number" can access it.
            LEA SI, user_guess
            LEA DI, to_be_validated
            CALL make_duplicate
            CALL validate_number

            ; Check if the "validate_number" procedure returned true.
            CMP is_valid, 1

            ; Display error message if the number isn't valid.
            JNE invalid_user_guess

            ; A display message for when the user's guess is invalid.
            invalid_user_guess:
                LEA DX, display_text_8
                CALL print_string

                ; Do the loop again if the number is not valid.
                JNE validating_user_guess_loop

        ;-------------------------------------------------------------------
        ; Add the user's guess to "all_guesses."

        ; Our own technique.
        MOV AX, 4
        MUL guess_count
        LEA SI, user_guess
        LEA DI, all_guesses + AX
        CALL make_duplicate

        ; From stack overflow.
        ; LEA DI, all_guesses
        ; ADD DI, guess_count
        ; MOV BYTE PTR [DI], user_guess

        ;-------------------------------------------------------------------
        ; Compare the user's guess with the magic number.
        ; The magic number is stored in BX so that calculate_N and calculate_P can access it.
        MOV BX, magic_number

        ; Calculate the N score and store it in BH.
        CALL calculate_N

        ; Add the N score of this particlar guess to 'N_scores.'
        ; Our own method.
        LEA SI, N_scores
        MOV AX, guess_count
        MOV BYTE [SI + AX], BH

        ; From stack overflow.
        ; MOV SI, offset N_scores
        ; ADD SI, guess_count
        ; MOV BYTE PTR [SI], BH

        ; Calculate the P score and store it in BL.
        CALL calculate_P
        
        ; Add the P score to the P_scores array.
        LEA SI, P_scores
        ADD SI, guess_count
        MOV BYTE PTR [SI], BL
        
        ;-------------------------------------------------------------------
        ; Display a history of all the user's guesses and their scores.

        CALL table_generator

        ;-------------------------------------------------------------------
        ; Check if the number has been found.
        LEA SI, N_scores
        ADD SI, guess_count
        CMP 4, BYTE PTR [SI]
        JE correct_N_label

        correct_N_label:
            LEA SI, P_scores
            ADD SI, guess_count
            CMP 4, BYTE PTR [SI]
            JE found_label
            JNE increment_guess_count_label

        found_label:
            MOV found, 1
            LEA DX, display_text_9
            CALL print_string
            JMP end_program_label

        ;-------------------------------------------------------------------
        ; Increment "guess_count" and check if the maximum number of guesses 
        ; has been reached.
        increment_guess_count_label:
            INC guess_count
            CMP guess_count, max_guess_count
            JE maximum_guesses_label

        maximum_guesses_label:
            LEA DX, display_text_10
            CALL print_string
            JMP end_program_label

        JMP game_loop
    
    ;-------------------------------------------------------------------
    ; End the program.
    end_program_label:
        MOV AH, 4Ch
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
        ; Procedure for copying the values in one array to another.
        ;-------------------------------------------------------------------
        make_duplicate PROC
            ; This takes whatever was specified by SI to DI.
            MOV CX, 4
            copy_loop:
                MOV al, [si]
                MOV [di], al
                INC si
                INC di
                LOOP copy_loop
        make_duplicate ENDP

        ;-------------------------------------------------------------------
        ; Procedure for validating a number.
        ;-------------------------------------------------------------------
        validate_number PROC
            LEA si, to_be_validated
            MOV cx, 4
            
            ; Check if the user's input is actually a string of numbers.
            check_loop:
                MOV al, [si]
                ADD al, '0'
                CMP al, '0'
                JL non_numeric
                CMP al, '9'
                jg non_numeric
                INC si

                LOOP check_loop

            ; Check if there are any repeating digits.
            CALL check_repeating_degit

            non_numeric:
                MOV is_valid, 0
                LEA DX, display_text_8
                CALL print_string

        validate_number ENDP 

        check_repeating_digit PROC
            lea si, to_be_validated

            ; Make a duplicate of to_be_validated.
            make_duplicate_label:
                lea si, to_be_validated
                lea di, to_be_validated_duplicate
                copy_loop_for_checker:
                    mov al, [si]
                    cmp al, 00
                    je count_repeating_digits_label
                    mov [di], al
                    inc si
                    inc di
                    jmp copy_loop_for_checker

            ; Count how many times an element from to_be_validated appears in to_be_validated_duplicate.
            count_repeating_digits_label:
                lea si, to_be_validated 
                lea di, to_be_validated_duplicate
                
                check_if_to_be_validated_is_empty:
                    mov ah, [si]
                    cmp ah, 00
                    je set_value_to_is_valid

                actual_comparison_loop:
                    mov al, [di]
                    cmp al, 00
                    je go_to_next_element_in_to_be_validated
                    cmp ah, al
                    je increment_if_same
                    inc di
                    jmp actual_comparison_loop

                increment_if_same:
                    inc bh
                    inc di
                    jmp actual_comparison_loop

                go_to_next_element_in_to_be_validated:
                    inc si
                    lea di, to_be_validated_duplicate
                    jmp check_if_to_be_validated_is_empty

            ; Set the 'is_valid' variable to 0 or 1 representing false or true respectively.
            set_value_to_is_valid:
                cmp bh, 4
                je no_repetitions_exist
                jne repetitions_exist

                no_repetitions_exist:
                    mov is_valid, 1

                repetitions_exist:
                    mov is_valid, 0
            
            RET

        check_repeating_digit ENDP

        ;-------------------------------------------------------------------
        ; Procedures for generating a random number.
        ;-------------------------------------------------------------------
        pseudo_random_number_generator PROC

            CALL InitializeRandom  
            CALL GenerateRandomNumber  
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
                push si
                push cx

                lea si, magic_number
                mov cx, 4

            ; check for the current users input in the rest of the magic's number array
            compare_current_input_loop:
                cmp al, [si]
                je increment_N_val
                inc si
            loop compare_current_input_loop
            jmp continue_N_comparison

            increment_N_val:
                inc bh
                jmp continue_N_comparison

            increment_N:
                inc bh
                jmp continue_N_comparison

            continue_N_comparison:
                pop cx
                pop si
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

    ENDS CODE_CUSTOM_PROCS

ENDS CODE
