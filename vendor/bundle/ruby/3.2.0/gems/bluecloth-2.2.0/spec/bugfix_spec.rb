#!/usr/bin/env ruby
# coding: utf-8

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent

	libdir = basedir + 'lib'

	$LOAD_PATH.unshift( basedir ) unless $LOAD_PATH.include?( basedir )
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
}

require 'timeout'

require 'rspec'
require 'spec/lib/helpers'
require 'bluecloth'


#####################################################################
###	C O N T E X T S
#####################################################################

describe BlueCloth, "bugfixes" do
	include BlueCloth::TestConstants,
		BlueCloth::Matchers

	before( :all ) do
		@basedir = Pathname.new( __FILE__ ).dirname.parent
		@datadir = @basedir + 'spec/data'
	end



	it "provides a workaround for the regexp-engine overflow bug" do
		datafile = @datadir + 're-overflow.txt'
		markdown = datafile.read

		lambda { BlueCloth.new(markdown).to_html }.should_not raise_error()
	end


	it "provides a workaround for the second regexp-engine overflow bug" do
		datafile = @datadir + 're-overflow2.txt'
		markdown = datafile.read

		lambda { BlueCloth.new(markdown).to_html }.should_not raise_error()
	end


	it "correctly wraps <strong> tags around two characters enclosed in four asterisks" do
		the_markdown( "**aa**" ).should be_transformed_into( "<p><strong>aa</strong></p>" )
	end


	it "correctly wraps <strong> tags around a single character enclosed in four asterisks" do
		the_markdown( "**a**" ).should be_transformed_into( "<p><strong>a</strong></p>" )
	end


	it "correctly wraps <strong> tags around two characters enclosed in four underscores" do
		the_markdown( "__aa__" ).should be_transformed_into( "<p><strong>aa</strong></p>" )
	end


	it "correctly wraps <strong> tags around a single character enclosed in four underscores" do
		the_markdown( "__a__" ).should be_transformed_into( "<p><strong>a</strong></p>" )
	end


	it "correctly wraps <em> tags around two characters enclosed in two asterisks" do
		the_markdown( "*aa*" ).should be_transformed_into( "<p><em>aa</em></p>" )
	end


	it "correctly wraps <em> tags around a single character enclosed in two asterisks" do
		the_markdown( "*a*" ).should be_transformed_into( "<p><em>a</em></p>" )
	end


	it "correctly wraps <em> tags around two characters enclosed in four underscores" do
		the_markdown( "_aa_" ).should be_transformed_into( "<p><em>aa</em></p>" )
	end


	it "correctly wraps <em> tags around a single character enclosed in four underscores" do
		the_markdown( "_a_" ).should be_transformed_into( "<p><em>a</em></p>" )
	end


	it "doesn't raise an error when run with $VERBOSE = true" do
		oldverbose = $VERBOSE

		lambda do
			$VERBOSE = true
			BlueCloth.new( "*woo*" ).to_html
		end.should_not raise_error()

		$VERBOSE = oldverbose
	end


	it "doesn't hang when presented with a series of hyphens (rails-security DoS/#57)" do
		the_indented_markdown( <<-"END_MARKDOWN" ).should be_transformed_into(<<-"END_HTML").without_indentation
		This line of markdown below will hang you if you're running BlueCloth 1.x.
		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   

		END_MARKDOWN
		<p>This line of markdown below will hang you if you're running BlueCloth 1.x.</p>

		<hr />
		END_HTML
	end

	it "recognizes closing block tags even when they're not on their own line" do
		the_indented_markdown( <<-"END_MARKDOWN" ).should be_transformed_into(<<-"END_HTML").without_indentation
		Para 1

		<div><pre>HTML block
		</pre></div>

		Para 2 [Link](#anchor)
		END_MARKDOWN
		<p>Para 1</p>

		<div><pre>HTML block
		</pre></div>

		<p>Para 2 <a href=\"#anchor\">Link</a></p>
		END_HTML
	end

	it "correctly wraps lines after a code block in a list item" do
		the_indented_markdown( <<-"END_MARKDOWN" ).should be_transformed_into(<<-"END_HTML").without_indentation
		* testing

		        pre

		    more li
		END_MARKDOWN
		<ul>
		<li><p>testing</p>

		<pre><code>  pre
		</code></pre>

		<p>  more li</p></li>
		</ul>
		END_HTML
	end

	it "renders heading with trailing spaces correctly (#67)" do
		the_indented_markdown( <<-"END_MARKDOWN" ).should be_transformed_into(<<-"END_HTML").without_indentation
		The Ant-Sugar Tales 
		=================== 

		By Candice Yellowflower

		Use of Metaphor 
		--------------- 

		The author's splendid...
		END_MARKDOWN
		<h1>The Ant-Sugar Tales </h1>

		<p>By Candice Yellowflower</p>

		<h2>Use of Metaphor </h2>

		<p>The author's splendid...</p>
		END_HTML
	end

	it "renders the example from #68 correctly" do
		the_indented_markdown( <<-"END_MARKDOWN" ).should be_transformed_into(<<-"END_HTML").without_indentation
		START example

		1. ö
		1. ü
		1. ó
		1. ő
		1. ú
		1. é
		1. á
		1. ű
		1. í

		- ö
		- ü
		- ó
		- ő
		- ú
		- é
		- á
		- ű
		- í

		END example
		END_MARKDOWN
		<p>START example</p>

		<ol>
		<li>ö</li>
		<li>ü</li>
		<li>ó</li>
		<li>ő</li>
		<li>ú</li>
		<li>é</li>
		<li>á</li>
		<li>ű</li>
		<li><p>í</p></li>
		<li><p>ö</p></li>
		<li>ü</li>
		<li>ó</li>
		<li>ő</li>
		<li>ú</li>
		<li>é</li>
		<li>á</li>
		<li>ű</li>
		<li>í</li>
		</ol>

		<p>END example</p>
		END_HTML
	end

	it "renders alignments in code blocks without changing indentation (#71)" do
		the_indented_markdown( "    Самообучение\n    Bugaga\n" ).
			should be_transformed_into( "<pre><code>Самообучение\nBugaga\n</code></pre>" )
	end

end


__END__

