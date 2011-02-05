require 'test/unit'
require 'prattle/parser'

class TestBlock < Test::Unit::TestCase
  def test_parse
    str = "[ bar ]"
    parser = Prattle::Parser.new(str)
    node = parser.parse :block

    assert_kind_of Prattle::AST::Block, node
    body = node.body.first

    assert_kind_of Prattle::AST::Variable, body
    assert_equal "bar", body.name
  end

  def test_multiple_expressions
    str = "[ bar. baz ]"
    parser = Prattle::Parser.new(str)
    node = parser.parse :block

    assert_kind_of Prattle::AST::Block, node
    body = node.body

    assert_equal 2, body.size

    assert_kind_of Prattle::AST::Variable, body[0]
    assert_equal "bar", body[0].name

    assert_kind_of Prattle::AST::Variable, body[1]
    assert_equal "baz", body[1].name
  end

  def test_multiple_expressions_sp
    many = ["[bar.baz]", "[bar.  baz]", "[bar .baz]", "[bar.\n baz]"]
    many.each do |str|
      parser = Prattle::Parser.new(str)
      node = parser.parse :block

      assert_kind_of Prattle::AST::Block, node
      body = node.body

      assert_equal 2, body.size

      assert_kind_of Prattle::AST::Variable, body[0]
      assert_equal "bar", body[0].name

      assert_kind_of Prattle::AST::Variable, body[1]
      assert_equal "baz", body[1].name
    end
  end

  def test_block_args
    str = "[ :x | x + 2 ]"
    parser = Prattle::Parser.new(str)
    node = parser.parse :block

    assert_kind_of Prattle::AST::Block, node
    body = node.body.first

    assert_equal ["x"], node.arguments

    assert_kind_of Prattle::AST::Operator, body
    assert_equal "x", body.lhs.name
    assert_equal 2, body.rhs.value
  end

  def test_many_block_args
    str = "[ :x :y | x + y ]"
    parser = Prattle::Parser.new(str)
    node = parser.parse :block

    assert_kind_of Prattle::AST::Block, node
    body = node.body.first

    assert_equal ["x", "y"], node.arguments

    assert_kind_of Prattle::AST::Operator, body
    assert_equal "x", body.lhs.name
    assert_equal "y", body.rhs.name
  end

  def test_value
    str = "[ 1 ]"
    parser = Prattle::Parser.new(str)
    node = parser.parse :block

    prc = node.run
    assert_kind_of Proc, prc
    assert_equal 1, prc.call
  end

  def test_called_value
    str = "[ 1 ] call"
    parser = Prattle::Parser.new(str)
    node = parser.parse.first

    assert_equal 1, node.run
  end

  def test_called_with_arg
    str = "[ :x | x ] ~call: 8"
    parser = Prattle::Parser.new(str)
    node = parser.parse.first

    assert_equal 8, node.run
  end

  def test_called_with_args
    str = "[ :x :y | {x. y} ] ~call: 8 and: 9"
    parser = Prattle::Parser.new(str)
    node = parser.parse.first

    assert_equal [8,9], node.run
  end
end
