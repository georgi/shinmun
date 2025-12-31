#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent

	libdir = basedir + 'lib'

	$LOAD_PATH.unshift( basedir ) unless $LOAD_PATH.include?( basedir )
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
}

require 'rspec'
require 'bluecloth'
require 'tidy'

require 'spec/lib/helpers'


#####################################################################
###	C O N T E X T S
#####################################################################

describe BlueCloth, "-- MarkdownTest 1.0.3: " do

	markdowntest_dir = Pathname.new( __FILE__ ).dirname + 'data/markdowntest'
	pattern = markdowntest_dir + '*.text'
	Pathname.glob( pattern.to_s ).each do |textfile|
		resultfile = Pathname.new( textfile.to_s.sub(/\.text/, '.html') )

		it textfile.basename( '.text' ) do
			markdown = textfile.read
			expected = resultfile.read
			options = { :smartypants => false }

			the_markdown( markdown, options ).should be_transformed_into_normalized_html( expected )
		end
	end

end

