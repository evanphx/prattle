module Prattle
  module AST
    def self.grammar(g)
      g.root = g.any(:true, :false, :self, :nil, :number,
                     :string, :symbol, :variable)
    end
  end
end
