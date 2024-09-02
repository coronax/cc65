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

// Values for stat::st_mode 
// For P:65, these match the values used for file type in dirent::d_type.
#define S_IFIFO  0x00
#define S_IFREG  0x01
#define S_IFDIR  0x02

// On success, returns 0.
// On failure, returns -1 & sets errno/oserror
int copyfile (const char* src, const char* dst);

#endif