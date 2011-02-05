module Prattle
  module AST
    def self.grammar(g)
      g.sig_sp = g.many g.any(" ", "\n")
      g.method_name = /[a-zA-Z][a-zA-Z0-9]*/

      g.level1 = g.any(:true, :false, :self, :nil, :number,
                       :string, :symbol, :variable)

      g.root = g.any(:unary_send, :level1)
    end
  end
end
