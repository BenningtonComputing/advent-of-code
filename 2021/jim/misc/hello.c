#include <stdio.h>
#include <limits.h>
int main(){
    printf("Hello.\n");
    printf("The sizeof(int) is %lu bytes.\n", sizeof(int));
    printf("The largest int is %d.\n", INT_MAX);
    printf("The sizeof(long) is %lu bytes.\n", sizeof(long));    
    printf("The largest long is %lu.\n", LONG_MAX);    
    printf("The sizeof(void*) is %lu bytes.\n", sizeof(void*));    
    return 0;
}
