module TDoc
  module Github
    # Checks whether a given method is linkable to GitHub
    # (i.e. all methods that aren't aliases).
    #
    # :sig: RDoc::AnyMethod -> true or false
    def linkable?(method)
      method.token_stream ? true : false
    end

    # Generates a link to a given method's source code on GitHub.
    #
    # The GitHub repository's URL is inferred based on the current
    # directory's Git configuration by looking whether an +origin+
    # remote is available or not. HTTPS and SSH Git remotes are supported.
    #
    # :sig: RDoc::AnyMethod -> String
    def github_link(method)
      data = method.token_stream.first[:text].match(/File\s(\S+), line (\d+)/)

      file, line = data[1], data[2]

      %(<a href="#{tree_url}#{file}#L#{line}" target="_blank">View on GitHub</a>)
    end

    private
      # Computes the GitHub repository's full URL with the last
      # commit SHA1 to easily generate links.
      #
      # We could look for the last commit on a per file basis (i.e.
      # the last commit that changes this file) but this would impact
      # the generation time and it works anyway with the repository
      # last SHA.
      def tree_url
        @tree_url ||= "https://#{remote_url}/tree/#{last_sha1}/"
      end

      # Checks whether the current system has Git available.
      def have_git?
        system('git --version > /dev/null 2>&1')
      end

      # Computes the GitHub repository remote URL based on the
      # availability of an `origin` Git remote. SSH and HTTPS
      # are supported.
      def remote_url
        @remote_url ||= begin
          remote_url = `git config --get remote.origin.url`

          if remote_url.include?('github.com')
            url_regex = /github.com(\:|\/)(\w+)\/(\w+)/

            (m = remote_url.match(url_regex)) ? m[0].sub(':', '/') : false
          else
            false
          end
        end
      end

      alias :github_repo? :remote_url

      def last_sha1
        @last_sha1 ||= `git rev-parse HEAD`.chomp
      end
  end
end
