/* Project:65 C Library
 * Christopher Just
 *
 * int __fastcall__ closedir (DIR* dir);
 * 
 */

#include <fcntl.h>
#include <stdlib.h>
#include <errno.h>
#include "dir.h"


int __fastcall__ closedir (DIR* dir)
{
    int result = -1;
    if (dir == NULL)
    {
        __seterrno(EBADF);
    }
    else
    {
        result = close(dir->m_fd);
        free(dir);
    }
    return result;
}