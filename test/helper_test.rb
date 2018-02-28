require 'test_helper'

class HelperTest < Minitest::Test
  include TDoc::Helper

  def test_breadcrumb
    context = parse <<~RUBY
      module Foo
        class Bar
          class Baz
          end
        end
      end
    RUBY

    foo = context.modules.first
    bar = foo.classes.first
    baz = bar.classes.first

    link = -> (klass, level) {
      link_to klass, "#{'../'*level}#{klass}.html"
    }

    assert_equal link.call("Foo", 0),
      breadcrumb(foo)
    assert_equal "#{link.call("Foo", 1)} > #{link.call("Bar", 0)}",
      strip(breadcrumb(bar))
    assert_equal "#{link.call("Foo", 2)} > #{link.call("Bar", 1)} > #{link.call("Baz", 0)}",
      strip(breadcrumb(baz))
  end

  def test_method_groups
    context = parse <<~RUBY
      class Foo
        def baz; end
        def bar; end
        def quux; end
      end
    RUBY

    klass = context.classes.first

    groups = {
      "B" => [ link_to('bar', '#method-i-bar'), link_to('baz', '#method-i-baz')],
      "Q" => [ link_to('quux', '#method-i-quux') ]
    }

    assert_equal groups, method_groups(klass.method_list)
  end

  def test_method_groups_are_alphabetically_sorted
    context = parse <<~RUBY
      class Bar
        def woot; end # This one first
        def lulz; end
      end
    RUBY

    klass = context.classes.first

    assert_equal ["L", "W"], method_groups(klass.method_list).keys
  end

  def test_link_to
    assert_equal link_to('a', 'b'), %(<a href="b">a</a>)
  end

  def test_group_name
    assert_equal 'A', group_name('ah')
    assert_equal '#', group_name('_foo')
  end

  def test_strip_tags
    strings = [
      [ %(<strong>Hello world</strong>),
          "Hello world" ],
      [ %(<a href="Streams.html">Streams</a> are great),
          "Streams are great" ],
      [ %(<a href="http://foo.com?x=1&y=2#123">zzak/sdoc</a> Standalone),
          "zzak/sdoc Standalone"],
      [ %(<h1 id="module-AR::Cb-label-Foo+Bar">AR Cb</h1>),
          "AR Cb" ],
      [ %(<a href="../Base.html">Base</a>),
          "Base" ],
      [ %(Some<br>\ntext),
        "Some\ntext" ]
    ]

    strings.each do |(html, stripped)|
      assert_equal stripped, strip_tags(html)
    end
  end

  def test_seo_desc
    description = <<~HTML
      Hello world ! Here's my <strong>super</strong> description
      with new lines and a lot of chars just to check whether
      truncating is working as expected. But here's another sentence
      just to add a few more chars ; yeah, pretty poetic.
    HTML

    expected = "Hello world ! Here's my super description with " \
               "new lines and a lot of chars just to check whether " \
               "truncating is working as expected."

    assert_equal expected, seo_desc(description)
  end

  def test_truncate
    assert_equal "Hello world.", truncate("Hello world")
    assert_equal ("a" * 200 + "."), truncate("a" * 300)
  end

  private
    def strip(string)
      string.gsub("&nbsp;", '')
    end
end
