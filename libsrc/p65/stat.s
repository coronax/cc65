; POSIX IO functions
; Project:65 C Library
; Christopher Just
;
; int __fastcall__ stat(const char *pathname, struct stat *statbuf);
;

        .export _stat
        .import popax, ___mappederrno
        .include "p65.inc"
;        .include "errno.inc"  
;        .include "filedes.inc"

; This gets called with statbuf in AX and pathname on the parameter stack
.proc _stat
        sta P65_ptr1        ; Save statbuf to P65 tmp 1
        stx P65_ptr1+1
        jsr popax           ; pop pathname into AX
        jsr P65_FS_STAT
        jmp ___mappederrno   ; Store into __oserror, set errno, return 0/-1
.endproc