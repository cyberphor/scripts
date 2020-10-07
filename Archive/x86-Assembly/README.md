<small>*These are my notes on x86 Assembly semantics written in the Intel syntax format (`opcode dst, src`).*</small>  

Malware programs are designed to disclose, alter, and destroy information & services. Yet, they function the same way benign programs do. They are simply a collection of instructions for the CPU to execute. What makes them *<font color='red'>malicious</font>* or not is their intented purpose. CPU instructions can be studied most accurately using Assembly, a low-level language of *mnemonics* that are directly mapped to machine code computers understand. In comparison, malware authors may use Assembly to perfect their exploits and avoid bloat higher-level computer languages may cause during software compilation. 

# Instructions
CPU Instructions in the context of the x86 Assembly Language can be parsed into *operation codes* and *operands*. For example, a x86 Assembly instruction will look similar to the following:
```nasm
mov eax 0x41 ; move the ASCII character "A" into the EAX register
```
An operation code, or *opcode*, is the action to perform. In our example, `mov` is what we're telling the CPU to do. Operands are arguments, data, or the subject we want to perform an action against. Here, `eax` and `0x41` are operands. 

# Opcodes
The following are commonly used opcodes within the x86 Assembly instruction set. 
```nasm
mov eax, ebx ; copies 'ebx' into 'eax'
```
```nasm
add eax, ebx ; adds 'ebx' to 'eax' and saves result in 'eax'
```
```nasm
sub eax, ebx ; subtracts 'ebx' from 'eax' and saves result in 'eax'
; modifies two flags: ZF if result is zero, CF if result is 'eax' < 'ebx'
```
```nasm
; other supported opcodes
lea
mul
imul
div
idiv
or
xor
shr
shl
ror
nop
```

**Stack Opcodes**<br>
```nasm
push 0x41 ; pushes item on top of the stack
```
```nasm
; other stack-related opcodes
pop 
call 
leave
enter
ret
```

# Operands
Common operands in x86 Assembly are Immediate Values, Registers, and Memory addresses.<br>

**Immediate Values**<br>
Immediate values can be overt and/or fixed. For example, the value `0x41` is fixed as `A` in ASCII. 

**Registers**<br>
There are General Registers, the EFLAGS Register, and Segment Registers. General Registers are used to hold data values during program execution:
* eax:
* ebx:
* ecx: 
* edx:
* esp: points to the top of the stack; changes as items are pushed/popped
* ebp: points to base of function; used it to orient local variables
* esi: 

On x86 systems, General Registers can hold 32 bits (4 bytes of data) each. They can also be divided into additional Registers to make specifying & fetching data more efficient:
```nasm
eax = 32 bits ; a 9 d c 8 1 f 5 
ax  = 16 bits ; 	8 1 f 5
ah  = 8 bits  ;	        8 1
al  = 4 bits  ;	            f 5 
```

The EFLAGS Register can also hold 32 bits of data which is used to help make logical decisions. Each bit represents a different flag:<br>
* ZF (Zero Flag): set when result is set to Zero 
* CF (Carry Flag): set when result is too small/big for destination operand 
* SF (Sign Flag): set when result is Negative (-)
* TF (Trap Flag): used for debugging; if set, the processor will execute one instruction at a time

Segment Registers track a program's various sections in memory:<br>
* The Stack: used for local variables; pulsates in size as functions are executed
* The Heap: designated for dynamically creating and/or eliminating new variables
* bss: uninitialized variables
* data: global & static variables that are required or explicitly initialized
* text: the program’s instructions 

**Memory Addresses**<br>
Addresses are locations in memory. They can be represented literally or like this `[eax]` (this value is, "the memory address of `eax`"). 

# Endianness
Endianness indicates how bytes may be arranged. 

**Little Endian**<br>
x86 Assembly arranges bytes using the Little Endian format, which means they are processed starting with the Smallest, or *Least Significant Byte*, first.

**Big Endian**<br>
Networking protocols arrange bytes using the Big Endian format, where the Biggest, or *Most Significant Byte* is addressed first. 
Take the network loopback address `127.0.0.1` as an example. It's first octet (`127`; `011111111`) in Hexadecimal is `7f`. In it's entirety, `127.0.0.1` in Hexadecimal would be `7f 00 00 01`. If it was written in Little Endian, it could be misinterpreted by network devices hard-coded to process data in Big Endian.  
```bash
# 127.0.0.1 in binary
01111111.00000000.00000000.00000001 

# the first octet of 127.0.0.1 in Hexadecimal is 7f
01111111 = 0111 1111 = (0+4+2+1) + (8+4+2+1) = 7+15 = 7+f

# 127.0.0.1 in the Big Endian format
7f 00 00 01 

# 127.0.0.1 in the Little Endian format
01 00 00 7f
```

References
* [*Practical Malware Analysis*](https://practicalmalwareanalysis.com) by Andrew Honig & Michael Sikorski
* [Primal Security: Introduction to ASM](http://www.primalsecurity.net/0x0-shellcoding-tutorial-introduction-to-asm/)
* [Reddit: AT&T vs. Intel Syntax](https://www.reddit.com/r/ProgrammerHumor/comments/56fjm5/att_vs_intel_syntax/)
