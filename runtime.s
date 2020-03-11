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
	global _runtime_SHOW
	global _runtime_ALEN
	global _runtime_AADD
	global _runtime_ABUF
	global _runtime_ARW
	global _runtime_RMV
	global _runtime_ARM
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
	cmp dword [edi], 0
	jz _exit_val
	sub esp, 8
	mov [ebp - 4], edi
	mov [ebp - 8], edx
	push edx
	call _private_rmval
	pop edx
	mov edi, [ebp - 4]
	mov ecx, [edi]
	xor eax, eax
	push ecx
	call malloc
	pop ecx
	test eax, eax
	jz _private_exit
	mov edi, [ebp - 4]
	mov edx, [ebp - 8]
	mov [edx + 1], ecx
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
	mov ah, [edx]
	cmp ah, 2
	jne _varfree_wrt
	; Free array value
	jmp _start_wrt
_varfree_wrt:
	push edx
	call _private_rmval
	pop edx
_start_wrt:
	mov ecx, 9
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
	cmp ah, 2
	je _array_buff
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
	jmp _exit_buff
_array_buff:
	push edx
	call _private_arrcpy
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
	sub esp, 8
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
	cmp byte [_buffer], 4
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

_runtime_SHOW:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	test edi, edi
	jz _private_exit
	mov edx, [edi + 1]
	mov cl, [edi]
	test cl, cl
	jnz _exit_show
	test edx, edx
	jz _exit_show
	push ebx
	mov eax, 4
	mov ebx, 1
	mov ecx, [edi + 5]
	int 0x80
	pop ebx
_exit_show:
	mov esp, ebp
	pop ebp
	ret

_runtime_RMV:
	push ebp
	mov ebp, esp
	mov esi, [ebp + 8]
	mov ah, [esi]
	cmp ah, 2
	je _array_rmv
	push esi
	call _private_rmvar
	jmp _exit_rmv
_array_rmv:
	;
_exit_rmv:
	mov esp, ebp
	pop ebp
	ret

_runtime_ALEN:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	mov eax, [edi + 1]
	test eax, eax
	jz _zero_alen
	mov cl, [edi]
	cmp cl, 2
	jne _zero_alen
	cmp eax, 4
	jl _zero_alen
	xor edx, edx
	mov ecx, 4
	div ecx
	test edx, edx
	jz _exit_alen
_zero_alen:
	xor eax, eax
_exit_alen:
	mov esp, ebp
	pop ebp
	ret

_runtime_AADD:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	test edi, edi
	jz _exit_aadd
	mov al, [edi]
	cmp al, 2
	jne _exit_aadd
	sub esp, 12
	mov [ebp - 8], edi
	push edi
	call _runtime_VAR
	add esp, 4
	test eax, eax
	jz _private_exit
	mov [ebp - 12], eax
	push eax
	call _runtime_WRT
	add esp, 4
	mov edi, [ebp - 8]
	mov ecx, [edi + 1]
	add ecx, 4
	push ecx
	call malloc
	pop ecx
	test eax, eax
	jz _private_exit
	sub ecx, 4
	mov edi, [ebp - 8]
	test ecx, ecx
	jz _write_aadd
	mov edi, [edi + 5]
	push ebx
_cycle_aadd:
	dec ecx
	mov bl, [edi + ecx]
	mov [eax + ecx], bl
	test ecx, ecx
	jnz _cycle_aadd
	pop ebx
	mov edi, [ebp - 8]
	mov ecx, [edi + 1]
_write_aadd:
	add ecx, 4
	mov [edi + 1], ecx
	sub ecx, 4
	mov edx, [ebp - 12]
	mov [eax + ecx], edx
	mov esi, [edi + 5]
	mov [edi + 5], eax
	test ecx, ecx
	jz _exit_aadd
	push esi
	call free
_exit_aadd:
	mov esp, ebp
	pop ebp
	ret

