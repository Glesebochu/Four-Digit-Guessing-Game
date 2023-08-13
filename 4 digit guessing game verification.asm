.model small
.stack 100h
;the process divided into procedures 
;1. accept data
;2. checks if data is only 4 cahracters and if not returns false and ends program
;3. done if 2 doesnt return false, checks if the data only has digits if not returns false and ends program
;4. done if 3 doesnt return false, checks if the data has non repeating digits if yes returns false and ends program 
;1. accept data
.data ;stores all of its elements in ram and this elements are variables with data types and sizes
    ;8 bits(byte) is a character and the 1st two bytes or words(a word is 2 bytes) is left for max n0 of bytesand n0 of occupied bytes or words if put in by the coder
     
    user_guess_number_buffer db 4 dup("$") 
    prompt db 'Enter a number: $' 
    warning db 10,13,10,13, 'The number you enterd has alpha numeric value $'  
    warning1 db 10,13,10,13, 'The number you enterd has repeating value $' 
    accepted db 10,13,10,13, 'You have successfuly entered a number $' 

.code
main proc
   
    mov ax,@data
    mov ds, ax 

    ;Display prompt
    
    mov dx,offset prompt 
    mov ah,0
    call printstring    
    
    ;read user input
    
    mov cx, 4
    lea si, user_guess_number_buffer
    input_loop:
    	mov ah, 01h 
    	int 21h
    	sub al, '0'
    	mov [si], al
    	inc si
    	loop input_loop

    ;checks alphanumeric values
    
    mov cx, 4
    lea si, user_guess_number_buffer
    check_loop:
    	mov al, [si]
    	add al, '0'
    	cmp al, '0'
    	jl non_numeric
    	cmp al, '9'
    	jg non_numeric
    	inc si

    loop check_loop
    jmp check_repeating_degit
    
    non_numeric:
        mov ax,'0'
    	;lea dx, warning 
    	;mov ah, 09h
    	;int 21h
        jmp end_program
     
    ;check repaeating digits 
    
     
    xor dl,dl 
    mov cx, 3
    lea si, user_guess_number_buffer
    mov al, [si]
    ;add al, '0' ;opptional if you want to compare ASCII values add it 
    mov dl,al
    check_repeating_degit: 
        inc si
        mov al, [si]
        ;add al, '0'
        cmp al,dl
        je repeat_s
        mov dl,al 
    loop check_repeating_degit 
     
    accurate:
        mov ax,'1'
        ;lea dx, accepted
        ;mov ah, 09h
        ;int 21h    
        jmp end_program    

    repeat_s:
        mov ax,'0'
        ;lea dx, warning1
        ;mov ah, 09h
        ;int 21h
        jmp end_program    
    
    
    
    
     ;a custom procedure to exit the program 
    end_program:
    mov ah, 4Ch
    int 21h  
    
     ;a custom procedure to display a string  
    printstring:
    mov ah, 09h 
    int 21h     
    ret       
                                                                                    
 
end main
endp 
      