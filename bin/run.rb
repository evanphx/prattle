require 'prattle/parser'
require 'pp'

file = ARGV.shift
str = File.read(file)

parser = Prattle::Parser.new(str)
begin
  nodes = parser.parse
rescue Prattle::Parser::ParseError => e
  p e.parser.pos
  e.parser.show_error
  exit
end

eval = Prattle::Evaluator.new(nodes)
eval.run
