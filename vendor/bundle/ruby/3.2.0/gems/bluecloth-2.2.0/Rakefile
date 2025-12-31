#!/usr/bin/env rake

require 'rbconfig'
require 'pathname'

begin
	require 'rake/extensiontask'
rescue LoadError
	abort "This Rakefile requires rake-compiler (gem install rake-compiler)"
end

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires hoe (gem install hoe)"
end

# Build constants
BASEDIR = Pathname( __FILE__ ).dirname.relative_path_from( Pathname.pwd )
SPECDIR = BASEDIR + 'spec'
LIBDIR  = BASEDIR + 'lib'
EXTDIR  = BASEDIR + 'ext'

DLEXT   = Config::CONFIG['DLEXT']
EXT     = LIBDIR + "bluecloth_ext.#{DLEXT}"

MANDIR  = BASEDIR + 'man'
MAN1DIR = MANDIR + 'man1'
MANPAGE = MAN1DIR + 'bluecloth.1'

MANPAGE_POD = BASEDIR + 'bluecloth.1.pod'


# Load Hoe plugins
Hoe.plugin :mercurial
Hoe.plugin :signing

Hoe.plugins.delete :rubyforge
Hoe.plugins.delete :compiler

# Configure Hoe
hoespec = Hoe.spec 'bluecloth' do
	self.readme_file = 'README.rdoc'
	self.history_file = 'History.rdoc'
	self.extra_rdoc_files << 'README.rdoc' << 'History.rdoc'

	self.developer 'Michael Granger', 'ged@FaerieMUD.org'

	self.dependency 'tidy-ext',      '~> 0.1', :developer
	self.dependency 'rake-compiler', '~> 0.7', :developer
	self.dependency 'rspec',         '~> 2.6', :developer

	self.spec_extras[:licenses] = ["BSD"]
	self.spec_extras[:extensions] = [ "ext/extconf.rb" ]

	self.require_ruby_version( '>=1.8.7' )

	self.hg_sign_tags = true if self.respond_to?( :hg_sign_tags= )
	self.rdoc_locations << "deveiate:/usr/local/www/public/code/#{remote_rdoc_dir}"
end

ENV['VERSION'] ||= hoespec.spec.version.to_s

# Ensure the specs pass before checking in
task 'hg:precheckin' => [ :check_manifest, :check_history, :spec ]

# Ensure the extension is compiled before testing
task :spec => :compile

# gem-testers support
task :test do
	# rake-compiler always wants to copy the compiled extension into lib/, but
	# we don't want testers to have to re-compile, especially since that
	# often fails because they can't (and shouldn't have to) write to tmp/ in
	# the installed gem dir. So we clear the task rake-compiler set up
	# to break the dependency between :spec and :compile when running under
	# rubygems-test, and then run :spec.
	Rake::Task[ EXT.to_s ].clear
	Rake::Task[ :spec ].execute
end

desc "Turn on warnings and debugging in the build."
task :maint do
	ENV['MAINTAINER_MODE'] = 'yes'
end

ENV['RUBY_CC_VERSION'] = '1.8.7:1.9.2'

# Rake-compiler task
Rake::ExtensionTask.new do |ext|
	ext.name           = 'bluecloth_ext'
	ext.gem_spec       = hoespec.spec
	ext.ext_dir        = 'ext'
	ext.source_pattern = "*.{c,h}"
	ext.cross_compile  = true
	ext.cross_platform = %w[i386-mswin32 i386-mingw32]
end

# Generate a manpage for bin/bluecloth for packagers
directory MAN1DIR.to_s
file MANPAGE_POD

file MANPAGE => [ MANPAGE_POD, MAN1DIR ] do |task|
	sh 'pod2man', '--center', '',
		'--release', '',
		'--name', 'bluecloth',
		'--utf8', task.prerequisites.first, task.name
end


