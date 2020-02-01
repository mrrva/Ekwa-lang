
#include "ekwa.h"
/*-------------------------------------------------------*/
void ekwa_codegen(struct ekwa_function *list) {
	struct ekwa_function *func = list;
	struct ekwa_binarycode *code = NULL;
	struct ekwa_bytecode *tmp;
	size_t line = 0; // Chould be: runtime size + size of the end function

	if (!list || list == NULL) {
		printf("[E]: Bytecode list is empty.\n");
		return;
	}

	while (func != NULL) {
		ekwa_binary(&code, oc_func_top(), 3);
		line += 3;
		
		if (func->stacksub != 0) {
			ekwa_binary(&code, oc_sub_esp(func->stacksub), 3);
			line += 3;
		}

		tmp = func->bcode;

		while (tmp != NULL) {
			switch (tmp->token) {
			case EKWA_FARG:
				ekwa_token_FARG(&code, &line, func, tmp);
				break;

			case EKWA_VAR:
				ekwa_token_VAR(&code, &line, func, tmp);
				break;
			}

			tmp = tmp->next;
		}

		ekwa_binary(&code, oc_func_bottom(), 4);
		line += 4;

		func = func->next;
	}
}
/*-------------------------------------------------------*/
void ekwa_parsefunctions(struct ekwa_bytecode *list,
	struct ekwa_function **funcs) {
	struct ekwa_bytecode *ptr = list;
	bool start = false, main = false;
	struct ekwa_function func;

	if (!list || list == NULL) {
		return;
	}

	while (ptr && ptr != NULL) {
		switch (ptr->token) {
		case EKWA_FUNC:
			if (start) {
				ekwa_addfunction(funcs, func, &main);
			}

			if (ptr->len1 == 0) {
				break;
			}

			strncpy(func.name, (char *)ptr->arg1,
					ptr->len1);
			func.stacksub = 0;
			func.bcode = NULL;
			func.vars = NULL;
			start = true;
			break;

		case EKWA_VAL:
			if (ptr->len1 == 0) {
				break;
			}

			func.stacksub += 4;
			ekwa_addvar(&func.vars, func.stacksub,
						ptr->arg1, ptr->len1);
			ekwa_addbytecode(&func.bcode, *ptr);
			break;

		case EKWA_LFARG:
			if (ptr->len1 == 0) {
				break;
			}

			func.stacksub += 4;
			ekwa_addarg(&func.args, ptr->arg1,
						ptr->len1, true);
			ekwa_addbytecode(&func.bcode, *ptr);
			break;

		case EKWA_FARG:
			if (ptr->len1 == 0) {
				break;
			}

			func.stacksub += 4;
			ekwa_addarg(&func.args, ptr->arg1,
						ptr->len1, false);
			ekwa_addbytecode(&func.bcode, *ptr);
			break;

		default:
			ekwa_addbytecode(&func.bcode, *ptr);
			break;
		}

		ptr = ptr->next;
	}

	if (start) {
		ekwa_addfunction(funcs, func, &main);
	}

	*funcs = (main) ? *funcs : NULL;
}
/*-------------------------------------------------------*/
void ekwa_binary(struct ekwa_binarycode **code,
	unsigned char *bytes, size_t len) {
	size_t size = sizeof(struct ekwa_binarycode);
	struct ekwa_binarycode *tmp = *code, *new;

	if (!bytes || len == 0) {
		return;
	}

	new = (struct ekwa_binarycode *)malloc(size);

	if (!new) {
		printf("[E]: Can't allocate memory.\n");
		exit(1);
	}

	new->code = bytes;
	new->size = len;
	new->next = NULL;

	if (!(*code) || (*code) == NULL) {
		*code = new;
		return;
	}

	while (tmp->next && tmp->next != NULL) {
		tmp = tmp->next;
	}

	tmp->next = new;
}
/*-------------------------------------------------------*/
void ekwa_addarg(struct ekwa_arg **args, unsigned char *name,
	size_t len, bool link) {
	size_t size = sizeof(struct ekwa_arg);
	struct ekwa_arg *new, *tmp = *args;

	new = (struct ekwa_arg *)malloc(size);

	if (!new) {
		printf("[E]: Can't allocate memory.\n");
		exit(1);
	}

	strncpy(new->name, (char *)name, len);
	new->next = NULL;
	new->ptr = link;

	if (!(*args) || (*args) == NULL) {
		*args = new;
		return;
	}

	while (tmp->next && tmp->next != NULL) {
		tmp = tmp->next;
	}

	tmp->next = new;
}
/*-------------------------------------------------------*/
void ekwa_addvar(struct ekwa_var **vars, size_t pos,
	unsigned char *name, size_t len) {
	size_t size = sizeof(struct ekwa_var);
	struct ekwa_var *new, *tmp = *vars;

	new = (struct ekwa_var *)malloc(size);

	if (!new) {
		printf("[E]: Can't allocate memory.\n");
		exit(1);
	}

	strncpy(new->name, (char *)name, len);
	new->next = NULL;
	new->pos = pos;

	if (!(*vars) || (*vars) == NULL) {
		*vars = new;
		return;
	}

	while (tmp->next && tmp->next != NULL) {
		tmp = tmp->next;
	}

	tmp->next = new;
}
/*-------------------------------------------------------*/
void ekwa_addfunction(struct ekwa_function **funcs,
	struct ekwa_function one, bool *main) {
	size_t size = sizeof(struct ekwa_function);
	struct ekwa_function *new, *tmp = *funcs;

	new = (struct ekwa_function *)malloc(size);

	if (!new) {
		printf("[E]: Can't allocate memory.\n");
		exit(1);
	}

	memcpy(new, &one, size);
	new->next = NULL;

	if (strcmp(one.name, "main") == 0) {
		*main = true;
	}

	if (!(*funcs) || (*funcs) == NULL) {
		*funcs = new;
		return;
	}

	while (tmp->next && tmp->next != NULL) {
		tmp = tmp->next;
	}

	tmp->next = new;
}
/*-------------------------------------------------------*/
struct ekwa_arg *ekwa_findarg(struct ekwa_function *func,
	char *name, size_t *num) {
	struct ekwa_arg *tmp = func->args, *ret = NULL;
	size_t cnum = 0;

	if (!tmp || !name) {
		printf("[W]: Incorrect args for ekwa_findarg.\n");
		exit(1);
	}

	while (tmp != NULL) {
		cnum++;

		if (strcmp(tmp->name, name) != 0) {
			tmp = tmp->next;
			continue;
		}

		ret = tmp;
		break;
	}

	*num = cnum;
	return ret;
}
/*-------------------------------------------------------*/
struct ekwa_var *ekwa_findvar(struct ekwa_function *func,
	char *name) {
	struct ekwa_var *tmp = func->vars, *ret = NULL;

	if (!tmp || !name) {
		printf("[W]: Incorrect args for ekwa_findvar.\n");
		exit(1);
	}

	while (tmp != NULL) {
		if (strcmp(tmp->name, name) != 0) {
			tmp = tmp->next;
			continue;
		}

		ret = tmp;
		break;
	}

	return ret;
}