_runtime_ARM:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	mov esi, [ebp + 12]
	mov ecx, [edi + 1]
	test ecx, ecx
	jz _exit_arm
	mov cl, [edi]
	cmp cl, 2
	jne _exit_arm
	sub esp, 8
	mov [ebp - 4], edi
	push esi
	call _private_getnum
	pop esi
	mov edi, [ebp - 4]
	mov edx, 4
	mul edx
	mov ecx, [edi + 1]
	cmp ecx, eax
	jl _exit_arm
	mov edi, [edi + 5]
	mov edi, [edi + eax]
	mov [ebp - 8], eax
	push edi
	call _runtime_RMV
	add esp, 4
	mov edi, [ebp - 4]
	mov ecx, [edi + 1]
	mov esi, [ebp - 8]
	sub ecx, 4
	cmp ecx, esi
	je _newlen_arm
	push ebx
	add ecx, 4
	mov ebx, esi
	add ebx, 4
	mov edi, [ebp - 4]
	mov edi, [edi + 5]
_cycle_arm:
	mov dh, [edi + ebx]
	mov [edi + esi], dh
	inc esi
	inc ebx
	cmp ebx, ecx
	jne _cycle_arm
	pop ebx
	sub ecx, 4
_newlen_arm:
	mov edi, [ebp - 4]
	mov [edi + 1], ecx
_exit_arm:
	mov esp, ebp
	pop ebp
	ret

_runtime_ARW:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	mov esi, [ebp + 12]
	mov ecx, [edi + 1]
	test ecx, ecx
	jz _exit_arw
	mov cl, [edi]
	cmp cl, 2
	jne _exit_arm
	sub esp, 8
	mov [ebp - 8], edi
	push esi
	call _private_getnum
	pop esi
	mov edx, 4
	mul edx
	mov edi, [ebp - 8]
	cmp eax, [edi + 1]
	jg _exit_arw
	mov [ebp - 4], eax
	mov dl, [_buffer]
	push edx
	call _runtime_VAR
	add esp, 4
	push eax
	call _runtime_WRT
	pop eax
	mov edi, [ebp - 8]
	mov edi, [edi + 5]
	mov ecx, [ebp - 4]
	mov edx, [edi + ecx]
	mov [edi + ecx], eax
	push edx
	call _runtime_RMV
_exit_arw:
	mov esp, ebp
	pop ebp
	ret

_runtime_ABUF:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	mov esi, [ebp + 12]
	mov ecx, [edi + 1]
	test ecx, ecx
	jz _exit_arw
	mov cl, [edi]
	cmp cl, 2
	jne _exit_abuf
	sub esp, 4
	mov [ebp - 4], edi
	push esi
	call _private_getnum
	add esp, 4
	mov edx, 4
	mul edx
	mov edi, [ebp - 4]
	mov ecx, [edi + 1]
	cmp eax, ecx
	jg _private_exit
	mov edi, [edi + 5]
	mov edx, [edi + eax]
	push edx
	call _runtime_BUFF
_exit_abuf:
	mov esp, ebp
	pop ebp
	ret
;
; Private functions - Functions list which are used
; by public functions. Functions can not be used by
; compiler.
;
_private_arrcpy:
	push ebp
	mov ebp, esp
	; array copy to the buffer
	mov esp, ebp
	pop ebp
	ret

_private_getnum:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	mov ecx, [edi + 1]
	cmp ecx, 4
	jne _private_exit
	mov eax, [edi + 5]
	mov eax, [eax]
	mov esp, ebp
	pop ebp
	ret

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

_private_rmvar:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	test edi, edi
	jz _exit_rmvar
	push edi
	call _private_rmval
	call free
_exit_rmvar:
	mov esp, ebp
	pop ebp
	ret

_private_rmval:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8]
	mov esi, [edi + 1]
	test esi, esi
	jz _exit_rmval
	push dword [edi + 5]
	call free
	add esp, 4
	mov dword [edi + 1], 0
_exit_rmval:
	mov dword [edi + 5], 0
	mov esp, ebp
	pop ebp
	ret

_private_exit:
	mov eax, 1
	mov ebx, 1
	int 0x80
