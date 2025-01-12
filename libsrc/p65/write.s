; POSIX IO functions
; Project:65 C Library
; Christopher Just
;
; int __fastcall__ write (int fd, void* buffer, int count)
;

        .export _write
        .importzp sp, ptr1, tmp1, tmp2, tmp3, tmp4
        .import popax
        .include "p65.inc"
        .include "errno.inc"
        .include "fcntl.inc"
        .include "filedes.inc"

; Write is another function modeled on its UNIX version. Write up to 
; count characters from buffer. Return actual number of characters
; written. Returns -1 on error.
; On entry, the stack looks like:
;    sp+3   0
;    sp+2   fd
;    sp+1   #>buffer
;    sp     #<buffer
; and count will be in AX
; We're going to use cc65's ptr1 for the buffer address.
; We'll use tmp1/2 to store count, Y and tmp3 to store result.
; Also use tmp4 to store the fd.

.proc _write
        ; Version using the OS read command P65_DEV_READ
        ; which requires the buffer in P65_ptr1 and the count in AX.
        pha             ; save count 
        phx
        jsr popax       ; Get the buffer ptr
        sta P65_ptr1
        stx P65_ptr1+1

        jsr popax       ; Get file descriptor from stack.
        sta tmp4        ; Save the value for later.
        cpx #0          ; Check if it's valid. High byte must be 0.
        bne bad_fd
        cmp #MAX_FDS    ; Low byte must be less than MAX_FDS.
        bcs bad_fd

        jsr getfdflags  ; check if file is open for reading
        and #O_WRONLY
        beq bad_fd

        lda tmp4        ; Retrieve fd
        jsr getfddevice
        jsr P65_SETDEVICE   ; set active device

        plx             ; get the count off the stack
        pla

        jsr P65_DEV_WRITE       
        cpx #$FF        ; Since count is signed, x = $FF can only mean an error
        beq write_error
        rts             ; otherwise we can just rts, I think...

write_error:
        and #$7f        ; clear top bit of error code
        jmp ___directerrno

bad_fd:
        plx             ; take the count off the stack before returning
        pla
        lda #EBADF
        jmp ___directerrno      ; Sets errno & returns -1.

.endproc


.if 0
.proc _write
        cmp #0
        bne nonzero
        cpx #0
        bne nonzero
        rts             ; count is 0, so we can just return 0.
nonzero:
        sta tmp1        ; low byte of count
        stx tmp2        ; high byte of count

        jsr popax
        sta ptr1
        stx ptr1+1      ; ptr1 points to buffer

        jsr popax       ; file descriptor
        sta tmp4
        cpx #0          ; and let's make sure fd is valid, so
        bne bad_fd      ; it's 0 <= fd < max_fds
        cmp #MAX_FDS
        bcs bad_fd

        jsr getfdflags  ; check if file is open for writing
        and #O_WRONLY
        beq bad_fd
        ;bne flags_ok
        ;lda EINVAL      ; flags are not ok
        ;jmp ___directerrno      ; eventually returns -1 in AX
        ;lda #$FF
        ;ldx #$FF
        ;rts             ; return -1 for failure

flags_ok:
        lda tmp4                ; Retrieve the fd
        jsr getfddevice
        jsr P65_SETDEVICE       ; set active device

        stz tmp3                ; initialize read count
        ldy #0
 
loop:
        ;lda #'+'
        ;jsr P65_PUT_CHAR
        lda (ptr1),y
        jsr P65_DEV_PUTC
        cpx #$FF
        beq done        ; I don't think we've established any errors for DEV_PUTC
        iny
        bne test_count
        inc tmp3        ; if Y rolled over, we need to increment
        inc ptr1+1      ; tmp3 and ptr1+1

test_count:
        ; if y/tmp3 == tmp1/tmp2, we are ready to exit.
        cpy tmp1
        bne loop
        lda tmp3
        cmp tmp2
        bne loop

done:
        tya             ; load read count into AX
        ldx tmp3
        rts

bad_fd:
        lda #EBADF
        jmp ___directerrno      ; Eventually returns -1 in AX
.endproc
.endif
