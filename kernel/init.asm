[BITS 32]

extern _Z5kmainv

; Old Seg Sels
CODESEG		equ 0x08
DATASEG		equ 0x10

; Access Bits
PRESENT        equ 1 << 7
NOT_SYS        equ 1 << 4
EXEC           equ 1 << 3
DC             equ 1 << 2
RW             equ 1 << 1
ACCESSED       equ 1 << 0

; Flag Bits
GRAN_4K       equ 1 << 7
SZ_32         equ 1 << 6
LONG_MODE     equ 1 << 5

; Paging
PML4T	equ		0x1000
PDPT	equ		0x2003
PDT	equ		0x3003
PT	equ		0x4003

section .text
PMEntry:
	mov ax, DATASEG                                 ; Set Segment Registers to Data Segment
        mov ds, ax
        mov fs, ax
        mov gs, ax
        mov es, ax
        mov ss, ax

	mov edi, PML4T					; Clear page tables
	mov cr3, edi
	xor eax, eax
	mov ecx, 4096
	rep stosd
	mov edi, cr3

	mov dword [edi], PDPT
	add edi, 0x1000
	mov dword [edi], PDT
	add edi, 0x1000
	mov dword [edi], PT
	add edi, 0x1000

	mov ebx, 0x03
	mov ecx, 512
	.SetEntry:
	mov dword [edi], ebx
	add ebx, 0x1000
	add edi, 0x08
	loop .SetEntry

	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax	

	mov ecx, 0xC0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	lgdt [GDT.POINTER]
	jmp GDT.CODESEG:CallKMain

[BITS 64]
CallKMain:
	cli

	mov ax, GDT.DATASEG
	mov ds, ax
	mov fs, ax
	mov gs, ax
	mov es, ax
	mov ss, ax

	call _Z5kmainv					; Enter Kernel

        jmp $
section .data
GDT:
.NULLSEG: equ	$-GDT
	dq 0x00
.CODESEG: equ	$-GDT
	dd 0xFFFF
	db 0x00
	db PRESENT | NOT_SYS | EXEC | RW
	db GRAN_4K | LONG_MODE | 0x0F
	db 0x00
.DATASEG: equ	$-GDT
	dd 0xFFFF
	db 0x00
	db PRESENT | NOT_SYS | RW
	db GRAN_4K | SZ_32 | 0x0F
	db 0x00
.TSSSEG:  equ	$-GDT
	dd 0x00000068
        dd 0x00CF8900
.POINTER:
	dw $-GDT-1
	dq GDT
