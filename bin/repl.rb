require 'prattle/parser'
require 'readline'
require 'pp'

while str = Readline.readline("> ")
  break if str.empty?
  parser = Prattle::Parser.new(str)
  nodes = parser.parse
  pp nodes

  eval = Prattle::Evaluator.new(nodes, true)
  puts "=> #{eval.run.inspect}"
end
