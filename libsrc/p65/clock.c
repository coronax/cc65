//
// Project:65 C library
// Christopher Just
//
// clock_t __fastcall__ clock (void);
//

#include <time.h>
#include <p65.h>

// Clock() is supposed to return the amount of processor time used by the
// program. In the P:65 implementation, this is just wall-clock time because
// we can't distinguish anything else.
// The value returned in this implementation is the global sytem time, 
// which can be set with clock_settime(). If never set, it's initialized to
// 0 at system startup, not the program start time.
// This count rolls over every 497 days.
clock_t __fastcall__ clock (void)
{
    clock_t result = *(unsigned char*)P65_TOD_SECONDS100;
    result += 100 * *(unsigned long*)P65_TOD_SECONDS;
    return result;
}
