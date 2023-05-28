    DOSSEG
    .MODEL SMALL
    .STACK 32
    .DATA
encoded     DB  80 DUP(0)
temp        DB  '0x', 160 DUP(0)
fileHandler DW  ?
filename    DB  'in/in.txt', 0              ; Trebuie sa existe acest fisier 'in/in.txt'!
outfile     DB  'out/out.txt', 0            ; Trebuie sa existe acest director 'out'!
message     DB  80 DUP(0)
msglen      DW  ?
padding     DB  0
iterations  DW  0 
x           Dw  ?
x0          Dw  ?
a           dw  0
b           dw  0
alfabet     DB  'Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW4ly5EkrqsnAxubTV03a=L/d'
firstname   DB  'Dragos'
lenName     DB  $-firstname
surname     DB  'Ioana'
lenSurname  DB  $-surname
_word       dw  0
output_length dw 0
    .CODE
START:
    MOV     AX, @DATA
    MOV     DS, AX

    CALL    FILE_INPUT                      ; NU MODIFICATI!

    CALL    SEED                            

    CALL    compute_a

    CALL    compute_b

    CALL    ENCRYPT                         
    
    CALL    ENCODE                          ; TODO - Trebuie implementata
    
                                            ; Mai jos se regaseste partea de
                                            ; afisare pe baza valorilor care se
                                            ; afla in variabilele x0, a, b, respectiv
                                            ; in sirurile message si encoded.
                                            ; NU MODIFICATI!
    MOV     AH, 3CH                         ; BIOS Int - Open file
    MOV     CX, 0
    MOV     AL, 1                           ; AL - Access mode ( Write - 1 )
    MOV     DX, OFFSET outfile              ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX               ; Return: AX - file handler or error code

    CALL    WRITE                           ; NU MODIFICATI!

    MOV     AH, 4CH                         ; Bios Int - Terminate with return code
    MOV     AL, 0                           ; AL - Return code
    INT     21H
FILE_INPUT:
    MOV     AH, 3DH                         ; BIOS Int - Open file
    MOV     AL, 0                           ; AL - Access mode ( Read - 0 )
    MOV     DX, OFFSET fileName             ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX               ; Return: AX - file handler or error code

    MOV     AH, 3FH                         ; BIOD Int - Read from file or device
    MOV     BX, [fileHandler]               ; BX - File handler
    MOV     CX, 80                          ; CX - Number of bytes to read
    MOV     DX, OFFSET message              ; DX - Data buffer
    INT     21H
    MOV     [msglen], AX                    ; Return: AX - number of read bytes

    MOV     AH, 3EH                         ; BIOS Int - Close file
    MOV     BX, [fileHandler]               ; BX - File handler
    INT     21H

    RET

SEED:
                                            ; TODO1: Completati subrutina SEED
                                            ; astfel incat la final sa fie salvat
                                            ; in variabila 'x' si 'x0' continutul 
                                        ; termenului initial

    mov     ah, 2Ch                    ; BIOS Int - Get System Time
    int     21h
                                        ; calcul 60 * (60 * ch + cl) + dh
    ;mov ch, 0eh
    ;mov cl, 17h
    ;mov dh, 26h
    ;mov dl, 4CH

    xor ax, ax
    xor bx, bx

    mov bl, 3ch                     ; 60
    xchg al, ch                     ;
    mul bl                          ; 60 * ch
    mov bl, 0FFh
    div bl                          ; (60 * ch) % 255
    xchg ah, al
    xor ah, ah 
    add ax, cx                      ; (60 * ch) % 255 + cl
    div bl                          ; ((60 * ch) % 255 + cl) % 255
    xchg ah, al
    xor ah, ah
    mov bl, 3ch                          
    mul bl                          ; calcul 60 * (((60 * ch) % 255 + cl) % 255)
    mov bl, 0FFh
    div bl
    xchg ah, al
    xor ah, ah
                                    ; calcul 60 * (60 * ch + cl) % 255                              
    mov bh, dl                      ; salvez dl
    xor dl, dl                      ; golesc dl
    xchg dl, dh
    add ax, dx                      ; + dh
    div bl                          ; % 255
    xchg ah, al
    xor ah, ah
    mov bl, 64h
    mul bl                          
    mov bl, 0FFh
    div bl
    xchg ah, al
    xor ah, ah
    xor dx, dx
    mov dl, bh
    add ax, dx
    div bl
    xchg ah, al
    xor ah, ah 
    mov [x0], ax                           ; calcul (60 * (60 * ch + cl) + dh) * 100 + dl mod ffh
    mov [x], ax
    xor al, al
    xor cx, cx
    xor dx, dx
    RET

compute_a:
    mov si, offset firstname
    mov cl, lenName
	call sum_a
    mov [a], ax
    xor ax, ax
    ret

sum_a:
    mov dl, byte ptr [si]
    add ax, dx
    div bl
    xchg ah, al
    xor ah, ah
    inc si
    loop sum_a
    ret

compute_b:
    xor ax, ax
    xor dx, dx
    mov si, offset surname
    mov cl, lenSurname
	call sum_b
    mov [b], ax
    xor ax, ax
    ret

