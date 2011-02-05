require 'test/unit'
require 'prattle/parser'

class TestUnarySend < Test::Unit::TestCase
  def test_simple_send
    str = "foo bar"
    parser = Prattle::Parser.new(str)
    node = parser.parse :unary_send

    assert_kind_of Prattle::AST::UnarySend, node
    assert_equal "bar", node.method_name

    assert_kind_of Prattle::AST::Variable, node.receiver
    assert_equal "foo", node.receiver.name
  end

  def test_chaining
    str = "foo bar baz"
    parser = Prattle::Parser.new(str)
    node = parser.parse :unary_send

    assert_kind_of Prattle::AST::UnarySend, node
    assert_equal "baz", node.method_name

    recv = node.receiver

    assert_kind_of Prattle::AST::UnarySend, recv
    assert_equal "bar", recv.method_name

    assert_kind_of Prattle::AST::Variable, recv.receiver
    assert_equal "foo", recv.receiver.name
  end

  def test_value
    str = "3 class"
    parser = Prattle::Parser.new(str)
    node = parser.parse :unary_send

    assert_equal Fixnum, node.run
  end

end
