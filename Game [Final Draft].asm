.MODEL medium

;*************************************************************
; Data segment of the program.
;*************************************************************
DATA SEGMENT

    ;=========================================================
    ; Constants
    ;=========================================================
    DATA_CONSTANTS SEGMENT
        ; The maximum number of guesses allowed.
        max_guess_count EQU 10
        
        ; The maximum length of each guess.
        max_guess_length EQU 5

        ; The width of each column on the display table.
        col_width EQU 7
    DATA_CONSTANTS ENDS
    ;=========================================================
    ; Arrays
    ;=========================================================
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

    ;=========================================================
    ; Variables
    ;=========================================================
    DATA_VARIABLES SEGMENT
        ; A variable to store the user's current guess.
        guess_string DW 0

        ; A variable to store the magic number.
        magic_string DW 0

        ; A variable for storing the number of guesses the user has made.
        guess_count DW 0

        ; A variable that holds information about whether or not the number has been found.
        found DW "true", 0

        ; A variable that holds information about whether or not the user's guess or the 
        ; randomly generated number is valid.
        valid_number DW "true", 0
    DATA_VARIABLES ENDS
    ;=========================================================
    ; Text
    ;=========================================================
    DATA_TEXT SEGMENT
        display_text_1 DW "Hello! Welcome to our number guessing game!", 0
        display_text_2 DW "You have to guess a four digit number that we will randomly generate. After every attempt, you will see the score.", 0
        display_text_3 DW "Rules of the game -You cannot repeat digits in your guess and Your guess must be exactly 4 digits long.", 0
        display_text_4 DW "N tells you how many digits you guessed correctly.", 0
        display_text_5 DW "P tells you how many of the correctly guessed digits are in the right position.", 0
        display_text_6 DW "The goal is to get a score of 4 for both N and P", 0
        display_text_7 DW "CONGRATS! You have found the number.", 0
        display_text_7 DW "You've reached the maximum of 20 guesses. Try again, sletebelah(sh).", 0
    DATA_TEXT ENDS

DATA ENDS

;*************************************************************
; Code segment of the program.
;*************************************************************
CODE SEGMENT
    ;---------------------------------------------------------
    ; Import all the necessary procedures.
    EXTERN pseudo_random_number_generator
    EXTERN calculate_N
    EXTERN calculate_P
    EXTERN table_generator
    EXTERN validate_number

    ; Define data segment.
    MOV ax, @data
    MOV ds, ax 

    ;---------------------------------------------------------
    ; Generate a valid random number.

    ;---------------------------------------------------------
    ; Display the rules of the game.

    ;---------------------------------------------------------
    ; Take input from the user and validate it.

    ;---------------------------------------------------------
    ; Add the user's guess to the "all_guesses."

    ;---------------------------------------------------------
    ; Compare the user's guess with the magic number.

    ;---------------------------------------------------------
    ; Display a history of all the user's guesses and their scores.

    ;---------------------------------------------------------
    ; Check if the number has been found.

    ;---------------------------------------------------------
    ; Increment "guess_count."


    ;---------------------------------------------------------
    ; End the program.
    MOV ah, 4Ch
    INT 21h

CODE ENDS
