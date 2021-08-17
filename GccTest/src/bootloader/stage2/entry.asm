bits 16

section .entry

; c start
extern _start

; sections
extern __bss_start
extern __end

global entry
entry:
    cli

    ; setup segments
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; setup stack at 0xFFF0
    mov esp, 0xFFF0
    mov ebp, esp
    sti

    ; expect boot drive in dl, send it as argument to cstart function
    mov [g_BootDrive], dl

    ;
    ; switch to protected mode
    ;
    cli

    call x86_EnableA20
    call x86_LoadGDT

    ; set "protection enable" flag in control register 0
    mov eax, cr0
    or al, 1
    mov cr0, eax

    ; far jump into protected mode
    jmp dword 08h:.pmode

.pmode:
    [bits 32]
    
    ; load segments
    mov ax, 10h
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; zero bss
    mov edi, __bss_start
    mov ecx, __end
    sub ecx, __bss_start
    mov al, 0
    cld
    rep stosb                           ; repeats instruction decrementing ECX until zero
                                        ; and stores value from AL incrementing ES:EDI

    ; call C
    push dword[g_BootDrive]
    call _start
    
    cli
    hlt


;
; Enables A20 gate
;
x86_EnableA20:
    [bits 16]

    ; disable keyboard
    call x86_A20WaitInput
    mov al, KbdControllerDisableKeyboard
    out KbdControllerCommandPort, al

    ; read control output port
    call x86_A20WaitInput
    mov al, KbdControllerReadCtrlOutputPort
    out KbdControllerCommandPort, al

    call x86_A20WaitOutput
    in al, KbdControllerDataPort
    push eax

    ; write control output port
    call x86_A20WaitInput
    mov al, KbdControllerWriteCtrlOutputPort
    out KbdControllerCommandPort, al

    call x86_A20WaitInput
    pop eax
    or al, 2                        ; set bit 2 - a20 bit
    out KbdControllerDataPort, al

    ; enable keyboard
    call x86_A20WaitInput
    mov al, KbdControllerEnableKeyboard
    out KbdControllerCommandPort, al

    call x86_A20WaitInput
    ret

 
x86_A20WaitInput:
    ; wait until status bit 2 (input buffer) is 0
    in al, KbdControllerCommandPort
    test al, 2
    jnz x86_A20WaitInput
    ret

x86_A20WaitOutput:
    ; wait until status bit 1 (output buffer) is 1 so it can be read
    in al, KbdControllerCommandPort
    test al, 1
    jz x86_A20WaitOutput
    ret


;
; Load protected mode GDT
;
x86_LoadGDT:
    [bits 16]
    lgdt [g_GDTDesc]
    ret


g_BootDrive:    dd 0

g_GDT:          ; NULL descriptor
                dq 0                    

                ; 32-bit code segment
                dw 0FFFFh           ; limit low - 0xfffff for full 4gb address space
                dw 0                ; base (bits 0-15) - 0x0
                db 0                ; base (bits 16-23)
                db 10011010b        ; access (present, ring 0, code segment, executable, direction 0, readable)
                db 11001111b 		; granularity (4kb pages, 32-bit protected mode) + limit high (0xF)
                db 0 				; base high

                ; 32-bit data segment
                dw 0FFFFh           ; limit low - 0xfffff for full 4gb address space
                dw 0                ; base (bits 0-15) - 0x0
                db 0                ; base (bits 16-23)
                db 10010010b        ; access (present, ring 0, data segment, executable, direction 0, writable)
                db 11001111b 		; granularity (4kb pages, 32-bit protected mode) + limit high (0xF)
                db 0 				; base high

                ; 16-bit code segment
                dw 0FFFFh           ; limit low - 0xfffff
                dw 0                ; base (bits 0-15) - 0x0
                db 0                ; base (bits 16-23)
                db 10011010b        ; access (present, ring 0, code segment, executable, direction 0, readable)
                db 00001111b 		; granularity (1b pages, 16-bit real mode) + limit high (0xF)
                db 0 				; base high

                ; 16-bit data segment
                dw 0FFFFh           ; limit low - 0xfffff
                dw 0                ; base (bits 0-15) - 0x0
                db 0                ; base (bits 16-23)
                db 10010010b        ; access (present, ring 0, data segment, executable, direction 0, writable)
                db 00001111b 		; granularity (1b pages, 16-bit real mode) + limit high (0xF)
                db 0 				; base high

g_GDTDesc:      dw g_GDTDesc - g_GDT - 1      ; limit = size of GDT
                dd g_GDT                      ; base of GDT


KbdControllerDataPort               equ 0x60
KbdControllerCommandPort            equ 0x64

KbdControllerDisableKeyboard        equ 0xAD
KbdControllerEnableKeyboard         equ 0xAE
KbdControllerReadCtrlOutputPort     equ 0xD0
KbdControllerWriteCtrlOutputPort    equ 0xD1
