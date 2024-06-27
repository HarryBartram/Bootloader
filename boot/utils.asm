printStr:                                               ; Print String Function(si is pointer to string)
        mov ah, 0x0E
.print:
        mov al, [si]
        int 0x10
        inc si
        cmp byte [si], 0x00
        jne .print
        ret

hang:							; To Cease Execution
	cli
	hlt
