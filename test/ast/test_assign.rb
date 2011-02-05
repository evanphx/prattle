require 'test/unit'
require 'prattle/parser'

class TestAssign < Test::Unit::TestCase
  def test_parse
    str = "foo := 8"
    parser = Prattle::Parser.new(str)
    node = parser.parse :assign

    assert_kind_of Prattle::AST::Assign, node
    assert_equal "foo", node.name
    assert_equal 8, node.value.value
  end

  def test_value
    str = "foo := 8"
    parser = Prattle::Parser.new(str)
    node = parser.parse :assign

    assert_equal 8, node.run
  end
end
