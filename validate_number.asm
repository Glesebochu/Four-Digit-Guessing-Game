.model small
.stack 100h

.data 

    guess_number db 10    ;store the input of max 5 characters + '$' terminator
    prompt db 'Enter a number: $'     
    valid_msg db ' True', 0x0D, 0x0A, '$'
    invalid_msg db ' False', 0x0D, 0x0A, '$'
  
.code
   
    mov ax,@data
    mov ds, ax 

    ;Display prompt
    
    mov dx,offset prompt
    call printstring    
    
    ;read user input
    
    mov dx, offset guess_number   
    mov ah, 0Ah
    int 21h
    
    
    
    ; checks if the input value has greater than 4 characters excluding the end of line character if so returns false
    
    mov cl,[guess_number+1] ; Get the length of the input string    
    dec cl  ;decrementcx by one to exclude the end of line character
    cmp cl, 3 ;compare to check if the loop reached the end of the string
    jg not_valid ;if greater than jump and call the not_valid procedure



    ;checks if all the characters of the input value are digits if not returns false
   
    check_digit_characters: 
         mov dl,[guess_number+2] ;set dl to the 1st character   
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
        mov al, [guess_number+2+bx] ; Get the first character for comparison
        cmp al, [guess_number+2+di] ; Compare with the character at the next index
        je not_valid              ; Jump if the characters are equal
        jmp check_repeating_digits_loop ; Continue checking the rest of the characters until the terminator is reached
  
   
    
                                                                         
                                                                                     
    ;a custom procedure to exit the program 
    end_program:
    mov ah, 4Ch
    int 21h                                                                                  
       
      ;a custom procedure to display "False" for invalid input
    not_valid:
    lea dx, invalid_msg
    mov ah, 9
    int 21h
    jmp end_program
   
    
     ;a custom procedure to display "True" for valid input
   valid:
    lea dx, valid_msg
    mov ah, 9
    int 21h
   
    
   
    
     ;a custom procedure to display a string  
    printstring:
    mov ah, 09h
    int 21h
    ret       
    
    
    