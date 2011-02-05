require 'test/unit'
require 'prattle/parser'

class TestSymbol < Test::Unit::TestCase
  def test_parse
    str = "#foo"
    parser = Prattle::Parser.new(str)
    node = parser.parse :symbol

    assert_kind_of Prattle::AST::Symbol, node
    assert_equal "foo", node.name
  end

  def test_value
    assert_equal :foo, Prattle::AST::Symbol.new("foo").run
  end
end
