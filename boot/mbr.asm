[BITS 16]
[ORG 0x7C00]

STAGE2START 	equ				0x01
STAGE2LOADPOINT equ				0x7E00

FATBOOTPARTSTART equ				0x800
FATBOOTLOADPOINT equ				0x8000

SECTORSPERCLUSTEROFF equ			0x0D
RESERVEDSECTORSOFF   equ			0x0E
NUMBEROFFATSOFF	     equ			0x10
SECTORSPERFATOFF     equ			0x24

SECTORSIZE	     equ			0x200
DIRECTORYENTRYSIZE   equ			0x20

DIRECTORYFLAGSOFF    equ			0x0B
LOWCLUSTERNUMOFF     equ			0x1A
HIGHCLUSTERNUMOFF    equ			0x14

STACKSTART equ					0x7B00

; TEXT	
start:
	xor ax, ax									; Set Up Segment Registers
	mov ds, ax
	mov es, ax

	;mov si, LoadSuccessStr						; Print Success Message For Load.
	;call printStr

	mov si, DAPACK								; Load Stage Two And The Kernel
	call loadStage2
	call loadKernel

	jmp enterPM

%include "boot/utils.asm" 

loadStage2:										; Load Second Stage
	mov ah, 0x42
	int 0x13
	jc loadError
	ret

loadKernel:	
	mov eax, FATBOOTPARTSTART					; Load FAT Boot Sector
	mov [d_lba], eax
	mov ax, FATBOOTLOADPOINT
	mov [db_add], ax
	mov ah, 0x42
	int 0x13
	jc loadError

	mov bx, FATBOOTLOADPOINT					; Get Sectors Per Cluster
	mov al, byte [bx + SECTORSPERCLUSTEROFF]
	mov [SectorsInCluster], al

	mov ax, word [bx + RESERVEDSECTORSOFF]		; Get FAT Offset
	mov [FATOffset], ax

	mov eax, dword [bx + SECTORSPERFATOFF]		; Get Size Of Each FAT
	mov [SectorsPerFAT], eax

	push dx										; Push Drive Num (So Not Smashed By Mul)

	mov cx, 0x02								; Get Offset To Root Directory
	mul cx
	mov [RootOffset], eax

	pop dx

	add eax, FATBOOTPARTSTART					; Load Root Directory
	add ax, word [FATOffset]
	mov [d_lba], eax
	mov ah, 0x42
	int 0x13
	jc loadError

	push dx

	mov di, bx									; Search For Directory Entry Of 'init'
.CheckFATName:
	add di, 0x01
	mov ax, 0x00
	mov si, InitFileNameStr
.CheckFATNameChar:
	mov dh, byte [di]
 	cmp byte [si], dh
	je .AreEqual
	mov ax, 0x01
.AreEqual:
	inc si
	add di, 0x02

	cmp byte [si], 0x00
	jne .CheckFATNameChar 

	cmp ax, 0x00
	je .FoundDir

	add bx, DIRECTORYENTRYSIZE					; add ability to differentiate LFNs and Non-LFNs
	add bx, DIRECTORYENTRYSIZE
	
	mov si, bx
	cmp byte [si], 'A'
	je .CheckFATName

.NotFoundDir:
	mov si, KernelNotFoundString
	call printStr

	jmp hang

.FoundDir:
	mov ax, word [bx + HIGHCLUSTERNUMOFF]		; Save Cluster Number
	shl eax, 16
	mov ax, word [bx + LOWCLUSTERNUMOFF]

	add eax, 0x01

	xor cx, cx
	mov cl, [SectorsInCluster]
	mul ecx

	mov dx, cx
	add cx, dx
	add cx, dx
	add cx, dx
	mov [blkcnt], cx

	add eax, [RootOffset]
	add ax, [FATOffset]
	add eax, FATBOOTPARTSTART
	mov [d_lba], eax

	mov si, DAPACK
	mov ah, 0x42
	pop dx
	int 0x13
	jc loadError

	ret

loadError:										; Failure on a drive read operation(int 0x13, ah=0x42)
	mov si, LoadErrorString
	call printStr
	jmp hang

; DATA
LoadErrorString: 
	db "Could not read from disk", 0x00
KernelNotFoundString:
	db "Kernel file not found", 0x0D, 0x0A, 0x00

DAPACK:											; INT 13h Data
	db 0x10
	db 0x00
blkcnt: dw 0x01									; This Is Reset To Number Of Blocks Actually Read
db_add: dw STAGE2LOADPOINT						; Memory Buffer Destination
	dw 0x00										; Memory Page Number
d_lba:  dd STAGE2START							; LBA Source Address
	dd 0x00

times 440-($-$$) db 0
DiskID: 	 dd 0x00000000
Reserved: 	 dw 0x0000
PartTable1:
	db 0x00
	db 0x20	; Head
	db 0x21	; Cylinder
	db 0x00	; Sector
	db 0x0C
	db 0x45
	db 0x04
	db 0x41
	db 0x00
	db 0x08
	db 0x00
	db 0x00
	db 0x00
	db 0xF8
	db 0x0F
	db 0x00
PartTable2:
	dq 0x00
	dq 0x00
PartTable3:
	dq 0x00
	dq 0x00
PartTable4:
	dq 0x00
	dq 0x00
dw 0xAA55

InitFileNameStr:  db "init", 0x00				; Kernel file name
SectorsInCluster: db 0x00						; FAT Related Information
FATOffset:	  dw 0x0000
SectorsPerFAT:	  dd 0x00000000
RootOffset:	  dd 0x00000000

%include "boot/stage2.asm"

times 1048576-($-$$) db 0x00
