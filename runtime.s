extern malloc
extern free
;
; Global functions.
;
global _start
;
; Global buffer for pointers.
;
section .bss
	global _buffer
	_buffer resb 9

section .text
;
; Variable creation.
;
runtime_varnew:
	push ebp
	mov ebp, esp
	mov dh, [ebp + 8]        ; Var type
	xor eax, eax
	push 9
	call malloc
	test eax, eax
	jz _ekwa_exit
	mov byte [eax], dh
	mov dword [eax + 1], 0
	mov esp, ebp
	pop ebp
	ret
;
; Set value of the var.
;
runtime_varval:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]       ; Var address
	mov edx, [ebp + 12]      ; Buffer address.
	test edi, edi
	jz _ekwa_exit
	sub esp, 8
	mov [ebp - 8], edi
	mov edi, [edx]
	cmp edi, 0
	jz _ekwa_exit
	push edi
	call malloc
	;add esp, 4
	test eax, eax
	jz _ekwa_exit
	mov [ebp - 4], edx
	mov edx, [ebp - 8]
	mov [edx + 1], edi
	mov [edx + 5], eax
	mov edx, [ebp - 4]
	mov ecx, [edx + 1]
	add edx, 4
_cycle_varval:
	dec ecx
	mov byte bh, [edx + ecx]
	mov byte [eax + ecx], bh
	jecxz _cycle_varval
	mov esp, ebp
	pop ebp
	ret
;
; Set new buffer value.
;
runtime_varbuff:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]       ; Var address
	test edi, edi
	jz _exit_varbuff
	xor ecx, ecx
_cycle_varbuff:
	mov ah, [edi + ecx]
	mov byte [_buffer + ecx], ah
	inc ecx
	cmp ecx, 9
	jne _cycle_varbuff
	mov edi, [_buffer + 1]
	test edi, edi
	jz _exit_varbuff
	xor eax, eax
	push edi
	call malloc
	test eax, eax
	jz _ekwa_exit
	xor ecx, ecx
	mov edi, [_buffer + 5]
_write_varbuff:
	mov dh, [edi + ecx]
	mov byte [eax + ecx], dh
	inc ecx
	cmp ecx, [_buffer + 1]
	jne _write_varbuff
	mov [_buffer + 5], eax
_exit_varbuff:
	mov esp, ebp
	pop ebp
	ret
;
; Set new buffer value as pointer.
;
runtime_varbuffptr:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]       ; Var address
	test edi, edi
	jz _exit_varbuffptr
	xor ecx, ecx
_cycle_varbuffptr:
	mov ah, [edi + ecx]
	mov byte [_buffer + ecx], ah
	inc ecx
	cmp ecx, 9
	jne _cycle_varbuffptr
_exit_varbuffptr:
	mov esp, ebp
	pop ebp
	ret
;
; Write buffer to var.
;
runtime_varwrt:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]       ; Var address
	xor ecx, ecx
	push dword [edi + 5]
	call runtime_rmvalvar
_cycle_varwrt:
	mov byte ah, [_buffer + ecx]
	mov byte [edi + ecx], ah
	inc ecx
	cmp ecx, 9
	jne _cycle_varwrt
	call runtime_rmbuffer
	mov esp, ebp
	pop ebp
	ret
;
; Clear buffer.
;
runtime_rmbuffer:
	xor ecx, ecx
	xor ah, ah
_cycle_rmbuffer:
	mov byte [_buffer + ecx], ah
	inc ecx
	cmp ecx, 9
	jne _cycle_rmbuffer
	ret
;
; Var removing.
;
runtime_rmvar:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]       ; Var address
	push edi
	call runtime_rmvalvar
	call free
	mov esp, ebp
	pop ebp
	ret
;
; Var value removing.
;
runtime_rmvalvar:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]       ; Var address
	mov edx, [edi + 1]
	test edx, edx
	jz _exit_rmvalvar
	push dword [edi + 5]
	call free
	mov dword [edi + 1], 0
_exit_rmvalvar:
	mov esp, ebp
	pop ebp
	ret
