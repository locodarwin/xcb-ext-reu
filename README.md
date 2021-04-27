# xcb-ext-reu
RAM Expansion Unit (REU) extension for XC=BASIC

# Usage

Include the file `xcb-ext-reu.bas` in the top of your program:

`include "path/to/xcb-ext-reu.bas"`
    
That's it, you can now use all the symbols defined by this extension. Avoid naming collisions by not defining symbols starting with `reu_` in your program.

# Example / Test

Refer to the file *examples/reu-ext-test.bas* for a complete test of this extension.

# Quick Reference

The extension adds a function to XC=BASIC that you can use to STASH, FETCH, SWAP, and VERIFY memory between the C64 (we'll call this "near" memory) and a RAM Expansion Unit (REU) (we'll call this "far memory"). Here is a brief description of the command:

## reu_trans()
Usage:

`call reu_trans (<operation>!, <#_of_bytes>, <c64_start_address>, <reu_start_address>, <reu_bank>!)`
  
Where:

* **operation** is a single byte value that specifies the type of reu transfer operation to perform (0 = stash, 1 = fetch, 2 = swap, >2 = verify)
* **#_of_bytes** is the number of bytes to transfer, swap, or verify as an integer (max value 32768 or $8000) 
* **c64_start_address** is the starting memory address of the c64 for the transfer, swap, or verify as an integer (0-65534)
* **reu_start_address** is the starting memory address of the installed REU as an integer (0-65534)
* **reu_bank** is a single byte value that specifies the REU bank for the transfer, swap, or verify operation (0-254)

Examples:

`call reu_trans(0, 1000, $0400, $0000, 0)` -- sends 1000 bytes of c64 screen memory to the REU at REU bank 0

`call reu_trans(1, 1000, $0400, $0000, 3)` -- fetches 1000 bytes from REU and sends to c64 screen memory at bank 3

`call reu_trans(2, 2000, $C000, $0000, 1)` -- swaps 2000 bytes of memory between c64 (at c64's $C000) and REU (at REU's $0000 bank 1)

`let z! = call reu_trans(3, 1234, $C000, $0000, 0)` -- verifies 1234 bytes of memory starting at $C000 on c64 with memory starting at $0000 bank 0 of REU - a value of 1 will be placed in z! if all bytes match exactly, otherwise z! = 0


**WARNING: For performance reasons, there is no sanity check for the arguments passed into reu_trans(). If you pass arguments that are out of bounds, you'll get unexpected and potentially catastrophic results without any warning or error.**

# Detailed Explanation

Many Commodore 8-bit enthusiasts today possess Ram Expansion Units (REUs) of some type, either in the form of real Commodore hardware units such as the 17xx series, the CMD GEORam cartridge, multi-function aftermarket expansion port cartridges (such as the 1541 Ultimate II+, xxxxxxxxxxxxx), or even as an REU option in an emulator such as Vice.
For the purposes of this documentation, we will differentiate REU-installed RAM from internally-installed computer RAM through the use of the terms "near" and "far," thus:

  * "Near" memory is the RAM that is natively installed in the computer. On the C64, this is the 64k that is natively addressable by the 6510 CPU. 

  * "Far" memory is the RAM that is installed in the REU. This can be anywhere from 128k to a whopping 16mb!

What can you use an REU for in XC-BASIC? There are several possibilities, including the following:

  * Preloading, stashing, and swapping ML routines or arbitrary code in and out of "near" (C64 internal) memory from "far" (REU) memory, to allow for larger or more modular application design than is possible on an unexpanded Commodore computer due to "near" memory limitations
  * Preloading, stashing, and restoring screen and color RAM for various uses, such as:
    * "Help screens" or other display information/text that isn't practical to store in "near" memory
	* Windowing or menu routines that "remember" their screen & color information, to enable fast menu systems and the like while keeping "near" memory use to a minimum (every little bit of memory counts!)
    * Relatively fast character animation or "movies" of many, many preloaded screens' worth of PETSCII characters, comprised of the standard character set or even additional character sets
  * Stashing and restoring hi-res screens or chunks of bitmap, to enable tricks like pseudo double-buffering or to speed up runtime game or map display
  * Preloading, stashing, and restoring sprites by the dozens or even hundreds, so they don't have to be loaded entirely into precious "near" memory all at once or swapped in and out with a lot of disk I/O at play time
  * Stashing and restoring map data tables, as with 2d tiled games, so that such maps can be made larger without a lot of disk I/O during play time
  * Preloading, stashing, and restoring game text, as with character dialog or text adventures, etc., again saving a lot of disk I/O during play time
  * Allowing text manipulation programs, such as note taking applications, text editors, or word processors to work with more data at a time
  * Preloading and storing of SID song or sound effect data (and even more interestingly, sound samples!) to be brought into "near" memory at opportune moments
  * Copying arbitrary RAM areas from one place to another in "near" memory faster than with MEMCPY and MEMSHIFT (see the "Tips & Tricks" section below)
  * Emulating "bank switching" for any application that may benefit from this kind of technique

Other less practical or pragmatic things that are nonetheless technically possible:

  * The creation of large "RAM drives" or similar for operating systems or command line application
  * Working area for XC-BASIC based native compilers or (gasp) XC-BASIC run time language interpreters





