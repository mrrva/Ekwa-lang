
#include "ekwa.h"
// sub    esp,{num}
/*-------------------------------------------------------*/
uint8_t *oc_sub_esp(uint8_t num) {
	uint8_t *bytes = {0x83, 0xec, num};
	return bytes;
}
// push {eax/ebx/ecx/edx/edi}
/*-------------------------------------------------------*/
uint8_t oc_push_reg(enum ekwa_reg reg) {
	switch (reg) {
	case EAX:
		return 0x50;
	case EBX:
		return 0x53;
	case ECX:
		return 0x51;
	case EDX:
		return 0x52;
	case EDI:
		return 0x57;
	default:
		return 0x00;
	}
}
// push byte {byte}
/*-------------------------------------------------------*/
uint8_t *oc_push_byte(uint8_t byte) {
	uint8_t *bytes = {0x6a, byte};
	return bytes;
}
// add    esp,{num}
/*-------------------------------------------------------*/
uint8_t *oc_add_esp(uint8_t num) {
	uint8_t *bytes = {0x83, 0xc4, num};
	return bytes;
}
// push   ebp
// mov    ebp,esp
/*-------------------------------------------------------*/
uint8_t *oc_func_top(void) {
	uint8_t *bytes = {0x55, 0x89, 0xe5};
	return bytes;
}
// mov    esp,ebp
// pop    ebp
// ret
/*-------------------------------------------------------*/
uint8_t *oc_func_bottom(void) {
	uint8_t *bytes = {0x89, 0xec, 0x5d, 0xc3};
	return bytes;
}
// push   DWORD PTR [ebp-{pos}]
/*-------------------------------------------------------*/
uint8_t *oc_push_var(size_t pos) {
	uint8_t *bytes = {0x89, 0xec, 0x5d, 0xFF - (--pos)};
	return bytes;
}
// mov    edx,DWORD PTR [ebp+0x04+{arg_id * 4}]
/*-------------------------------------------------------*/
uint8_t *oc_mov_arg(size_t arg_id) {
	uint8_t *bytes = {0x8b, 0x55, 0x04 + (arg_id * 4)};
	return bytes;
}
// mov    DWORD PTR [ebp-{pos}],edx
/*-------------------------------------------------------*/
uint8_t *oc_mov_arg_to_stack(size_t pos) {
	uint8_t *bytes = {0x89, 0x55, 0xFF - (--pos)};
	return bytes;
}
// mov    DWORD PTR [ebp-{pos}],eax
/*-------------------------------------------------------*/
uint8_t *oc_mov_eax_to_stack(size_t pos) {
	uint8_t *bytes = {0x89, 0x45, 0xFF - (--pos)};
	return bytes;
}
// call   {addr}
/*-------------------------------------------------------*/
uint8_t *oc_call(signed int func, signed int pos) {
	uint8_t *bytes = (uint8_t *)malloc(5);
	signed int addr = func - (pos + 5);

	if (!bytes) {
		printf("[E]: Can't allocate memory.\n");
	}

	memcpy(bytes + 1, &addr, 4);
	bytes[0] = 0xe8;

	return bytes;
}