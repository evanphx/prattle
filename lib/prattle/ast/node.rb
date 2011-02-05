require 'prattle/evaluator'

module Prattle
  module AST
    class Node
      def run(debug=false)
        Evaluator.new(self, debug).run
      end
    end
  end
end
