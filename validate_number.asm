.model small
.stack 100h


.data 
    to_be_validated db 4 dup("$") 
  
.code
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
			copy_loop:
				mov al, [si]
				cmp al, 00
				je count_repeating_digits_label
				mov [di], al
				inc si
				inc di
				jmp copy_loop

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


/*  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$       COMMENTS :-     $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

	The method you've used for capturing user input is accurate, but it allows user's to enter more than four digits. To prevent this, I recommend prompting the user to enter a single character on four separate occasions. This approach will effectively prevent the entry of a fifth digit.
	    mov dx, offset to_be_validated ;move the ADDress(we use offset to specify that we want to move the ADDress and not the value in that ADDress) of the 1st byte of the buffer in ram to dx register  
	    mov ah, 0Ah ;an instruction that says 'read a string from keyboard and save it in the memory pointed to by the buffer giving the is moved to ah
	    int 21h ; is a sw interupt that executes whatever instruction is stored in Ah


	Tip :- You can finish the printing of a newline there in the data section by appending 10,13 before your string. This approach saves you from having to write an extensive amount of code.
	    ;print new line
	    mov dx,offset new_line
	    mov ah,0
	    call printstring      

    
    Tip:- Refrain from employing labels as procedures; otherwise, you will definitely get a headache. The singular method to declare a procedure is as follows: `` commence with "printstring proc" and conclude with "end printstring" ``.
       printstring: -> This is a label not a procedure.
	    mov ah, 09h ;an instruction to print string stored in the data register(dx)
	    int 21h     ;a system interrupt to execute whatever is stored in ah
	    ret       

	Tip :- Always indent your inner label or procedure codes ( it makes it more readable )

	Helpful Suggestion :- In your future comments, rather than attempting to explain the code's functionality, it's preferable to solely articulate the code's intended actions.
*/
