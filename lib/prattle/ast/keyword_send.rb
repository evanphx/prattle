module Prattle
  module AST
    class KeywordSend < AST::Node
      Prattle::Parser.register self

      def self.rule_name
        "keyword_send"
      end

      def initialize(receiver, name)
        @receiver = receiver
        @method_name = name
        @arguments = []
      end

      attr_reader :receiver, :method_name, :arguments

      Pair = Struct.new(:name, :value)

      def self.collect(pairs)
        name = ""
        args = []

        if pairs.kind_of? Array
          pairs.each do |pair|
            name << "#{pair.name}:"
            args << pair.value
          end
        else
          name << "#{pairs.name}:"
          args << pairs.value
        end

        [name, args]
      end

      def self.grammar(g)
        g.name_var_pair = g.seq(g.t(:method_name), ":", :sp, g.t(:level3),
                                g.kleene(" ")) do |n,v|
          Pair.new(n,v)
        end

        g.send_args = g.many(:name_var_pair) do |*pairs|
          collect(pairs)
        end

        g.keyword_send = g.seq(:level3, :sig_sp, :send_args) do
                              |v,_,arg|

          s = new(v,arg.first)
          s.arguments.concat arg.last
          s
        end
      end

      def bytecode(g)
        @receiver.bytecode(g)

        if @method_name[0] == ?~
          @arguments.each do |a|
            a.bytecode(g)
          end

          colon = @method_name.index(":")
          new_name = @method_name[1..colon-1]

          g.send new_name.to_sym, @arguments.size
        else
          @arguments.each do |a|
            a.bytecode(g)
          end

          g.send @method_name.to_sym, @arguments.size
        end
      end
    end
  end
end
