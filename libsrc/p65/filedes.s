; File descriptor table & utility functions.
; Project:65 C library
; Christopher Just
;
; Based on appleii/filedes.s, Oliver Schmidt, 30.12.2004
;

        .include        "errno.inc"
        .include        "fcntl.inc"
        .include        "filedes.inc"


; Note that most of these utility functions only take a single byte for the
; file descriptor. Therefore the caller is responsible for making sure that
; the fd is within the valid range [0,MAX_FDS).

; Allocates a currently unused file descriptor.
; On success, returns fd in A and clears carry.
; On failure, sets carry.
.proc allocfd
        ldx #0
loop:
        lda fdtab + FDTAB_ENTRY::FLAGS,x
        beq found_available
        inx
        inx
        cpx #(MAX_FDS + MAX_FDS)
        bne loop
        ; no free files
        sec
        rts
found_available:
        txa
        lsr     ; divide by 2 to convert back to fd.
        clc
        rts
.endproc


; Frees a file descriptor (which basically means setting its flags & device 
; index to 0). Note that this function does not close the underlying device.
; Pre: fd is in [0,MAX_FDS)
; A contains FD to free
; On success, carry is clear and A contains EOK.
; On failure, carry is set and A contains error
.proc freefd
        ; Convert handle to fdtab slot
        .assert .sizeof(FDTAB_ENTRY) = 2, error
        asl

        ; Clear the fdtab. Should closing a closed fd
        ; be an error? Probably unnecessary.
        tay
        lda #0
        sta fdtab + FDTAB_ENTRY::DEVTAB_INDEX,y
        sta fdtab + FDTAB_ENTRY::FLAGS,y
        rts
.endproc


; Sets the P65 device index and flags for a file descriptor.
; Pre: fd is in [0,MAX_FDS)
; A = fd
; X = p65 device index
; Y = flags/filemode
.proc setfd
        phy
        asl
        tay
        txa
        sta fdtab + FDTAB_ENTRY::DEVTAB_INDEX,y
        pla
        sta fdtab + FDTAB_ENTRY::FLAGS,y
        rts
.endproc


; Retrieves the P65 device index for the fd passed in A.
; Pre: fd is in [0,MAX_FDS)
; Uses AX
.proc getfddevice
        asl
        tax
        lda fdtab + FDTAB_ENTRY::DEVTAB_INDEX,x
        rts
.endproc


; Retrieves the flags/filemode for the fd passed in A
; Pre: fd is in [0,MAX_FDS)
; Returns 0 if fd isn't open.
; Uses AX
.proc getfdflags
        asl
        tax
        lda fdtab + FDTAB_ENTRY::FLAGS,x
        rts
.endproc




.data

fdtab:  .assert .sizeof(FDTAB_ENTRY) = 2, error

        .byte   4               ; stdin defaults to device 0
        .byte   O_RDONLY        ; and is readonly

        .byte   0               ; stdout defaults to device 0
        .byte   O_WRONLY        ; and is writeonly

        .byte   0               ; stderr defaults to device 0
        .byte   O_WRONLY        ; and is writeonly

.repeat MAX_FDS - 3
        .byte   0
        .byte   0
.endrepeat
;        .res    (MAX_FDS - 3) * .sizeof(FDTAB_ENTRY) ; remaining FDs



