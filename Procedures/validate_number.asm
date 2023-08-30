;-------------------------------------------------------------------
; Procedure for validating a number.
; ----------------------------------
; - Registers used: AX, BX, CX, DX -
;-------------------------------------------------------------------

CODE SEGMENT
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
				RET

			
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
		LEA SI, to_be_validated
		LEA DI, to_be_validated_duplicate
		CALL make_duplicate


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
				JE go_to_next_element_in_to_be_validated
				CMP ah, al
				JE increment_if_same
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
			JE no_repetitions_exist
			JNE repetitions_exist

			no_repetitions_exist:
				MOV is_valid, 1
				RET

			repetitions_exist:
				MOV is_valid, 0
		
		RET

	check_repeating_digit ENDP
ENDS CODE