# xcb-ext-reu
RAM Expansion Unit (REU) extension for XC=BASIC

# Usage

Include the file `xcb-ext-reu.bas` in the top of your program:

`include "path/to/xcb-ext-reu.bas"`
    
That's it, you can now use all the symbols defined by this extension. Avoid naming collisions by not defining symbols starting with `reu_` in your program.

# Example / Test

Refer to the file *examples/reu-ext-test.bas* for a complete example and test of this extension, written entirely in easy-to-read XC=BASIC code with comments.

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

## Example Use:

`call reu_trans(0, 1000, $0400, $0000, 0)`
Sends 1000 bytes of c64 screen memory to the REU at REU bank 0

`call reu_trans(1, 1000, $0400, $0000, 3)`
Fetches 1000 bytes from $0000 at REU bank 3 and sends to c64 screen memory

`call reu_trans(2, 2000, $C000, $0000, 1)`
Swaps 2000 bytes of memory between c64 (at c64's $C000) and REU (at REU's $0000 bank 1)

`let z! = call reu_trans(3, 1234, $C000, $0000, 0)`
Verifies 1234 bytes of memory starting at $C000 on c64 with memory starting at $0000 bank 0 of REU - a value of 1 will be placed in z! if all bytes match exactly, otherwise z! = 0


**WARNING: For performance & memory saving reasons, there is no sanity/bounds check for the arguments passed into reu_trans(). If you pass arguments that are out of bounds, you'll get unexpected and potentially catastrophic results without any warning or error.**

# Detailed Explanation

Many Commodore 8-bit enthusiasts today possess RAM Expansion Units (REUs) of some type, either in the form of real Commodore hardware units such as the 17xx series or clones, the CMD GEORAM cartridge or clones, multi-function aftermarket expansion port cartridges (such as the 1541 Ultimate II+), or even as an REU option in an emulator such as Vice. XC=BASIC does not possess native commands to allow the programmer to harness the power of an REU, but with a simple extension function like the one provided here, it's now trivial to implement REU usage in your own XC=BASIC programs without having to understand the inner workings or I/O registers of such devices. Using an REU is now *almost* as simple as using the XC=BASIC MEMCPY command.

For the sake of clarity, we will differentiate REU-installed RAM from internally-installed computer RAM through the use of the terms "near" and "far," as follows:

  * "Near" memory is the RAM that is natively installed in the computer. On the C64, this is the 64k that is natively addressable by the 6510 CPU. 
  * "Far" memory is the RAM that is installed in the REU. This can be anywhere from 128k to a whopping 16mb!

Because 65xx CPUs like the 6510 can only directly address (and thus access) 64k of onboard memory, REUs are designed to STASH, FETCH, and SWAP memory between the computer and the REU. This means a programmer cannot, for example, execute code that has been STASHed to the REU, nor PEEK or POKE the REU directly. The desired memory of the REU must be transferred to a safe location in the C64's memory first and then accessed in the usual way.



## Why USE an REU in XC=BASIC?

What can you use an REU for in XC=BASIC? There are several possibilities, including the following:

  * Preloading, stashing, and swapping ML routines or arbitrary code in and out of "near" memory from "far" memory, to allow for larger or more modular application design than is possible on an unexpanded Commodore computer due to "near" memory addressing limitations
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
  * Working area for XC=BASIC based native compilers or (gasp) XC=BASIC run time language interpreters

## Limitations

There are some limitations that the programmer must keep in mind:

* Since XC=BASIC was not designed with an REU in mind, this extension cannot enhance or expand the XC-BASIC memory map to give you more *direct* free RAM to use. As mentioned previously, the REU's RAM is not directly addressable by the CPU of the computer, so you are not able to write longer sections of XC-BASIC code than an unexpanded computer would allow, and built-in variables will still need to fit into the XC-BASIC's allocated RAM areas. These limitations can be somewhat overcome or worked-around if you compile separate XC-BASIC programs as code modules into other "near" memory start_address spaces (and without the BASIC loader), preload them into those "near" memory start_address spaces temporarily, and then STASH/FETCH them in and out of "far" memory as needed. Note, however, that such modules will not be able to share XC-BASIC variables directly at run time. Use memory directly for data you intend to share between code modules.
* This extension cannot give the programmer more space for XC=BASIC's built in variables and data types, at least not directly. XC=BASIC was not designed with an REU in mind, so in order to stash and retrieve variables to/from the REU it would be necessary for the programmer to create buffer areas in "near" memory, either in the XC=BASIC program variable space through the use of arrays/indexes, or in programmer-reserved areas higher above the XC=BASIC program & variable space. While this is certainly something you can do if you wish, trying to handle XC=BASIC variables in this way isn't very practical in practice. Additionally, great care must be taken to ensure reserved areas do not interfere with XC-BASIC program and variable space, as it will most certainly cause crashes and/or variable overwriting.
* The VIC-20's RAM expansion cartridges are of a different kind. Since the VIC-20 ships stock with only 3.5k or so of free RAM available to the programmer, all of the VIC-20's RAM expansion cartridges are designed to increase the amount of free RAM for use by the 6502 processor directly. Therefore this extension won't work at all on the VIC-20.
* GEORAM and its clone devices work differently from standard REUs. GEORAM is not currently implemented but planned for a future release.

## Tips & Tricks






