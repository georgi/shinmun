require 'rake'
require 'rdoc/task'

begin
  require 'rspec/core/rake_task'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install the rspec gem:
    gem install rspec
EOS
  exit(0)
end

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--format', 'documentation', '--color']
  t.pattern = 'test/**/*_spec.rb'
end

desc "Print SpecDocs"
RSpec::Core::RakeTask.new(:doc) do |t|
  t.rspec_opts = ["--format", "documentation"]
  t.pattern = 'test/*_spec.rb'
end

desc "Generate RDoc documentation"
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README.md' <<
    '--title' << 'Shinmun Documentation' <<
    '--charset' << 'utf-8'
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include 'README.md'
  Dir['lib/**/*.rb'].each do |file|
    rdoc.rdoc_files.include file
  end
end

desc "Run the rspec"
task :default => :spec
