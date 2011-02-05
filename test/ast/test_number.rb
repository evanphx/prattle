require 'test/unit'
require 'prattle/parser'

class TestNumber < Test::Unit::TestCase
  def test_parse
    parser = Prattle::Parser.new("1")
    node = parser.parse :number

    assert_kind_of Prattle::AST::Number, node
    assert_equal 1, node.value
  end

  def test_zero
    parser = Prattle::Parser.new("0")
    node = parser.parse :number

    assert_kind_of Prattle::AST::Number, node
    assert_equal 0, node.value
  end
end
