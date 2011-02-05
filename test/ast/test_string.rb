require 'test/unit'
require 'prattle/parser'

class TestString < Test::Unit::TestCase
  def test_parse
    str = "'hello'"
    parser = Prattle::Parser.new(str)
    node = parser.parse :string

    assert_kind_of Prattle::AST::String, node
    assert_equal "hello", node.value
  end

  def test_run
    assert_equal "evan", Prattle::AST::String.new("evan").run
  end
end
