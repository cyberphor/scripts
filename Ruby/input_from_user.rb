#!/usr/bin/env ruby

def greet_user()
    puts '[+] Who are you?'
    name = gets
    puts '[+] Hello ' + name
end

greet_user()
