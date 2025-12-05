[bits 16]
[org 0x8000]

; --------------------------------------------------------
; menu16.asm  -> menu16.bin
; 16-bit KAOS State Machine Menu at 0000:8000
; --------------------------------------------------------
; - Shows simple text menu with ">" arrow
; - Text drawn in VGA memory, green themed
; - Hardware cursor is hidden
; - Up/Down arrows move selection
; - Enter:
;     0 → load 16-bit prog16.bin  (LBA 5) to 0000:9000
;     1 → load 32-bit pm32.bin    (LBA 9) to 0000:A000
; --------------------------------------------------------

OPTION_COUNT equ 2

start_menu:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [BootDrive], dl

    ; ---- Clear screen (80x25 text) ----
    mov ax, 0x0003
    int 0x10
    ; ---- End clear screen ----

    ; ---- Hide hardware cursor ----
    mov ah, 1
    mov ch, 0x20
    mov cl, 0x00
    int 0x10
    ; ---- End hide cursor ----

    mov byte [Selected], 0

.redraw:
    call draw_menu

.menu_loop:
    ; wait for key (returns AL=ascii, AH=scan)
    xor ah, ah
    int 0x16

    ; Enter key (scan code 1Ch)
    cmp ah, 0x1C
    je .enter

    ; Up arrow (scan 48h)
    cmp ah, 0x48
    je .up

    ; Down arrow (scan 50h)
    cmp ah, 0x50
    je .down

    jmp .menu_loop

.up:
    mov al, [Selected]
    cmp al, 0
    je .menu_loop           ; already at top
    dec al
    mov [Selected], al
    jmp .redraw

.down:
    mov al, [Selected]
    cmp al, OPTION_COUNT-1
    jae .menu_loop          ; already at bottom
    inc al
    mov [Selected], al
    jmp .redraw

.enter:
    mov al, [Selected]
    cmp al, 0
    je run_16bit

    cmp al, 1
    je run_32bit

    jmp .menu_loop          ; safety
; ---- End menu input loop ----

; ---- Option 0: run 16-bit prog16.bin ----
; LBA 5–8 → 0000:9000
run_16bit:
    mov byte [DAP], 16
    mov byte [DAP+1], 0
    mov word [DAP+2], 4         ; sectors
    mov word [DAP+4], 0x9000    ; offset
    mov word [DAP+6], 0x0000    ; segment
    mov dword [DAP+8], 5        ; starting LBA = 5
    mov dword [DAP+12], 0

    mov si, DAP
    mov dl, [BootDrive]
    mov ah, 0x42
    int 0x13
    jc load_error

    jmp 0x0000:0x9000
; ---- End run_16bit ----

; ---- Option 1: run 32-bit pm32.bin ----
; LBA 9–12 → 0000:A000
run_32bit:
    mov byte [DAP], 16
    mov byte [DAP+1], 0
    mov word [DAP+2], 4         ; sectors
    mov word [DAP+4], 0xA000    ; offset
    mov word [DAP+6], 0x0000    ; segment
    mov dword [DAP+8], 9        ; starting LBA = 9
    mov dword [DAP+12], 0

    mov si, DAP
    mov dl, [BootDrive]
    mov ah, 0x42
    int 0x13
    jc load_error

    jmp 0x0000:0xA000
; ---- End run_32bit ----

load_error:
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
    jmp load_error
; ---- End load_error ----

; ---- draw_menu: draws menu with arrow using VGA memory ----
draw_menu:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    ; set ES to VGA text memory
    mov ax, 0xB800
    mov es, ax

    ; ---- Clear screen to blank + dark green FG ----
    xor di, di
    mov ax, 0x0220              ; ' ' with attribute 0x02 (green on black)
    mov cx, 80*25
    rep stosw
    ; ---- End clear ----

    ; ---- Draw title centered-ish on row 3 ----
    mov dh, 3                   ; row
    mov dl, 20                  ; col
    mov bl, 0x0A                ; bright green
    mov si, msg_title
    call put_string_color

    ; ---- Draw option 0 at row 7 ----
    mov dh, 7
    mov dl, 22
    mov bl, 0x0A
    mov al, [Selected]
    cmp al, 0
    jne .opt0_not_sel
    mov si, line_opt0_sel
    jmp .opt0_draw
.opt0_not_sel:
    mov si, line_opt0
.opt0_draw:
    call put_string_color

    ; ---- Draw option 1 at row 9 ----
    mov dh, 9
    mov dl, 22
    mov bl, 0x0A
    mov al, [Selected]
    cmp al, 1
    jne .opt1_not_sel
    mov si, line_opt1_sel
    jmp .opt1_draw
.opt1_not_sel:
    mov si, line_opt1
.opt1_draw:
    call put_string_color

    ; ---- Draw footer hint at row 20 ----
    mov dh, 20
    mov dl, 10
    mov bl, 0x08                ; dark gray
    mov si, msg_hint
    call put_string_color

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
; ---- End draw_menu ----

; ---- put_string_color: DS:SI -> zero-terminated
; Input: DH=row, DL=col, BL=attribute
; Assumes: ES = 0xB800
put_string_color:
    push ax
    push cx
    push dx
    push di

    ; compute offset = (row*80 + col)*2
    movzx ax, dh
    mov cx, 80
    mul cx                 ; AX = row*80
    movzx dx, dl
    add ax, dx             ; AX = row*80 + col
    shl ax, 1              ; word offset
    mov di, ax

.ps_loop:
    lodsb
    cmp al, 0
    je .ps_done
    mov ah, bl
    stosw
    jmp .ps_loop

.ps_done:
    pop di
    pop dx
    pop cx
    pop ax
    ret
; ---- End put_string_color ----

; ---- Data ----
BootDrive   db 0
Selected    db 0

msg_title       db ' KAOS State Machine Menu', 0

line_opt0_sel   db ' > Run 16-bit mode', 0
line_opt0       db '   Run 16-bit mode', 0

line_opt1_sel   db ' > Run 32-bit mode', 0
line_opt1       db '   Run 32-bit mode', 0

msg_hint        db ' Use Arrow key UP/DOWN and ENTER.  F1 to return to Menu', 0

DAP:
    db 0,0
    dw 0,0,0
    dd 0,0
; ---- End data ----
