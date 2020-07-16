#!/usr/bin/env ruby

def read_src_code()
  src_file = File.open('./input_from_file.rb')
  src_code = src_file.read
  puts src_code
end

read_src_code()
