//
// Project:65 C library
// Christopher Just
//
// int __fastcall__ clock_gettime (clockid_t clk_id, struct timespec *tp);
//

#include <time.h>
#include <errno.h>
#include <p65.h>
#include <stdio.h>

// A quandary and/or bug; I'm not sure yet. It seems like common/time.s
// calls clock_gettime without setting a value for clk_id. It's just
// allocating an uninitialized byte of stack.
// Which means we can't do any real checking here. I mean, it's not like
// I actually _have_ multiple clocks, but it is weird.

int __fastcall__ clock_gettime (clockid_t clk_id, struct timespec *tp)
{
    // we're basically going to ignore clk_id for now.
    if (clk_id != 0xff/*== CLOCK_REALTIME*/)
    {
        printf("ok clock_gettime - clock is %d\r\n", clk_id);
        tp->tv_sec = *(unsigned long*)P65_TOD_SECONDS;
        // convert from 10ms increments to nanoseconds
        tp->tv_nsec = 10000000 * *(unsigned char*)P65_TOD_SECONDS100; 
        return 0;
    }
    else
    {
        //printf("clock_gettime - clock is %d\r\n", clk_id);
        errno = EINVAL;
        return -1;
    }

}


int __fastcall__ clock_settime (clockid_t clk_id, const struct timespec *tp)
{
    if (clk_id == CLOCK_REALTIME)
    {
        printf("ok clock_settime - clock is %d\r\n", clk_id);
        *(unsigned long*)P65_TOD_SECONDS = tp->tv_sec;
        *(unsigned char*)P65_TOD_SECONDS100 = (unsigned char)(tp->tv_nsec / 10000000);
        return 0;
    }
    else
    {
        //printf("clock_settime - clock is %d\r\n", clk_id);
        errno = EINVAL;
        return -1;
    }

}
