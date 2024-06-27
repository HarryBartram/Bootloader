[BITS 16]

KbdControllerDataPort equ               0x60            ; Because A20 gate works through the keyboard (PS/2) Controller
KbdControllerCommandPort equ            0x64
KbdControllerDisableKbd equ             0xAD
KbdControllerEnableKbd equ              0xAE
KbdControllerReadCtrlOutPort equ        0xD0
KbdControllerWriteCtrlOutPort equ       0xD1

CODESEG equ                             KernelCodeDesc - GDT
DATASEG equ                             KernelDataDesc - GDT

; TEXT
enterPM:                                                ; Enter 32-bit protected mode	
	cli
	call enableA20
        lgdt [GDTR]
        mov eax, cr0
        or al, 1
        mov cr0, eax
        jmp CODESEG:FATBOOTLOADPOINT

enableA20:
        call .WaitInput                                 ; Disable The KeyBoard
        mov al, KbdControllerDisableKbd
        out KbdControllerCommandPort, al

        call .WaitInput                                 ; Read Control Output Port
        mov al, KbdControllerReadCtrlOutPort
        out KbdControllerCommandPort, al

        call .WaitOutput
        in al, KbdControllerDataPort
        push eax

        call .WaitInput                                 ; Write The New Value To Control Output Port
        mov al, KbdControllerWriteCtrlOutPort
        out KbdControllerCommandPort, al

        call .WaitInput
        pop eax
        or al, 2
        out KbdControllerDataPort, al

        call .WaitInput                                 ; Re-enable The Keyboard
        mov al, KbdControllerEnableKbd
        out KbdControllerCommandPort, al

        call .WaitInput
        ret

.WaitInput:                                             ; Wait Until Accepting Input
        in al, KbdControllerCommandPort
        test al, 2
        jnz .WaitInput
        ret
.WaitOutput:                                            ; Wait Until Accepting Output
        in al, KbdControllerCommandPort
        test al, 1
        jz .WaitOutput
        ret

; DATA
GDT:                                                    ; Global Descriptor Table
        dq 0x00000000
KernelCodeDesc:
        dw 0xFFFF
        dw 0x0000
        db 0x00
        db 10011010b
        db 11001111b
        db 0x00
KernelDataDesc:
        dw 0xFFFF
        dw 0x0000
        db 0x00
        db 10010010b
        db 11001111b
        db 0x00
GDTR:
        dw GDTR-GDT-1
        dd GDT
