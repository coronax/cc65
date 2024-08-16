/* Project:65 C Library
 * Christopher Just
 *
 * int __fastcall__ __sysrename (const char* src, const char* dst);
 * 
 */

#include <fcntl.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include <p65.h>

// a private fn to verify that the opened fd is of a particular type.
// If we had stat(), we could just use that, but we don't. yet?
int __fastcall__ getfdtype(int fd);

int __fastcall__ _syscp (const char* src, const char* dest);
int __fastcall__ _sysrm (const char* name);

// So I have a limitation on my SD card filesystem: The Arduino SD library
// doesn't have a file rename function. So let's implement this (for files
// only) as a copy and remove. I suppose ultimately we could handle 
// directories as a deep copy & recursive remove, but yech.
// We return a P:65 error code. Which we can create with errno values or'ed
// with 0x80
int __fastcall__ _sysrename (const char* src, const char* dst)
{
    int fd;
    int tp;

    fd = open(src, O_RDONLY);
    if (fd != -1)
    {
        tp = getfdtype(fd);
        close(fd);
        if (tp == 2)
            return P65_EISDIR;
        else
        {
            int result = _syscp(src,dst);
            if (result == 0)
                return _sysrm(src);
            else
                return result;
        }
    }
    else
    {
        return ENOENT | 0x80;
    }
}