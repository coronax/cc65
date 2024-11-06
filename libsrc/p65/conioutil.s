;
; Project:65 C library
; Christopher Just
;
; Several conio functions.
;


.export gotoxy, _cputc
.import _gotoxy, popa
.importzp ptr1, ptr2

.include "p65.inc"

; The assembly gotoxy is apparently stdcall 
; Problem: _gotoxy uses ptr1, but this is called by stuff that uses ptr1.
; As a kludge, we can temporarily use P65_ptr1 to stash it.
gotoxy:
        lda ptr1
        sta P65_ptr1
        lda ptr1+1
        sta P65_ptr1+1

        lda ptr2
        sta P65_ptr2
        lda ptr2+1
        sta P65_ptr2+1

        jsr     popa            ; Get Y
        jsr     _gotoxy

        lda P65_ptr1
        sta ptr1
        lda P65_ptr1+1
        sta ptr1+1

        lda P65_ptr2
        sta ptr2
        lda P65_ptr2+1
        sta ptr2+1

_cputc:
        pha
        lda #0
        jsr P65_SETDEVICE
        pla
        jmp P65_PUT_CHAR


; This method is called by _screensize.
screensize:
        ldx #80 ; yeah we're just gonna hardcode this.
        ldy #24
        rts

