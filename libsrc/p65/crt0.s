;
; Startup code for Project:65 computer
;

	.export	    _exit
	.export		startup
    .export     __STARTUP__ : absolute = 1      ; Mark as startup
	.import		initlib, donelib
    .import	    zerobss, callmain

    .include    "zeropage.inc"
	.include	"p65.inc"

; ------------------------------------------------------------------------
; Place the startup code in a special segment that will be the first thing
; in the program image.

.segment       	"STARTUP"

		; P:65 borrows a convention from the C64, where the first two bytes
		; of a program are the address to load into / start execution from.
        .word   Head            ; Load address
Head: 
startup:  
; ------------------------------------------------------------------------
; Actual code

		cld				; Make sure we're not in BCD mode.

		; Save the current stack pointer. If the program terminates normally
		; by returning from main() this isn't necessary--we'll just naturally
		; arrive back at the same stack location. Buf it we don't--for 
		; example because of a call to exit()--we need to patch things up so
		; we can return into the command line processor.
	   	tsx
    	stx	spsave		; Save the system stack ptr

		; Set the CC65 parameter stack to the top of RAM at 0x7fff
		; (Not 0x07ff - lost a day to that mistake!)
		lda #$ff
		sta	sp
		ldx	#$7f
    	stx	sp+1

		jsr	zerobss			; Clear BSS data

		jsr initlib			; Call library constructors, etc.

		; Push arguments and call main()

    	jsr	callmain


; Call module destructors. This is also the _exit entry.
_exit:  
		; Store the program return code
		sta P65_program_ret

        jsr	donelib

		; Restore the stack pointer
		ldx	spsave
		txs	    

    	rts 			; Back to P65 monitor


.data
; spsave has to be in data, not bss, because we write to it before
; initializing bss.
spsave:	.byte	0

