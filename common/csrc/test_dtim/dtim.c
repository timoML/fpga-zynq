#include <stdio.h>

#define BASE_DTIM 0x20000000
#define SIZE_TEST 0x4000

int main(void) {
	int j=0;
	int fail=0;	
	for(int i=BASE_DTIM; i<BASE_DTIM + SIZE_TEST; i+=0x4){
	    // write
		int * p_mem = (int *)i;
	    *p_mem = j;
	    // test
		if(j != *p_mem){
			fail = j;
	    }
	    j++;
	}
    	
	if(fail != 0){
	    printf("DTIM memory test failed. Last error at j=%d \n", fail);	
	    return 1;
		// error code 1337: crashed while memory access, DTIM there?
	}
	else{
	    printf("Passed %d. DTIM ok. \n", j);
	    return 0;
	}
}
