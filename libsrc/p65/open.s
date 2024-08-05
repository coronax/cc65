; POSIX IO functions
; Project:65 C Library
; Christopher Just
;
; int __cdecl__ open (const char* name, int flags, ...)
;

        .export _open
        .importzp tmp1, tmp2
        .import _close, _fclose, incsp2, addysp, popax
        .destructor closeallfiles
        .include "p65.inc"
        .include "errno.inc"
        .include "filedes.inc"
        .include "_file.inc"
        .include "stdio.inc"    ; for FOPEN_MAX


.if 0
.proc _dummy
	jsr incsp2      ; add 2 to stack pointer
	jsr incsp2      ; add 2 to stack pointer again
	rts
.endproc

.proc _dummy_open
parmok:
        ; Retrieve the mode from the stack, and... store it on the other
        ; stack for a moment.
        jsr     popax
        pha

        ; Retrieve the filename from the parameter stack & print to console
        jsr     popax
        jsr     P65_OUTPUTSTRING

        ; Now we can print the mode
        pla
        jsr     P65_PUT_HEXIT

        ; Finally, we'll return an error code -1
        lda     #$FF
        ldx     #$FF
        rts
.endproc
.endif



.proc _open
        ; Open is technically a variadic function, which means that Y stores
        ; the number of bytes of arguments that the caller placed on the 
        ; stack. I've borrowed this chunk of code from cbm/open.s which
        ; assumes there are at least 2 arguments (4 bytes), which are the 
        ; only ones I actually care about, and just discards the rest.
        dey                     ; Parm count < 4 shouldn't be needed to be...
        dey                     ; ...checked (it generates a c compiler warning)
        dey
        dey
        beq     parmok          ; Branch if parameter count ok
        jsr     addysp          ; Fix stack, throw away unused parameters
parmok:
        ; With the variadic arguments out of the way, let's get to work.
        ; First, we need a file descriptor
        jsr     allocfd
        bcs     fail_allocfd
        sta     tmp1            ; Stash fd for later.

        ; Next, we need to find an open device table entry. The P:65 OS
        ; provides two file I/O devices. If a device's filemode in the 
        ; device table is 0, that means the device is not in use.
        lda     #P65_DEV_FILE0
        jsr     P65_SETDEVICE
        jsr     P65_DEV_GET_STATUS
        ;ldx     P65_DEVICE_OFFSET
        ;lda     DEVTAB + DEVENTRY::FILEMODE,X
        beq     do_open         ; If filemode == 0, device is available

        lda     #P65_DEV_FILE1
        jsr     P65_SETDEVICE
        jsr     P65_DEV_GET_STATUS
        bne     fail_allocdev

do_open:
        ; We found an available device table entry, so now we need to tell
        ; the OS to open it. First we pop the filename and mode off the 
        ; stack and tell the OS about them:
        jsr     popax 
        jsr     P65_SET_FILEMODE

        jsr     popax
        jsr     P65_SET_FILENAME

        ; And now we make the actual open call.
        jsr     P65_OPEN_DEV  
        cpx     #0      ; 0 on success
	bne	fail_os

        ; Set fdtab entry values
        sta     tmp2                    ; save filetype
        jsr     P65_DEV_GET_STATUS
        tay
        ldx     P65_CURRENT_DEVICE
        lda     tmp1            ; Retrieve fd
        jsr     setfd           ; Update fdtab
	lda	tmp1            ; Retrieve & return fd
	ldx	#0	        ; cc65 __fopen wants us to return a 16-bit value
	rts

fail_os:
        and #$7f                ; Clear high bit of errno value.
        jmp ___directerrno      ; Sets errno & returns -1.

fail_allocdev:
        lda tmp1                ; Recover the fd that we stashed.
        jsr freefd              ; Release it before returning.
fail_allocfd:
        lda #EMFILE
        jmp ___directerrno      ; Sets errno & returns -1.
.endproc


; Anything that is opened should be closed. In this case, i'm concerned with
; _fdtab and __filetab elements not including stdin/out/error.
; Technically, I only really need to clean up the OS devices that are left
; open, but actually cleaning up the data structures here will make it 
; easier to run programs multiple times without reloading. This is certainly
; not sufficient to make cc65 programs re-executable, but it will make testing
; go a little faster.
.proc closeallfiles
        ; So just zeroing out filetab doesn't quite work for some reason.
        ; So we'll actually go through and call _fclose on each entry.
        ; I believe _fclose will check if the file is actually open, so
        ; we don't have to here.
        ; Since I'm only interested in __filetab[3] thru __filetab[7] I'm 
        ; just going to write this without a loop.
        lda #<(__filetab + 9)
        ldx #>(__filetab + 9)
        jsr _fclose
        lda #<(__filetab + 12)
        ldx #>(__filetab + 12)
        jsr _fclose
        lda #<(__filetab + 15)
        ldx #>(__filetab + 15)
        jsr _fclose
        lda #<(__filetab + 18)
        ldx #>(__filetab + 18)
        jsr _fclose
        lda #<(__filetab + 21)
        ldx #>(__filetab + 21)
        jsr _fclose

.if 1
        ; The above will only close files opened via fopen. If the application
        ; used open directly, it's not enough. We can do a 2nd pass through
        ; fdtab, like this:
        lda #3
loop2:  ldx #0
        pha
        jsr _close      ; we'll let close() check if the fd is actually open,
        pla             ; and just ignore the result.
        inc
        cmp #MAX_FDS
        bne loop2
.endif
.if 1
        ; But What if the application used the P65 Kernel interface directly?
        ; Well, we can just close those, too. We don't need to worry about the
        ; return code.
        lda #2
        jsr P65_SETDEVICE
        jsr P65_CLOSE_DEV
        lda #3
        jsr P65_SETDEVICE
        jsr P65_CLOSE_DEV
.endif
        rts
.endproc
