module TDoc
  module Helper
    # \Helper method to render a partial inside a template. By
    # convention, partial files are prefixed with an underscore
    # at the beginning so this method assumes it's true and automatically
    # adds it. For example:
    #
    #   render("header", binding)
    #
    # Would actually render the +_header.html.erb+ file within the current
    # binding.
    #
    # See TDoc::Rendering for further information on template rendering.
    def render(partial, scope)
      scope.eval(get_template("_#{partial}.html.erb"))
    end

    # Recursively renders a breadcrumb for a given +RDoc::CodeObject+
    # by properly creating a relative link to the parent namespace
    # elements.
    def breadcrumb(object, level = 0)
      path = ("../" * level) + object.name + ".html"
      link = link_to(object.name, path)

      if object.parent.kind_of?(RDoc::TopLevel)
        link
      else
        breadcrumb(object.parent, level+1) + "&nbsp; > &nbsp;" + link
      end
    end

    # Gathers methods alphabetically in groups. With a class like:
    #
    #   class Foo
    #     def bar; end
    #     def baz; end
    #   end
    #
    # This method would produce:
    #
    #   { "B" => ['<a>bar</a>', '<a>baz</a>'] }
    #
    # The links are properly generated with the anchor as the href.
    def method_groups(methods)
      groups = methods.group_by { |m| group_name(m.name) }

      groups.map do |letter, group|
        links = group.sort_by(&:name).map do |m|
          link_to(m.name, "##{m.aref}")
        end

        [ letter, links ]
      end.sort_by { |(l,_)| l }.to_h
    end

    # Shortcut to generate a simple HTML link. For example:
    #
    #   link_to('foo', 'bar')
    #   # => '<a href="bar">foo</a>'
    #
    # :sig: String, String -> String
    def link_to(text, href)
      %(<a href="#{href}">#{text}</a>)
    end

    # Creates a SEO friendly description for the SEO description
    # tags (i.e. a truncated version of the code object's description
    # with HTML tags stripped out).
    def seo_desc(description)
      return "" if description.empty?

      truncate(strip_tags(description.gsub("\n", " ").strip))
    end

    private
      def group_name(name)
        name[0].match?(/[a-z]/) ? name[0].upcase : '#'
      end

      def strip_tags(text)
        text.gsub(%r{</?[^>]+?>}, "")
      end

      def truncate(text)
        stop = text.rindex(".", 200) || 200

        "#{text[0, stop]}."
      end
  end
end
