; POSIX IO functions
; Project:65 C Library
; Christopher Just
;
; int __fastcall__ read (int fd, void* buffer, int count)
;

        .export _read
        .constructor initstdin
        .destructor closestdin
        .importzp ptr1, tmp1, tmp2, tmp3, tmp4
        .import popax, __filetab
        .include "p65.inc"
        .include "errno.inc"
        .include "fcntl.inc"
        .include "filedes.inc"
        .include "_file.inc"    ; for _FOPEN

;--------------------------------------------------------------------------
; initstdin: Open (and therefore reinitialize) the TTY device attached to 
; stdin. Pretty much every input function uses read(), so it makes sense to 
; include this constructor here.
.segment "ONCE"

.proc   initstdin
        lda #4                  ; device id for tty
        jsr P65_SETDEVICE
        jsr P65_OPEN_DEV        ; This should always succeed

.if 1
        ; Also, as a kludge here: clear the pushback buffer for standard IO
        ; channels, and reset the flags to _FOPEN.
        ; This doesn't make cc65 code reentrant, but it might solve one 
        ; irritation that's come up during testing.
        lda #_FOPEN
        sta __filetab + 1
        stz __filetab + 2
        sta __filetab + 4
        stz __filetab + 5
        sta __filetab + 7
        stz __filetab + 8
.endif
        rts
.endproc

.code

.proc closestdin
        lda #4                  ; close the tty device
        jsr P65_SETDEVICE
        jsr P65_CLOSE_DEV
        rts
.endproc


; It looks like this read() is closely modeled on the Unix version. So
; that means it will read up to count characters into buffer, and return
; the number of characters actually read. A return value of 0 indicates
; end-of-file, and -1 indicates an error.
; On entry, the stack looks like:
;    sp+3   0
;    sp+2   fd
;    sp+1   #>buffer
;    sp     #<buffer
; and count will be in AX
; We're going to use cc65's ptr1 for the buffer address
; We'll use tmp1/2 to store count, Y and tmp3 to store result.
; Also use tmp4 to store the fd.
; Uses AXY
.proc _read
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

        jsr popax       ; get file descriptor from stack
        sta tmp4        ; stash it in tmp4
        cpx #0          ; and let's make sure fd is valid, so
        bne bad_fd      ; it's 0 <= fd < max_fds
        cmp #MAX_FDS
        bcs bad_fd

        jsr getfdflags  ; check if file is open for reading
        and #O_RDONLY
        bne flags_ok
        lda EINVAL      ; flags are not ok
        jmp ___directerrno      ; eventually returns -1 in AX

        ;lda #$FF
        ;ldx #$FF
        ;rts             ; return -1 for failure

flags_ok:
        lda tmp4        ; Retrieve fd
        jsr getfddevice
        jsr P65_SETDEVICE   ; set active device

        stz tmp3        ; initialize read count
        ldy #0
 
loop:
        jsr P65_DEV_GETC
        bcc loop
        cpx #$FF
        beq done        ; $FF in X means we received EOF
        sta (ptr1),y    ; save character to buffer
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
