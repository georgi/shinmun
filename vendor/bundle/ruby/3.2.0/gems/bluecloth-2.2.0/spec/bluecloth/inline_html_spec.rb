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

describe BlueCloth, "document with inline HTML" do

	it "preserves TABLE block" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is a regular paragraph.

		<table>
		    <tr>
		        <td>Foo</td>
		    </tr>
		</table>

		This is another regular paragraph.
		---
		<p>This is a regular paragraph.</p>

		<table>
		    <tr>
		        <td>Foo</td>
		    </tr>
		</table>

		<p>This is another regular paragraph.</p>
		---
	end

	it "preserves DIV block" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is a regular paragraph.

		<div>
		   Something
		</div>
		Something else.
		---
		<p>This is a regular paragraph.</p>

		<div>
		   Something
		</div>

		<p>Something else.</p>
		---
	end


	it "preserves HRs" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is a regular paragraph.

		<hr />

		Something else.
		---
		<p>This is a regular paragraph.</p>

		<hr />

		<p>Something else.</p>
		---
	end


	it "preserves fancy HRs" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is a regular paragraph.

		<hr class="publishers-mark" id="first-hrule" />

		Something else.
		---
		<p>This is a regular paragraph.</p>

		<hr class="publishers-mark" id="first-hrule" />

		<p>Something else.</p>
		---
	end


	it "preserves IFRAMEs" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is a regular paragraph.

		<iframe src="foo.html" id="foo-frame"></iframe>

		Something else.
		---
		<p>This is a regular paragraph.</p>

		<iframe src="foo.html" id="foo-frame"></iframe>

		<p>Something else.</p>
		---
	end


	it "preserves span-level HTML" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is some stuff with a <span class="foo">spanned bit of text</span> in
		it. And <del>this *should* be a bit of deleted text</del> which should be
		preserved, and part of it emphasized.
		---
		<p>This is some stuff with a <span class="foo">spanned bit of text</span> in
		it. And <del>this <em>should</em> be a bit of deleted text</del> which should be
		preserved, and part of it emphasized.</p>
		---
	end

	it "preserves block-level HTML case-insensitively" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is a regular paragraph.

		<TABLE>
		    <TR>
		        <TD>Foo</TD>
		    </TR>
		</TABLE>

		This is another regular paragraph.
		---
		<p>This is a regular paragraph.</p>

		<TABLE>
		    <TR>
		        <TD>Foo</TD>
		    </TR>
		</TABLE>

		<p>This is another regular paragraph.</p>
		---
	end

	it "preserves span-level HTML case-insensitively" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is some stuff with a <SPAN CLASS="foo">spanned bit of text</SPAN> in
		it. And <DEL>this *should* be a bit of deleted text</DEL> which should be
		preserved, and part of it emphasized.
		---
		<p>This is some stuff with a <SPAN CLASS="foo">spanned bit of text</SPAN> in
		it. And <DEL>this <em>should</em> be a bit of deleted text</DEL> which should be
		preserved, and part of it emphasized.</p>
		---
	end

	it "preserves HTML5 tags" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		<aside>
			<p>This is a sidebar that explains some stuff.</p>
		</aside>

		The main content.

		<footer>
			<p>Copyright &copy; 2010 by J. Random Hacker.</p>
		</footer>
		---
		<aside>
		    <p>This is a sidebar that explains some stuff.</p>
		</aside>

		<p>The main content.</p>

		<footer>
		    <p>Copyright &copy; 2010 by J. Random Hacker.</p>
		</footer>
		---
	end


end


