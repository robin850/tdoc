require 'rake/task'

module TDoc
  # Facility around TDoc::GemVersions to create a Rake task that
  # will generate a +versions.json+ file.
  class VersionsTask < Rake::TaskLib
    # Defines a new Rake task to bump the +versions.json+ file.
    # Just like TDoc::GemVersions#new, this method can take a
    # minimum version to remove old versions from the output.
    def initialize(minimum = nil)
      @minimum = minimum
      define
    end

    def define # :nodoc:
      desc "Bump the `versions.json`"
      namespace :tdoc do
        task :versions do
          gem_versions = TDoc::GemVersions.new(@minimum)

          File.open('versions.json', 'w') do |f|
            f.write(gem_versions.versions.to_json)
          end
        end
      end
    end
  end
end
