[bits 16]
[org 0x7C00]

; ----------------------------------------------------
; boot16.asm  →  boot16.bin
; KAOS Bootloader "My Bootie"
; ----------------------------------------------------
; - Sets 80x25 text mode
; - Draws white smiley + red heart at (0,0)
; - Hides cursor during art
; - Waits using nested delay
; - Loads 4 sectors from LBA 1 to 0000:8000 (menu16.bin)
; - Jumps to 0000:8000
; - On error, spams bright red hearts forever
; ----------------------------------------------------

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [BootDrive], dl          ; save BIOS drive #

    ; ---- Set 80x25 text mode ----
    mov ax, 0x0003
    int 0x10
; ---- End video mode set ----

; ---- Begin Boot Art (cursor OFF) ----
    ; Ensure 80x25 text mode
    mov ax, 0x0003
    int 0x10

    ; Turn cursor OFF
    mov ah, 0x01
    mov ch, 0x20     ; CH > CL => invisible
    mov cl, 0x00
    int 0x10


    ; Move cursor to (0,0)
    mov ah, 0x02
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 0x10

    ; Print white smiley
    mov ah, 0x09
    mov al, 2
    mov bh, 0
    mov bl, 0x07
    mov cx, 1
    int 0x10

    ; Move to (0,1)
    mov ah, 0x02
    mov bh, 0
    mov dh, 0
    mov dl, 1
    int 0x10

    ; Print red heart
    mov ah, 0x09
    mov al, 3
    mov bh, 0
    mov bl, 0x04
    mov cx, 1
    int 0x10
; ---- End Boot Art ----

; ---- Boot16: Delay before loading ----
    mov cx, 2                    ; number of long delay cycles
.wait_blinks:
    call delay_blink
    loop .wait_blinks
; ---- End Delay ----


; ---- Boot16: Disk load to 0000:8000 ----
    ; DAP for INT 13h AH=42h (extended read)
    mov word [DAP + 2], 4        ; sectors to read (LBA 1–4)
    mov word [DAP + 4], 0x8000   ; offset
    mov word [DAP + 6], 0x0000   ; segment
    mov dword [DAP + 8], 1       ; starting LBA = 1 (menu16)
    mov dword [DAP + 12], 0      ; high dword of LBA

    mov si, DAP
    mov dl, [BootDrive]
    mov ah, 0x42                 ; INT 13h extended read
    int 0x13
    jc load_error

    ; Jump to loaded 16-bit menu at 0000:8000
    jmp 0x0000:0x8000
; ---- End Disk load ----

; ---- Boot16: Error handler (♥ spam) ----
load_error:
	mov ax, 0xB800
	mov es, ax
	xor di, di              ; DI = linear cell * 2

.fill:
    mov al, 0x03        ; heart
    mov ah, 0x04        ; red
    stosw               ; write character, advance DI by 2
    cmp di, 80*25*2
    jb .fill
; ---- End Error handler ----

; ---- Boot16: Delay routine (nested loops) ----
delay_blink:
    push ax
    push bx
    push dx

    mov bx, 4                    ; outer repeat

.delay_outer:
    mov ax, 0xFFFF               ; mid-level loop

.delay_mid:
    mov dx, 0x00FF               ; inner loop

.delay_inner:
    dec dx
    jnz .delay_inner

    dec ax
    jnz .delay_mid

    dec bx
    jnz .delay_outer

    pop dx
    pop bx
    pop ax
    ret
; ---- End Delay routine ----

; ---- Boot16: Data area ----
BootDrive db 0

DAP:
    db 16, 0                     ; size, reserved
    dw 0, 0, 0                   ; sectors, offset, segment
    dd 0, 0                      ; LBA low, LBA high
; ---- End Data area ----

; ---- Boot16: Boot signature ----
times 510-($-$$) db 0
dw 0xAA55
; ---- End Boot signature ----
