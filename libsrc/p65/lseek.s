; POSIX IO functions
; Project:65 C Library
; Christopher Just
;
; long int __fastcall__ lseek (int fd, long int offset, int whence)
;

        .export _lseek
        .importzp tmp1, tmp4, sreg
        .import popax, pushax
        .include "p65.inc"
        .include "errno.inc"
        .include "filedes.inc"
        .include "_file.inc"
        .include "stdio.inc"    ; for FOPEN_MAX

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
        ;bne flags_ok
        ;lda EINVAL      ; fd invalid (not open)
        ;jmp ___directerrno      ; eventually returns -1 in AX

flags_ok:
        lda tmp4        ; Retrieve fd
        jsr getfddevice
        jsr P65_SETDEVICE   ; set active device
        pla                 ; load whence into A
        jsr P65_DEV_SEEK
        


        ; check error code in A
        lda P65_ptr2+1      ; error if high byte is $80
        cmp #$80
        beq ret_error       ; put the return value in the right place
        lda P65_ptr2
        ldx P65_ptr2+1
        sta sreg
        stx sreg+1
        ;jsr pushax
        lda P65_ptr1
        ldx P65_ptr1+1
        rts                 ; return OK
ret_error:
        ;pha     ; save actual error code
        ;jsr P65_PUT_HEXIT
        ;sta tmp4
        ;ldx #$ff
        ;tax
        ;stx sreg
        ;stx sreg+1
        ;jsr pushax             ; high word of result
        ;lda tmp4
        lda #$ff
        ;tax
        ;jsr pushax
        sta sreg                ; fill in high word of ret val, because ___directerrno won't
        sta sreg+1
        lda P65_ptr1            ; retrieve actual error value
        ldx #0
        and #$7f
        jmp ___directerrno      ; Eventually returns -1 in AX

bad_fd:
        ply                     ; Remove the whence we stashed on the stack
        lda #$ff
        ;tax
        sta sreg
        sta sreg+1
        ;jsr pushax              ; high word of result
        lda #EBADF
        jmp ___directerrno      ; Eventually returns -1 in AX
.endproc
