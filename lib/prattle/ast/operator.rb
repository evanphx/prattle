module Prattle
  module AST
    class Operator < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "operator"
      end

      def initialize(operator, lhs, rhs)
        @operator = operator
        @lhs = lhs
        @rhs = rhs
      end

      attr_reader :operator, :lhs, :rhs

      def self.grammar(g)
        g.operators = g.any("+", "-", "*", "/", ">=", ">", "<=", "<")
        g.operator = g.seq(:operator, :sp, :operators, :sp, :level2) { |l,_,o,_,r|
                          Operator.new(o,l,r)
                        } \
                   | g.seq(:level2, :sp, :operators, :sp, :level2) { |l,_,o,_,r|
                          Operator.new(o,l,r)
                        }
      end

      def bytecode(g)
        @lhs.bytecode(g)
        @rhs.bytecode(g)
        g.send @operator.to_sym, 1
      end
    end
  end
end
