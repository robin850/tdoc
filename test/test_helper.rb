require 'minitest/autorun'
require 'rdoc'

require 'json'
require 'net/http'

require 'tmpdir'

require 'tdoc'

class Minitest::Test
  def in_git_repo
    in_tmp_dir do
      `git init`
      `touch foo`
      `git add foo`
      `git commit -m "Initial commit"`
      yield
    end
  end

  def in_tmp_dir
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        yield
      end
    end
  end

  def parse(content)
    parser = RDoc::Parser::Ruby.new(top_level, "foo", content, options, stats)
    parser.scan

    parser.instance_variable_get(:@top_level)
  end

  def assert_option_recognized(&block)
    stdout, stderr = capture_io(&block)

    assert_predicate stdout, :empty?
    assert_predicate stderr, :empty?
  end

  # Boilerplate needed to setup an RDoc Ruby parser
  private
    def top_level
      @top_level ||= store.add_file("foo")
    end

    def options
      @options ||= rdoc.options
    end

    def rdoc
      @rdoc ||= begin
        gen = Object.new
        def gen.class_dir; end
        def gen.file_dir; end

        rdoc = RDoc::RDoc.new
        rdoc.store     = store
        rdoc.options   = RDoc::Options.new
        rdoc.generator = gen

        rdoc
      end
    end

    def store
      @store ||= RDoc::Store.new
    end

    def stats
      @stats ||= RDoc::Stats.new(store, 0)
    end
end

class RDoc::TopLevel < RDoc::Context
  # Shortcut when we are parsing a single method (i.e. in most cases).
  def method_list
    classes.first.method_list
  end
end

# No-op for #get to save some time during test runs
# since we don't care about the result.
module Net
  class HTTP
    class << self
      remove_method :get

      def get(url)
      end
    end
  end
end

# Mock +JSON.parse+ to set the result of the HTTP GET
# request.
def JSON.parse(str)
  [
    { "number" => "5.1.4" },
    { "number" => "5.1.5" },
    { "number" => "4.2.7" },
    { "number" => "2.3.0" }
  ]
end
