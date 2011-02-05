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

      def self.conditional(g, name, args)
        return false unless args[0].kind_of? AST::Block

        done_lbl = g.new_label
        else_lbl = g.new_label

        g.gif else_lbl
        args[0].body.each_with_index do |e,idx|
          g.pop unless idx == 0
          e.bytecode(g)
        end

        g.goto done_lbl

        else_lbl.set!
        g.push :nil

        done_lbl.set!

        return true
      end

      def self.send_method(g, name, args)
        if name == "ifTrue:"
          return if conditional g, name, args
        end

        if name[0] == ?~
          if args.last.kind_of? Block
            block = args.pop
          end

          args.each do |a|
            a.bytecode(g)
          end

          colon = name.index(":")
          new_name = name[1..colon-1]

          if block
            block.bytecode(g)
            g.send_with_block new_name.to_sym, args.size
          else
            g.send new_name.to_sym, args.size
          end

        else
          args.each do |a|
            a.bytecode(g)
          end

          g.send name.to_sym, args.size
        end
      end

      def bytecode(g)
        @receiver.bytecode(g)

        KeywordSend.send_method g, @method_name, @arguments
      end
    end
  end
end
