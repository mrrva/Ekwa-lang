
#include "ekwa.h"
/*-------------------------------------------------------*/
bool ekwa_readbytes(struct ekwa_bytecode **list,
	unsigned char *bytes, size_t size) {
	unsigned char *ptr = bytes;
	struct ekwa_bytecode line;
	uint16_t len = 0;
	size_t num = 0;

	if (!bytes || size < 3) {
		return false;
	}

	while (num++, ptr && ptr != NULL) {
		if (*ptr >= EKWA_END || *ptr == 0x00) {
			break;
		}

		line.token = *ptr;

		if (!(++ptr)) {
			printf("[E]: Invalid length 1 for %x"
				", line: %lu\n", *ptr, num);
			exit(1);
		}

		memcpy(&len, ptr, sizeof(uint16_t));
		ptr += sizeof(uint16_t);

		////////////////////// IT WILL BE REMOVED
		len >>= 8;

		if (len > ARGLEN || !ptr) {
			printf("[E]: Invalid arg 1 for %x"
				", line: %lu\n", *ptr, num);
			exit(1);
		}
		else if (len == 0) {
			line.len1 = 0;
			line.len2 = 0;
			ekwa_addbytecode(list, line);
			continue;
		}

		memcpy(line.arg1, ptr, len);
		line.len1 = len;
		ptr += len;

		if (!ptr) {
			printf("[E]: Invalid length 2 for %x"
				", line: %lu\n", *ptr, num);
			exit(1);
		}

		memcpy(&len, ptr, sizeof(uint16_t));
		ptr += sizeof(uint16_t);

		////////////////////// IT WILL BE REMOVED
		len >>= 8;

		if (len > ARGLEN || !ptr) {
			printf("[E]: Invalid arg 2 for %x"
				", line: %lu\n", *ptr, num);
			exit(1);
		}
		else if (len == 0) {
			line.len2 = 0;
			ekwa_addbytecode(list, line);
			continue;
		}

		memcpy(line.arg2, ptr, len);
		line.len2 = len;

		ekwa_addbytecode(list, line);
		ptr += len;
	}

	return true;
}
/*-------------------------------------------------------*/
void ekwa_addbytecode(struct ekwa_bytecode **list,
	struct ekwa_bytecode line) {
	size_t size = sizeof(struct ekwa_bytecode);
	struct ekwa_bytecode *ptr = *list, *buff;

	buff = (struct ekwa_bytecode *)malloc(size);

	if (!buff) {
		printf("[E]: Can't allocate memory.\n");
	}

	memcpy(buff, &line, size);
	buff->next = NULL;

	if (!ptr || ptr == NULL) {
		*list = buff;
		return;
	}

	while (ptr->next && ptr->next != NULL) {
		ptr = ptr->next;
	}

	ptr->next = buff;
}
/*-------------------------------------------------------*/
void ekwa_freebytecode(struct ekwa_bytecode **list) {
	struct ekwa_bytecode *ptr = *list, *tmp;

	if (!(*list) || (*list) == NULL) {
		return;
	}

	while (ptr && ptr != NULL) {
		tmp = ptr->next;
		free(ptr);
		ptr = tmp;
	}

	*list = NULL;
}