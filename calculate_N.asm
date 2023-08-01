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

    ; Procedure to calculate the number of correctly guessed digits (the N score) ( Status : Done )
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

end