require 'erubi'

module TDoc
  module Rendering
    # Renders a template with a given name, output file and
    # possible local variables:
    #
    #   render_template('file', 'out/put.html', foo: 'bar')
    #
    # This will evaluate the +file.html.erb+ template, assigning
    # the +foo+ variable with the +'bar'+ value and writes the
    # output to the +out/put.html+ file (ensuring that the +out+
    # directory exists).
    def render_template(template, outfile, variables = {})
      full_template_path = template_path.join(template.to_s + '.html.erb')

      outfile.dirname.mkpath
      outfile.open('w', 0644) do |f|
        f.write evaluate_template(full_template_path, outfile, variables)
      end
    end

    # Evaluates a template from a given name and a given hash of
    # local variables.
    #
    # This basically creates a new binding in order to define the
    # local variables and evaluate the template through ERubi.
    #
    # Unless we are rendering the index page, we are computing the
    # +assets_prefix+ local variable to be able to build relative URLs
    # for assets based on the nesting in the output.
    def evaluate_template(template, outfile, variables = {})
      scope = binding.dup

      variables.each do |name, value|
        scope.local_variable_set(name, value)
      end

      context  = variables[:object] || variables[:file]
      file_dir = outfile.dirname

      # If we are rendering the index, the `assets_prefix` is already
      # set inline so there's no need to compute it.
      unless variables[:index]
        scope.local_variable_set(:assets_prefix, out_dir.relative_path_from(file_dir).to_s + '/')
      end

      scope.eval(get_template(template))
    end

    private
      def get_template(template)
        @cache[template] ||= Erubi::Engine.new(template_path.join(template).read).src
      end

      def template_path
        ::TDoc::TEMPLATE_PATH
      end
  end
end
