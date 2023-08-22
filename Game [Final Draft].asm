.MODEL large

;***********************************************************************
; Data segment of the program.
;***********************************************************************
DATA SEGMENT

    ;===================================================================
    ; Constants
    ;===================================================================
        ; The maximum number of guesses allowed.
        max_guess_count EQU 10
        
        ; The maximum length of each guess.
        max_guess_length EQU 5

        ; The width of each column on the display table.
        col_width EQU 7

        ; For the pseudo random number generator
        ARBITRARY_NUM_1 equ 0x6C07h
        ARBITRARY_NUM_2 equ 0xAAA5h
        
    ;===================================================================
    ; Arrays
    ;===================================================================
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

    ;===================================================================
    ; Variables
    ;===================================================================
        ; A variable to store the user's current guess.
        user_guess DB 4 dup(0)

        ; A variable for storing the number of guesses the user has made.
        guess_count DB 0

        ; A variable that holds information about whether or not the number has been found.
        found DB 0

        ; A variable that holds information about whether or not a number is valid.
        is_valid DB 0

        ; A variable for storing a number before it is validated.
        to_be_validated DB 4 dup(0)  

        ; For checking if there are repeating digits in the number to be validated.
        to_be_validated_duplicate DB 4 dup(0)

        ; A variable to store the magic (random) number.
        random_number DB 4 dup(?)

        ; For the table generator.
        separator DB '//$'   
        header DB 'Guess|N//P$', 0;

    
    ;===================================================================
    ; Text
    ;===================================================================
        ; A new line.
        new_line DB 10,13,'$'
        ; Rules and overall explanation.
        display_text_1 DB "Hello! Welcome to our number guessing game!$"
        display_text_2 DB "You have to guess a four digit number that we will randomly generate. After every attempt, you will see the score.$"
        display_text_3 DB "Rules of the game - You cannot repeat digits in your guess and Your guess must be exactly 4 digits long.$"
        display_text_4 DB "N tells you how many digits you guessed correctly.$"
        display_text_5 DB "P tells you how many of the correctly guessed digits are in the right position.$"
        display_text_6 DB "The goal is to get a score of 4 for both N and P.$"

        ; During interaction with the user.
        display_text_7 DB "Enter a four digit number: $"
        display_text_8 DB "Invalid. Try again.$"

        display_text_9 DB "CONGRATS! You have found the number.$"
        display_text_10 DB "You've reached the maximum of 10 guesses. Try again, sletebelah(sh).$"

ENDS DATA

