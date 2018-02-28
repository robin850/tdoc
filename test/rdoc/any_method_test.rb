require 'test_helper'

class RDocAnyMethodPatches < Minitest::Test
  def test_deprecated_predicate
    context = parse <<~RUBY
      def foo
        ActiveSupport::Deprecation.warn(<<~FOO)
          Hello world!
        FOO
      end
    RUBY

    rmethod = context.method_list.first

    assert rmethod.deprecated?
    assert_equal "Hello world!", rmethod.deprecation_message.strip
  end

  def test_plugin_api_methods
    context = parse <<~RUBY
      def foo # :plugin:
      end
    RUBY

    rmethod = context.method_list.first

    assert rmethod.plugin_api?
    refute rmethod.private_api?
  end

  def test_private_api_methods
    context = parse <<~RUBY
      def foo # :private:
      end
    RUBY

    rmethod = context.method_list.first

    assert rmethod.private_api?
    refute rmethod.plugin_api?
  end
end
