module Prattle
  module AST
    class Nil < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "nil"
      end

      def initialize
      end

      def self.grammar(g)
        g.nil = g.str("nil") { Nil.new }
      end

      def bytecode(g)
        g.push :nil
      end
    end
  end
end
