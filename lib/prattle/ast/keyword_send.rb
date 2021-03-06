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

      def self.if_cond(g, name, args, if_true)
        return false unless args[0].kind_of? AST::Block

        done_lbl = g.new_label
        else_lbl = g.new_label

        if if_true
          g.gif else_lbl
        else
          g.git else_lbl
        end

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

      def self.if_cond_else(g, name, args, if_true)
        return false unless args[0].kind_of? AST::Block
        return false unless args[1].kind_of? AST::Block

        done_lbl = g.new_label
        else_lbl = g.new_label

        if if_true
          g.gif else_lbl
        else
          g.git else_lbl
        end

        args[0].body.each_with_index do |e,idx|
          g.pop unless idx == 0
          e.bytecode(g)
        end

        g.goto done_lbl

        else_lbl.set!

        args[1].body.each_with_index do |e,idx|
          g.pop unless idx == 0
          e.bytecode(g)
        end

        done_lbl.set!

        return true
      end

      def self.send_method(g, name, args)
        case name
        when "ifTrue:"
          return if if_cond g, name, args, true
        when "ifFalse:"
          return if if_cond g, name, args, false
        when "ifTrue:ifFalse:"
          return if if_cond_else g, name, args, true
        when "ifFalse:ifTrue:"
          return if if_cond_else g, name, args, false
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

      def loop_cond(g, if_true)
        return false unless @receiver.kind_of? AST::Block
        return false unless @arguments[0].kind_of? AST::Block

        top_lbl  = g.new_label
        done_lbl = g.new_label

        top_lbl.set!

        @receiver.body.each_with_index do |e,idx|
          g.pop unless idx == 0
          e.bytecode(g)
        end

        if if_true
          g.gif done_lbl
        else
          g.git done_lbl
        end

        @arguments[0].body.each_with_index do |e,idx|
          e.bytecode(g)
          g.pop
        end

        g.goto top_lbl

        done_lbl.set!
        g.push :nil

        return true
      end

      def bytecode(g)
        case @method_name
        when "whileTrue:"
          return if loop_cond g, true
        when "whileFalse:"
          return if loop_cond g, false
        end

        @receiver.bytecode(g)

        KeywordSend.send_method g, @method_name, @arguments
      end
    end
  end
end
