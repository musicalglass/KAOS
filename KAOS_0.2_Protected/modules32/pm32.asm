; ==============================================================
; FACTOID pm32.l2
; role:
;   Minimal protected-mode demonstration for KAOS Horizons LBA
;
; Behavior:
;   - Switch CPU into 32-bit protected mode
;   - Clear VGA text screen
;   - Print:
;       "Welcome to KAOS ☺"
;       "32 Bit Protected Mode enabled"
;   - Halt forever
;
; Lesson intent:
;   This is the first conscious step out of Real Mode and into
;   a larger, flatter reality. No keyboard. No return.
;   Pure enlightenment.
; ==============================================================

[bits 16]
[org 0xA000]

CODE32_SEL equ 0x08
DATA32_SEL equ 0x10
VID_MEM    equ 0xB8000

; --------------------------------------------------------------
; Enter protected mode
; --------------------------------------------------------------
pm32_start:
    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or  eax, 1
    mov cr0, eax

    jmp CODE32_SEL:pm32_entry


; ==============================================================
; 32-BIT CORE
; ==============================================================

[bits 32]
pm32_entry:
    mov ax, DATA32_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000

    ; ----------------------------------------------------------
    ; Clear screen (80x25 text mode)
    ; ----------------------------------------------------------
    mov edi, VID_MEM
    mov ax, 0x0720            ; ' ' + white on black
    mov ecx, 80*25
.clear_loop:
    mov [edi], ax
    add edi, 2
    loop .clear_loop

    ; ----------------------------------------------------------
    ; Print "Welcome to KAOS ☺"
    ; ----------------------------------------------------------
    mov edi, VID_MEM
    mov ax, 0x0A57            ; W
    stosw
    mov ax, 0x0A65            ; e
    stosw
    mov ax, 0x0A6C            ; l
    stosw
    mov ax, 0x0A63            ; c
    stosw
    mov ax, 0x0A6F            ; o
    stosw
    mov ax, 0x0A6D            ; m
    stosw
    mov ax, 0x0A65            ; e
    stosw
    mov ax, 0x0A20            ; space
    stosw
    mov ax, 0x0A74            ; t
    stosw
    mov ax, 0x0A6F            ; o
    stosw
    mov ax, 0x0A20            ; space
    stosw
    mov ax, 0x0A4B            ; K
    stosw
    mov ax, 0x0A41            ; A
    stosw
    mov ax, 0x0A4F            ; O
    stosw
    mov ax, 0x0A53            ; S
    stosw
    mov ax, 0x0A20            ; space
    stosw
    mov ax, 0x0A02            ; ☺ (CP437)
    stosw

    ; ----------------------------------------------------------
    ; Move to next line (row 1)
    ; ----------------------------------------------------------
    mov edi, VID_MEM + (80 * 2)

    ; ----------------------------------------------------------
    ; Print "32 Bit Protected Mode enabled"
    ; ----------------------------------------------------------
    mov esi, msg_pm32
.print_loop:
    lodsb
    test al, al
    jz .done_print
    mov ah, 0x0A              ; bright green
    stosw
    jmp .print_loop

.done_print:
.hang:
    hlt
    jmp .hang


; ==============================================================
; DATA
; ==============================================================

msg_pm32 db '32 Bit Protected Mode enabled',0


; ==============================================================
; GDT
; ==============================================================

gdt_start:
gdt_null:
    dq 0

gdt_code32:
    dw 0xFFFF, 0
    db 0
    db 10011010b
    db 11001111b
    db 0

gdt_data32:
    dw 0xFFFF, 0
    db 0
    db 10010010b
    db 11001111b
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; ------- End FACTOID pm32.l2 -------
