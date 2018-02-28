require 'rdoc'
require 'rake/tasklib'

module RDoc
  METHOD_MODIFIERS << "private"
  METHOD_MODIFIERS << "plugin"

  # Monkey-patch to mimick the pipe option but only for
  # headers ; thus we don't have the anchors attached to
  # them.
  #
  # We can't globally set the +pipe+ option, otherwise we
  # wouldn't have the code highlighting.
  class Markup::ToHtml < Markup::Formatter # :nodoc:
    alias :original_accept_heading :accept_heading

    def accept_heading(heading)
      @options.pipe = true
      original_accept_heading(heading)
    ensure
      @options.pipe = false
    end
  end

  # Allows user to specify the +github+, +version+ and
  # +host+ options defining the Rake task and properly
  # propagates the values running RDoc through shell.
  class Task < Rake::TaskLib # :nodoc:
    attr_accessor :github
    attr_accessor :version
    attr_accessor :host

    alias :original_option_list :option_list

    def option_list
      result = original_option_list
      result << "-g"     << github  if github
      result << "-v"     << version if version
      result << "--host" << host    if host
      result
    end
  end

  class Options # :nodoc:
    attr_accessor :github
    attr_accessor :version
    attr_accessor :host
  end

  # Just for fixing purpose, nix this once RDoc 6.0.2 or 6.1
  # is released.
  module TokenStream # :nodoc:
    remove_method :tokens_to_s

    def tokens_to_s
      token_stream.compact.map { |token| token[:text] }.join ''
    end
  end

  # Monkey-patch to support the +:sig:+ directive in
  # methods' documentation.
  class Comment # :nodoc:
    alias :origin_extract_call_seq :extract_call_seq

    def extract_call_seq(method)
      origin_extract_call_seq(method)

      if @text =~ /^\s*:sig:(.*?)(\s*$|\z)/
        string = $~[1]
        types, return_type = string.split("->")

        types = types.split(",").map(&:strip)
        return_type = return_type.lstrip

        # Remove the `:sig:` call from the final documentation
        all_start, all_stop = $~.offset(0)
        @text.slice! all_start...all_stop

        # Inject the different parameter types but only if
        # there is no `:call-seq:` present in the code ; the
        # latter supersedes `:sig:`.
        unless method.call_seq
          params = method.params[1..-2] # Remove braces
          params = params.split(", ")

          params = params.map.with_index do |param, index|
            type = types[index] ? types[index].lstrip + " " : ""
            type + param
          end.join(", ")

          method.params = "(#{params}) -> #{return_type}"
        end
      end
    end
  end

  # Monkey-patch to support the +:private:+ and +:plugin+
  # directives on method definitions.
  class Markup::PreProcess # :nodoc:
    alias :original_handle_directive :handle_directive

    def handle_directive(prefix, directive, param, code_object = nil, encoding = nil)
      blankline = "#{prefix.strip}\n"
      directive = directive.downcase

      case directive
      when "plugin"
        code_object.plugin_api = true

        blankline
      when "private"
        # Or code_object.document_self = nil to have the same behavior
        # as with :nodoc:.
        code_object.private_api = true

        blankline
      else
        original_handle_directive(prefix, directive, param, code_object, encoding)
      end
    end
  end

  class AnyMethod < MethodAttr
    attr_reader :deprecation_message
    attr_writer :private_api, :plugin_api # :nodoc:

    # Returns whether a method is deprecated or not. A method is
    # considered deprecated if its body contains a method call
    # to <tt>ActiveSupport::Deprecation#warn</tt>.
    #
    # The deprecation message is then computed based on the argument
    # passed to this method call.
    #
    # :sig: -> true or false
    def deprecated?
      return false unless token_stream

      if tokens_to_s.include?("ActiveSupport::Deprecation.warn")
        position = token_stream.index { |tk| tk[:text] == "Deprecation" }

        return false unless position

        token = token_stream[position..-1].find do |tk|
          tk[:kind] == :on_heredoc || tk[:kind] == :on_tstring
        end

        if token[:kind] == :on_heredoc
          @deprecation_message = token[:text]
        else
          @deprecation_message = token[:text][1..-2] # To remove quotes
        end

        return true
      else
        return false
      end
    end

    # Predicate to know whether a method is part of the plugin API.
    def plugin_api?
      defined?(@plugin_api) && @plugin_api
    end

    # Preidcate to know whether a method is part of the private API.
    def private_api?
      defined?(@private_api) && @private_api
    end
  end
end
