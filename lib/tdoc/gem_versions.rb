require 'json'
require 'net/http'

module TDoc
  class GemVersions
    attr_reader :gem_name, :minimum

    def initialize(minimum = "0.0.0")
      @gem_name = Dir['*.gemspec'].first.sub('.gemspec', '')
      @minimum  = Gem::Version.new(minimum)
    end

    def versions
      json = JSON.parse(query)
      maximums = []

      versions = json.map do |version|
        Gem::Version.new(version["number"])
      end

      # All versions which aren't prereleases and are higher
      # than the set minimum are kept and grouped by MAJOR.MINOR.
      #
      # So for example, with versions = ['5.2.0', '5.1.5', '5.1.4']:
      #
      #  {
      #   '5.2' => ['5.2.0'],
      #   '5.1' => ['5.1.5', '5.1.4']
      #  }
      grouped_versions = versions.select { |v| (!v.prerelease?) && v >= minimum }
                                 .group_by { |v| v.version[0..2] }

      grouped_versions.each do |_, v|
        maximums << v.max.version
      end

      maximums
    end

    private
      def query
        uri = URI("https://rubygems.org/api/v1/versions/#{gem_name}.json")
        Net::HTTP.get(uri)
      end
  end
end
