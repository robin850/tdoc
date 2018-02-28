$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = "tdoc"
  s.version = "1.0.0"

  s.authors = ["Robin Dupret"]
  s.description = %q{Modern RDoc generator with built-in search.}
  s.summary = %q{Modern RDoc generator with built-in search.}
  s.homepage = %q{https://github.com/robin/tdoc}
  s.email = %q{robin.dupret@gmail.com}
  s.license = 'MIT'

  s.require_path = 'lib'

  s.extra_rdoc_files = ["README.md"]

  s.add_runtime_dependency("rdoc", ">= 6.0")
  s.add_runtime_dependency("erubi", ">= 1.7.0")
end
