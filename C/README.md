```bash
# create a source file
vim hello_world.c
```
```c
/* add source code to the source file */
# include <stdio.h>
int main() {
    printf("Hello world!");
    return 0;
}
```
```bash
# compile the source file
gcc -c hello_world.c -o hello_world
```
```bash
# execute the program
./hello_world
```
