[bits 16]
[org 0xA000]

; ##############################################################
; ## KAOS-MODULE
; ## name: modules32/pm32
; ## provides: pm32_start
; ## description:
; ##   16-bit real-mode stub at 0000:A000 that:
; ##     - hides the hardware cursor
; ##     - switches to 32-bit protected mode
; ##     - clears the screen
; ##     - prints "Welcome to KAOS" at (row 5, col 10) in bright green
; ##     - waits for F1 key (scancode 0x3B) via keyboard controller
; ##     - transitions to 16-bit protected mode
; ##     - switches back to real mode
; ##     - jumps directly back to the 16-bit menu at 0000:8000
; ##############################################################

CODE32_SEL equ 0x08
DATA32_SEL equ 0x10
CODE16_SEL equ 0x18
DATA16_SEL equ 0x20

; --------------------------------------------------------
; 16-bit real-mode entry at 0000:A000
; --------------------------------------------------------
pm32_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; ---- Hide cursor before switching to PM ----
    mov ah, 1
    mov ch, 0x20
    mov cl, 0x00
    int 0x10
    ; ---- End hide cursor ----

    ; Load GDT (contains 32-bit + 16-bit descriptors)
    lgdt [gdt_descriptor]

    ; Enable protected mode
    mov eax, cr0
    or  eax, 1            ; set PE
    mov cr0, eax

    ; Far jump into 32-bit code segment
    jmp CODE32_SEL:pm32_32
; ---- End pm32_start ----

; --------------------------------------------------------
; 32-bit protected-mode section
; --------------------------------------------------------
[bits 32]
pm32_32:
    ; Set up flat 32-bit segments
    mov ax, DATA32_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000      ; 32-bit stack

    ; ---- Clear screen via VGA memory ----
    mov edi, 0xB8000
    mov ax, 0x0720        ; ' ' with attribute 0x07 (white on black)
    mov ecx, 80*25
.clear_loop:
    mov [edi], ax
    add edi, 2
    loop .clear_loop
    ; ---- End clear screen ----

    ; ---- Print "Welcome to KAOS" at (row 5, col 10) in bright green ----
    mov esi, welcome32_msg
    mov edi, 0xB8000 + (5*80 + 10)*2
    mov bl, 0x0A          ; bright green on black

.print_welcome:
    lodsb
    test al, al
    jz .welcome_done
    mov ah, bl
    mov [edi], ax
    add edi, 2
    jmp .print_welcome

.welcome_done:
    ; ---- End welcome print ----

    ; ---- Wait for F1 using keyboard controller ----
.wait_key:
    in  al, 0x64
    test al, 1
    jz  .wait_key

    in  al, 0x60      ; read scancode
    cmp al, 0x3B      ; F1 key?
    jne .wait_key     ; ignore others
    ; ---- End wait_key ----

    ; ---- Drop back to 16-bit protected mode helper ----
    call switch_to_real_mode
    ; never returns

; --------------------------------------------------------
; 32-bit helper: switch to 16-bit PM, then real mode
; --------------------------------------------------------
switch_to_real_mode:
    cli

    ; Re-load GDT (same table)
    lgdt [gdt_descriptor]

    ; Far jump to 16-bit protected-mode entry
    jmp CODE16_SEL:pm16_entry
; ---- End switch_to_real_mode ----

; --------------------------------------------------------
; 16-bit protected-mode stub
; --------------------------------------------------------
[bits 16]
pm16_entry:
    ; Now in 16-bit protected mode
    mov ax, DATA16_SEL
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    ; Real-mode IDT (IVT at 0:0)
    lidt [idtr_real]

    ; Turn off protected mode (clear PE)
    mov eax, cr0
    and eax, 0xFFFFFFFE
    mov cr0, eax

    ; Far jump into true real mode, CS=0
    jmp 0x0000:real_mode_entry
; ---- End pm16_entry ----

; --------------------------------------------------------
; Real-mode entry after leaving protected mode
; --------------------------------------------------------
real_mode_entry:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov sp, 0x7C00        ; simple stack in low memory
    sti

    ; Jump directly back to the 16-bit State Machine menu
    jmp 0x0000:0x8000
; ---- End real_mode_entry ----

; --------------------------------------------------------
; Real-mode IDT descriptor (IVT at 0:0)
; --------------------------------------------------------
idtr_real:
    dw 0x03FF         ; limit = 0x400 bytes - 1 (256 vectors)
    dd 0x00000000     ; base  = 0x0000:0000
; ---- End idtr_real ----

; --------------------------------------------------------
; GDT: 32-bit and 16-bit descriptors
; --------------------------------------------------------
gdt_start:

gdt_null:
    dq 0

; 32-bit code segment: base=0, limit=4GB, 32-bit
gdt_code32:
    dw 0xFFFF          ; limit low
    dw 0x0000          ; base low
    db 0x00            ; base mid
    db 10011010b       ; code, ring0, present
    db 11001111b       ; gran=4K, 32-bit, limit high
    db 0x00            ; base high

; 32-bit data segment: base=0, limit=4GB, 32-bit
gdt_data32:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b       ; data, ring0, present
    db 11001111b       ; gran=4K, 32-bit
    db 0x00

; 16-bit code segment: base=0, limit=1MB, 16-bit
gdt_code16:
    dw 0xFFFF          ; limit low
    dw 0x0000          ; base low
    db 0x00            ; base mid
    db 10011010b       ; code, ring0, present
    db 00001111b       ; gran=1, 16-bit (G=1, D=0, limit high=0xF)
    db 0x00            ; base high

; 16-bit data segment: base=0, limit=1MB, 16-bit
gdt_data16:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b       ; data, ring0, present
    db 00001111b       ; gran=1, 16-bit
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start
; ---- End GDT ----

; --------------------------------------------------------
; Data
; --------------------------------------------------------
welcome32_msg db 'Welcome to KAOS', 0
; ---- End data ----

