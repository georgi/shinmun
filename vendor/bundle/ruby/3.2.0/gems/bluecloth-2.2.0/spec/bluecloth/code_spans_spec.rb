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

describe BlueCloth, "that contains code blocks or spans" do

	it "wraps CODE tags around backticked spans" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Making `code` work for you
		---
		<p>Making <code>code</code> work for you</p>
		---
	end

	it "allows you to place literal backtick characters at the beginning or end of a code span " +
	   "by padding the inner string with spaces" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Making `` `code` `` work for you
		---
		<p>Making <code>`code`</code> work for you</p>
		---
	end

	it "wraps CODE tags around doubled backtick spans with a single literal backtick inside them" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		``There is a literal backtick (`) here.``
		---
		<p><code>There is a literal backtick (`) here.</code></p>
		---
	end

	it "correctly transforms two literal spans in one line" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This `thing` should be `two` spans.
		---
		<p>This <code>thing</code> should be <code>two</code> spans.</p>
		---
	end

	it "correctly transforms literal spans at the beginning of a line" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		I should think that the
		`tar` command would be universal.
		---
		<p>I should think that the
		<code>tar</code> command would be universal.</p>
		---
	end

	it "encodes ampersands and angle brackets within code spans as HTML entities" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		The left angle-bracket (`&lt;`) can also be written as a decimal-encoded
		(`&#060;`) or hex-encoded (`&#x3c;`) entity. This
		also works with `<div>` elements.
		---
		<p>The left angle-bracket (<code>&amp;lt;</code>) can also be written as a decimal-encoded
		(<code>&amp;#060;</code>) or hex-encoded (<code>&amp;#x3c;</code>) entity. This
		also works with <code>&lt;div&gt;</code> elements.</p>
		---
	end

	# At the beginning of a document (Bug #525)
	it "correctly transforms code spans at the beginning of paragraphs (bug #525)" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		`world` views
		---
		<p><code>world</code> views</p>
		---
	end




	### [Code blocks]

	# Para plus code block (literal tab, no colon)
	it "wraps sections indented with a literal tab in a code block" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is a chunk of code

			some.code > some.other_code

		Some stuff.
		---
		<p>This is a chunk of code</p>

		<pre><code>some.code &gt; some.other_code
		</code></pre>

		<p>Some stuff.</p>
		---
	end

	# Para plus code block (tab-width spaces)
	it "wraps sections indented with at least 4 spaces in a code block" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is a chunk of code:

		    some.code > some.other_code

		Some stuff.
		---
		<p>This is a chunk of code:</p>

		<pre><code>some.code &gt; some.other_code
		</code></pre>

		<p>Some stuff.</p>
		---
	end

	# Preserve leading whitespace (Bug #541)
	it "removes one level of indentation (and no more) from code blocks" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Examples:

		          # (Waste character because first line is flush left !!!)
		          # Example script1
		          x = 1
		          x += 1
		          puts x

		Some stuff.
		---
		<p>Examples:</p>

		<pre><code>      # (Waste character because first line is flush left !!!)
		      # Example script1
		      x = 1
		      x += 1
		      puts x
		</code></pre>

		<p>Some stuff.</p>
		---
	end

end


