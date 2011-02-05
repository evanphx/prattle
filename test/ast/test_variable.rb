require 'test/unit'
require 'prattle/parser'

class TestVariable < Test::Unit::TestCase
  def test_parse
    str = "foo"
    parser = Prattle::Parser.new(str)
    node = parser.parse :variable

    assert_kind_of Prattle::AST::Variable, node
    assert_equal "foo", node.name
  end

  def test_underscores
    str = "foo_bar"
    parser = Prattle::Parser.new(str)
    node = parser.parse :variable

    assert_kind_of Prattle::AST::Variable, node
    assert_equal "foo_bar", node.name
  end

  def test_uppercase
    str = "Window"
    parser = Prattle::Parser.new(str)
    node = parser.parse :variable

    assert_kind_of Prattle::AST::Variable, node
    assert_equal "Window", node.name
  end

  def test_constant_variable
    str = "Kernel"
    parser = Prattle::Parser.new(str)
    node = parser.parse :variable

    assert_equal Kernel, node.run
  end
end
