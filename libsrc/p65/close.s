; POSIX IO functions
; Project:65 C Library
; Christopher Just
;
; int __fastcall__ close (int fd)
;

        .export _close
        .importzp tmp1
        .include "p65.inc"
        .include "errno.inc"
        .include "filedes.inc"

; Closes the file descriptor passed in AX.
; On success, returns 0.
; if FD is outside the range [0,MAX_FDS), returns -1 and sets errno
; to EBADF.
.proc _close
        sta tmp1            ; Save FD for later
        cpx #$00            ; high byte of fd must be 0
        bne bad_fd
        cmp #MAX_FDS        ; low byte must be < MAX_FDS
        bcs bad_fd
        jsr getfdflags      ; check if file is open for reading
        beq bad_fd
        lda tmp1
        jsr getfddevice
        jsr P65_SETDEVICE   ; fd is already in accumulator
        jsr P65_CLOSE_DEV
        lda tmp1
        jsr freefd
        ; P65_CLOSE_DEV doesn't return any meaningful errors. For now, we
        ; just return 0 in AX.
        lda #0
        tax
        rts
bad_fd:
        lda #EBADF
        jmp ___directerrno      ; Eventually returns -1 in AX
.endproc