#!/usr/bin/env python3

line_up = ["joe","john","jim"]
name = input("What is your name? ")
line_up += name

for person in line_up:
    if person == "victor":
        print("I know a cool dude named " + person)
    elif person == "elliot":
        print("I know a hacker-man named " + person)
    else:
        print("I know someone named " + person)
