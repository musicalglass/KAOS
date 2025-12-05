[bits 16]
[org 0x9000]

; --------------------------------------------------------
; prog16.asm  -> prog16.bin
; Simple 16-bit KAOS demo at 0000:9000
; --------------------------------------------------------
; - Clears the screen
; - Prints "16-BIT KAOS MODE"
; - Prints a hint: "Press F1 to return to KAOS menu."
; - Waits for F1 (scancode 0x3B) via keyboard controller
; - Jumps back to KAOS menu at 0000:8000
; --------------------------------------------------------

start16:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Clear screen
    mov ax, 0x0003
    int 0x10

    ; Print "16-BIT KAOS MODE"
    mov ah, 0x0E
    mov al, '1'
    int 0x10
    mov al, '6'
    int 0x10
    mov al, '-'
    int 0x10
    mov al, 'B'
    int 0x10
    mov al, 'I'
    int 0x10
    mov al, 'T'
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'K'
    int 0x10
    mov al, 'A'
    int 0x10
    mov al, 'O'
    int 0x10
    mov al, 'S'
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'M'
    int 0x10
    mov al, 'O'
    int 0x10
    mov al, 'D'
    int 0x10
    mov al, 'E'
    int 0x10

    ; Newline
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10

    ; Instruction line
    mov si, msg_16_hint
    call print_string

.wait_f1:
    ; Wait for F1 key using keyboard controller
    in  al, 0x64
    test al, 1
    jz  .wait_f1
    in  al, 0x60          ; read scancode
    cmp al, 0x3B          ; F1 scancode
    jne .wait_f1

    ; Jump back to KAOS menu
    jmp 0x0000:0x8000

; ---- print_string: DS:SI -> zero-terminated ----
print_string:
.ps_loop:
    lodsb
    cmp al, 0
    je .ps_done
    mov ah, 0x0E
    int 0x10
    jmp .ps_loop
.ps_done:
    ret
; ---- End print_string ----

msg_16_hint db 'Press F1 to return to KAOS menu.', 0
