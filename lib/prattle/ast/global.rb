module Prattle
  module AST
    def self.grammar(g)
      g.sp = g.kleene g.any(" ", "\n")
      g.sig_sp = g.many g.any(" ", "\n")
      g.method_name = /~?[a-zA-Z][a-zA-Z0-9]*/

      g.grouped = g.seq("(", :sp, g.t(:expression), :sp, ")")
      g.level1 = g.any(:true, :false, :self, :nil, :number,
                       :string, :symbol, :variable, :grouped,
                       :block, :array_literal)

      g.level2 = g.any(:unary_send, :level1)

      g.level3 = g.any(:operator, :level2)

      g.expression = g.any(:cascade_send, :keyword_send, :assign, :level3)

      g.expressions = g.seq(:expression, :sp,
                            g.kleene(
                              g.seq(:sp, ".", :sp, g.t(:expression), :sp))) {
                                |x,_,m|
                                m = Array(m)
                                m.unshift x
                                m
                              }

      g.root = g.expressions
    end
  end
end
