require 'fileutils'

module RDoc::Generator
  # This class wraps all the generation logic for creating
  # an \RDoc generator. The +setup_options+ method is called in the
  # first place by RDoc and then, the +generate+ method holds all the
  # basic operations to generate the documentation for a project.
  #
  # This class needs to be loaded in order for \RDoc to be able to use
  # it as a generator. Then, you can specify it defining the Rake task
  # like this:
  #
  #   RDoc::Task.new do |rdoc|
  #     rdoc.generator = 'tdoc'
  #   end
  #
  # It comes with a few new options:
  #
  # * +github+ : to automatically generates links to GitHub source
  #   code for methods.
  # * +version+ : to display the current version for the generated
  #   documentation.
  # * +host+ : to automatically inject the current version in URLs
  #   that reference the given host.
  class TDoc
    ::RDoc::RDoc.add_generator self # :nodoc:

    include ::TDoc::Github
    include ::TDoc::Rendering
    include ::TDoc::Helper

    attr_reader :store, :options
    attr_reader :out_dir, :class_dir, :file_dir, :base_dir # :nodoc:

    def initialize(store, options) # :nodoc:
      @cache   = {}
      @out_dir = Pathname.new(options.op_dir)
                         .expand_path(Pathname.pwd.expand_path)

      @class_dir = 'classes'
      @file_dir  = 'files'
      @base_dir  = Pathname.pwd.expand_path


      options.github = options.github && have_git? && github_repo?

      @store   = store
      @options = options

      @json_index = RDoc::Generator::JsonIndex.new(self, options)

      if options.host
        unless options.version
          raise "You are trying to version #{host} but didn't specify any version"
        end

        host  = options.host
        host += '/' unless host.end_with?('/')

        unless host.start_with?('http://') || host.start_with?('https://')
          host = "http://#{host}"
        end

        RDoc::Markup::ToHtml.alias_method(:default_gen_url, :gen_url)
        RDoc::Markup::ToHtml.remove_method(:gen_url)
        RDoc::Markup::ToHtml.define_method(:gen_url) do |url, text|
          if url.start_with?(host)
            versioned_url = url.sub(host, "#{host}#{options.version}/")
            %(<a href="#{versioned_url}">#{text}</a>)
          else
            default_gen_url(url, text)
          end
        end
      end
    end

    # Called by RDoc to actually run the generator.
    def generate
      setup_output_dir
      generate_index_file(store.all_files)
      generate_text_file_files(store.all_files)
      generate_class_module_files(store.all_classes_and_modules)
    end

    # Setup the output directory copying assets and generating the
    # JSON Index files for the search.
    def setup_output_dir
      FileUtils.cp_r(::TDoc::TEMPLATE_PATH.join('assets'), out_dir)

      @json_index.generate
      @json_index.generate_gzipped
    end

    # Generates an `index.html` file at the root of the output
    # directory.
    #
    # If the `main_page` option has been specified, this file is used
    # as the index file. Otherwise, we try to look for a `README` file
    # and if there is none, we pick the first file available in the
    # project.
    def generate_index_file(files)
      main_page = if options.main_page && file = files.find { |f| f.full_name == options.main_page }
        file
      elsif file = files.find { |f| f.path.include?("README") }
        file
      else
        files.first
      end

      # Little turn-around for having RDoc to generate the correct
      # relative links. By default, it uses the output name to
      # generate links but it would think that this file would
      # live inside the `files/` directory while it's at the root.
      main_page.define_singleton_method(:path) { 'index.html' }

      outfile = out_dir.join('index.html')

      render_template(:file, outfile, {
        file: main_page,
        index: true,
        assets_prefix: ''
      })
    end

    # Generates the HTML files for each text file of the project
    # (i.e. Markdown or RDoc files).
    def generate_text_file_files(files)
      files.select(&:text?).each do |file|
        outfile = out_dir.join(file.path.to_s)

        render_template(:file, outfile, file: file)
      end
    end

    # Generates the HTML files for each class and module of the current
    # project.
    def generate_class_module_files(classes_and_modules)
      classes_and_modules.each do |class_module|
        outfile = out_dir.join(class_module.path.to_s)

        render_template(:class_module, outfile, object: class_module)
      end
    end

    # Called by RDoc to handle the specified options.
    def self.setup_options(options)
      opt = options.option_parser

      opt.separator nil
      opt.separator "TDoc generator options:"
      opt.separator nil

      opt.on("--github", "-g",
              "Generate links to GitHub.") do
        options.github = true
      end

      opt.separator nil

      opt.on("-v VERSION",
              "Generate documentation for this version.") do |version|
        options.version = version.strip
      end

      opt.separator nil

      opt.on("--host HOST", "-H",
              "Attach version to URLs referencing this host") do |host|
        options.host = host.strip
      end
    end
  end
end
