require 'test/unit'
require 'prattle/parser'

class TestFalse < Test::Unit::TestCase
  def test_parse
    str = "false"
    parser = Prattle::Parser.new(str)
    node = parser.parse :false

    assert_kind_of Prattle::AST::False, node
  end

  def test_value
    assert_equal false, Prattle::AST::False.new.run
  end
end
