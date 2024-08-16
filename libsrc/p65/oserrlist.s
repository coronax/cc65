; Platform-specific error list
; Project:65 C library
; Christopher Just
;
; Based on cbm/oserrlist.s,
; 2002-07-18, Ullrich von Bassewitz
; 2014-05-28, Greg King
;
; Defines the platform-specific error list.
;
; The table is built as a list of entries:
;
;       .byte   entrylen
;       .byte   errorcode
;       .asciiz errormsg
;
; and, terminated by an entry with length zero that is returned if the
; error code could not be found.
;

        .export         __sys_oserrlist
        .include "p65.inc"
;----------------------------------------------------------------------------
; Macros used to generate the list (may get moved to an include file?)

; Regular entry
.macro  sys_oserr_entry         code, msg
        .local  Start, End
Start:  .byte   End - Start
        .byte   code
        .asciiz msg
End:
.endmacro

; Sentinel entry
.macro  sys_oserr_sentinel      msg
        .byte   0                       ; Length is always zero
        .byte   0                       ; Code is unused
        .asciiz msg
.endmacro

;----------------------------------------------------------------------------
; The error message table

.rodata

__sys_oserrlist:
        sys_oserr_entry          P65_ENOTDIR, "Not a directory"
        sys_oserr_entry          P65_EISDIR, "Is a directory"
        sys_oserr_sentinel      "Unknown OSerror"
