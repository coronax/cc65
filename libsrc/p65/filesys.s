;
; Project:65 C library
; Christopher Just
;
; int __fastcall__ __sysmkdir (const char* name);
;


.include "p65.inc"
.export __sysmkdir, __sysrmdir, __sysrm


__sysmkdir = P65_FS_MKDIR   ; We can just call the kernel fn directly.

__sysrmdir = P65_FS_RMDIR   ; We can just call the kernel fn directly.

__sysrm = P65_FS_RM         ; I'd rather this was called unlink, but cc65 already has 
                            ; an unlink() that calls remove, which feels backwards.

; An actual UNIX-style remove will rm files and rmdir directories. Which is
; a little awkward for us. Luckily we solved that problem when we were working
; on opendir().
;.proc __sysremove

;.endproc

