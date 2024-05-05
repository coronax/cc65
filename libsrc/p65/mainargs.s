;
; argc/argv initialization for Project:65 computer
;

        .constructor initmainargs, 24
        .import __argc, __argv
 	    .include "p65.inc"

        .segment "ONCE"

initmainargs:
        ; We can just copy these values from the P65 kernel's
        ; argc/argv.
        lda     P65_argc
        sta     __argc
        stz     __argc+1
        lda     #<P65_argv0L
        sta     __argv
        lda     #>P65_argv0L
        sta     __argv+1
        rts
