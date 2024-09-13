; POSIX IO functions
; Project:65 C Library
; Christopher Just
;
; long int __fastcall__ lseek (int fd, long int offset, int whence)
;

        .export _lseek
        .importzp tmp1, tmp4, sreg
        .import popax
        .include "p65.inc"
        .include "errno.inc"
        .include "filedes.inc"


.proc _lseek

        pha             ; stash low byte of whence
        ; OK, I had a moment of confusion about the order of bytes on the parameter stack.
        ; Offset is being pushed on the stack as a single 4-byte value. The high word is
        ; pushed first so that in-memory the 4 bytes are little endian.
        jsr popax       ; read low word of offset
        sta P65_ptr1
        stx P65_ptr1+1
        jsr popax       ; read high word of offset
        sta P65_ptr2
        stx P65_ptr2+1

        jsr popax       ; get file descriptor from stack
        sta tmp4        ; stash it in tmp4
        cpx #0          ; and let's make sure fd is valid, so
        bne bad_fd      ; it's 0 <= fd < max_fds
        cmp #MAX_FDS
        bcs bad_fd

        jsr getfdflags  ; check if file is open
        beq bad_fd

flags_ok:
        lda tmp4        ; Retrieve fd
        jsr getfddevice
        jsr P65_SETDEVICE   ; set active device
        pla                 ; load whence into A
        jsr P65_DEV_SEEK
        ; check error code in A
        cmp #0
        bne ret_error

        lda P65_ptr2            ; Copy the result in AX & sreg
        ldx P65_ptr2+1
        sta sreg
        stx sreg+1
        lda P65_ptr1
        ldx P65_ptr1+1
        rts                     ; return OK

bad_fd:
        pla                     ; We still have the whence argument on the stack.
        lda #P65_EBADF          ; pass thru a P65 style error code to ___mappederrno

ret_error:
        ldx #$ff
        stx sreg                ; fill in high word of 32-bit retval, because ___directerrno won't
        stx sreg+1
        jmp ___mappederrno
.endproc
