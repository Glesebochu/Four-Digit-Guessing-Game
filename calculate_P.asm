.model small
.stack 100h
.data
    user_guess db 4 dup(?)    
    magic_number db 1, 2, 3, 4 
    prompt_msg db "Enter your numbers here: $"
    new_line db 10,13,10,13, "$" 
    prompt_N db "The Number of correctly gussed digets are: $"
    prompt_P db 10,13, "The Number of guessed digets in their correct order are: $"


.code
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    lea dx, prompt_msg
    int 21h

    lea si, user_guess
    mov cx, 4

    ; Procedure to calculate the number of digits in their correct order (P score) ( Status : Done )
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

end