sum_b:
    mov dl, byte ptr [si]
    add ax, dx
    div bl
    xchg ah, al
    xor ah, ah
    inc si
    loop sum_b
    ret

ENCRYPT:
    MOV     CX, [msglen]
    MOV     SI, OFFSET message
                                            ; TODO3: Completati subrutina ENCRYPT
                                            ; astfel incat in cadrul buclei sa fie
                                            ; XOR-at elementul curent din sirul de
                                            ; intrare cu termenul corespunzator din
                                            ; sirul generat, iar mai apoi sa fie generat
                                            ; si termenul urmator
    mov ax, [x0]
    call compute_encrypt
    ret

compute_encrypt:
    mov [x], ax
    mov ax, [x]
    mov ah, byte ptr [si]
    xor ah, al
    mov byte ptr [si], ah
    inc si
    call RAND
    loop compute_encrypt
    ret

RAND:
    mov ax, [x]
                                            ; TODO2: Completati subrutina RAND, astfel incat
                                            ; in cadrul acesteia va fi calculat termenul
                                            ; de rang n pe baza coeficientilor a, b si a 
                                            ; termenului de rang inferior (n-1) si salvat
                                            ; in cadrul variabilei 'x'
    mov bx, [a]
    mul bl
    mov bl, 0ffh
    div bl
    xchg ah, al
    xor ah, ah
    add ax, [b]
    div bl
    xchg ah, al
    xor ah, ah
    ret

ENCODE:
                                            ; TODO4: Completati subrutina ENCODE, astfel incat
                                            ; in cadrul acesteia va fi realizata codificarea
                                            ; sirului criptat pe baza alfabetului COD64 mentionat
                                            ; in enuntul problemei si rezultatul va fi stocat
                                            ; in cadrul variabilei encoded
    xor ax, ax
    call compute_padding
    call compute_encode
    ret

compute_padding:
    mov ax, [msglen]
    mov bl, 3
    div bl
    mov [padding], 3
    sub [padding], ah
    mov byte ptr [iterations], al
    ret

compute_encode:
    mov si, offset message
    mov di, offset encoded
    mov cx, [iterations]
    call loop_encode
    cmp [padding], 0
    jnz add_padding
    ret

loop_encode:
    mov ah, byte ptr [si]           
    inc si
    mov al, byte ptr [si]
    inc si
    call case1
    call case2
    mov ah, al
    mov al, byte ptr [si]
    inc si
    call case3
    call case4
    xor ax, ax                 
    loop loop_encode 
    mov cl, [padding] 
    ret      

add_padding:
    mov ah, byte ptr [si]
    inc si
    mov al, byte ptr [si]
    inc si
    call case1
    call case2
    cmp [padding], 2
    jz complete_padding
    mov ah, al
    mov al, byte ptr [si]
    inc si
    call case3
    cmp [padding], 1
    jz complete_padding
    ret

complete_padding:
    mov bl, '+' 
    mov byte ptr [di], bl
    inc di
    inc [output_length]
    loop complete_padding
    ret

case1:
    mov [_word], 0fc00h           ; extragem primul cuvant
    and [_word], ax               
    shr [_word], 10
    call write_encoded
    ret
case2:
    mov [_word], 03f0h
    and [_word], ax
    shr [_word], 4
    call write_encoded
    ret
case3:
    mov [_word], 0fc0h
    and [_word], ax
    shr [_word], 6
    call write_encoded
    ret

case4:
    mov [_word], 3fh
    and [_word], ax
    call write_encoded
    ret

write_encoded:
    mov bx, offset alfabet
    mov dx, [_word]
    add bx, dx
    mov dx, [bx]
    mov byte ptr [di], dl
    inc di
    inc [output_length]
    ret

WRITE_HEX:
    MOV     DI, OFFSET temp + 2
    XOR     DX, DX
DUMP:
    MOV     DL, [SI]
    PUSH    CX
    MOV     CL, 4

    ROR     DX, CL
    
    CMP     DL, 0ah
    JB      print_digit1

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     next_digit

print_digit1:  
    OR      DL, 30h
    MOV     byte ptr [DI] ,DL
next_digit:
    INC     DI
    MOV     CL, 12
    SHR     DX, CL
    CMP     DL, 0ah
    JB      print_digit2

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     AGAIN

print_digit2:    
    OR      DL, 30h
    MOV     byte ptr [DI], DL
AGAIN:
    INC     DI
    INC     SI
    POP     CX
    LOOP    dump
    
    MOV     byte ptr [DI], 10
    RET
WRITE:
    MOV     SI, OFFSET x0
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21h

    MOV     SI, OFFSET a
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET b
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET x
    MOV     CX, 1
    CALL    WRITE_HEX    
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET message
    MOV     CX, [msglen]
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, [msglen]
    ADD     CX, [msglen]
    ADD     CX, 3
    INT     21h

    MOV     AX, [output_length]
    MOV     CX, AX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET encoded
    INT     21H

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H
    RET
    END START