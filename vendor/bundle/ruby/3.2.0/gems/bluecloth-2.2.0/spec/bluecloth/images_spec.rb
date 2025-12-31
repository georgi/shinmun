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

describe BlueCloth, "images" do

	### [Images]

	# Inline image with title
	it "transforms inline images with a title in double quotes to an IMG tag" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		![alt text](/path/img.jpg "Title")
		---
		<p><img src="/path/img.jpg" title="Title" alt="alt text" /></p>
		---
	end

	# Inline image with title (single-quotes)
	it "transforms inline images with a title in single quotes to an IMG tag" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		![alt text](/path/img.jpg 'Title')
		---
		<p><img src="/path/img.jpg" title="Title" alt="alt text" /></p>
		---
	end

	# Inline image with title (with embedded quotes)
	it "transforms inline images with a title that includes quotes to an IMG tag" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		![alt text](/path/img.jpg 'The "Title" Image')
		---
		<p><img src="/path/img.jpg" title="The &quot;Title&quot; Image" alt="alt text" /></p>
		---
	end

	# Inline image without title
	it "transforms inline images without a title to an IMG tag" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		![alt text](/path/img.jpg)
		---
		<p><img src="/path/img.jpg" alt="alt text" /></p>
		---
	end

	# Inline image with quoted alt text
	it "transforms inline images with quoted alt text to an IMG tag" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		![the "alt text"](/path/img.jpg)
		---
		<p><img src="/path/img.jpg" alt="the &quot;alt text&quot;" /></p>
		---
	end


	# Reference image
	it "transforms image references with a title to an IMG tag" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		![alt text][id]

		[id]: /url/to/img.jpg "Title"
		---
		<p><img src="/url/to/img.jpg" title="Title" alt="alt text" /></p>
		---
	end

end


