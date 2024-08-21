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
P65_DEV_TTY       = 4
P65_DEV_SENTINEL  = 5			; demarcates end of device list

P65_CURRENT_DEVICE = $0220

; This is available unless/until I add a proper clock device.
P65_TOD_SECONDS = $0206 ; 32-bit count of seconds.
P65_TOD_SECONDS100 = $020a ; 8-bit hundredths of seconds

; These are in here because DEV_LSEEK uses them:
P65_ptr1 = $30
P65_ptr2 = $32

; DEVTAB entry format
;.struct DEVENTRY
;	CHANNEL   .byte
;	FILEMODE  .byte   ; contains file mode if the dev is open, else 0.
;	INIT      .word
;	GETC	  .word
;	PUTC      .word
;	OPEN	  .word
;	CLOSE	  .word
;.endstruct

;-----------------------------------------------------------------------------
; P65 Custom error values (in addition to the cc65 errnos I've adopted)

P65_ESYNTAX  =   $80 | 19
P65_ENOTDIR  =   $80 | 20
P65_EISDIR   =   $80 | 21

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
P65_argv4L          = $0289
P65_argv4H          = $028a
P65_program_ret     = $028b		; Store return code of called program

;-----------------------------------------------------------------------------
; P65 Kernel routines

P65_FS_MKDIR		= $FFBB
P65_FS_RMDIR		= $FFBE
P65_FS_RM			= $FFC1
P65_FS_CP			= $FFC4
P65_FS_MV			= $FFC7
P65_DEV_IOCTL       = $FFCA
P65_DEV_SEEK        = $FFCD
;P65_DEV_TELL        = $FFCB
P65_DEV_GET_STATUS  = $FFD0
P65_FILEOPEN    	= $FFD3		; Open filename and allocate a device for it
P65_SET_FILENAME    = $FFD6		; Set filename (in AX) for subsequent FILEOPEN
P65_SET_FILEMODE    = $FFD9		; Set mode (in A) for subsequent FILEOPEN
P65_OPEN_DEV    	= $FFDC		; Opens a specific device
P65_CLOSE_DEV   	= $FFDF
P65_COMMANDLINE     = $FFE2
P65_OUTPUTSTRING    = $FFE5		; Writes 0-terminated string to console.
P65_PUT_CHAR     	= $FFE8		; Write character in A to console
P65_GET_CHAR        = $FFEB
P65_PUT_HEXIT       = $FFEE		; Writes character to console as hex
P65_DEV_PUTC 		= $FFF1		; Write character to current device
P65_DEV_GETC 		= $FFF4		; Read character from current device
P65_SETDEVICE 		= $FFF7

;----------------------------------------------------------------------------
; Vector jump locations

; When P:65 RESET is called, $0200 and $0203 are initialized with jmp 
; instructions to redirect into the default interrupt handlers in ROM.
; The interrupt handlers can be replaced or prepended to by changing 
; the jump addresses.
NMIVec		= $0200
;BRKVec		= RESET				; Jumps to ROM; cannot be overriden.
IRQVec		= $0203

