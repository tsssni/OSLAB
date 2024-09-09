#include <stdio.h>
#include <stdlib.h>
#include "foo.h"

int main() {
    int *a = malloc(8);
    printf("addr is        0x%016lx\n", a);
    printf("addr + 0x10 is 0x%016lx\n", foo(a));
}