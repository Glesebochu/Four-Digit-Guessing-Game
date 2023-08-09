.MODEL medium

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
    EXTERN pseudo_random_number_generator
    EXTERN calculate_N
    EXTERN calculate_P
    EXTERN table_generator
    EXTERN validate_number

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

    MOV magic_number, DX
    
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
        ; A custom procedure for easily printing text out on the screen.
        print_string PROC
            MOV AH, 09h
            INT 21h
            RET
        print_string ENDP

        ; A custom procedure for easily finding the size of an array.
        ; find_array_size:
        ;     CMP BYTE PTR [array+SI], 0   ; Check if element is null
        ;     JE return_to_caller
        ;     INC SI                        ; Move to the next element
        ;     INC CX                        ; Increment count
        ;     JMP find_array_size

        ; return_to_caller:
        ;     RET

    CODE_CUSTOM_PROCS ENDS

CODE ENDS