;***********************************************************************
; Code segment of the program.
;***********************************************************************
CODE SEGMENT

    main PROC
        ;-------------------------------------------------------------------
        ; Define data segment.
        MOV AX, @DATA
        MOV DS, AX 

        ;-------------------------------------------------------------------
        ; Generate a valid random number.
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
            CMP is_valid, 0
            
            ; Do the LOOP again if the number is not valid.
            JE validating_random_number_loop

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
                JE valid_user_guess

                ; A display message for when the user's guess is invalid.
                invalid_user_guess:
                    LEA DX, display_text_8
                    CALL print_string

                    ; Do the LOOP again if the number is not valid.
                    JNE validating_user_guess_loop

                valid_user_guess:

            ;-------------------------------------------------------------------
            ; Add the user's guess to "all_guesses."

            ; Our own technique.
            LEA SI, user_guess
            LEA DI, all_guesses
            MOV AL, guess_count
            MOV AH, 0
            add DI, AX
            CALL make_duplicate

            ;-------------------------------------------------------------------
            ; Compare the user's guess with the magic number.
            ; Calculate the N score and store it in BH.
            CALL calculate_N

            ; Add the N score of this particlar guess to 'N_scores.'
            LEA DI, N_scores
            MOV AL, guess_count
            MOV AH, 0
            add DI, AX
            MOV [DI], bh

            ; Calculate the P score and store it in BL.
            CALL calculate_P
            
            ; Add the P score to the P_scores array.
            LEA DI, P_scores
            MOV AL, guess_count
            MOV AH, 0
            add DI, AX
            MOV [DI], bl
            
            ;-------------------------------------------------------------------
            ; Display a history of all the user's guesses and their scores.

            CALL table_generator

            ;-------------------------------------------------------------------
            ; Check if the number has been found.
            LEA SI, N_scores
            MOV AL, guess_count
            MOV AH, 0
            ADD SI, AX
            CMP [SI], 4
            JE correct_N_label

            correct_N_label:
                LEA SI, P_scores
                MOV AL, guess_count
                MOV AH, 0
                ADD SI, AX
                CMP [SI], 4
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
    main ENDP
    ;===================================================================
    ; Custom procedures.
    ;===================================================================
        ;-------------------------------------------------------------------
        ; Procedure for easily printing text out on the screen.
        ; ----------------------
        ; - Registers used: DX -
        ;-------------------------------------------------------------------
        print_string PROC
            MOV AH, 09h
            INT 21h

            ; Clear the DX register (after printing out the desired string) for the new line.
            XOR DX, DX

            LEA DX, new_line
            INT 21h
            
            RET
        print_string ENDP

        ;-------------------------------------------------------------------
        ; Procedure for copying the values in one array to another.
        ; ------------------------------
        ; - Registers used: AX, CX, DX -
        ;-------------------------------------------------------------------
        make_duplicate PROC
            ; This takes whatever was specified by SI to DI.
            MOV CX, 4
            copy_loop:
                MOV AL, [si]
                MOV [di], al
                INC si
                INC di
                LOOP copy_loop
            RET
        make_duplicate ENDP

        ;-------------------------------------------------------------------
        ; Procedure for validating a number.
        ; ----------------------------------
        ; - Registers used: AX, BX, CX, DX -
        ;-------------------------------------------------------------------
        validate_number PROC
            LEA SI, to_be_validated
            MOV CX, 4
            
            ; Check if the user's input is actually a string of numbers.
            check_loop:
                MOV AL, [si]
                ADD AL, '0'
                CMP AL, '0'
                JL non_numeric
                CMP AL, '9'
                jg non_numeric

                INC si
                JMP numeric
                non_numeric:
                    MOV is_valid, 0
                    LEA DX, display_text_8
                    CALL print_string
                
                numeric:
                LOOP check_loop

            ; Check if there are any repeating digits.
            CALL check_repeating_digit

            RET

        validate_number ENDP 

        check_repeating_digit PROC
            ; Clear BX register for usage.
            XOR BX, BX

            LEA SI, to_be_validated

            ; Make a duplicate of to_be_validated.
            make_duplicate_label:
                LEA SI, to_be_validated
                LEA DI, to_be_validated_duplicate

                MOV CX, 4
                copy_loop_for_checker:
                    MOV AL, [si]
                    CMP CX, 00
                    je count_repeating_digits_label
                    MOV [di], al
                    INC SI
                    INC DI
                    LOOP copy_loop_for_checker

            ; Count how many times an element from to_be_validated appears in to_be_validated_duplicate.
            count_repeating_digits_label:
                LEA SI, to_be_validated 
                LEA DI, to_be_validated_duplicate
                
                ; Counter variable for going through 'to_be_validated'
                MOV CX, 4
                check_if_to_be_validated_is_empty:
                    MOV ah, [si]
                    CMP CX, 00
                    JE set_value_to_is_valid
                    DEC CX

                ; Counter variable for going through 'to_be_validated_duplicate'
                MOV DL, 4
                actual_comparison_loop:
                    MOV AL, [di]
                    CMP DL, 00
                    je go_to_next_element_in_to_be_validated
                    CMP ah, al
                    je increment_if_same
                    INC DI
                    DEC DL
                    jmp actual_comparison_loop

                increment_if_same:
                    inc bh
                    INC DI
                    DEC DL
                    jmp actual_comparison_loop

                go_to_next_element_in_to_be_validated:
                    INC SI
                    LEA DI, to_be_validated_duplicate
                    jmp check_if_to_be_validated_is_empty

            ; Set the 'is_valid' variable to 0 or 1 representing false or true respectively.
            set_value_to_is_valid:
                CMP bh, 4
                je no_repetitions_exist
                jne repetitions_exist

                no_repetitions_exist:
                    MOV is_valid, 1
                    RET

                repetitions_exist:
                    MOV is_valid, 0
            
            RET

        check_repeating_digit ENDP

        ;-------------------------------------------------------------------
        ; Procedures for generating a random number.
        ; ----------------------------------
        ; - Registers used: AX, BX, CX, DX -        
        ;-------------------------------------------------------------------
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

        ;-------------------------------------------------------------------
        ; Procedure for calculating the N score of the user's guess.
        ; ----------------------------------
        ; - Registers used: AX, BX, CX, DX - 
        ;-------------------------------------------------------------------
        calculate_N PROC
            ; Reset the BX register for proper usage.
            XOR BX, BX
            
            ; load the two arrays aaddress into the si and di register for looping
            LEA SI, user_guess 
            LEA DI, random_number

            ; set your counter register
            MOV CX, 4

            check_existance:

                MOV AL, [si]
                CMP AL, [di]
                je increment_N

                ; save the previous value of the CX register to prevent CX from being reset 
                push si
                push CX

                LEA SI, random_number
                MOV CX, 4

            ; check for the current users input in the rest of the random_number array
            compare_current_input_loop:
                CMP AL, [si]
                je increment_N_val
                INC SI
            LOOP compare_current_input_loop
            jmp continue_N_comparison

            increment_N_val:
                inc bh
                jmp continue_N_comparison

            increment_N:
                inc bh
                jmp continue_N_comparison

            continue_N_comparison:
                pop CX
                pop si
                INC SI      ; Move to the next digit in user_guess
                INC DI      ; Move to the next digit in random_number
                LOOP check_existance

            ret
        calculate_N ENDP

        ;-------------------------------------------------------------------
        ; Procedure for calculating the P score of the user's guess.
        ; ----------------------------------
        ; - Registers used: AX, BX, CX, DX -         
        ;-------------------------------------------------------------------
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
                je increment_P

                ; Move to the next digit in user_guess and the magic number
                INC SI
                INC DI
                LOOP compare_P_loop

                ret

            increment_P:
                INC BL  
                INC SI  
                INC DI  
                LOOP compare_P_loop

                ret
        calculate_P ENDP

        ;-------------------------------------------------------------------
        ; Procedure for drawing a table for displaying the user's past guesses.
        ; ----------------------------------
        ; - Registers used: AX, BX, CX, DX -        
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
            MOV ah, 9    
            int 21h
            
            ;the N array display            
            MOV AL, [BX]        
            ADD AL, 30h        
            MOV DL, AL         

            MOV AH, 02h        
            INT 21h
                
            ;insert separator
            lea dx, separator
            MOV ah, 9    
            int 21h
            
            ;the P array display      
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

ENDS CODE 
END main