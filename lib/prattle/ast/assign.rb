module Prattle
  module AST
    class Assign < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "assign"
      end

      def initialize(name, value)
        @name = name
        @value = value
      end

      attr_reader :name, :value

      def self.grammar(g)
        g.assign = g.seq(g.t(/[a-z][a-zA-Z0-9_]*/),
                         :sp, ":=", :sp, g.t(:expression)) do |name, expr|
          Assign.new(name, expr)
        end
      end

      def bytecode(g)
        depth, slot = g.state.scope.find_variable @name
        @value.bytecode(g)
        g.set_local slot
      end
    end
  end
end
