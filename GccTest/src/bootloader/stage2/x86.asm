;
; Enter protected mode
;
%macro x86_EnterProtectedMode 0
    [bits 16]
    cli
    
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

%endmacro

%macro x86_EnterRealMode 0
    [bits 32]
    cli

    ; jump to 16-bit protected mode
    jmp word 18h:.pmode16

.pmode16:
    [bits 16]

    ; disable protected mode
    mov eax, cr0
    and al, ~1
    mov cr0, eax

    ; jump to real mode
    jmp word 00h:.rmode

.rmode:

    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    sti

%endmacro


;
; Convert linear address to segment:offset address
; Args: 1 - linear address
;       2 - target segment (e.g. es)
;       3 - target 32-bit register to use (e.g. eax)
;       4 - target lower 16-bit half of #3 (e.g. ax)
; Result: segment:offset is in 2:4 (e.g. es:ax)
;
%macro LinearToSegOffset 4

    mov %3, %1      ; eax = linear address
    mov %4, 0       ;  ax = 0
    shr %3, 4       ; eax >> 4 to get segment
    mov %2, %4      ;  es = segment
    mov %3, %1      ; eax = linear address

%endmacro


;
; Output byte to port
;
; void __attribute__((cdecl)) x86_outb(uint16_t port, uint8_t data);
;
global x86_outb
x86_outb:
    [bits 32]
    
    mov dx, [esp + 4]
    mov al, [esp + 8]
    out dx, al

    ret

