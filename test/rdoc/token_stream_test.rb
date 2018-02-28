require 'test_helper'

class RDocTokenStreamPatches < Minitest::Test
  def test_tokens_to_s
    klass = Class.new do
      include RDoc::TokenStream

      def initialize
        @token_stream = [
          { text: "def" },
          { text: " "   },
          { text: "foo" },
          { text: "("   },
          { text: "bar" },
          { text: ")"   },
        ]
      end
    end

    code_object = klass.new

    assert_equal "def foo(bar)", code_object.tokens_to_s
  end
end
