require 'test_helper'

class RDocMarkupToHtmlPatches < Minitest::Test
  def test_anchors_are_not_present
    context = parse <<~RUBY
      # == A title
      def foo
      end
    RUBY

    rmethod   = context.method_list.first
    title_tag = %(<h2 id="method-i-foo-label-A+title">A title</h2>)

    assert_equal title_tag, rmethod.description.strip
  end

  def test_code_highlighting_is_enabled
    context = parse <<~RUBY
      # Here's some text:
      #
      #   puts "And a super cool code snippet"
      def bar
      end
    RUBY

    rmethod = context.method_list.first

    assert_includes rmethod.description, %(class="ruby-string">)
  end

  def test_versionned_urls
    options.version = 'v1.2.3'
    options.host    = 'http://doc.myproject.org'
    options.op_dir  = 'foo'

    # Just to redefine the `Markup::ToHtml#gen_url` method
    RDoc::Generator::TDoc.new(store, options)

    context = parse <<~RUBY
      # For futher information check {this}[http://doc.myproject.org/foo.html]
      # out.
      def baz
      end
    RUBY

    rmethod = context.method_list.first
    link    = %(<a\nhref="http://doc.myproject.org/v1.2.3/foo.html">this</a>)

    assert_includes rmethod.description, link
  end
end
