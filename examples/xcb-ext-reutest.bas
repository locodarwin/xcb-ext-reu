; REU test program for xcb-ext-reu

; include the reu extension
include "xcb-ext-reu.bas"

; some handy constants for readability
const STASH! = 0
const FETCH! = 1
const SWAP! = 2
const VERIFY! = 3
const BANK! = 0          ; alter this to test other REU banks

poke 53272, 23   ; switch to upper/lowercase

; "wait for keypress" procedure
proc presskey
loop:
    let key = inkey()
    if key = 0 then goto loop
endproc

; "clear the screen" procedure
proc cls
    memset 1024, 1000, 32
endproc

; set up some test strings
let lorem$ = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
let fox$ = "The quick brown fox jumped over the lazy dog. "

; let's get the ball rolling
call cls
textat 8, 4, "***********************"
textat 8, 5, "* REU Extenstion Test *"
textat 8, 6, "***********************"
textat 1, 8, "First, we will fill two screens with"
textat 4, 9, "text and stash them into the REU"
textat 12, 13, "(press any key)"

call presskey

; print out the lorem$ string and stash it as screen 1
for x = 1 to 22
    print lorem$; 
next x
call reu_trans(STASH!, 1000, $0400, $0000, BANK!) ; mixed hex and decimal notation

; print out the fox$ string and stash it as screen 2
for x = 1 to 24
    print fox$; 
next x
call reu_trans(STASH!, $0400, $0400, $0401, BANK!) ; pure hex notation

call cls
textat 1, 5, "Next, we will flip between the screens"
textat 2, 6, "5 times each, waiting for key press"
textat 1, 7, "each time - remember to press any key"
textat 2, 8, "a total of 10 times to complete the"
textat 6, 9, "the test once it starts."
textat 7, 13, "(press any key to begin)"

call presskey

; flip between stashed screens with fetch
for x = 0 to 4
    call reu_trans(FETCH!, 1000, $0400, $0000, BANK!)
    call presskey
    call reu_trans(FETCH!, 1000, $0400, $0401, BANK!)
    call presskey
next x


; perform a swap test
call cls

textat 1, 4, "Now we will perform mem swaps between"
textat 1, 5, "the REU and screen memory. First, we"
textat 2, 6, "will fill the REU memory area with"
textat 3, 7, "1000 astrisk (*) characters..."
textat 12, 10, "(press any key)"

call presskey

; put 1024 "*" into mem at 49152
memset 49152, 1000, 42

; push the 1024 bytes of mem at 49152 to REU bank 0, addr 0
call reu_trans(STASH!, 1000, 49152, 0, BANK!) ; pure decimal notation

textat 4, 12, "...done. Now we'll swap between"
textat 3, 13, "screen mem and REU mem 5 times each"
textat 3, 14, "using only the REU swap operation."
textat 3, 16, "Remember to press any key a total"
textat 6, 17, "of 5 times once test begins."
textat 7, 19, "(press any key to begin)"

call presskey 

; swap 5 times!
for x = 0 to 4
    call reu_trans(SWAP!, 1000, $0400, $0000, BANK!)   ; mixed hex and decimal notation
    call presskey
next x

; perform a verify test (set up for success)
call cls
textat 4, 4, "Next we'll perform a verify test."
textat 4, 5, "We'll fill the C64 mem at 49152"
textat 3, 6, "($C000) with 2,000 bytes and then"
textat 5, 7, "stash that mem into the REU."
textat 3, 8, "We'll then verify the REU contents"
textat 5, 9, "against the C64 mem contents"
textat 7, 11, "(press any key to begin)"

call presskey
memset 49152, 2000, 38
textat 4, 13, "...2000 bytes pushed into $C000"
textat 3, 14, "(press any key to stash into REU)"

call presskey
call reu_trans(STASH!, 2000, $C000, 0, BANK!)
textat 0, 16, "...2000 bytes at $C000 pushed into REU"
textat 0, 17, "(press any key to verify REU vs. $C000)"

call presskey
let z! = reu_trans!(VERIFY!, 2000, $C000, $0000, BANK!)

if z! = 1 then
    textat 12, 19, "We have a match!"
else
    textat 8, 19, "We don't have a match!"
endif
textat 12, 20, "(press any key)"
call presskey

; perform another verify test (set up for failure)
call cls
textat 4, 4, "Now to complete the verify test,"
textat 2, 5, "we'll change one mem value somewhere"
textat 3, 6, "within 2,000 bytes of $C000 and"
textat 2, 7, "try the verify operation again. It"
textat 3, 8, "should fail miserably even though"
textat 5, 9, "the difference is a single byte!"
textat 7, 11, "(press any key to begin)"

call presskey
memset 49205, 1, 36
textat 7, 13, "...1 byte altered at $C035"
textat 0, 14, "(press any key to verify REU vs. $C000)"

call presskey
let z! = reu_trans!(VERIFY!, 2000, $C000, $0000, BANK!)

if z! = 1 then
    textat 12, 16, "We have a match!"
else
    textat 9, 16, "We don't have a match!"
endif
textat 12, 17, "(press any key)"

; we're done
call presskey
call cls
textat 1, 5, "REU extension test complete."
