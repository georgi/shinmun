Gem::Specification.new do |s|
  s.name = 'shinmun'
  s.version = '0.2'
  s.date = '2008-12-17'
  s.summary = 'a small blog engine'
  s.author = 'Matthias Georgi'
  s.email = 'matti.georgi@gmail.com'
  s.homepage = 'http://github.com/georgi/shinmun'  
  s.description = "Shinmun is a small blog engine, which runs on the micro framework kontrol."
  s.files = File.read(File.join(File.dirname(__FILE__), 'MANIFEST')).split("\n")
  s.bindir = 'bin'
  s.executables << 'shinmun'
  s.require_path = 'lib'
  s.add_dependency 'BlueCloth'
  s.add_dependency 'rubypants'
  s.add_dependency 'rack'
  s.add_dependency 'coderay'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md']  
end

