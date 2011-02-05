module Prattle
  class Lobby
    def print(str)
      Kernel.puts(str)
    end

    alias_method :"print:", :print

    def show(obj)
      p obj
    end

    alias_method :"p:", :show

    def new_class(str)
      Object.const_set str, Class.new

      puts "Created class #{str}"
    end

    alias_method :"newclass:", :new_class

    def import(str)
      require str
    end

    alias_method :"import:", :import
  end

  class Evaluator
    def initialize(nodes, debug=false)
      @nodes = Array(nodes)
      @debug = debug
      @lobby = Lobby.new
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
      cm = @lobby.metaclass.dynamic_method :call do |g|
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
      @lobby.call
    end
  end
end
