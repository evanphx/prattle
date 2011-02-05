module Prattle
  module AST
    class CascadeSend < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "cascade_send"
      end

      def initialize(initial, cascades)
        @initial = initial
        @cascades = Array(cascades)
      end

      attr_reader :initial, :cascades

      class SubSend
        def initialize(name, arguments=[])
          @method_name = name
          @arguments = arguments
        end

        attr_reader :method_name, :arguments
      end

      def self.grammar(g)
        g.cascade_simple = g.seq(:method_name) { |n| SubSend.new(n) }
        g.cascade_args = g.seq(:send_args) { |pair|
                           SubSend.new(*pair)
                         }
        g.cascade_any = g.any(:cascade_args, :cascade_simple)
        g.cascades = g.seq(:sp, ";", :sp, g.t(:cascade_any))

        g.cascade_send = g.seq(g.any(:keyword_send, :unary_send),
                               g.many(:cascades)) do |s,c|
          CascadeSend.new(s,c)
        end
      end

      def bytecode(g)
        recv = @initial.receiver

        recv.bytecode(g)
        g.dup

        KeywordSend.send_method g, @initial.method_name, @initial.arguments

        @cascades.each_with_index do |c,idx|
          g.pop
          g.dup

          KeywordSend.send_method g, c.method_name, c.arguments
        end
      end
    end
  end
end
