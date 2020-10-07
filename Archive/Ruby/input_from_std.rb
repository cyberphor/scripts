#!/usr/bin/env ruby

# ex: echo -e "foo\nbar" | ./input_from_std.rb
# ex: ./input_from_std.rb passwords.txt 

def read_std()
    ARGF.each do |line|
        puts line
    end
end

read_std()
