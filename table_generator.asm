.model small
.stack 100h

.data

    msg2 db 'Enter the number of rows: $'
    col db ?
    row db ? 
    col_val db ?
    row_val db ?


.code 

    mov ax, @data
    mov ds, ax
             
         
    ; Ask for the number of rows
    mov ah, 09h
    lea dx, msg2
    int 21h

    ; Read the number of rows
    mov ah, 01h
    int 21h
    sub al, 30h
    mov row, al

    ; Store the values in memory
    mov ah, 0
    mov al, row
    mov [row_val], al

    ; Call the C++ program
    mov ax, 4C00h
    int 21h


end
