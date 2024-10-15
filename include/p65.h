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

// usleep would have been ridiculous. But waiting for milliseconds makes sense.
// Note that the P:65 clock resolution is 10 ms.
unsigned __fastcall__ msleep (unsigned wait);

// On success, returns 0 or an op-specific value.
// On failure, returns -1 & sets errno/oserror
int __cdecl__ ioctl(int fd, int op, ...);

// ioctl ops
#define IO_INIT				0
#define IO_FLUSH			1
#define IO_AVAILABLE		2		// Returns # bytes available with blocking.

#define IO_SER_RATE			36	    // not implemented yet

#define IO_TTY_ECHO_ON		32
#define IO_TTY_ECHO_OFF		33
#define IO_TTY_RAW_MODE		34
#define IO_TTY_COOKED_MODE	35

// These are in here because things like DEV_LSEEK and FS_STAT use them:
//void** P65_ptr1 = (void**)0x30;
//void** P65_ptr2 = (void**)0x32;
//#define P65_ptr1 (void*)0x30
//#define P65_ptr2 (void*)0x32;

#endif