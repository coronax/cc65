/* Project:65 C Library
 * Chrisotpher Just
 */


#include "dir.h"


#include <unistd.h>
#include <stdlib.h>
//#include <errno.h>



struct dirent *readdir(DIR *dir)
{
    static struct dirent ent;
    if (sizeof(struct dirent) == read(dir->fd,&ent,sizeof(struct dirent)))
        return &ent;
    else
        return NULL;
}

