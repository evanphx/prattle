module Prattle
  module AST
    def self.grammar(g)
      g.root = g.any(:true, :false, :self, :nil, :number)
    end
  end
end
