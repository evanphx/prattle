require 'test/unit'
require 'prattle/parser'

class TestArray < Test::Unit::TestCase
  def test_parse
    str = "{ a. b }"
    parser = Prattle::Parser.new(str)
    node = parser.parse :array_literal

    assert_kind_of Prattle::AST::ArrayLiteral, node
    assert_equal 2, node.elements.size

    assert_equal "a", node.elements[0].name
    assert_equal "b", node.elements[1].name
  end

  def test_value
    str = "{ #a. #b }"
    parser = Prattle::Parser.new(str)
    node = parser.parse :array_literal

    assert_equal [:a, :b], node.run
  end

  def test_send_to_array
    str = "{ 1 } class"

    parser = Prattle::Parser.new(str)
    node = parser.parse :unary_send

    assert_kind_of Prattle::AST::UnarySend, node
    assert_equal "class", node.method_name

    recv = node.receiver

    assert_kind_of Prattle::AST::ArrayLiteral, recv
    assert_equal 1, recv.elements[0].value
  end

  def test_send_to_array2
    str = "{ 1. 2. 3 } class"

    parser = Prattle::Parser.new(str)
    node = parser.parse :unary_send

    assert_kind_of Prattle::AST::UnarySend, node
    assert_equal "class", node.method_name

    recv = node.receiver

    assert_kind_of Prattle::AST::ArrayLiteral, recv
    assert_equal 1, recv.elements[0].value
  end
end
