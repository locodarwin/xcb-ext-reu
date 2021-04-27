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

`call reu_trans (<oper>!, <#_of_bytes>, <c64_start_address>, <reu_start_address>, <reu_bank>!)`
  
Where:

* <oper>! is a single byte value that specifies the type of reu transfer operation to perform (0 = stash, 1 = fetch, 2 = swap, >2 = verify)
* <#_of_bytes> is the number of bytes to transfer, swap, or verify as an integer (max value 32768 or $8000) 
* <c64_start_address> is the starting memory address of the c64 for the transfer, swap, or verify as an integer (0-65534)
* <reu_start_address> is the starting memory address of the installed REU as an integer (0-65534)
* <reu_bank>! is a single byte value that specifies the REU bank for the transfer, swap, or verify operation (0-254)

Examples:

`call reu_trans(0, 1000, $0400, $0000, 0)` - sends 1000 bytes of c64 screen memory to the REU at REU bank 0

`call reu_trans(1, 1000, $0400, $0000, 3)` - fetches 1000 bytes from REU and sends to c64 screen memory at bank 3

`call reu_trans(2, 2000, $C000, $0000, 1)` - swaps 2000 bytes of memory between c64 (at c64's $C000) and REU (at REU's $0000 bank 1)

`let z! = call reu_trans(3, 1234, $C000, $0000, 0)` - verifies 1234 bytes of memory starting at $C000 on c64 with memory starting at $0000 bank 0 of REU - a value of 1 will be placed in z! if all bytes match exactly, otherwise z! = 0

**WARNING: For performance reasons, there is no sanity check for the arguments passed into reu_trans(). If you pass arguments that are out of bounds, you'll get unexpected and potentially catastrophic results without any warning or error.**

# Detailed Explanation

Here it is.

