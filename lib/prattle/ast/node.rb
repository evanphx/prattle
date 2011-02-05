require 'prattle/evaluator'

module Prattle
  module AST
    class Node
      def run
        Evaluator.new(self).run
      end
    end
  end
end
