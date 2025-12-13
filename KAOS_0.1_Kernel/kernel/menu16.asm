; ==============================================================
; FACTOID menu16.l1
; KAOS BASELINE – LESSON 1
; --------------------------------------------------------------
; role:
;   16-bit real-mode KAOS menu kernel.
;
; responsibilities:
;   - Runs at physical address 0000:8000
;   - Displays a simple text menu
;   - Waits for keyboard input via PS/2 controller
;   - Launches a 16-bit demo program when F2 is released
;
; control flow:
;   BIOS → boot16.asm → menu16.asm → prog16.asm → menu16.asm
;
; return path:
;   prog16.asm returns here via:
;       jmp 0000:8000
;
; assumptions:
;   - boot16.asm loaded this code from disk (INT 13h)
;   - CPU is in 16-bit real mode
;   - DS = ES = SS = 0x0000
;
; lesson focus:
;   - Keyboard scancodes (MAKE vs BREAK)
;   - Polling the keyboard controller
;   - Far jumps vs near jumps
; ==============================================================

[bits 16]
[org 0x8000]

; --------------------------------------------------------------
; Constants
; --------------------------------------------------------------
OPTION_RUN16 equ 1


; --------------------------------------------------------------
; Entry point from boot16.asm
; --------------------------------------------------------------
start_menu:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; BIOS passes boot drive in DL
    mov [BootDrive], dl

    ; Set text mode and clear screen
    mov ax, 0x0003
    int 0x10

    ; Hide the blinking cursor
    mov ah, 1
    mov ch, 0x20
    mov cl, 0x00
    int 0x10

    call draw_menu


; --------------------------------------------------------------
; Main menu input loop
; Polls the PS/2 controller directly.
;
; We trigger on F2 *BREAK* (key release),
; not MAKE, to avoid auto-repeat issues.
; --------------------------------------------------------------
.menu_loop:
    in  al, 0x64        ; keyboard status port
    test al, 1
    jz  .menu_loop      ; no scancode available

    in  al, 0x60        ; read scancode

    cmp al, 0xBC        ; F2 BREAK (0x3C + 0x80)
    je  run_16bit

    jmp .menu_loop


; --------------------------------------------------------------
; Run 16-bit demo program
;
; Disk layout assumption:
;   LBA 5 → prog16.bin
;
; Load destination:
;   0000:9000
; --------------------------------------------------------------
run_16bit:
    mov byte [DAP],     16          ; size of DAP
    mov byte [DAP+1],   0
    mov word [DAP+2],   4           ; sectors to read
    mov word [DAP+4],   0x9000      ; offset
    mov word [DAP+6],   0x0000      ; segment
    mov dword [DAP+8],  5           ; starting LBA
    mov dword [DAP+12], 0

    mov si, DAP
    mov dl, [BootDrive]
    mov ah, 0x42                   ; INT 13h extensions
    int 0x13
    jc  irish_error

    ; IMPORTANT:
    ; Far jump so CS is set correctly.
    jmp 0x0000:0x9000


; --------------------------------------------------------------
; Disk load failure handler
; --------------------------------------------------------------
load_error:
    mov ah, 0x0E
    mov al, '!'
.err_loop:
    int 0x10
    jmp .err_loop
	
; ---- Boot16: Error handler (♣ spam) ----
irish_error:
	mov ax, 0xB800
	mov es, ax
	xor di, di              ; DI = linear cell * 2

.fill:
    mov al, 0x05        ; ♣
    mov ah, 0x0A        ; green
    stosw               ; write character, advance DI by 2
    cmp di, 80*25*2
    jb .fill
; ---- End Error handler ----


; --------------------------------------------------------------
; Menu rendering routine
; Simple BIOS teletype output.
; --------------------------------------------------------------
draw_menu:
    push ax
    push bx
    push cx
    push dx
    push si

    ; Move cursor to top-left
    mov ah, 2
    mov bh, 0
    mov dx, 0
    int 0x10

    mov si, msg_title
    call print_string

    ; New line
    mov al, 13
    mov ah, 0x0E
    int 0x10
    mov al, 10
    int 0x10
	mov al, 10
    int 0x10

    mov si, msg_opt16
    call print_string

    ; New line
    mov al, 13
    mov ah, 0x0E
    int 0x10
    mov al, 10
    int 0x10

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; --------------------------------------------------------------
; print_string
; DS:SI → zero-terminated string
; --------------------------------------------------------------
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


; --------------------------------------------------------------
; Data
; --------------------------------------------------------------
BootDrive   db 0

msg_title   db ' KAOS Kernel', 0
msg_opt16   db ' Press F2 to run 16 Bit program', 0

; Disk Address Packet (INT 13h extensions)
DAP:
    db 0, 0
    dw 0, 0, 0
    dd 0, 0


; ==============================================================
; END FACTOID menu16.l1
; ==============================================================
