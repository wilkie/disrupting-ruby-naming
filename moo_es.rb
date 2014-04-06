require :spaES
require 'foo'

puts Foo.respond_to? :decir # true
puts Foo.respond_to? :say   # false
puts Foo.respond_to? :puts  # false

# HELLO
Foo.decir

require_relative './moo2'
