; Platform-specific error error handling
; Project:65 C library
; Christopher Just
;
; Based on cbm/oserror.s,
; 2000-05-17, Ullrich von Bassewitz
; 2014-05-28, Greg King
;
; int __fastcall__ __osmaperrno (unsigned char oserror);
; /* Map a system-specific error into a system-independent code. */
;

.include "errno.inc"
.include "p65.inc"

.code

; A contains a P:65 OS error code (possibly 0).
; Returns a cc65 errno value in AX, and sets ___oserror if it's 
; not just the same as the return value.
.proc ___osmaperrno
        ; Quite a few P:65 error codes are just cc65 error codes with the high
        ; bit set.
        ;pha
        ;jsr P65_PUT_HEXIT
        ;pla
        cmp #(EUNKNOWN | $80)
        bmi is_errno            ; the error code is a cc65 errno code (with the high bit set)

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

is_errno:       ; result is an inverted errno code
        and     #$7f            ; clear the high bit
        ;pha
        ;jsr P65_PUT_HEXIT
        ;pla
        ldx     #$00
        stz     ___oserror      ; If we're returning EXACTLY a cc65 error value, we shouldn't return anything in oserror.
        rts
.endproc

.rodata

; So at the moment I don't have any well-definied error conditions
; but we'll probably come up with those as we work on IO &c.
; See asminc/errno.inc for the error types - EUNKNOWN etc.

ErrTab:
        .byte   P65_ENOTDIR, EBADF       ; Something that wanted a directory didn't get one
        .byte   P65_EISDIR,  EBADF       ; Something that didn't want a directory got one

ErrTabSize = (* - ErrTab)
