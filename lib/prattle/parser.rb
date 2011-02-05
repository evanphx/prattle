# Introduce our vendored kpeg
$:.unshift File.expand_path("../../vendor/kpeg/lib", __FILE__)

require 'kpeg'

module Prattle
  class Parser
    @nodes = []
    def self.register(node)
      @nodes << node
    end

    def self.to_kpeg
      gram = KPeg::Grammar.new

      @nodes.each do |node|
        node.grammar(gram)
      end

      gram
    end

    def initialize(str)
      @parser = KPeg::Parser.new(str, Grammar)
    end

    class ParseError < RuntimeError
      def initialize(parser, match)
        super parser.error_expectation
        @parser = parser
        @match = match
      end

      attr_reader :parser, :match
    end

    def parse(rule=nil)
      @last_match = match = @parser.parse(rule ? rule.to_s : nil)

      if @parser.failed?
        raise ParseError.new(@parser, match)
      end

      return match.value if match
    end

    attr_reader :last_match

    path = File.expand_path("../ast", __FILE__)

    require 'prattle/ast/node'

    Dir["#{path}/*.rb"].sort.each do |f|
      require "prattle/ast/#{File.basename f}"
    end

    Grammar = to_kpeg
  end
end

