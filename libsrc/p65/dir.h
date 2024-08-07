/* Project:65 C Library
 * Christopher Just
 */

#ifndef _DIR_H
#define _DIR_H


#include <dirent.h>

struct DIR
{
    int m_fd;
    struct dirent m_dirent;
};

#endif
