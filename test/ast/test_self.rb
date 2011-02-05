require 'test/unit'
require 'prattle/parser'

class TestSelf < Test::Unit::TestCase
  def test_parse
    str = "self"
    parser = Prattle::Parser.new(str)
    node = parser.parse :self

    assert_kind_of Prattle::AST::Self, node
  end
end
