module Prattle
  module AST
    class Block < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "block"
      end

      def initialize(body, args)
        @body = body
        @arguments = args
      end

      attr_reader :body, :arguments

      def self.grammar(g)
        name = g.seq(":", g.t(/[a-zA-Z][a-zA-Z0-9_]*/), :sp)
        args = g.seq(:sp, g.t(g.kleene(name)), "|")

        g.block = g.seq('[', g.t(g.maybe(args)), :sp,
                             g.t(:expressions), :sp, ']') do |args,v|
          Block.new(v, Array(args))
        end
      end

      def bytecode(g)
        c = Rubinius::Generator.new
        c.name = :block
        c.file = :dynamic
        c.set_line 1

        scope = Evaluator::Scope.new(g.state.scope)
        c.push_state(scope)

        c.required_args = c.total_args = @arguments.size
        c.local_count = @arguments.size

        case @arguments.size
        when 0
          # Nothing
        when 1
          c.cast_for_single_block_arg
          c.set_local scope.add_variable(@arguments.first)
          c.pop
        else
          c.cast_for_multi_block_arg
          @arguments.each do |a|
            c.shift_array
            c.set_local scope.add_variable(a)
            c.pop
          end
          c.pop
        end

        @body.each_with_index do |node,idx|
          c.pop unless idx == 0
          node.bytecode(c)
        end

        c.ret
        c.close

        c.use_detected

        g.push_const :Kernel
        g.create_block c
        g.send_with_block :proc, 0
      end
    end
  end
end
