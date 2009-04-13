require 'rake'
require 'rake/rdoctask'

begin
  require 'spec/rake/spectask'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install the rspec gem:
    gem install rspec
EOS
  exit(0)
end

desc "Run all specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['-cfs']
  t.spec_files = FileList['test/**/*_spec.rb']
end

desc "Print SpecDocs"
Spec::Rake::SpecTask.new(:doc) do |t|
  t.spec_opts = ["--format", "specdoc"]
  t.spec_files = FileList['test/*_spec.rb']
end

desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
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