;
; Var comparing - equal.
;
runtime_ife:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]       ; First var pointer
	mov edx, [ebp + 12]      ; Second var pointer
	push edx
	push edi
	call runtime_varlencmp
	add esp, 8
	test eax, eax
	jnz _fail_ife
	mov byte ah, [edi]
	cmp ah, [edx]
	jne _fail_ife
	mov ecx, [edi + 1]
	mov edi, [edi + 5]
	mov edx, [edx + 5]
	mov eax, 1
_cycle_ife:
	dec ecx
	mov byte ah, [edi + ecx]
	mov byte al, [edx + ecx]
	cmp ah, al
	jne _fail_ife
	jecxz _good_ife
	jmp _cycle_ife
_fail_ife:
	xor eax, eax
_good_ife:
	mov esp, ebp
	pop ebp
	ret
;
; Var length comparing.
; Result: 0 equal, 1 smaller, 2 bigger.
;
runtime_varlencmp:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]       ; First var pointer
	mov edx, [edi + 1]
	mov eax, [ebp + 12]      ; Second var pointer
	mov edi, [eax + 1]
	cmp edx, edi
	je _equal_varlencmp
	jl _less_varlencmp
	mov eax, 2
	jmp _exit_varlencmp
_less_varlencmp:
	mov eax, 1
	jmp _exit_varlencmp
_equal_varlencmp:
	xor eax, eax
_exit_varlencmp:
	mov esp, ebp
	pop ebp
	ret
;
; Var comparing - smaller or bigger.
;
runtime_ifsb:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]       ; First var pointer
	mov edi, [ebp + 12]      ; Second var pointer
	push edi
	push edx
	call runtime_varlencmp
	add esp, 8
	cmp eax, 1
	jne _fail_ifsb
	mov byte ch, [edx]
	mov byte cl, [edi]
	cmp ch, cl
	jne _fail_ifsb
	cmp ch, 4
	jl _fail_ifsb
	push edi
	push edx
	call runtime_numcmp
	add esp, 8
	jmp _exit_ifsb
_fail_ifsb:
	xor eax, eax
_exit_ifsb:
	mov esp, ebp
	pop ebp
	ret
;
; Numbers comparing.
; Result: 0 equal, 1 smaller, 2 bigger.
;
runtime_numcmp:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]       ; First var pointer
	mov edx, [ebp + 12]      ; Second var pointer
	mov byte ah, [edi]
	mov edi, [edi + 5]
	mov edx, [edx + 5]
	cmp ah, 4
	jg _float_numcmp
	cmp edi, edx
	je _equal_numcmp
	jl _smaller_numcmp
	jg _bigger_numcmp
_float_numcmp:
	finit
	fld dword [edx]
	fld dword [edi]
	fcom st0, st1
	fstsw ax
	and eax, 0100011100000000B
	cmp eax, 0000000100000000B
	je _smaller_numcmp
	cmp eax, 0100000000000000B
	je _equal_numcmp
_bigger_numcmp:
	mov eax, 2
	jmp _exit_numcmp
_smaller_numcmp:
	mov eax, 1
	jmp _exit_numcmp
_equal_numcmp:
	xor eax, eax
_exit_numcmp:
	mov esp, ebp
	pop ebp
	ret
;
; Make var copy.
;
runtime_varcopy:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]       ; Var address
	test edx, edx
	jz _ekwa_exit
	mov byte ah, [edx]
	cmp ah, 3
	je _array_varcopy
	push eax
	call runtime_varnew
	add esp, 4
	push edx
	call runtime_varbuff
	add esp, 4
	push eax
	call runtime_varwrt
	jmp _exit_varcopy
_array_varcopy:
	push edx
	call runtime_arraycopy
_exit_varcopy:
	call runtime_varbuffptr
	call free
	mov esp, ebp
	pop ebp
	ret
;
; Make array copy.
;
runtime_arraycopy:
	push ebp
	mov ebp, esp
	
	mov esp, ebp
	pop ebp
	ret
;
; Print string on the screen.
;
runtime_showstr:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]       ; Var address
	mov eax, 4
	mov ebx, 1
	mov ecx, [edx + 5]
	mov edx, [edx + 1]
	syscall
	mov esp, ebp
	pop ebp
	ret
;
; End of the program.
;
_ekwa_exit:
	mov eax, 1
	mov ebx, 0
	syscall

_start:
	jmp _ekwa_exit













