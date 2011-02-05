require 'prattle/parser'
require 'readline'
require 'pp'

while str = Readline.readline("> ")
  break if str.empty?

  parser = Prattle::Parser.new(str)
  begin
    nodes = parser.parse
  rescue Prattle::Parser::ParseError => e
    puts "Syntax error detected:"
    e.parser.show_error
    next
  end

  pp nodes

  eval = Prattle::Evaluator.new(nodes, true)
  puts "=> #{eval.run.inspect}"
end
