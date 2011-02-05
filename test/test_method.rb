require 'test/unit'
require 'prattle/parser'

class TestMethod < Test::Unit::TestCase
  def test_syntax
    str = <<-STR
Blah define; add: x to: y; as: [ x + y ]
    STR

    parser = Prattle::Parser.new(str)
    node = parser.parse.first

    assert_kind_of Prattle::AST::CascadeSend, node
    start = node.initial

    assert_kind_of Prattle::AST::UnarySend, start
    assert_equal "define", start.method_name
    assert_equal "Blah", start.receiver.name

    sig = node.cascades[0]
    assert_kind_of Prattle::AST::CascadeSend::SubSend, sig
    assert_equal "add:to:", sig.method_name
    assert_equal "x", sig.arguments[0].name
    assert_equal "y", sig.arguments[1].name

    body = node.cascades[1]
    assert_kind_of Prattle::AST::CascadeSend::SubSend, body
    assert_equal "as:", body.method_name
    
    block = body.arguments[0]
    assert_kind_of Prattle::AST::Block, block
    assert_equal "+", block.body.first.operator
    assert_equal "x", block.body.first.lhs.name
    assert_equal "y", block.body.first.rhs.name
  end
end
