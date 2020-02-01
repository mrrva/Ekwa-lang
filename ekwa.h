
#ifndef _EKWA_LANGUAGE_
#define _EKWA_LANGUAGE_

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#define ARGLEN 4000
#define CODEMAX 1000000
/*
	Structure of var:
	1 byte - type / uint8_t
	4 byte - size of data / uint32_t
	4 byte - addr of value / uint32_t

	Data types:
	0 - String
	1 - Bool
	3 - Array
	4 - Int
	5 - Float

	https://stackoverflow.com/questions/8196835/calculate-the-jmp-opcodes
*/
enum ekwa_reg {
	EAX	= 0x00,
	EBX	= 0x01,
	ECX	= 0x02,
	EDX	= 0x03,
	EDI	= 0x04
};

enum ekwa_type {
	EKWA_STRING = 0x00,
	EKWA_BOOL	= 0x01,
	EKWA_ARRAY	= 0x02,
	EKWA_INT	= 0x03,
	EKWA_FLOAT	= 0x04
};

enum ekwa_opcode {
	EKWA_FUNC	= 0x01,
	EKWA_FARG	= 0x02,
	EKWA_VAR	= 0x03,
	EKWA_SHOW	= 0x04,
	EKWA_RET	= 0x05,
	EKWA_VAL	= 0x06,
	EKWA_CALL	= 0x07,

	EKWA_JMP	= 0x08,
	EKWA_FSET	= 0x09,
	EKWA_WRT	= 0x0a,
	EKWA_BUFF	= 0x0b,
	EKWA_PBUF	= 0x0c,
	EKWA_IFE	= 0x0d,
	EKWA_IFNE	= 0x0e,
	EKWA_IFS	= 0x0f,
	EKWA_IFB	= 0x10,
	EKWA_INFO	= 0x11,
	EKWA_RMV	= 0x12,
	EKWA_CAT	= 0x13,
	EKWA_EXIT	= 0x14,
	EKWA_ARG	= 0x15,
	EKWA_ARGL	= 0x16,

	/* Arithmetic operations */
	EKWA_ADD	= 0x17,
	EKWA_SUB	= 0x19,
	EKWA_DIV	= 0x19,
	EKWA_MOD	= 0x1a,
	EKWA_MUL	= 0x1b,
	EKWA_SAL	= 0x1c,
	EKWA_SAR	= 0x1d,

	EKWA_END	= 0x1e
};

enum runtime_addr {
	VARNEW		= 0xfff517,
	VARVAL		= 0xfff517,
	VARBUFF		= 0xfff517,
	VARBUFFPTR	= 0xfff517,
	VARWRT		= 0xfff517,
	RMBUFFER	= 0xfff517,
	RMVAR		= 0xfff517,
	RMVALVAR	= 0xfff517,
	IFE			= 0xfff517,
	VARLENCMP	= 0xfff517,
	IFSB		= 0xfff517,
	NUMCMP		= 0xfff517,
	VARCOPY		= 0xfff517,
	ARRAYCOPY	= 0xfff517
};

struct ekwa_bytecode {
	unsigned char arg1[ARGLEN];
	unsigned char arg2[ARGLEN];
	struct ekwa_bytecode *next;
	enum ekwa_opcode token;
	size_t len1, len2;
};

struct ekwa_var {
	struct ekwa_var *next;
	char name[ARGLEN];
	size_t pos; // Stack position
};

struct ekwa_arg {
	struct ekwa_arg *next;
	char name[ARGLEN];
	size_t pos; // Stack position
	bool ptr;
};

struct ekwa_function {
	char name[ARGLEN];
	struct ekwa_bytecode *bcode;
	struct ekwa_function *next;
	struct ekwa_var *vars;
	struct ekwa_arg *args;
	size_t stacksub;
};

struct ekwa_binarycode {
	struct ekwa_binarycode *next;
	unsigned char *code;
	size_t len;
};
/*
struct ekwa_flag {
	struct ekwa_flag *next;
	char name[ARGLEN];
	size_t linenum;
};

struct ekwa_linemap {
	size_t line;
	size_t ocsize;
};*/
void ekwa_token_FARG(struct ekwa_binarycode **, size_t *, struct ekwa_function *, struct ekwa_bytecode *);
void ekw_token_VAR(struct ekwa_binarycode **, size_t *, struct ekwa_function *, struct ekwa_bytecode *);
void ekwa_addfunction(struct ekwa_function **, struct ekwa_function, bool *);
void ekwa_parsefunctions(struct ekwa_bytecode *, struct ekwa_function **);
struct ekwa_arg *ekwa_findarg(struct ekwa_function *, char *, size_t *);
bool ekwa_readbytes(struct ekwa_bytecode **, unsigned char *, size_t);
void ekwa_addvar(struct ekwa_var **, size_t, unsigned char *, size_t);
void ekwa_binary(struct ekwa_binarycode **, unsigned char *, size_t);
void ekwa_addbytecode(struct ekwa_bytecode **, struct ekwa_bytecode);
void ekwa_addarg(struct ekwa_arg **, unsigned char *, size_t, bool);
struct ekwa_var *ekwa_findvar(struct ekwa_function *, char *);
void ekwa_freebytecode(struct ekwa_bytecode **);
void ekwa_codegen(struct ekwa_function *);

uint8_t *oc_call(signed int, signed int);
uint8_t *oc_mov_arg_to_stack(size_t);
uint8_t *oc_mov_eax_to_stack(size_t);
uint8_t oc_push_reg(enum ekwa_reg);
uint8_t *oc_push_byte(uint8_t);
uint8_t *oc_func_bottom(void);
uint8_t *oc_push_var(size_t);
uint8_t *oc_add_esp(uint8_t);
uint8_t *oc_sub_esp(uint8_t);
uint8_t *oc_mov_arg(size_t);
uint8_t *oc_func_top(void);

#endif