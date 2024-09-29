#include <time.h>
#include <unistd.h>


// sleep for specified milliseconds. Note that our resolution is 10ms.
/* We cannot implement this function without a working clock function */
#if defined(CLOCKS_PER_SEC)
unsigned __fastcall__ msleep (unsigned wait)
{
    clock_t goal = clock () + ((clock_t) wait) * CLOCKS_PER_SEC / 1000;
    while ((long) (goal - clock ()) > 0) ;
    return 0;
}
#endif



