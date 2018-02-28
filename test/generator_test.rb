require 'test_helper'

class GeneratorTest < Minitest::Test
  def setup
    options.setup_generator 'tdoc'
  end

  def test_tdoc_is_recognized_as_an_rdoc_generator
    assert_includes RDoc::RDoc::GENERATORS, 'tdoc'
  end

  def test_github_option
    refute options.github

    stdout, stderr = capture_io do
      options.option_parser.parse ["--github"]
    end

    assert_predicate stdout, :empty?
    assert_predicate stderr, :empty?

    assert options.github
  end

  def test_version_option
    refute options.version

    assert_option_recognized do
      options.option_parser.parse ["-v", "v1.2.3"]
    end

    assert_equal "v1.2.3", options.version
  end

  def test_host_option
    refute options.host

    assert_option_recognized do
      options.option_parser.parse ["-H", "http://rubyonrails.org"]
    end

    assert_equal "http://rubyonrails.org", options.host
  end

  def test_host_full_option
    refute options.host

    assert_option_recognized do
      options.option_parser.parse ["--host", "http://rubyonrails.org"]
    end

    assert_equal "http://rubyonrails.org", options.host
  end
end
