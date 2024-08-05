/* Project:65 C Library
 * Chrisotpher Just
 */

#include <fcntl.h>
#include <stdlib.h>
#include <errno.h>
#include "dir.h"


int closedir (DIR* dir)
{
    int result = -1;
    if (dir == NULL)
    {
        __seterrno(EBADF);
    }
    else
    {
        result = close(dir->fd);
        free(dir);
    }
    return result;
}