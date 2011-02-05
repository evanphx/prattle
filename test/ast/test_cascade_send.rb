require 'test/unit'
require 'prattle/parser'

class TestCascadeSend < Test::Unit::TestCase
  def test_simple
    str = "foo bar ; baz"
    parser = Prattle::Parser.new(str)
    node = parser.parse :cascade_send

    assert_kind_of Prattle::AST::CascadeSend, node
    initial = node.initial

    assert_kind_of Prattle::AST::UnarySend, initial
    assert_equal "bar", initial.method_name
    assert_kind_of Prattle::AST::Variable, initial.receiver
    assert_equal "foo", initial.receiver.name

    assert_equal 1, node.cascades.size
    s = node.cascades[0]
    assert_kind_of Prattle::AST::CascadeSend::SubSend, s
    assert_equal "baz", s.method_name
  end

  def test_with_arg
    str = "foo bar ; with: baz"
    parser = Prattle::Parser.new(str)
    node = parser.parse :cascade_send

    assert_kind_of Prattle::AST::CascadeSend, node
    initial = node.initial

    assert_kind_of Prattle::AST::UnarySend, initial
    assert_equal "bar", initial.method_name
    assert_kind_of Prattle::AST::Variable, initial.receiver
    assert_equal "foo", initial.receiver.name

    assert_equal 1, node.cascades.size
    s = node.cascades[0]
    assert_kind_of Prattle::AST::CascadeSend::SubSend, s
    assert_equal "with:", s.method_name

    assert_equal 1, s.arguments.size
    assert_kind_of Prattle::AST::Variable, s.arguments[0]
    assert_equal "baz", s.arguments[0].name
  end

  def test_with_two_args
    str = "foo bar ; with: baz and: ballon"
    parser = Prattle::Parser.new(str)
    node = parser.parse :cascade_send

    assert_kind_of Prattle::AST::CascadeSend, node
    initial = node.initial

    assert_kind_of Prattle::AST::UnarySend, initial
    assert_equal "bar", initial.method_name
    assert_kind_of Prattle::AST::Variable, initial.receiver
    assert_equal "foo", initial.receiver.name

    assert_equal 1, node.cascades.size
    s = node.cascades[0]
    assert_kind_of Prattle::AST::CascadeSend::SubSend, s
    assert_equal "with:and:", s.method_name

    assert_equal 2, s.arguments.size
    assert_kind_of Prattle::AST::Variable, s.arguments[0]
    assert_equal "baz", s.arguments[0].name

    assert_kind_of Prattle::AST::Variable, s.arguments[1]
    assert_equal "ballon", s.arguments[1].name
  end

  def test_classic
    str = "window new label: hello; open"
    parser = Prattle::Parser.new(str)
    node = parser.parse :cascade_send

    assert_kind_of Prattle::AST::CascadeSend, node
    s = node.initial

    assert_kind_of Prattle::AST::KeywordSend, s
    assert_equal "label:", s.method_name

    assert_equal 1, s.arguments.size
    assert_kind_of Prattle::AST::Variable, s.arguments[0]
    assert_equal "hello", s.arguments[0].name

    r = s.receiver
    assert_kind_of Prattle::AST::UnarySend, r
    assert_equal "new", r.method_name
    assert_kind_of Prattle::AST::Variable, r.receiver
    assert_equal "window", r.receiver.name

    assert_equal 1, node.cascades.size

    s = node.cascades[0]
    assert_kind_of Prattle::AST::CascadeSend::SubSend, s
    assert_equal "open", s.method_name
  end

  def test_value
    str = "CascadeTester ~add: 8; ~add: 9"
    parser = Prattle::Parser.new(str)
    node = parser.parse :cascade_send

    assert_equal 9, node.run
    assert_equal [8,9], CascadeTester.seen
  end
end
  
class CascadeTester
  def self.add(x)
    @seen ||= []
    @seen << x
    x
  end

  def self.seen
    @seen
  end
end

