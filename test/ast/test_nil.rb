require 'test/unit'
require 'prattle/parser'

class TestNil < Test::Unit::TestCase
  def test_parse
    str = "nil"
    parser = Prattle::Parser.new(str)
    node = parser.parse :nil

    assert_kind_of Prattle::AST::Nil, node
  end

  def test_value
    assert_equal nil, Prattle::AST::Nil.new.run
  end
end
