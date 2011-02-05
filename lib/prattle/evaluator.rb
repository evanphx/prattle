module Prattle
  class Evaluator
    def initialize(nodes, debug=false)
      @nodes = Array(nodes)
      @debug = debug
    end

    def compile
      cm = metaclass.dynamic_method :call do |g|
        if @nodes.empty?
          g.push :nil
        else
          @nodes.each_with_index do |node,idx|
            g.pop unless idx == 0
            node.bytecode(g)
          end
        end

        g.ret
      end

      puts cm.decode if @debug
    end

    def run
      compile
      call
    end
  end
end
