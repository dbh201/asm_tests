#include <stdio.h>

int asm_add(int a, int b) {
	int c = 0;
	asm (	
		"mov %2, %%eax\n"
		"mov %1, %%ebx\n"
		"add %%ebx, %%eax\n"
		"mov %%eax, %0\n"
		: "=r"(c)
		: "r"(a),"r"(b)
		: "rax","rbx"
		);
	return c;

}
int main(int argc, char* argv[]) {
	printf("%i",asm_add(34,21));
	return 0;
}
