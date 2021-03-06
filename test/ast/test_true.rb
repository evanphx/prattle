require 'test/unit'
require 'prattle/parser'

class TestTrue < Test::Unit::TestCase
  def test_parse
    str = "true"
    parser = Prattle::Parser.new(str)
    node = parser.parse :true

    assert_kind_of Prattle::AST::True, node
  end

  def test_value
    assert_equal true, Prattle::AST::True.new.run
  end
end
