;
; Project:65 C library
; Christopher Just
;
; int __fastcall__ __sysmkdir (const char* name);
;


.include "p65.inc"
.export __sysmkdir, __sysrmdir, __sysrm
.import popax


.proc __sysmkdir            ; So mkdir() is varargs and therefore stdcall.
    jsr popax               ; So we have to clean up the stack.
    jmp P65_FS_MKDIR
.endproc

__sysrmdir = P65_FS_RMDIR   ; We can just call the kernel fn directly.

__sysrm = P65_FS_RM         ; I'd rather this was called unlink, but cc65 already has 
                            ; an unlink() that calls remove, which feels backwards.


;.endproc

