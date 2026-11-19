; Two-number arithmetic - MASM, Win32, Irvine32
; Input: two signed integers from -32768 to 32767.
; Calculate in 32 bits; display AX/BX/CX/DX (the low 16 bits).

INCLUDE Irvine32.inc

.data
    titleText BYTE "Two-number arithmetic",0Dh,0Ah,
                   "Input range: -32768 to 32767",0Dh,0Ah,
                   "Registers: AX/BX/CX/DX in hexadecimal (low 16 bits)",
                   0Dh,0Ah,0Dh,0Ah,0
    firstPrompt BYTE "First number: ",0
    secondPrompt BYTE "Second number: ",0
    inputError BYTE "Enter an integer from -32768 to 32767.",0Dh,0Ah,0

    addText BYTE "Addition: ",0
    subText BYTE "Subtraction: ",0
    mulText BYTE "Multiplication: ",0
    divText BYTE "Division - quotient: ",0
    remainderText BYTE "  remainder: ",0
    zeroText BYTE "Division: cannot divide by zero.",0Dh,0Ah,0
    exitText BYTE "Press any key to exit...",0

    axText BYTE "  AX=",0
    bxText BYTE "  BX=",0
    cxText BYTE "  CX=",0
    dxText BYTE "  DX=",0

    firstNumber SDWORD ?
    secondNumber SDWORD ?
    resultValue SDWORD ?
    remainderValue SDWORD ?
    savedAX WORD ?
    savedBX WORD ?
    savedCX WORD ?
    savedDX WORD ?

.code
main PROC
    mov edx, OFFSET titleText
    call WriteString

    mov edx, OFFSET firstPrompt
    call ReadNumber
    mov firstNumber, eax

    mov edx, OFFSET secondPrompt
    call ReadNumber
    mov secondNumber, eax
    call Crlf

    ; Addition
    call LoadNumbers
    add eax, ebx
    call SaveRegisters
    mov edx, OFFSET addText
    call PrintResult

    ; Subtraction: first number - second number
    call LoadNumbers
    sub eax, ebx
    call SaveRegisters
    mov edx, OFFSET subText
    call PrintResult

    ; Signed multiplication: EDX:EAX = EAX * EBX
    call LoadNumbers
    imul ebx
    call SaveRegisters
    mov edx, OFFSET mulText
    call PrintResult

    ; Signed integer division: EAX = quotient, EDX = remainder
    call LoadNumbers
    cmp ebx, 0
    je DivideByZero
    cdq
    idiv ebx
    call SaveRegisters

    mov edx, OFFSET divText
    call WriteString
    mov eax, resultValue
    call WriteInt
    mov edx, OFFSET remainderText
    call WriteString
    mov eax, remainderValue
    call WriteInt
    call Crlf
    call ShowRegisters
    call Crlf
    jmp Finish

DivideByZero:
    ; No IDIV is executed. Show the registers prepared for division.
    call SaveRegisters
    mov edx, OFFSET zeroText
    call WriteString
    call ShowRegisters
    call Crlf

Finish:
    mov edx, OFFSET exitText
    call WriteString
    call ReadChar
    exit
main ENDP

; EDX = prompt address. EAX = valid input on return.
ReadNumber PROC USES esi edx
    mov esi, edx
ReadAgain:
    mov edx, esi
    call WriteString
    call ReadInt
    jo InvalidNumber
    cmp eax, -32768
    jl InvalidNumber
    cmp eax, 32767
    jg InvalidNumber
    ret
InvalidNumber:
    mov edx, OFFSET inputError
    call WriteString
    jmp ReadAgain
ReadNumber ENDP

; Start each operation from the original two inputs.
; ECX keeps the first input. EDX starts at zero.
LoadNumbers PROC
    mov eax, firstNumber
    mov ebx, secondNumber
    mov ecx, eax
    xor edx, edx
    ret
LoadNumbers ENDP

; Snapshot BEFORE printing changes registers such as EDX.
SaveRegisters PROC
    mov savedAX, ax
    mov savedBX, bx
    mov savedCX, cx
    mov savedDX, dx
    mov resultValue, eax
    mov remainderValue, edx
    ret
SaveRegisters ENDP

; EDX = result label. Display the saved signed 32-bit result.
PrintResult PROC
    call WriteString
    mov eax, resultValue
    call WriteInt
    call Crlf
    call ShowRegisters
    call Crlf
    ret
PrintResult ENDP

; Four hexadecimal digits per register, as requested (16 bits).
ShowRegisters PROC USES eax ebx ecx edx
    mov edx, OFFSET axText
    call WriteString
    movzx eax, savedAX
    mov ebx, TYPE WORD
    call WriteHexB

    mov edx, OFFSET bxText
    call WriteString
    movzx eax, savedBX
    mov ebx, TYPE WORD
    call WriteHexB

    mov edx, OFFSET cxText
    call WriteString
    movzx eax, savedCX
    mov ebx, TYPE WORD
    call WriteHexB

    mov edx, OFFSET dxText
    call WriteString
    movzx eax, savedDX
    mov ebx, TYPE WORD
    call WriteHexB
    call Crlf
    ret
ShowRegisters ENDP

END main
