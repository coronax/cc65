; Project:65 C Library
; Christopher Just
;
; int __cdecl__ _syscp (const char* src, const char* dst)
;

        .export __syscp, _copyfile
        .import popax
        .import ___mappederrno
        .include "p65.inc"


; __syscp is basically just glue to convert from cc65 stack to a call to P65_FS_CP
; Returns a P:65 error code
.proc __syscp
        ; AX contains dst. We need to copy this to P65's ptr2
        sta P65_ptr2
        stx P65_ptr2 + 1
        jsr popax                   ; Get src from stack
        jmp P65_FS_CP
.endproc


; C-callable version. Returns 0 or -1 & sets errno/oserror
.proc   _copyfile

        jsr     __syscp             ; Call __syscp to do the actual work
        jmp     ___mappederrno      ; Set errno/oserror & return 0 or -1

.endproc
