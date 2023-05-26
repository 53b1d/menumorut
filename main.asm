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
x           DB  ?
x0          DB  ?
a           db  0
b           db  0
alfabet     DB  'Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW4ly5EkrqsnAxubTV03a=L/d'
firstname   DB  'Dragos'
lenName     DB  $-firstname
surname     DB  'Ioana'
lenSurname  DB  $-surname
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

    ;mov     ah, 2Ch                    ; BIOS Int - Get System Time
    ;int     21h
                                        ; calcul 60 * (60 * ch + cl) + dh
    mov ch, 0eh
    mov cl, 17h
    mov dh, 26h
    mov dl, 4CH

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
    mov [x0], al                           ; calcul (60 * (60 * ch + cl) + dh) * 100 + dl mod ffh
    mov [x], al
    xor al, al
    xor cx, cx
    xor dx, dx
    RET

compute_a:
    mov si, offset firstname
    mov cl, lenName
	call sum_a
    mov [a], al
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
    mov [b], al
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
    call compute_encrypt
    xor ax, ax
    RET

compute_encrypt:
    mov al, [x]
    mov ah, byte ptr [si]
    xor ah, al
    mov byte ptr [si], ah
    inc si
    call RAND
    loop compute_encrypt
    ret

RAND:

    mov al, [x]
                                            ; TODO2: Completati subrutina RAND, astfel incat
                                            ; in cadrul acesteia va fi calculat termenul
                                            ; de rang n pe baza coeficientilor a, b si a 
                                            ; termenului de rang inferior (n-1) si salvat
                                            ; in cadrul variabilei 'x'

    mov bh, [a]
    mul bh
    div bl
    xchg ah, al
    xor ah, ah
    add al, [b]
    div bl
    xchg ah, al
    xor ah, ah
    mov [x], al
    RET

ENCODE:
                                            ; TODO4: Completati subrutina ENCODE, astfel incat
                                            ; in cadrul acesteia va fi realizata codificarea
                                            ; sirului criptat pe baza alfabetului COD64 mentionat
                                            ; in enuntul problemei si rezultatul va fi stocat
                                            ; in cadrul variabilei encoded
    call compute_padding
    call compute_encode

    ret


compute_encode:
    mov si, offset message
    mov di, offset encoded
    xor ax, ax
    call loop_encode

    ret

loop_encode:
    mov al, byte ptr [si]           ;extragem in al primul octet din sirul criptat
    mov dl, 3h                      ;masca pentru lsb 2 biti
    and dl, al                      ;extragem lsb 2 biti din octet
    shr al, 2                       ;extragem msb 6 biti din octet
    mov bx, offset alfabet          ;accesam alfabetul pentru codificare
    add bx, ax                      ;accesam caracterul corespunzator msb 6 biti din primul caracter
    mov ax, [bx]  
    mov byte ptr [di], al           ;scriem caracterul codificat
    inc di                          ;urmatorul caracter codificat scris
    shl dl, 4                       ;shiftam cu 4 biti la stanga cei 2 biti ramasi din primul octet pentru a face loc celor 4 biti din urmatorul octet al sirului criptat
    inc si 
    mov al, byte ptr [si]           ;extragem urmatorul octet
    mov dh, 0F0h                    ;masca pentru msb 4 biti din octet
    and dh, al                      ;extragem msb 4 biti din octetul 2
    mov ah, 15                      ;masca pentru lsb 4 biti
    and ah, al                      ;extragem lsb 4 biti
    shr dh, 4
    or dl, dh                       ;compunem urmatorul cuvant de 6 biti
    xor dh, dh                      ;curatam dh
    mov bx, offset alfabet
    add bx, dx
    mov dx, [bx]
    mov byte ptr [di], dl           ;codificam
    inc si
    inc di
    mov al, byte ptr [si] 
    shl ah, 2                       ;shiftam cu 2
    mov dl, 0c0h
    and dl, al                      ;extragem msb 2 biti
    shl dl, 6                       ;shift 
    or dl, ah
    xor dh, dh
    mov bx, offset alfabet
    add bx, dx
    mov dx, [bx]
    mov byte ptr [di], dl
    inc di
    shl al, 2
    shr al, 2
    xor ah, ah
    mov bx, offset alfabet
    add bx, ax
    mov ax, [bx]
    mov byte ptr [di], al
    inc di
    inc si
    xor ax, ax
    ; neterminat
    ret

compute_padding:
    ; vom calcula numarul de octeti al string-ului codificat utilizand
    ; bytes * 8 + (6 - bytes % 6) / 6, bytes = numarul de octeti al string-ului de input
    mov cx, [msglen]
    mov ax, cx
    mov bl, 8
    mul bl
    mov dl, al
    mov bl, 6
    div bl
    xchg ah, al
    mov ah, 6
    sub ah, al
    mov [padding], ah
    add dl, ah
    xor ah, ah
    mov al, dl 
    div bl
    mov byte ptr [iterations], al
    mov cx, [iterations]
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

    MOV     AX, [iterations]
    MOV     BX, 4
    MUL     BX
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