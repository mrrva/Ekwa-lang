
#include "ekwa.h"
/*-------------------------------------------------------*/
void ekwa_token_FARG(struct ekwa_binarycode **code,
	size_t *len, struct ekwa_function *func,
	struct ekwa_bytecode *line) {
	struct ekwa_arg *arg = NULL;
	char name[ARGLEN];
	size_t num = 0;

	if (!(*code) || !func || !line || line->len1 == 0) {
		printf("[W]: Incorrect args for FARG.\n");
		return;
	}

	strncpy(name, (char *)line->arg1, line->len1);
	arg = ekwa_findarg(func, name, &num);

	if (arg == NULL) {
		printf("[W]: Can't find argument %s.\n", name);
		return;
	}

	ekwa_binary(&code, oc_mov_arg(num), 3);
	ekwa_binary(&code, oc_mov_arg_to_stack(arg->pos), 3);

	*len += 6; 
}
/*-------------------------------------------------------*/
void ekw_token_VAR(struct ekwa_binarycode **code,
	size_t *len, struct ekwa_function *func,
	struct ekwa_bytecode *line) {
	struct ekwa_var *var = NULL;
	char name[ARGLEN];

	if (!(*code) || !func || !line || line->len1 == 0
		|| line->len2 != 1) {
		printf("[W]: Incorrect args for VAR.\n");
		return;
	}

	strncpy(name, (char *)line->arg1, line->len1);
	var = ekwa_findvar(func, name);

	if (var == NULL) {
		printf("[W]: Can't find var %s.\n", name);
		return;
	}

	ekwa_binary(&code, oc_push_byte(*func->arg2), 2);
	*len += 2;
	
	ekwa_binary(&code, oc_call(VARNEW, *len), 5);
	ekwa_binary(&code, oc_add_esp(1), 3);
	ekwa_binary(&code, oc_mov_eax_to_stack(var->pos), 3);
	*len += 11;
}
