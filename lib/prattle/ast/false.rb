module Prattle
  module AST
    class False < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "false"
      end

      def initialize
      end

      def self.grammar(g)
        g.false = g.str("false") { False.new }
      end
    end
  end
end
