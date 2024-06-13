; POSIX IO functions
; Project:65 C Library
; Christopher Just
;
; int __fastcall__ read (int fd, void* buffer, int count)
;

        .export _read
        .importzp ptr1, tmp1, tmp2, tmp3, tmp4
        .import popax
        .include "p65.inc"
        .include "fcntl.inc"
        .include "filedes.inc"

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
        jsr getfdflags  ; check if file is open for reading
        and #O_RDONLY
        bne flags_ok
        lda #$FF
        ldx #$FF
        rts             ; return -1 for failure

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

.endproc
