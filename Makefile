
all:
	gcc -Wall ekwa.c reader.c codegen.c opcodes.c tokens.c -std=c11 -o ekwa

runtime:
	nasm -f elf32 runtime.s -o runtime.o -lc
	ld -shared -o libruntime.so runtime.o -m elf_i386 -lc
	gcc -Wall debug.c -o debug -L"./" -I"./" -Wl,--rpath="./" -lruntime -std=c11 -m32

de:
	objdump -M intel intel-mnemonic -d libruntime.so

debug:
	gcc debug.c -o debug

test:
	nasm -f elf32 test.s -o test.o -lc
	ld -s -o test test.o -m elf_i386