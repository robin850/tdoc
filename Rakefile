$:.unshift(File.expand_path(File.join(__dir__, 'lib')))

require 'tdoc'
require 'rdoc/task'
require 'rake/testtask'

Rake::TestTask.new('test') do |t|
  t.libs << "lib"
  t.libs << "test"
  t.warning = true
  t.verbose = true
  t.pattern = "test/**/*_test.rb"
end

RDoc::Task.new do |rdoc|
  rdoc.github    = 'yep'
  rdoc.generator = 'tdoc'
  rdoc.version   = 'v5.1.4'
  rdoc.host      = 'http://api.rubyonrails.org/'
  rdoc.title     = 'Ruby on Rails API'
  rdoc.main      = 'README.md'
end

task :rm do
  `rm -rf html`
end

task default: [:rm, :rdoc]
