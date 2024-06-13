; File descriptor table & utility functions.
; Project:65 C library
; Christopher Just
;

.struct FDTAB_ENTRY
        DEVTAB_INDEX .byte
        FLAGS       .byte
.endstruct

; File descriptor methods defined in filedes.s
.global     allocfd, freefd, getfdflags, getfddevice, setfd
.global     fdtab

MAX_FDS = 8
