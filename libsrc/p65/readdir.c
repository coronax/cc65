/* Project:65 C Library
 * Christopher Just
 *
 * struct dirent* __fastcall__ readdir (DIR* dir);
 * 
 */


#include "dir.h"

#include <unistd.h>
#include <stdlib.h>



struct dirent* __fastcall__ readdir(DIR *dir)
{
    if (sizeof(struct dirent) == read(dir->m_fd,&dir->m_dirent,sizeof(struct dirent)))
        return &dir->m_dirent;
    else
        return NULL;
}

