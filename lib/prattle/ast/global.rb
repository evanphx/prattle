module Prattle
  module AST
    def self.grammar(g)
      g.sp = g.kleene g.any(" ", "\n")
      g.sig_sp = g.many g.any(" ", "\n")
      g.method_name = /[a-zA-Z][a-zA-Z0-9]*/

      g.grouped = g.seq("(", :sp, g.t(:root), :sp, ")")
      g.level1 = g.any(:true, :false, :self, :nil, :number,
                       :string, :symbol, :variable, :grouped)

      g.level2 = g.any(:unary_send, :level1)

      g.root = g.any(:operator, :level2)
    end
  end
end
