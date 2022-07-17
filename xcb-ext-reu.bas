
' XC=BASIC v3 Extension
' REU Transfer
'
' By Shawn Olson aka Locodarwin
'
' Namespace: _REU
' 
' The ML routine in this work is based primarily
' on the Commodore 1700, 1750, and 1764 user guides
' and the transfer routines described in C=Hacking #8
' by Richard Hable
' http://www.ffd2.com/fridge/chacking/c=hacking8.txt

' register constants
shared const _REU_STATUS	= $DF00
shared const _REU_COMMAND	= $DF01
shared const _REU_INTBASE	= $DF02
shared const _REU_REUBASE	= $DF04
shared const _REU_REUBANK	= $DF06
shared const _REU_TRANSLEN	= $DF07
shared const _REU_IRQMASK	= $DF09    ' not needed for this extension but included for reference
shared const _REU_CONTROL	= $DF0A

' operation constants
shared const _REU_OP_STASH 	= $00
shared const _REU_OP_FETCH	= $01
shared const _REU_OP_SWAP 	= $02
shared const _REU_OP_VERIFY	= $03

' **************************************************
' syntax: reu_trans(type, bytes, intadd, reuadd, reubank)
'
' Transfers bytes between CPU (near) memory and REU (far) memory
' (Can also perform swap and verify operations)
' 
' type		(byte)	The type of action to perform (0 = stash, 1 = fetch, 2 = swap, >2 = verify)
' bytes		(word)	Number of bytes to transfer or swap (max 32768 or $8000)
' intadd	(word)	C64/C128 starting address
' reuadd	(word)	REU starting address
' reubank	(byte)	REU bank (0 to 255)
' 
' Returns single byte value that contains success ($01) or failure ($00) of verify operation
' (the returned byte means nothing for non-verify operations)
' **************************************************
function reu_trans as byte (type as byte, bytes as word, intadd as word, reuadd as word, reubank as byte) shared static
    dim ret_byte as byte
    asm
	
    lda #$00
    sta $DF0A
    
    lda {intadd}			; load near RAM start address
    sta $DF02 
    lda {intadd}+1
    sta $DF02+1

    lda {reuadd}			; load far RAM start address 
    sta $DF04
    lda {reuadd}+1
    sta $DF04+1

    lda {reubank}			; load far bank into REU bank reg
    sta $DF06
  
    lda {bytes}				; load number of bytes for transfer
    sta $DF07
    lda {bytes}+1
    sta $DF07+1
 
    lda {type}				; which type of transfer? (0, 1, 2, or >2)
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
    sta $DF01	    		; do it!
    lda $DF00         		; check status register of REU
    and #%00100000          ; for verify, bit 5 tells us if verification passes
    beq .success
    lda #$00
    sta {ret_byte}
    jmp .end
.success
    lda #$01 
    sta {ret_byte} 
.end
    end asm
    return ret_byte
end function
