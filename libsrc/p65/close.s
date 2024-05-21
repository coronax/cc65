; Project:65 C Library
; int __fastcall__ close (int fd)
;

        .export _close
 	    .include "p65.inc"


.proc _close
        jsr P65_SETDEVICE   ; fd is already in accumulator
        jsr P65_CLOSE_DEV
        ; We don't currently have any error codes that can be returned.
        ; So we just return 0 in AX.
        lda #0
        ldx #0
        rts
.endproc