; ==============================================================
; FACTOID prog16.l1
; Minimal 16-bit KAOS demo (Lesson 1)
; - Loaded by menu16 at 0000:9000 from LBA 5
; - Clears screen, prints message, waits for F1 or F2
; - F1 → return to menu (0000:8000)
; - F2 → reload self from LBA 5
; ==============================================================

[bits 16]
[org 0x9000]

start16:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Clear screen (mode 3)
    mov ax, 0x0003
    int 0x10

; ---- Flush stale scancodes ----
.flush_kbd:
    in   al, 0x64
    test al, 1
    jz   .flush_done
    in   al, 0x60      ; discard byte
    jmp  .flush_kbd
.flush_done:

    ; Print title
    mov si, msg_title
    call print_string

    ; Newline
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
	mov al, 10
    int 0x10

    ; Hint
    mov si, msg_hint
    call print_string

; Wait for key
.wait_key:
    in  al, 0x64
    test al, 1
    jz  .wait_key
    in  al, 0x60
    cmp al, 0x3B     ; F1
    je  .return_to_menu
    cmp al, 0x3C     ; F2
    je  .reload_self
    jmp .wait_key

.return_to_menu:
    jmp 0x0000:0x8000

.reload_self:
    ; INT 13h extensions to read from LBA 5 into 0000:9000
    mov ah, 0x42
    mov dl, 0x80
    mov si, lba_packet
    int 0x13
    jc .disk_error
    jmp 0x0000:0x9000

.disk_error:
    mov si, msg_err
    call print_string
    jmp $

; --------------------------------------------------------
; print_string: DS:SI → zero-terminated, BIOS teletype
; --------------------------------------------------------
print_string:
.ps_loop:
    lodsb
    cmp al, 0
    je  .done
    mov ah, 0x0E
    int 0x10
    jmp .ps_loop
.done:
    ret

; --------------------------------------------------------
; LBA read packet
; --------------------------------------------------------
lba_packet:
    db 0x10              ; size
    db 0x00              ; reserved
    dw 1                 ; 1 sector
    dw 0x9000            ; offset
    dw 0x0000            ; segment
    dq 5                 ; LBA 5

; --------------------------------------------------------
; Messages
; --------------------------------------------------------
msg_title db ' KAOS 16 Bit Application', 0
msg_hint  db ' Press F1 to return to KAOS menu', 0
msg_err   db ' Disk error during reload', 0

; ===== END FACTOID prog16.l1 (string version) =====
