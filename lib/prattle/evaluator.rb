module Prattle
  class Evaluator
    def initialize(nodes, debug=false)
      @nodes = Array(nodes)
      @debug = debug
    end

    class Scope
      def initialize(parent=nil)
        @parent = parent
        @variables = {}
      end

      attr_reader :variables, :parent

      def find_variable(name)
        depth = 0
        scope = self
        while scope
          if idx = scope.variables[name]
            return [depth, idx]
          end
          depth += 1
          scope = scope.parent
        end

        idx = @variables.size
        @variables[name] = idx

        return [0, idx]
      end

      def add_variable(name)
        idx = @variables.size
        @variables[name] = idx
        return idx
      end
    end

    def compile
      cm = metaclass.dynamic_method :call do |g|
        scope = Scope.new
        g.push_state(scope)

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
