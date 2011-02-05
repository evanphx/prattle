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

    def add_method(n)
      name = n.initial.receiver.name
      sig = n.cascades[0]
      body = n.cascades[1].arguments[0]

      puts "Adding method #{sig.method_name} to #{name}"

      begin
        const = Object.const_get(name)
      rescue NameError
        const = Class.new
        Object.const_set name, const
      end

      const.dynamic_method sig.method_name.to_sym do |g|
        g.total_args = sig.arguments.size
        g.required_args = g.total_args
        g.local_count = g.required_args

        scope = Scope.new
        g.push_state(scope)

        sig.arguments.each do |arg|
          scope.add_variable arg.name
        end

        body.body.each_with_index do |node,idx|
          g.pop unless idx == 0
          node.bytecode(g)
        end

        g.ret
      end
    end

    def detect_methods
      @nodes.delete_if do |n|
        if n.kind_of? AST::CascadeSend
          init = n.initial
          if init.kind_of? AST::UnarySend and init.method_name == "define"
            add_method(n)
            next true
          end
        end

        false
      end
    end

    def compile
      detect_methods
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
