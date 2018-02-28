require 'test_helper'

class RDocCommentPatches < Minitest::Test
  def test_sig_comment
    context = parse <<~RUBY
      # :sig: String, Integer|nil -> String
      def foo(bar, baz)
      end
    RUBY

    rmethod = context.method_list.first

    assert_equal "(String bar, Integer|nil baz) -> String", rmethod.params
  end

  def test_sig_comment_is_removed_from_final_description
    context = parse <<~RUBY
      # Hello world
      #
      # :sig: TrueClass|FalseClass -> Integer
      def dunno(foo)
      end
    RUBY

    rmethod = context.method_list.first

    assert_equal "<p>Hello world</p>", rmethod.description.strip
  end

  def test_call_seq_silences_sig
    context = parse <<~RUBY
      # :call-seq:
      #   foo(bar, baz, quux)
      #
      # :sig: String, nil -> String
      def foo(*args)
      end
    RUBY

    rmethod = context.method_list.first

    assert_equal "(*args)", rmethod.params
  end
end
