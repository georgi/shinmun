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

describe BlueCloth, "blockquotes" do

	### [Blockquotes]

	# Regular 1-level blockquotes
	it "wraps sections with an angle-bracket left margin in a blockquote" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		> Email-style angle brackets
		> are used for blockquotes.
		---
		<blockquote><p>Email-style angle brackets
		are used for blockquotes.</p></blockquote>
		---
	end

	# Nested blockquotes
	it "supports nested blockquote sections" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		> Email-style angle brackets
		> are used for blockquotes.

		> > And, they can be nested.
		---
		<blockquote><p>Email-style angle brackets
		are used for blockquotes.</p>

		<blockquote><p>And, they can be nested.</p></blockquote></blockquote>
		---
	end

	# Doubled blockquotes
	it "supports nested blockquote sections even if there's only one multi-level section" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		> > And, they can be nested.
		---
		<blockquote><blockquote><p>And, they can be nested.</p></blockquote></blockquote>
		---
	end

	# Lazy blockquotes
	it "wraps sections preceded by an angle-bracket in a blockquote" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
		consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
		Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.

		> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
		id sem consectetuer libero luctus adipiscing.
		---
		<blockquote><p>This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
		consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
		Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.</p>

		<p>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
		id sem consectetuer libero luctus adipiscing.</p></blockquote>
		---
	end


	# Blockquotes containing other markdown elements
	it "supports other Markdown elements in blockquote sections" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		> ## This is a header.
		>
		> 1.   This is the first list item.
		> 2.   This is the second list item.
		>
		> Here's some example code:
		>
		>     return shell_exec("echo $input | $markdown_script");
		---
		<blockquote><h2>This is a header.</h2>

		<ol>
		<li> This is the first list item.</li>
		<li> This is the second list item.</li>
		</ol>

		<p>Here's some example code:</p>

		<pre><code>return shell_exec("echo $input | $markdown_script");
		</code></pre></blockquote>
		---
	end

	# Blockquotes with a <pre> section
	it "supports block-level HTML inside of blockquotes", :pedantic => true do
		pending "a fix in Discount" do
			the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
			> The best approximation of the problem is the following code:
			>
			> <pre>
			> foo + bar; foo.factorize; foo.display
			> </pre>
			>
			> This should result in an error on any little-endian platform.
			>
			> <div>- Garrick Mettronne</div>
			---
			<blockquote><p>The best approximation of the problem is the following code:</p>

			<pre>
			foo + bar; foo.factorize; foo.display
			</pre>

			<p>This should result in an error on any little-endian platform.</p>

			<div>- Garrick Mettronne</div>
			</blockquote>
			---
		end
	end


end


