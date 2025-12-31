#!/usr/bin/env ruby
# encoding: utf-8

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent
	
	libdir = basedir + 'lib'
	
	$LOAD_PATH.unshift( basedir ) unless $LOAD_PATH.include?( basedir )
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
}

require 'rspec'
require 'bluecloth'

require 'spec/lib/helpers'


#####################################################################
###	C O N T E X T S
#####################################################################

describe BlueCloth, "document with paragraphs" do

	it "wraps them in P tags" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is some stuff that should all be
		put in one paragraph
		even though
		it occurs over several lines.

		And this is a another
		one.
		---
		<p>This is some stuff that should all be
		put in one paragraph
		even though
		it occurs over several lines.</p>

		<p>And this is a another
		one.</p>
		---
	end

	it "transforms trailing double spaces to line breaks" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Mostly the same kind of thing  
		with two spaces at the end  
		of each line  
		should result in  
		line breaks, though.

		And this is a another  
		one.
		---
		<p>Mostly the same kind of thing<br/>
		with two spaces at the end<br/>
		of each line<br/>
		should result in<br/>
		line breaks, though.</p>

		<p>And this is a another<br/>
		one.</p>
		---
	end

end


