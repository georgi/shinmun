require 'rake'
require 'rake/rdoctask'
 
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


