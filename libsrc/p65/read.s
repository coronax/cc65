; Project:65 C Library
; int __fastcall__ read (int fd, void* buffer, int count)
;

        .export _read
        .importzp sp, ptr1, tmp1, tmp2, tmp3
        .import popax
 	    .include "p65.inc"

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
; We'll use tmp1/2 to store count, Y and tmp3 to store result
.proc _read
        ;pha
        ;phx             ; Save count to the stack for now
        cmp #0
        bne nonzero
        cpx #0
        bne nonzero
        rts             ; count is 0, just return?
nonzero:
        sta tmp1        ; low byte of count
        stx tmp2        ; high byte of count
        ldy #0
        lda (sp),y
        sta ptr1
        iny
        lda (sp),y
        sta ptr1+1      ; Save buffer ptr to ptr1
        iny
        lda (sp),y
        jsr P65_SETDEVICE   ; set active device to fd

        jsr popax ; fix up stack
        jsr popax

        ; We should probably check if the file is actually open.
        ldx		P65_DEVICE_OFFSET
		lda		DEVTAB + DEVENTRY::FILEMODE,X
        bne     start_read
        lda #$FF
        ldx #$FF
        rts             ; return fail
start_read:
        stz tmp3
        ldy #0
        ;stz tmp4

        ; we need to subtract one from count, so that we terminate 
        ; when count flips to $FFFF
;        lda tmp1
;        sec
;        sbc #1
;        sta tmp1
;        lda tmp2
;        sbc #0 ; just subtract the carry
;        sta tmp2

loop:
        ;lda #'+'
        ;jsr P65_PUT_CHAR
        jsr P65_DEV_GETC
        cpx #$FF
        beq done        ; EOF
        sta (ptr1),y    ; save character to buffer
        iny
        bne decrement_count
        ; y rolled over, so we need to increment ptr1h and tmp3
        inc tmp3
        inc ptr1+1
decrement_count:

        ; subtract one from count (in tmp1/2). If nonzero, loop
        lda tmp1
        sec
        sbc #1
        sta tmp1
        lda tmp2
        sbc #0 ; just subtract the borrow
        sta tmp2
        bne loop
        lda tmp1
        bne loop


;        ldx tmp1        ; CJ BUG indexing is messed up, we're looping once too many. 
;        dex
;        stx tmp1
;        cpx #$ff        ; check if tmp1 rolled under
;        bne loop
;        ldx tmp2
;        dex
;        stx tmp2
;        cpx #$ff        ; check if tmp2 rolled under
;        bne loop
done:
        tya             ; load result into AX
        ldx tmp3
        rts


.endproc
