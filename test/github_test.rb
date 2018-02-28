require 'test_helper'

class GitHubTest < Minitest::Test
  include TDoc::Github

  def test_regular_methods_are_linkable
    context = parse <<~RUBY
      def foo
      end
    RUBY

    rmethod = context.method_list.first

    assert linkable?(rmethod)
  end

  def test_ghost_methods_are_linkable
    context = parse <<~RUBY
      class Foo
        # :method: foo
      end
    RUBY

    rmethod = context.method_list.first

    assert linkable?(rmethod)
  end

  def test_aliases_arent_linkable
    context = parse <<~RUBY
      class Foo
        def foo; end

        alias :bar :foo
      end
    RUBY

    rmethod = context.method_list[1]

    assert_equal "bar", rmethod.name
    refute linkable?(rmethod)
  end

  def test_github_remote_url_through_https
    skip unless have_git?

    in_git_repo do
      `git remote add origin https://github.com/rails/rails.git`
      assert_equal "github.com/rails/rails", remote_url
    end
  end

  def test_github_remote_url_through_ssh
    skip unless have_git?

    in_git_repo do
      `git remote add origin git@github.com:foo/bar.git`
      assert_equal "github.com/foo/bar", remote_url
    end
  end

  def test_github_link
    skip unless have_git?

    context = parse <<~RUBY
      # Some dirt to check that the line
      # number is working.
      def woot
      end
    RUBY

    in_git_repo do
      `git remote add origin git@github.com:foo/bar.git`

      url  = "https://github.com/foo/bar/tree/#{last_sha1}/foo#L3"
      link = %(<a href="#{url}" target="_blank">View on GitHub</a>)

      assert_equal link, github_link(context.method_list.first)
    end
  end
end
