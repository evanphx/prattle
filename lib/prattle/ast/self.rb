module Prattle
  module AST
    class Self < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "self"
      end

      def initialize
        # Nothing.
      end

      def self.grammar(g)
        g.self = g.str("self") { Self.new }
      end
    end
  end
end
