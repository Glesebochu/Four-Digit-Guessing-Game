.model medium



;**********************************************************
; Data segment of the program.
;**********************************************************
.data 

    ;=========================================================
    ; Constants
    ;=========================================================
    
    ; The maximum number of guesses allowed.
    max_guess_count equ 20
    
    ; The maximum length of each guess.
    max_guess_length equ 5

    ; The width of each column on the display table.
    col_width equ 7
    
    ;=========================================================
    ; Arrays
    ;=========================================================
    
    ; An array to store all the guesses the user has previously made.
    all_guesses dw 0

    ; An array to store all the N scores of each guess.
    N dw 0

    ; An array to store all the P scores of each guess.
    P dw 0

    ;=========================================================
    ; Variables
    ;=========================================================
    ; A variable to store the user's current guess.
    guess_string dw 0

    ; A variable to store the magic number.
    magic_string dw 0

    ; A variable for storing the number of guesses the user has made.
    guess_count dw 0

    ; A variable that holds information about whether or not the number has been found.
    found dw "true", 0

    ; A variable that holds information about whether or not the user's guess or the 
    ; randomly generated number is valid.
    valid_number dw "true", 0

    ;=========================================================
    ; Text
    ;=========================================================
    display_text_1 dw "Hello! Welcome to our number guessing game!", 0
    display_text_2 dw "You have to guess a four digit number that we will randomly generate. After every attempt, you will see the score.", 0
    display_text_3 dw "Rules of the game -You cannot repeat digits in your guess and Your guess must be exactly 4 digits long.", 0
    display_text_4 dw "N tells you how many digits you guessed correctly.", 0
    display_text_5 dw "P tells you how many of the correctly guessed digits are in the right position.", 0
    display_text_6 dw "The goal is to get a score of 4 for both N and P", 0
    display_text_7 dw "CONGRATS! You have found the number.", 0
    display_text_7 dw "You've reached the maximum of 20 guesses. Try again, sletebelah(sh).", 0
end

;**********************************************************
; Code segment of the program.
;**********************************************************
.code
    ;---------------------------------------------------------
    ; Import all the necessary procedures.

    ; Define data segment.
    mov ax, @data
    mov ds, ax 

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
    

end
