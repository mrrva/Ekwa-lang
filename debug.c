
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>

extern int runtime_varlencmp(char *, char *);

int main() {
	/*int sp;
	__asm__  ("movl %%ebp, %0" : "=r" (sp));
*/
	/*char *ptr1, *ptr2;
	uint32_t tmp = 2;
	int res;

	ptr1 = (char *)malloc(9);
	ptr2 = (char *)malloc(9);

	memcpy(ptr1 + 1, &tmp, 4);
	tmp = 8;
	memcpy(ptr2 + 1, &tmp, 4);

	res = runtime_varlencmp(ptr1, ptr2);
	printf("res: %d\n", res);*/
	/*

00000517 <_ekwa_exit>:
 517:	b8 01 00 00 00       	mov    eax,0x1
 51c:	c3                   	ret    

0000051d <_start>:
 51d:	e8 f5 ff ff ff       	call   517 <_ekwa_exit>
 522:	e8 f0 ff ff ff       	call   517 <_ekwa_exit>
 527:	e8 eb ff ff ff       	call   517 <_ekwa_exit>
 52c:	e8 e6 ff ff ff       	call   517 <_ekwa_exit>

	*/
	signed int num = 0xfff517 - (0xfff51d + 5);

	//num = (signed int *)malloc(20);

	//memset(num + 3, 0xf5, 1);
	//memset(num + 2, 0xff, 1);
	//memset(num + 1, 0xff, 1);
	//memset(num + 0, 0xff, 1);

	printf("%d - %x - %d\n", num, num, 0xfffff5);

	//signed int num = - 1;

	//printf("%x\n", num);

	//return 0;
}

//1303 - cur
//1309 - f

//303 + 5 - 1309