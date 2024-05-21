; Project:65 C Library
; int __cdecl__ open (const char* name, int flags, ...)
;

        .export _open, _dummy_open, _dummy
        .importzp sp
        .import incsp2, addysp, popax
 	    .include "p65.inc"

.proc _dummy
	jsr incsp2	; add 2 to stack pointer
	jsr incsp2  ; add 2 to stack pointer again
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
        ; First, we need to find an open device table entry. The P:65 OS
        ; provides two file I/O devices. If a device's filemode in the 
        ; device table is 0, that means the device is not in use.
		lda		#P65_DEV_FILE0
		jsr		P65_SETDEVICE
		ldx		P65_DEVICE_OFFSET
		lda		DEVTAB + DEVENTRY::FILEMODE,X
		beq		do_open         ; If filemode == 0, device is available

		lda 	#P65_DEV_FILE1
		jsr		P65_SETDEVICE
		ldx		P65_DEVICE_OFFSET
		lda		DEVTAB + DEVENTRY::FILEMODE,X
        bne     on_fail

do_open:
        ; We found an available device table entry, so now we need to tell
        ; the OS to open it. First we pop the filename and mode off the 
        ; stack and tell the OS about them:
        jsr     popax 
        jsr     P65_SET_FILEMODE

        jsr     popax
        jsr     P65_SET_FILENAME

        ; And now we make the actual open call.
		jsr		P65_OPEN_DEV    
        cmp     #'0'    ; In 2013 it apparently made sense to return '0'
		beq		on_fail ; for failure, and '1' for success.

		lda		P65_CURRENT_DEVICE  ; On success, return # of current device.
		ldx		#0				    ; cc65 __fopen wants us to return a 16-bit value
		rts
on_fail:
    	lda		#$ff
        ldx     #$ff
	    rts
.endproc