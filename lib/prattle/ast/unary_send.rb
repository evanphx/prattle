module Prattle
  module AST
    class UnarySend < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "unary_send"
      end

      def initialize(receiver, method)
        @receiver = receiver
        @method_name = method
      end

      attr_reader :receiver, :method_name

      def self.grammar(g)
        g.unary_send = g.seq(:unary_send, :sig_sp, :method_name, g.notp(":")) {
                            |v,_,n| UnarySend.new(v,n)
                         } \
                     | g.seq(:level1, :sig_sp, :method_name, g.notp(":")) {
                          |v,_,n| UnarySend.new(v,n)
                        } 
      end

      def bytecode(g)
        @receiver.bytecode(g)
        g.send @method_name.to_sym, 0
      end
    end
  end
end
