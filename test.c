#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>

extern uint32_t _runtime_IFNE(char *, char *);
extern uint32_t _runtime_IFE(char *, char *);
extern uint32_t _runtime_IFS(char *, char *);
extern uint32_t _runtime_IFB(char *, char *);
extern void _runtime_CAT(char *, char *); 
extern void _runtime_VAL(char *, char *);
extern void _runtime_ADD(char *, char *);
extern void _runtime_PBUF(char *);
extern void _runtime_BUFF(char *);
extern void _runtime_WRT(char *);
extern char *_runtime_VAR(char);

int main() {
	// New var
	char *var1 = _runtime_VAR(0), *var2;
	printf("New var: %p & Type: %d\n", var1, var1[0]);

	// Set var value
	char *hl = "Hello world!", *content, *d;
	uint32_t size = strlen(hl) + 1, vsize;

	content = (char *)malloc(size + 4);
	memcpy(content + 4, hl, size);
	memcpy(content, &size, 4);

	_runtime_VAL(var1, content);

	memcpy(&vsize, var1 + 1, 4);
	memcpy(&d, var1 + 5, sizeof(char *));
	printf("Var size: %d, content: %s, ptr content:"
		" %p\n", vsize, d, d);

	// Set buffer value and write to var (as pointer)
	var2 = _runtime_VAR(0);
	_runtime_PBUF(var1);
	_runtime_WRT(var2);

	memcpy(&vsize, var2 + 1, 4);
	memcpy(&d, var2 + 5, sizeof(char *));
	printf("> From buffer:\nVar size: %d, content: %s, "
		"ptr content: %p\n", vsize, d, d);

	// Set buffer value and write to var (as new pointer)
	_runtime_BUFF(var1);
	_runtime_WRT(var2);

	memcpy(&vsize, var2 + 1, 4);
	memcpy(&d, var2 + 5, sizeof(char *));
	printf("> From buffer:\nVar size: %d, content: %s, "
		"ptr content: %p\n", vsize, d, d);

	// Vars comparing (are equal)
	uint32_t res = _runtime_IFE(var1, var2);
	printf("Comparing result: %d\n", res);

	// Vars comparing (aren't equal)
	res = _runtime_IFNE(var1, var2);
	printf("Comparing result (IFE): %d\n", res);

	// New integer vars with comparing
	char *var_num1 = _runtime_VAR(3);
	char *var_num2 = _runtime_VAR(3);

	free(content);
	size = 4;
	content = (char *)malloc(4 + size);

	memcpy(content + 4, &(int){10}, size);
	memcpy(content, &size, 4);
	_runtime_VAL(var_num1, content);

	memcpy(content + 4, &(int){50}, size);
	_runtime_VAL(var_num2, content);

	int *va1, *va2;

	memcpy(&va1, var_num1 + 5, 4);
	memcpy(&va2, var_num2 + 5, 4);

	printf("Var addresses: %p : %p\nVar val: %d : %d\n",
		var_num1, var_num2, *va1, *va2);

	res = _runtime_IFS(var_num1, var_num2);
	printf("Comparing result (IFS): %d\n", res);

	res = _runtime_IFB(var_num1, var_num2);
	printf("Comparing result (IFB): %d\n", res);

	// New float vars with comparing
	char *var_flt1 = _runtime_VAR(4);
	char *var_flt2 = _runtime_VAR(4);

	free(content);
	size = sizeof(float);
	content = (char *)malloc(4 + size);

	memcpy(content + 4, &(float){6.0}, size);
	memcpy(content, &size, 4);
	_runtime_VAL(var_flt1, content);

	memcpy(content + 4, &(float){4.2}, size);
	_runtime_VAL(var_flt2, content);

	res = _runtime_IFS(var_flt1, var_flt2);
	printf("Comparing result (IFS): %d\n", res);

	// Strings concatenation
	char *var_str1 = _runtime_VAR(0);
	char *var_tmp = _runtime_VAR(0);
	size = strlen(hl);
	free(content);

	content = (char *)malloc(size + 4);
	memcpy(content + 4, hl, strlen(hl));
	memcpy(content, &size, 4);

	_runtime_VAL(var_str1, content);
	_runtime_CAT(var_str1, var1);
	_runtime_WRT(var_tmp);

	memcpy(&d, var_tmp + 5, sizeof(char *));
	size = (uint32_t)*(var_tmp + 1);
	printf("Concat: %s, size: %d\n", d, size);

	// Add to number (int)
	_runtime_ADD(var_num1, var_num2);
	_runtime_WRT(var_num1);
	memcpy(&d, var_num1 + 5, 4);
	printf("Add res: %d\n", (int)*d);

	// Add to number (float)
	_runtime_ADD(var_flt1, var_flt2);
	_runtime_WRT(var_flt1);
	memcpy(&d, var_flt1 + 5, 4);
	printf("Fadd res: %f\n", (float)*d);
}