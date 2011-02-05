module Prattle
  module AST
    class True < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "true"
      end

      def initialize
      end

      def self.grammar(g)
        g.true = g.str("true") { True.new }
      end

      def bytecode(g)
        g.push :true
      end
    end
  end
end
