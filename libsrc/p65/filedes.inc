; File descriptor table & utility functions.
; Project:65 C library
; Christopher Just
;

.struct FDTAB_ENTRY
        DEVTAB_INDEX .byte
        FLAGS       .byte       ; access mode. O_RDONLY, etc.
        TYPE         .byte      ; 0 for stream, 1 for regular file, 2 for directory
        RESERVED     .byte
.endstruct

; File descriptor methods defined in filedes.s
.global     allocfd, freefd, getfdflags, getfddevice, setfd, _getfdtype
.global     fdtab

MAX_FDS = 8
