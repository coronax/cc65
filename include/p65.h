#ifndef _P65_H_
#define _P65_H_

// OS-specific codes
#define P65_ESYNTAX  (0x80 | 19)
#define P65_ENOTDIR  (0x80 | 20)
#define P65_EISDIR   (0x80 | 21)

// timer values. Making these available as raw values for now.
// Would it be interesting to make a timer device at some point?
#define P65_TOD_SECONDS 0x0206
#define P65_TOD_SECONDS100 0x020a

// On success, returns 0.
// On failure, returns -1 & sets errno/oserror
int copyfile (const char* src, const char* dst);

#endif