
test:
	rm -f runtime.o
	rm -f libruntime.so
	nasm -f elf32 runtime.s -o runtime.o -lc -g
	ld -shared -o libruntime.so runtime.o -m elf_i386 -lc
	gcc -Wall test.c -o test -L"./" -I"./" -Wl,--rpath="./" -lruntime -std=c11 -m32 -g

debug:
	objdump -M intel intel-mnemonic -d test