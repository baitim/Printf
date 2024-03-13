; nasm -f elf64 printf.asm -o printf.o
; gcc -no-pie main.c printf.o -o main
; ./main
section .data
Number db 65 dup 0
Minus db '-'

SwitchByte:     dq SwitchBreak           ; a
                dq SwitchBin             ; b
                dq SwitchChar            ; c
                dq SwitchDec             ; d
                dq SwitchBreak           ; e
                dq SwitchBreak           ; f
                dq SwitchBreak           ; g
                dq SwitchBreak           ; h
                dq SwitchBreak           ; i
                dq SwitchBreak           ; g
                dq SwitchBreak           ; k
                dq SwitchBreak           ; l
                dq SwitchBreak           ; m
                dq SwitchBreak           ; n
                dq SwitchOct             ; o
                dq SwitchBreak           ; p
                dq SwitchBreak           ; q
                dq SwitchBreak           ; r
                dq SwitchStr             ; s
                dq SwitchBreak           ; t
                dq SwitchBreak           ; u
                dq SwitchBreak           ; v
                dq SwitchBreak           ; w
                dq SwitchHex             ; x
                dq SwitchBreak           ; y
                dq SwitchBreak           ; z

section .bss
%define SYS_write 1
%define SYS_exit 60

section .text

;-----------------------------------------
; Print string like printf in C
; Assumes: rdi - string
; Entry:
;       rdi - 1 arg(string)
;       rsi - 2 arg
;       rdx - 3 arg
;       rcx - 4 arg
;       r8  - 5 arg
;       r9  - 6 arg
;       stack - next args
; Destr: a lot(
; Return: rax
;-----------------------------------------
global printf
printf:     
            pop r12
            push r9
            push r8
            push rcx
            push rdx
            push rsi

            push rbp

            mov rsi, rdi
            mov rbp, rsp
            add rbp, 8      ; was push rbp   
            xor r8, r8

            .Next:
                mov r8b, byte [rsi]
                cmp r8b, 0x00
                je .End

                cmp r8b, '%'
                je .Arg

                call Putc
                inc rsi
                jmp .Next

                .Arg:
                inc rsi
                mov r8b, byte [rsi]
                call PrintArg
                inc rsi
                jmp .Next
            .End:

            pop rbp

            pop rsi
            pop rdx
            pop rcx
            pop r8
            pop r9
            push r12
            ret
        
;---------------------------------------------------------------
; check byte after % and calls functions by Switch
; Entry: r8b - byte
;        rbp - stack pointer
; Destr: r10, rbp, r9, r8
;---------------------------------------------------------------
PrintArg:   
            cmp r8b, '%'                   
            jne .Arg
            call Putc
            call Putc
            ret

            .Arg:
            sub r8b, 'a'
            shl r8b, 3
            push rsi
            mov r10, [SwitchByte + r8]
            jmp r10

            SwitchChar:
                mov rsi, rbp
                call Putc
                jmp SwitchBreak

            SwitchStr:
                mov rsi, [rbp]
                call Puts
                jmp SwitchBreak

            SwitchDec:
                mov rax, [rbp]
                mov r9, 10
                call PutNum
                jmp SwitchBreak
                
            SwitchBin:
                mov rax, [rbp]
                mov r9, 2
                call PutNum
                jmp SwitchBreak

            SwitchOct:
                mov rax, [rbp]
                mov r9, 8
                call PutNum
                jmp SwitchBreak

            SwitchHex:
                mov rax, [rbp]
                mov r9, 16
                call PutNum
                jmp SwitchBreak

            SwitchBreak:

            pop rsi
            add rbp, 8
            ret

;---------------------------------------------------------------
; print byte from rsi to stdout
; Entry: rsi - ptr of buffer
; Assumes: 
; Destr: rax, rdi, rdx
;---------------------------------------------------------------
Putc:       
            mov rax, SYS_write
            mov rdi, 1
            mov rdx, 1   
            syscall
            ret

;---------------------------------------------------------------
; print string until separator('\0')
; Entry: rsi - ptr of buffer
; Assumes:
; Destr: rax, rdi, rdx, rsi, r8b
;---------------------------------------------------------------
Puts:    
            .Next:
                mov r8b, byte [rsi]
                cmp r8b, 0x00
                je .End
                call Putc
                inc rsi
                jmp .Next
            .End:

            ret

;---------------------------------------------------------------
; print num, which system of calculation less then 10
; Entry: rax - number
;        r9 - foundation of system of calculation
; Assumes:
; Destr: rax, rdi, rdx, rsi, r10
;---------------------------------------------------------------
PutNum:              

        cmp r9, 10
        jne .Start
        cmp rax, 0
        jge .Start
        push rax
        mov rsi, Minus
        call Putc
        pop rax
        neg rax
        .Start:
        xor r10, r10
        .Next:
            xor rdx, rdx
            div r9
            cmp dl, 10
            jl .Digit
            add rdx, 'A'
            sub rdx, 10
            jmp .Write
            .Digit:
            add rdx, '0'
            .Write:
            mov byte [Number + r10], dl
            inc r10
            cmp rax, 0
            je .End
            jmp .Next
        .End:
        call _PutNum
        ret

;---------------------------------------------------------------
; print [Number]
; Entry: r10 - count of digits
; Assumes:
; Destr: rsi, r10, rax, rdi, rdx
;---------------------------------------------------------------
_PutNum:              

        mov rsi, Number
        add rsi, r10
        dec rsi

        .Next:
            call Putc
            dec rsi
            dec r10
            cmp r10, 0
            je .End
            jmp .Next
        .End:

        ret