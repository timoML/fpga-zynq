#include <stdio.h>

#define BASE_DTIM 0x20000000
#define SIZE_TEST 0x4000

int main(void) {

	for(int i=BASE_DTIM; i<BASE_DTIM + SIZE_TEST; i+=0x4){
	    printf("%x %x \n", (int *) i, *(int *)i);	
	}
}
