; ==============================================================
; FACTOID menu16.l2
; role:
;   Minimal KAOS real-mode launcher
;   - Displays title text
;   - Waits for F3 BREAK (release)
;   - Loads 32-bit PM payload via LBA
;   - Jumps to protected-mode entry
;
; Lesson 2 scope:
;   * No 16-bit program
;   * No menu navigation
;   * No return path
; ==============================================================

[bits 16]
[org 0x8000]

start_menu:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [BootDrive], dl

    ; Clear screen
    mov ax, 0x0003
    int 0x10

    ; Hide cursor
    mov ah, 0x01
    mov ch, 0x20
    mov cl, 0x00
    int 0x10

    ; Print banner
    mov si, msg_title
    call print_string

.wait_key:
    in  al, 0x64
    test al, 1
    jz  .wait_key

    in  al, 0x60
    cmp al, 0xBD          ; F3 BREAK
    jne .wait_key

; --------------------------------------------------------------
; Load PM32 payload (LBA → 0000:A000)
; --------------------------------------------------------------
load_pm32:
    mov byte [DAP],     16
    mov byte [DAP+1],   0
    mov word [DAP+2],   8           ; sectors
    mov word [DAP+4],   0xA000
    mov word [DAP+6],   0x0000
    mov dword [DAP+8],  9           ; LBA start
    mov dword [DAP+12], 0

    mov si, DAP
    mov dl, [BootDrive]
    mov ah, 0x42
    int 0x13
    jc  disk_fail

    jmp 0x0000:0xA000

disk_fail:
    mov ah, 0x0E
    mov al, '!'
.err:
    int 0x10
    jmp .err

; --------------------------------------------------------------
; Helpers
; --------------------------------------------------------------
print_string:
.ps:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .ps
.done:
    ret

; --------------------------------------------------------------
; Data
; --------------------------------------------------------------
BootDrive db 0

msg_title db 'KAOS LBA Lesson 2 - Press F3 to enter Protected Mode',13,10,0

DAP:
    db 0,0
    dw 0,0,0
    dd 0,0

; ------- End FACTOID menu16.l2 -------
