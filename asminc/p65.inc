;
; Project:65 C Library defines
;

;-----------------------------------------------------------------------------
; Device numbers
;

P65_DEV_SERIAL1   = 0			; Serial console
P65_DEV_SDCONTROL = 1			; Command channel for SD filesystem
P65_DEV_FILE0     = 2			; Open file #0
P65_DEV_FILE1     = 3			; Open file #1
P64_DEV_SENTINEL  = 4			; demarcates end of device list

;-----------------------------------------------------------------------------
; P65 User program arguments & return

P65_argc		    = $0280   	; The input buffer will be parsed into a c-like
P65_argv0L          = $0281   	; argv array, with the pointers pointing into
P65_argv0H          = $0282   	; the buffer itself.  
P65_argv1L          = $0283
P65_argv1H          = $0284
P65_argv2L          = $0285
P65_argv2H          = $0286
P65_argv3L          = $0287
P65_argv3H          = $0288
P65_program_ret     = $0289		; Store return code of called program

;-----------------------------------------------------------------------------
; P65 Kernel routines

P65_FILEOPEN    	= $FFD1		; Open filename and allocate a device for it
P65_SET_FILENAME    = $FFD4		; Set filename (in AX) for subsequent FILEOPEN
P65_SET_FILEMODE    = $FFD7		; Set mode (in A) for subsequent FILEOPEN
P65_OPEN_DEV    	= $FFDA		; Opens a specific device
P65_CLOSE_DEV   	= $FFDD
P65_COMMANDLINE     = $FFE0
P65_OUTPUTSTRING    = $FFE3		; Writes 0-terminated string to console.
P65_PutChar     	= $FFE6		; Write character in A to console
P65_GetChar         = $FFE9
P65_PutHexit        = $FFEC		; Writes character to console as hex
P65_DEV_PUTC 		= $FFEF		; Write character to current device
P65_DEV_GETC 		= $FFF2		; Read character from current device
P65_SETDEVICE 		= $FFF5

;----------------------------------------------------------------------------
; Vector jump locations

; When P:65 RESET is called, $0200 and $0203 are initialized with jmp 
; instructions to redirect into the default interrupt handlers in ROM.
; The interrupt handlers can be replaced or prepended to by changing 
; the jump addresses.
NMIVec		= $0200
;BRKVec		= RESET				; Jumps to ROM; cannot be overriden.
IRQVec		= $0203

