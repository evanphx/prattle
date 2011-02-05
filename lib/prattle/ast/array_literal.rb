module Prattle
  module AST
    class ArrayLiteral < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "array"
      end

      def initialize(elements)
        @elements = elements
      end

      attr_reader :elements

      def self.grammar(g)
        g.array_literal = g.seq("{", :sp, g.t(:expressions), :sp, "}") { |e|
          ArrayLiteral.new(e)
        }
      end

      def bytecode(g)
        @elements.each do |e|
          e.bytecode(g)
        end

        g.make_array @elements.size
      end
    end
  end
end
