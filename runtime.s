extern malloc
extern free
;
; Buffer declaration - We use buffer for moving data
; between vars. Using with tokens: PBUF, BUFF, WRT.
;
section .bss
	global _buffer
	_buffer resb 9
;
; Debug part - If you do not want to debug runtime
; functions just delete line after.
;
%define _DEBUG_
%ifdef  _DEBUG_
	global _runtime_PBUF
	global _runtime_BUFF
	global _runtime_IFNE
	global _runtime_IFB
	global _runtime_IFS
	global _runtime_VAR
	global _runtime_VAL
	global _runtime_WRT
	global _runtime_IFE
	global _runtime_CAT
	global _runtime_ADD
%endif

section .text
;
; Public functions - Functions list which will be
; used by compiler for code generation.
;
_runtime_VAR:
	push ebp
	mov ebp, esp
	sub esp, 1
	mov edx, [ebp + 8]
	mov [ebp - 1], dl
	xor eax, eax
	push 9
	call malloc
	test eax, eax
	jz _private_exit
	mov dl, [ebp - 1]
	mov [eax], dl
	mov dword [eax + 1], 0
	mov dword [eax + 5], 0
	mov esp, ebp
	pop ebp
	ret

_runtime_VAL:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]
	mov edi, [ebp + 12]
	mov ecx, [edi]
	test ecx, ecx
	jz _exit_val
	mov [edx + 1], ecx
	sub esp, 8
	mov [ebp - 4], edi
	mov [ebp - 8], edx
	push ecx
	call malloc
	pop ecx
	test eax, eax
	jz _private_exit
	mov edi, [ebp - 4]
	mov edx, [ebp - 8]
	mov [edx + 5], eax
_cycle_val:
	dec ecx
	mov dh, [edi + ecx + 4] 
	mov [eax + ecx], dh
	test ecx, ecx
	jnz _cycle_val
_exit_val:
	mov esp, ebp
	pop ebp
	ret

_runtime_WRT:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]
	mov ecx, 9
	; Delete value pointer.
_cycle_wrt:
	dec ecx
	mov ah, [_buffer + ecx]
	mov [edx + ecx], ah
	test ecx, ecx
	jnz _cycle_wrt
	mov esp, ebp
	pop ebp
	ret

_runtime_PBUF:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]
	mov ecx, 9
_cycle_pbuf:
	dec ecx
	mov ah, [edx + ecx]
	mov [_buffer + ecx], ah
	test ecx, ecx
	jnz _cycle_pbuf
	mov esp, ebp
	pop ebp
	ret

_runtime_BUFF:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]
	mov ecx, [edx + 1]
	mov ah, [edx]
	mov [_buffer], ah
	mov [_buffer + 1], ecx
	test ecx, ecx
	jz _exit_buff
	sub esp, 4
	mov [ebp - 4], edx
	push ecx
	call malloc
	pop ecx
	test eax, eax
	jz _private_exit
	mov [_buffer + 5], eax
	mov edx, [ebp - 4]
	mov edx, [edx + 5]
	push ebx
_cycle_buff:
	dec ecx
	mov bl, [edx + ecx]
	mov [eax + ecx], bl
	test ecx, ecx
	jnz _cycle_buff
	pop ebx
_exit_buff:
	mov esp, ebp
	pop ebp
	ret

_runtime_IFE:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]
	mov edi, [ebp + 12]
	push edi
	push edx
	call _private_cmpvarlen
	pop edx
	pop edi
	test eax, eax
	jnz _not_equal_ife
	mov ecx, [edi + 1]
	test ecx, ecx
	jz _equal_ife
	mov edx, [edx + 5]
	mov edi, [edi + 5]
_cycle_ife:
	dec ecx
	mov ah, [edx + ecx]
	mov al, [edi + ecx]
	cmp ah, al
	jne _not_equal_ife
	test ecx, ecx
	jz _equal_ife
	jmp _cycle_ife
_equal_ife:
	mov eax, 1
	jmp _exit_ife
_not_equal_ife:
	xor eax, eax
_exit_ife:
	mov esp, ebp
	pop ebp
	ret

_runtime_IFNE:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]
	mov edi, [ebp + 12]
	push edi
	push edx
	call _runtime_IFE
	cmp eax, 0
	je _equal_ifne
	xor eax, eax
	jmp _exit_ifne
_equal_ifne:
	mov eax, 1
_exit_ifne:
	mov esp, ebp
	pop ebp
	ret

_runtime_IFS:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	mov edx, [ebp + 12]
	push edx
	push edi
	call _private_cmpvarlen
	pop edi
	pop edx
	test eax, eax
	jnz _cmpvarlen_ifs
	push edx
	push edi
	call _private_numcmp
	cmp eax, 1
	je _exit_ifs
	xor eax, eax
	jmp _exit_ifs
