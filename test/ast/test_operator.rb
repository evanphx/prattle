require 'test/unit'
require 'prattle/parser'

class TestOperator < Test::Unit::TestCase
  def test_3_plus_4
    str = "3 + 4"
    parser = Prattle::Parser.new(str)
    node = parser.parse :operator

    assert_kind_of Prattle::AST::Operator, node
    assert_equal "+", node.operator

    assert_kind_of Prattle::AST::Number, node.lhs
    assert_equal 3, node.lhs.value

    assert_kind_of Prattle::AST::Number, node.rhs
    assert_equal 4, node.rhs.value
  end

  def test_3_plus_4_times_5
    str = "3 + 4 * 5"
    parser = Prattle::Parser.new(str)
    top = parser.parse :operator

    assert_kind_of Prattle::AST::Operator, top
    assert_equal "*", top.operator

    node = top.lhs

    assert_kind_of Prattle::AST::Operator, node
    assert_equal "+", node.operator

    assert_kind_of Prattle::AST::Number, node.lhs
    assert_equal 3, node.lhs.value

    assert_kind_of Prattle::AST::Number, node.rhs
    assert_equal 4, node.rhs.value

    assert_kind_of Prattle::AST::Number, top.rhs
    assert_equal 5, top.rhs.value
  end

  def test_3_plus_4_times_5_paren
    str = "3 + (4 * 5)"
    parser = Prattle::Parser.new(str)
    top = parser.parse :operator

    assert_kind_of Prattle::AST::Operator, top
    assert_equal "+", top.operator

    assert_kind_of Prattle::AST::Number, top.lhs
    assert_equal 3, top.lhs.value

    node = top.rhs

    assert_kind_of Prattle::AST::Operator, node
    assert_equal "*", node.operator

    assert_kind_of Prattle::AST::Number, node.lhs
    assert_equal 4, node.lhs.value

    assert_kind_of Prattle::AST::Number, node.rhs
    assert_equal 5, node.rhs.value
  end

  def test_unary_priority1
    str = "3 + 4 factorial"

    parser = Prattle::Parser.new(str)
    add = parser.parse :operator

    assert_kind_of Prattle::AST::Operator, add
    assert_equal "+", add.operator

    assert_equal 3, add.lhs.value

    assert_kind_of Prattle::AST::UnarySend, add.rhs
    assert_equal "factorial", add.rhs.method_name
    assert_equal 4, add.rhs.receiver.value
  end

  def test_unary_priority2
    str = "3 factorial + 4 factorial"

    parser = Prattle::Parser.new(str)
    add = parser.parse :operator

    assert_kind_of Prattle::AST::Operator, add
    assert_equal "+", add.operator

    assert_kind_of Prattle::AST::UnarySend, add.lhs
    assert_equal "factorial", add.lhs.method_name
    assert_equal 3, add.lhs.receiver.value

    assert_kind_of Prattle::AST::UnarySend, add.rhs
    assert_equal "factorial", add.rhs.method_name
    assert_equal 4, add.rhs.receiver.value
  end

  def test_value
    str = "3 + 4"

    parser = Prattle::Parser.new(str)
    add = parser.parse :operator

    assert_equal 7, add.run
  end

end
