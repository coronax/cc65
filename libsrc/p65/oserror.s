;
; int __fastcall__ __osmaperrno (unsigned char oserror);
; /* Map a system-specific error into a system-independent code. */
;

        .include        "errno.inc"
        .include "p65.inc"

.code

___osmaperrno:
        ldx     #ErrTabSize
@L1:    cmp     ErrTab-2,x      ; Search for the error code
        beq     @L2             ; Jump if found
        dex
        dex
        bne     @L1             ; Next entry

; Code not found, return EUNKNOWN

        lda     #<EUNKNOWN
        ldx     #>EUNKNOWN
        rts

; Found the code

@L2:    lda     ErrTab-1,x
        ldx     #$00            ; High byte always zero
        rts

.rodata

; So at the moment I don't have any well-definied error conditions
; but we'll probably come up with those as we work on IO &c.
; See asminc/errno.inc for the error types - EUNKNOWN etc.

ErrTab:
        .byte   P65_ENOTDIR, EBADF       ; Something that wanted a directory didn't get one
        .byte   P65_EISDIR,  EBADF       ; Something that didn't want a directory got one

ErrTabSize = (* - ErrTab)