_cmpvarlen_ifs:
	cmp eax, 1
	je _exit_ifs
	xor eax, eax
_exit_ifs:
	mov esp, ebp
	pop ebp
	ret

_runtime_IFB:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	mov edx, [ebp + 12]
	push edx
	push edi
	call _private_cmpvarlen
	pop edi
	pop edx
	test eax, eax
	jnz _cmpvarlen_ifb
	push edx
	push edi
	call _private_numcmp
	cmp eax, 2
	je _exit_ifb
	xor eax, eax
	jmp _exit_ifb
_cmpvarlen_ifb:
	cmp eax, 2
	je _bigger_ifb
	xor eax, eax
	jmp _exit_ifb
_bigger_ifb:
	mov eax, 1
_exit_ifb:
	mov esp, ebp
	pop ebp
	ret

_runtime_CAT:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]
	mov edi, [ebp + 12]
	sub esp, 16
	mov [ebp - 8], edx
	mov [ebp - 4], edi
	mov ah, [edx]
	mov al, [edi]
	cmp ah, al
	jne _private_exit
	mov ecx, [edx + 1]
	jecxz _move_cat
	mov esi, [edi + 1]
	add ecx, esi
	mov [ebp - 16], esi
	mov [_buffer], ah
	mov [_buffer + 1], ecx
	xor eax, eax
	push ecx
	call malloc
	pop ecx
	test eax, eax
	jz _private_exit
	mov [_buffer + 5], eax
	mov edx, [ebp - 8]
	mov edi, [ebp - 4]
	mov esi, [ebp - 16]
	mov edx, [edx + 5]
	mov edi, [edi + 5]
	mov [ebp - 8], ecx
	sub ecx, esi
	push ebx
_cycle1_cat:
	dec ecx
	mov bh, [edx + ecx]
	mov [eax + ecx], bh
	test ecx, ecx
	jnz _cycle1_cat
	mov ecx, [ebp - 8]
	jecxz _exit_pop_cat
_cycle2_cat:
	dec ecx
	dec esi
	mov bh, [edi + esi]
	mov [eax + ecx], bh
	test esi, esi
	jnz _cycle2_cat
_exit_pop_cat:
	pop ebx
	jmp _exit_cat
_move_cat:
	push edx
	call _runtime_BUFF
_exit_cat:
	mov esp, ebp
	pop ebp
	ret

_runtime_ADD:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	mov edx, [ebp + 12]
	mov ah, [edi]
	mov al, [edx]
	cmp ah, al
	jne _private_exit
	mov ecx, [edi + 1]
	mov [_buffer + 1], ecx
	mov [_buffer], ah
	mov edi, [edi + 5]
	mov edx, [edx + 5]
	cmp ah, 3
	jl _private_exit
	xor eax, eax
	sub esp, 9
	mov [ebp - 9], ah
	mov [ebp - 8], edi
	mov [ebp - 4], edx
	push ecx
	call malloc
	add esp, 4
	test eax, eax
	jz _private_exit
	mov edi, [ebp - 8]
	mov edx, [ebp - 4]
	mov [_buffer + 5], eax
	cmp byte [ebp - 9], 4
	jne _int_add
	finit
	fld dword [edi]
	fld dword [edx]
	fadd
	fstp dword [eax]
	jmp _exit_add
_int_add:
	mov edi, [edi]
	mov edx, [edx]
	add edi, edx
	mov [eax], edi
_exit_add:
	mov esp, ebp
	pop ebp
	ret
;
; Private functions - Functions list which are used
; by public functions. Functions can not be used by
; compiler.
;
_private_cmpvarlen:
	push ebp
	mov ebp, esp
	mov eax, [ebp + 8]
	mov edx, [ebp + 12]
	mov eax, [eax + 1]
	mov edx, [edx + 1]
	cmp eax, edx
	je _equal_cmpvarlen
	jl _smaller_cmpvarlen
	mov eax, 2
	jmp _exit_cmpvarlen
_smaller_cmpvarlen:
	mov eax, 1
	jmp _exit_cmpvarlen
_equal_cmpvarlen:
	xor eax, eax
_exit_cmpvarlen:
	mov esp, ebp
	pop ebp
	ret

_private_numcmp:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	mov edx, [ebp + 12]
	mov byte ah, [edi]
	mov edi, [edi + 5]
	mov edx, [edx + 5]
	cmp ah, 4
	je _float_numcmp
	mov edi, [edi]
	mov edx, [edx]
	cmp edi, edx
	je _equal_numcmp
	jg _bigger_numcmp
	jl _smaller_numcmp
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

_private_exit:
	mov eax, 1
	mov ebx, 1
	syscall
