#!/usr/bin/env ruby

require 'mkmf'
require 'fileutils'
require 'pathname'
require 'rbconfig'
include RbConfig

versionfile = Pathname.new( __FILE__ ).dirname + 'VERSION'
version = versionfile.read.chomp

# Thanks to Daniel Berger for helping me out with this. :)
if CONFIG['host_os'].match( 'mswin' )
	$CFLAGS << ' -I.' << ' -W3' << ' -Zi'
else
	$CFLAGS << ' -I.'
end
$CPPFLAGS << %Q{ -DVERSION=\\"#{version}\\"}

# Add my own debugging hooks if building for me
if ENV['MAINTAINER_MODE']
	$stderr.puts "Maintainer mode enabled."
	$CFLAGS << ' -Wall'
	$CFLAGS << ' -ggdb' << ' -DDEBUG'
end

# Stuff from configure.sh
have_func( "srand" ) || have_func( "srandom" )
have_func( "random" ) || have_func( "rand" )

# bzero() isn't ANSI C, so use memset() if it isn't defined
have_func( "bzero", %w[string.h strings.h] )

unless have_func( "strcasecmp" ) || have_func( "stricmp" )
	abort "This extension requires either strcasecmp() or stricmp()"
end
unless have_func( "strncasecmp" ) || have_func( "strnicmp" )
	abort "This extensions requires either strncasecmp() or strnicmp()"
end

have_header( 'mkdio.h' ) or abort "missing mkdio.h"

# Check for 1.9.xish encoding header
have_header( 'ruby/encoding.h' )

create_header()
create_makefile( 'bluecloth_ext' )

FileUtils.rm_rf( 'conftest.dSYM' ) # MacOS X cleanup
