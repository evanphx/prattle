require 'test/unit'
require 'prattle/parser'

class TestKeywordSend < Test::Unit::TestCase
  def test_chaining_with_arg
    str = "foo bar baz: cash"
    parser = Prattle::Parser.new(str)
    node = parser.parse :keyword_send

    assert_kind_of Prattle::AST::KeywordSend, node
    assert_equal "baz:", node.method_name
    assert_equal 1, node.arguments.size
    assert_kind_of Prattle::AST::Variable, node.arguments[0]
    assert_equal "cash", node.arguments[0].name

    recv = node.receiver

    assert_kind_of Prattle::AST::UnarySend, recv
    assert_equal "bar", recv.method_name

    assert_kind_of Prattle::AST::Variable, recv.receiver
    assert_equal "foo", recv.receiver.name
  end

  def test_with_argument
    str = "foo bar: baz"
    parser = Prattle::Parser.new(str)
    node = parser.parse :keyword_send

    assert_kind_of Prattle::AST::KeywordSend, node
    assert_equal "bar:", node.method_name

    assert_kind_of Prattle::AST::Variable, node.receiver
    assert_equal "foo", node.receiver.name

    args = node.arguments
    assert_equal 1, args.size
    assert_kind_of Prattle::AST::Variable, args[0]
    assert_equal "baz", args[0].name
  end

  def test_with_two_arguments
    str = "foo bar: baz with: ballons"
    parser = Prattle::Parser.new(str)
    node = parser.parse :keyword_send

    assert_kind_of Prattle::AST::KeywordSend, node
    assert_equal "bar:with:", node.method_name

    assert_kind_of Prattle::AST::Variable, node.receiver
    assert_equal "foo", node.receiver.name

    args = node.arguments
    assert_equal 2, args.size
    assert_kind_of Prattle::AST::Variable, args[0]
    assert_equal "baz", args[0].name

    assert_kind_of Prattle::AST::Variable, args[1]
    assert_equal "ballons", args[1].name
  end

  def test_with_vars_and_numbers
    str = "foo bar: 8 with: ballons"
    parser = Prattle::Parser.new(str)
    node = parser.parse :keyword_send

    assert_kind_of Prattle::AST::KeywordSend, node
    assert_equal "bar:with:", node.method_name

    assert_kind_of Prattle::AST::Variable, node.receiver
    assert_equal "foo", node.receiver.name

    args = node.arguments
    assert_equal 2, args.size
    assert_kind_of Prattle::AST::Number, args[0]
    assert_equal 8, args[0].value

    assert_kind_of Prattle::AST::Variable, args[1]
    assert_equal "ballons", args[1].name
  end

  def test_with_vars_and_numbers_sp
    many = ["foo bar: 8 with: ballons",
            "foo bar:8 with: ballons",
            "foo  bar: 8 with: ballons",
            "foo bar: 8 with:ballons",
            "foo bar: 8 with:  ballons"]

    many.each do |str|
      parser = Prattle::Parser.new(str)
      node = parser.parse :keyword_send

      assert_kind_of Prattle::AST::KeywordSend, node
      assert_equal "bar:with:", node.method_name

      assert_kind_of Prattle::AST::Variable, node.receiver
      assert_equal "foo", node.receiver.name

      args = node.arguments
      assert_equal 2, args.size
      assert_kind_of Prattle::AST::Number, args[0]
      assert_equal 8, args[0].value

      assert_kind_of Prattle::AST::Variable, args[1]
      assert_equal "ballons", args[1].name
    end
  end

  def test_priority
    str = "3 factorial + 4 factorial between: 10 and: 100"

    parser = Prattle::Parser.new(str)
    top = parser.parse :keyword_send

    assert_kind_of Prattle::AST::KeywordSend, top
    assert_equal "between:and:", top.method_name

    assert_equal 10,  top.arguments[0].value
    assert_equal 100, top.arguments[1].value

    add = top.receiver

    assert_kind_of Prattle::AST::Operator, add
    assert_equal "+", add.operator


    assert_kind_of Prattle::AST::UnarySend, add.lhs
    assert_equal "factorial", add.lhs.method_name
    assert_equal 3, add.lhs.receiver.value

    assert_kind_of Prattle::AST::UnarySend, add.rhs
    assert_equal "factorial", add.rhs.method_name
    assert_equal 4, add.rhs.receiver.value
  end

  def test_ruby_value
    str = "'hello' ~index: 'l'"

    parser = Prattle::Parser.new(str)
    node = parser.parse :keyword_send

    assert_equal 2, node.run
  end
end
