require 'pathname'

require 'tdoc/rdoc_patches'

module TDoc
  TEMPLATE_PATH = Pathname.new(__dir__).join('..', 'resources')

  autoload :Github,    'tdoc/github'
  autoload :Rendering, 'tdoc/rendering'
  autoload :Helper,    'tdoc/helper'

  autoload :GemVersions,  'tdoc/gem_versions'
  autoload :VersionsTask, 'tdoc/versions_task'
end

require 'tdoc/generator'
