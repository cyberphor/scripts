# How to write a program in C
1. Use a text editor to write and save source code into a source file (ex: `helloWorld.c`)
2. Compile the source file using a compiler (ex: `gcc`)

```
vim helloWorld.c							
```
```c
// Purpose: Print 'Hello world!' to the console

// tells the compiler to include the specified header file in the object file
# include <stdio.h>								

// declares the 'main' function
int main()  {

	// calls the 'print' function with 'Hello world!' as an argument
	printf("Hello world!\n");

	// specifies 0 as the error code				
	return 0;									
}
```
The following command will compile the source file (with a copy of the code) into an object file.
```
gcc -g helloWorld.c -o helloWorld				
```
To execute your C program, use the full-path to your object file. 
```bash
./helloWorld # full-path here is my current directory
Hello world!
```

# Variables
Variables declared outside of a function are *Global*. Variables declared inside of a function are stored in the program's **Stack** area of memory.
```c 
// this integer variable is Global
int x = 3; 						

int BakeCookies() {	
	// this integer variable is stored in the "Stack"
	int y = 4;						
}
```
If you use a local variable as an argument, it does not change during execution. Consider where the variable is in memory. Use a variable's memory address to continuously modify it during execution.

# Pointers
Pointers are used to share data between functions. Otherwise, a new copy of the data would have be created every time a function needed it. Pointers are actually references, or addresses of data stored in memory. Use pointers so functions reference the same instance of data.
```c
// declares the integer variable 'x,' as '3'
int x = 3;					
		
// prints the memory address (pointer) of 'x'
printf("x is stored at %p\n.", &x);	
```
```c
// output goes here
```
The `&` symbol finds the memory address of a variable. The `*` symbol *reads* data at the memory address. 
```c
// declares the integer variable 'x,' as '3'
int x = 3;			
					
// declares a pointer variable using the memory address of 'x'
int *pointer_to_x = &x;				
	
// prints the contents of 'x' (3)
printf("x contains %i \n", x);			
	
// prints the memory address of 'x'
printf("x is stored at %p \n", &x);		
	
// prints of the contents of '*another_copy_of_x' (3)
printf("x contains %i \n", *pointer_to_x )	
	
// pointer arrays contain more than one memory address
int *pointer_array[20]			
```

# FAQs
**What is an** `unsigned char`**?**
* Unsigned chars are 8 bits, 0-255, a single byte 
* Following law of arithmetic modulo (2^n)

**Why are these header files required to make C prog work?** `<stdio.h>` `<string.h>`
* `#include` = directive used to call upon header files
* two types of header files: (1) home-brewed, (2) comes with compiler 
* requested header file has functions in it
* `<stdio.h>` brings `printf()`, `scanf()`

**Why does** `main()` **need** `int` **before it?**
* the `main()` function is used to pass control of the OS to the program 

**What are pre-built functions in C aside from:** `printf()`**,** `strlen()`**?**
* It depends on what header is included/called

**Why is** `return 0` **required in the Main function?**
* It is only required if you use `int main()`
* Can avoid having to use it if you use `void main()`
* `return 0` is an "Exit Status" convention to show the prog exec successfully
* Using `gcc` on a Mac had issues using exit codes > 3 digits 
	* For example, use 23 as exit code

**What is** `%d` **for when using the strlen() function?**
* Prints a decimal integer 
* Use `%s` for strings and `%f` for floating point numbers

**What does the header file** `<string.h>` **provide?**<br>
The `strlen()` function.

**What does this mean?**
```
int (*ret)() = (int (*)())shellcode;
```
```
int (*ret)() 
```
* Declares a function pointer called "ret"
* Takes an unspecific amount of arguments
* Returns an integer

```
(int (*)())shellcode
```
* Casts the "shellcode" array to a (integer type) function pointer
* Converts address of the "shellcode" array to a function pointer
* Which allows you to call it and execute it
* The bytes in the "shellcode" array will vary depending on the CPU!

**What is a function pointer?**<br>
They point to executable code.
