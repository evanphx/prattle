module Prattle
  module AST
    class Variable < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "variable"
      end

      def initialize(name)
        @name = name
      end

      attr_reader :name

      def self.grammar(g)
        g.variable = g.lit(/[a-zA-Z][a-zA-Z0-9_]*/) do |str|
          Variable.new(str)
        end
      end

      def bytecode(g)
        if /^[A-Z]/.match(@name)
          g.push_const @name.to_sym
        else
          depth, slot = g.state.scope.find_variable @name
          g.push_local slot
        end
      end
    end
  end
end
