#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>

int main(void)
{
    char byte;

    /* We block until urandom has been initialized */
    if (syscall(SYS_getrandom, &byte, sizeof byte, 0) == -1)
        perror("getrandom");

    return 0;
}
