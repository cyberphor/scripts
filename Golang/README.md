## Table of Contents
* [A quick "Hello world!" example](#a-quick-hello-world-example)
* [Setup](#setup)
* [Comments](#comments)
* [Variables](#variables)
* [User input](#user-input)
* TODO:
  * If statements
  * For loops
  * Sockets
  * Read files
  * Write to files

## A quick "Hello world!" example
1. Use a text-editor to create a source file
2. Add your source code
3. Tell Go to execute your program

```bash
# step 1
vim hello_world.go
```
```go
// step 2
package main
import "fmt"

func main() {
    fmt.Println("Hello world!")
}
```
```bash
# step 3
go run hello_world.go
```

## Setup
Run the command below to install the Go language onto your Linux machine.
```bash
sudo apt install go
```

## Comments
Use two forward-slashes or a forward-slash to include a comment in your Go code. You can also use forward-slash and asterisk book-ends for a multi-line comment.
```go
// this is a one-line comment

/*
this is a
multi-line
comment
*/
```
Below is an example of Go code with single and multi-line comments.
```go
// author: Victor Fernandez 
package main
import "fmt"

func main() {
    fmt.Println("Hello world!")
    /*
        TODO:
            1. Foo
            2. Bar
    */
}
```

## Variables
Use `var`, `int`, and/or `:=` to delcare variables. 
```go
var color = "white"
var atm_pin int = 1234
secret := "Peanut butter goes on first."
```
Below is an example of Go code with explicitly declared strings and integers. The example also includes a variable with a *data type* determined automatically by Go. 
```go
package main
import "fmt"

func main() {
    var color string = "white"
    fmt.Println("My laces are " + color)

    var atm_pin int = 1234
    fmt.Println(atm_pin)

    secret := "Peanut butter goes on first."
    fmt.Println("Psst..." + secret)
}
```
Use the `strconv` library to convert integers to strings. Below is an example of how you can print both data types together.
```go
package main
import "fmt"
import "strconv"

func main() {
    number := 1234
    letters := strconv.Itoa(number)
    fmt.Println("My ATM PIN is " + letters)
}
```

## User input
Use the `bufio` and `os` libraries to process user input. Below is an example. 
```go
package main
import "fmt"
import "bufio"
import "os"

func main() {
    reader := bufio.NewReader(os.Stdin)
    fmt.Println("Who are you?")
    username, _ := reader.ReadString('\n')
    fmt.Print("Hello, " + username)
}
```
