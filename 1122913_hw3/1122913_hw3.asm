INCLUDE Irvine32.inc

.data
    promptPlain   BYTE "Enter plaintext: ", 0
    promptLen     BYTE "Enter random keyword length (L): ", 0
    msgModified   BYTE "Modified Plaintext: ", 0
    msgKey        BYTE "Key: ", 0
    msgEncrypt    BYTE "Encrypted Message (hex): ", 0
    msgDecrypt    BYTE "Decrypted Message: ", 0
    msgErrEmpty   BYTE "Error: Modified plaintext is empty.", 0dh,0ah, 0
    msgErrLen     BYTE "Error: L must be between 1 and modified plaintext length.", 0dh,0ah, 0

    spaceStr      BYTE " ", 0

    bufferSize    EQU 100
    plaintext     BYTE bufferSize DUP(0)
    modified      BYTE bufferSize DUP(0)
    keyword       BYTE bufferSize DUP(0)
    fullKey       BYTE bufferSize DUP(0)
    encrypted     BYTE bufferSize DUP(0)
    decrypted     BYTE bufferSize DUP(0)
    
    L_val         DWORD ?
    modLen        DWORD 0

.code

main PROC
    call PromptForValidPlaintext
    call FilterPlaintext
    call PromptForValidL
    call GenerateRandomKey
    call CreateFullKey
    call Encrypt
    call Decrypt
    exit
main ENDP

PromptForValidPlaintext PROC
    mov edx, OFFSET promptPlain
    call WriteString
    mov edx, OFFSET plaintext
    mov ecx, bufferSize
    call ReadString                 
    mov ecx, eax                    
    ret
PromptForValidPlaintext ENDP

FilterPlaintext PROC
    mov esi, OFFSET plaintext
    mov edi, OFFSET modified
    mov modLen, 0

L_Filter:
    cmp ecx, 0
    je E_Filter

    mov al, [esi]
    cmp al, ' '
    je Skip_Char
    cmp al, 27h                     
    je Skip_Char
    cmp al, ','
    je Skip_Char
    cmp al, '.'
    je Skip_Char

    mov [edi], al
    inc edi
    inc modLen

Skip_Char:
    inc esi
    dec ecx
    jmp L_Filter

E_Filter:
    mov BYTE PTR [edi], 0

    cmp modLen, 0
    jne ShowModified
    mov edx, OFFSET msgErrEmpty
    call WriteString
    exit

ShowModified:
    mov edx, OFFSET msgModified
    call WriteString
    mov edx, OFFSET modified
    call WriteString
    call Crlf
    ret
FilterPlaintext ENDP

PromptForValidL PROC
   
Read_L_Again:
    mov edx, OFFSET promptLen
    call WriteString
    call ReadInt
    mov L_val, eax

    cmp eax, 1
    jl InvalidLInput
    cmp eax, modLen
    jg InvalidLInput
    jmp ValidLInput

InvalidLInput:
    mov edx, OFFSET msgErrLen
    call WriteString
    jmp Read_L_Again

ValidLInput:
    ret
PromptForValidL ENDP

GenerateRandomKey PROC
    call Randomize
    mov ecx, L_val
    mov edi, OFFSET keyword

L_GenRand:
    mov eax, 5Eh                   
    call RandomRange               
    add eax, 21h                  
    mov [edi], al
    inc edi
    loop L_GenRand
    mov BYTE PTR [edi], 0
    ret
GenerateRandomKey ENDP

CreateFullKey PROC
  
    mov esi, OFFSET keyword
    mov edi, OFFSET fullKey
    mov ecx, L_val
    rep movsb
    
    mov ecx, modLen
    sub ecx, L_val                 
    jbe E_KeyGen
    mov esi, OFFSET modified
    rep movsb

E_KeyGen:
    mov BYTE PTR [edi], 0

    mov edx, OFFSET msgKey
    call WriteString
    mov edx, OFFSET fullKey
    call WriteString
    call Crlf
    ret
CreateFullKey ENDP

Encrypt PROC
    mov ecx, modLen
    mov esi, 0

L_Encrypt:
    cmp ecx, 0
    je E_Encrypt

    mov al, modified[esi]
    xor al, fullKey[esi]
    mov encrypted[esi], al

    inc esi
    dec ecx
    jmp L_Encrypt

E_Encrypt:
    mov BYTE PTR encrypted[esi], 0

    mov edx, OFFSET msgEncrypt
    call WriteString

    mov ecx, modLen
    mov esi, 0

L_PrintHex:
    cmp ecx, 0
    je E_PrintHex

    mov al, encrypted[esi]
    call WriteHexB

    mov edx, OFFSET spaceStr
    call WriteString

    inc esi
    dec ecx
    jmp L_PrintHex

E_PrintHex:
    call Crlf
    ret
Encrypt ENDP

Decrypt PROC
    mov ecx, L_val
    mov esi, 0

L_Decrypt_Part1:
    cmp ecx, 0
    je Start_Part2

    mov al, encrypted[esi]
    xor al, keyword[esi]
    mov decrypted[esi], al

    inc esi
    dec ecx
    jmp L_Decrypt_Part1

Start_Part2:
    mov ecx, modLen
    sub ecx, L_val
    jbe E_FinishDec

L_Decrypt_Part2:
    cmp ecx, 0
    je E_FinishDec

    mov al, encrypted[esi]

    mov ebx, esi
    sub ebx, L_val
    mov dl, decrypted[ebx]
    xor al, dl

    mov decrypted[esi], al
    inc esi
    dec ecx
    jmp L_Decrypt_Part2

E_FinishDec:
    mov BYTE PTR decrypted[esi], 0

    mov edx, OFFSET msgDecrypt
    call WriteString
    mov edx, OFFSET decrypted
    call WriteString
    call Crlf
    ret
Decrypt ENDP

END main