
#include "ekwa.h"
/*-------------------------------------------------------*/
size_t ekwa_readfile(unsigned char **ptr, FILE *fp) {
	unsigned char tmp[100], *buff;
	size_t len, blen = 0;

	if (!(buff = (unsigned char *)malloc(1))) {
		printf("[E]: Can't allocate memory.\n");
		return 0;
	}

	while ((len = fread(tmp, 1, 100, fp)) > 0) {
		if (blen > CODEMAX) {
			printf("[W]: A lot of byte code.\n");
			break;
		}

		blen += len;
		buff = (unsigned char *)realloc(buff, blen);

		if (!buff) {
			printf("[E]: Can't realloc memory.\n");
			exit(1);
		}

		memcpy(buff + blen - len, tmp, len);
	}

	*ptr = buff;
	fclose(fp);

	return blen;
}
/*-------------------------------------------------------*/
int main(int argc, char *argv[]) {
	struct ekwa_bytecode *codes = NULL;
	struct ekwa_function *funcs = NULL;
	unsigned char *buffer;

	size_t size;
	FILE *fp;

	if (argc != 2) {
		printf("Error: Incorrect input data.\n");
		return 1;
	}

	if (!(fp = fopen(argv[1], "rb"))) {
		printf("Error: %s doesn't exists.\n", argv[1]);
		return 1;
	}

	if ((size = ekwa_readfile(&buffer, fp)) == 0) {
		printf("[E]: Bytefile is empty.\n");
		return 1;
	}

	if (!ekwa_readbytes(&codes, buffer, size)
		|| codes == NULL) {
		printf("[E]: Incorrect bytecode file.\n");
		return 1;
	}

	free(buffer);

	ekwa_parsefunctions(codes, &funcs);
	ekwa_freebytecode(&codes);

	if (funcs == NULL) {
		printf("[E]: Can't find main function.\n");
		return 1;
	}

	ekwa_codegen(funcs);
	return 0;
}
