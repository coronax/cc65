/* Project:65 C Library
 * Christopher Just
 *
 * int __fastcall__ __sysremove (const char* name);
 * 
 */

#include <fcntl.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>


// a private fn to verify that the opened fd is of a particular type.
// If we had stat(), we could just use that, but we don't. yet?
int __fastcall__ getfdtype(int fd);
int __fastcall__ _sysrmdir (const char* name);
int __fastcall__ _sysrm (const char* name);

// An actual UNIX-style remove will rm files and rmdir directories. Which is
// a little awkward for us. Luckily we solved that problem when we were working
// on opendir().
// We return a P:65 error code. Which we can create with errno values or'ed
// with 0x80
int __fastcall__ _sysremove (const char* name)
{
    int fd;
    int tp;

    fd = open(name, O_RDONLY);
    if (fd != -1)
    {
        tp = getfdtype(fd);
        close(fd);
        if (tp == 2)
            return _sysrmdir(name);
        else
            return _sysrm(name);
    }
    else
    {
        // return whatever error got left behind by open().
        return errno | _oserror | 0x80; //ENOENT | 0x80;   // ie P65_ENOENT
    }
}