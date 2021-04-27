
; XC=BASIC Extension
; REU Transfer
;
; By Shawn Olson aka Locodarwin
;
; Namespace: reu_
; 
; The ML routine in this work is based primarily
; on the Commodore 1700, 1750, and 1764 user guides
; and the transfer routines described in C=Hacking #8
; by Richard Hable
; https://rr.pokefinder.org/wiki/Programming_the_Commodore_REUs_C%3DHacking_Issue_8.txt

const REU_STATUS	= $DF00
const REU_COMMAND	= $DF01
const REU_INTBASE	= $DF02
const REU_REUBASE	= $DF04
const REU_REUBANK	= $DF06
const REU_TRANSLEN	= $DF07
const REU_IRQMASK	= $DF09    ; not needed for this extension but included for reference
const REU_CONTROL	= $DF0A

; *************************************************
; syntax: reu_trans!(type!, bytes, intadd, reuadd, reubank!)
;
; Transfers bytes between CPU (near) memory and REU (far) memory
; (Can also perform swap and verify)
; 
; type!		The type of action to perform (0 = stash, 1 = fetch, 2 = swap, >2 = verify)
; bytes		number of bytes to transfer or swap (max 32768 or $8000)
; intadd	C64/C128 starting address
; reuadd	REU starting address
; reubank!	REU bank (0 to 255)
; 
; Returns single byte! value that contains success ($01) or failure ($00) of verify operation
; (the returned byte means nothing for non-verify operations)
; **************************************************
fun reu_trans!(type!, bytes, intadd, reuadd, reubank!)
    dim ret_byte!
    asm "
    lda #$00
    sta _REU_CONTROL
    
    lda {self}.intadd		; load near RAM start address
    sta _REU_INTBASE 
    lda {self}.intadd+1
    sta _REU_INTBASE+1
   
    lda {self}.reuadd		; load far RAM start address 
    sta _REU_REUBASE
    lda {self}.reuadd+1
    sta _REU_REUBASE+1
   
    lda {self}.reubank		; load far bank into REU bank reg
    sta _REU_REUBANK
  
    lda {self}.bytes		; load number of bytes for transfer
    sta _REU_TRANSLEN
    lda {self}.bytes+1
    sta _REU_TRANSLEN+1
 
    lda {self}.type			; which type of transfer? (0, 1, 2, or >2)
    bne .fetchtest			; compare against 0 (stash)
    lda #%10010000			; if yes, set command reg to stash
    bne .command			; then go do it
        
.fetchtest 
    cmp #01					; otherwise compare against fetch (1)
    bne .swaptest		 
    lda #%10010001			; if fetch, set command reg to fetch
    bne .command			; then go do it
.swaptest 
    cmp #02					; otherwise compare against swap (2)
    bne .verify			
    lda #%10010010			; if swap, set command reg to swap
    bne .command			; then go do it      
.verify		 
    lda #%10010011			; must be verify then (>2)
.command 
    sta _REU_COMMAND	    ; do it!
    lda _REU_STATUS         ; check status register of REU
    and #%00100000          ; for verify, bit 5 tells us if verification passes
    beq .success
    lda #$00
    sta {self}.ret_byte
    jmp .end
.success 
    lda #$01 
    sta {self}.ret_byte 
.end"
	return ret_byte!
endfun