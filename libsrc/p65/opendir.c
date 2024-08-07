/* Project:65 C Library
 * Christopher Just
 */

#include <fcntl.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>

#include "dir.h"


// a private fn to verify that the opened fd is of a particular type.
// If we had stat(), we could just use that, but we don't. yet?
int __fastcall__ getfdtype(int fd);


DIR* opendir (const char* name)
{
    int fd;
    int tp;

    fd = open(name, O_RDONLY);
    if (fd != -1)
    {
        tp = getfdtype(fd);
        //printf ("fdtype is %d\r\n",tp);
        if (getfdtype(fd) == 2)
        {
            DIR* dir = malloc(sizeof(DIR));
            if (dir)
            {
                dir->m_fd = fd;
                return dir;
            }
            else
            {
                close(fd);
                __seterrno(ENOMEM);
                return NULL;
            }
        }
        else
        {
            close(fd);
            //__seterrno(EINTR);
            __mappederrno(P65_ENOTDIR);
            return NULL;
        }
    }
    else
    {
        return NULL;
    }
}