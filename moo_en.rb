require :engUS
require 'foo'

puts Foo.respond_to? :say   # true
puts Foo.respond_to? :puts  # false
puts Foo.respond_to? :decir # false

# HELLO
Foo.say

require_relative './moo2'
