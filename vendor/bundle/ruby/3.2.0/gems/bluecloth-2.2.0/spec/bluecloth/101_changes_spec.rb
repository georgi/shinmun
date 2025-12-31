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

describe BlueCloth, "after the 1.0.1 changes" do

	it "doesn't touch escapes in code blocks" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Markdown allows you to use backslash escapes to generate literal
		characters which would otherwise have special meaning in Markdown's
		formatting syntax. For example, if you wanted to surround a word with
		literal asterisks (instead of an HTML `<em>` tag), you can backslashes
		before the asterisks, like this:

			\\*literal asterisks\\*

		---
		<p>Markdown allows you to use backslash escapes to generate literal
		characters which would otherwise have special meaning in Markdown's
		formatting syntax. For example, if you wanted to surround a word with
		literal asterisks (instead of an HTML <code>&lt;em&gt;</code> tag), you can backslashes
		before the asterisks, like this:</p>

		<pre><code>\\*literal asterisks\\*
		</code></pre>
		---
	end

	it "shouldn't touched escapes in code spans" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		You can escape the splat operator by backslashing it like this: `/foo\\*/`.
		---
		<p>You can escape the splat operator by backslashing it like this: <code>/foo\\*/</code>.</p>
		---
	end


	it "converts reference-style links at or deeper than tab width to code blocks" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		An [example][ex] reference-style link.

			[ex]: http://www.bluefi.com/
		---
		<p>An [example][ex] reference-style link.</p>

		<pre><code>[ex]: http://www.bluefi.com/
		</code></pre>
		---
	end

	it "fixes inline links using < and > URL delimiters, which weren't working" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		like [this](<http://example.com/>)
		---
		<p>like <a href="http://example.com/">this</a></p>
		---
	end

	it "keeps HTML comment blocks as-is" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		<!-- This is a comment -->
		---
		<!-- This is a comment -->
		---
	end

	it "doesn't auto-link inside code spans" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		like this: `<http://example.com/>`
		---
		<p>like this: <code>&lt;http://example.com/&gt;</code></p>
		---
	end


	it "no longer creates a list when lines in the middle of hard-wrapped paragraphs look " +
	   "like the start of a list item" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		I recommend upgrading to version
		8. Oops, now this line is treated
		as a sub-list.
		---
		<p>I recommend upgrading to version
		8. Oops, now this line is treated
		as a sub-list.</p>
		---
	end


	it "correctly marks up header + list + code" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		## This is a header.

		1.   This is the first list item.
		2.   This is the second list item.

		Here's some example code:

			return shell_exec("echo $input | $markdown_script");
		---
		<h2>This is a header.</h2>

		<ol>
		<li> This is the first list item.</li>
		<li> This is the second list item.</li>
		</ol>

		<p>Here's some example code:</p>

		<pre><code>return shell_exec("echo $input | $markdown_script");
		</code></pre>
		---
	end

end


