; IO control utility functions.
; Project:65 C library
; Christopher Just
;
; int __cdecl__ ioctl (int fd, int op, ...)
;
        .export _ioctl
        .import incsp2, addysp, popax
        .include        "p65.inc"
        .include        "errno.inc"
        ;.include        "fcntl.inc"
        .include        "filedes.inc"

.proc _ioctl
        ; ioctl() is a variadic function, which means that Y stores
        ; the number of bytes of arguments that the caller placed on the 
        ; stack. I've borrowed this chunk of code from cbm/open.s which
        ; assumes there are at least 2 arguments (4 bytes), which are the 
        ; only ones I actually care about, and just discards the rest.
        dey                     ; Parm count < 4 shouldn't be needed to be...
        dey                     ; ...checked (it generates a c compiler warning)
        dey
        dey
        beq parmok          ; Branch if parameter count ok
        jsr addysp          ; Fix stack, throw away unused parameters
parmok:
        jsr popax       ; Get op from stack
        pha             ; save it for later
        jsr popax       ; get FD from stack

        cpx #$00            ; high byte of fd must be 0
        bne invalid
        cmp #MAX_FDS        ; low byte must be < MAX_FDS
        bcs invalid

        jsr getfddevice
        jsr P65_SETDEVICE   ; fd is already in accumulator
        pla
        jsr P65_DEV_IOCTL
        ; If X == 0, we just rts. Otherwise we need to set errno
        cpx #0
        bne report_err
        rts
report_err:
        and #$7f                ; clear high bit of errno value.
        jmp ___directerrno      ; eventually returns -1 in AX
        ;lda #0
        ;tax
        ;rts
invalid:
        pla                 ; because we still had op on the stack
        lda #EINVAL
        jmp ___directerrno      ; Eventually returns -1 in AX
.endproc