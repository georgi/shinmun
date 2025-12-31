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

describe BlueCloth, "lists" do

	it "support unordered lists with asterisk bullets" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		*   Red
		*   Green
		*   Blue
		---
		<ul>
		<li>Red</li>
		<li>Green</li>
		<li>Blue</li>
		</ul>
		---
	end

	it "supports unordered lists with hyphen bullets" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		-   Red
		-   Green
		-   Blue
		---
		<ul>
		<li>Red</li>
		<li>Green</li>
		<li>Blue</li>
		</ul>
		---
	end

	it "supports unordered lists with '+' bullets" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		+   Red
		+   Green
		+   Blue
		---
		<ul>
		<li>Red</li>
		<li>Green</li>
		<li>Blue</li>
		</ul>
		---
	end

	it "supports unordered lists with mixed bullets" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		+   Red
		-   Green
		*   Blue
		---
		<ul>
		<li>Red</li>
		<li>Green</li>
		<li>Blue</li>
		</ul>
		---
	end

	it "supports ordered lists" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		1.  Bird
		2.  McHale
		3.  Parish
		---
		<ol>
		<li>Bird</li>
		<li>McHale</li>
		<li>Parish</li>
		</ol>
		---
	end

	it "doesn't care what the actual numbers you use to mark up an unordered list are (all 1s)" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		1.  Bird
		1.  McHale
		1.  Parish
		---
		<ol>
		<li>Bird</li>
		<li>McHale</li>
		<li>Parish</li>
		</ol>
		---
	end

	it "doesn't care what the actual numbers you use to mark up an unordered list are (random numbers)" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		3.  Bird
		1.  McHale
		8.  Parish
		---
		<ol>
		<li>Bird</li>
		<li>McHale</li>
		<li>Parish</li>
		</ol>
		---
	end

	it "supports hanging indents" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		*   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
		    Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
		    viverra nec, fringilla in, laoreet vitae, risus.
		*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
		    Suspendisse id sem consectetuer libero luctus adipiscing.
		---
		<ul>
		<li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
		Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
		viverra nec, fringilla in, laoreet vitae, risus.</li>
		<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
		Suspendisse id sem consectetuer libero luctus adipiscing.</li>
		</ul>
		---
	end

	it "supports lazy indents" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		*   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
		Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
		viverra nec, fringilla in, laoreet vitae, risus.
		*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
		Suspendisse id sem consectetuer libero luctus adipiscing.
		---
		<ul>
		<li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
		Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
		viverra nec, fringilla in, laoreet vitae, risus.</li>
		<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
		Suspendisse id sem consectetuer libero luctus adipiscing.</li>
		</ul>
		---
	end

	it "wraps the items in <p> tags if the list items are separated by blank lines" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		*   Bird
		
		*   Magic
		---
		<ul>
		<li><p>Bird</p></li>
		<li><p>Magic</p></li>
		</ul>
		---
	end

	it "supports multi-paragraph list items" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		1.  This is a list item with two paragraphs. Lorem ipsum dolor
		    sit amet, consectetuer adipiscing elit. Aliquam hendrerit
		    mi posuere lectus.
		
		    Vestibulum enim wisi, viverra nec, fringilla in, laoreet
		    vitae, risus. Donec sit amet nisl. Aliquam semper ipsum
		    sit amet velit.
		
		2.  Suspendisse id sem consectetuer libero luctus adipiscing.
		---
		<ol>
		<li><p>This is a list item with two paragraphs. Lorem ipsum dolor
		sit amet, consectetuer adipiscing elit. Aliquam hendrerit
		mi posuere lectus.</p>
		
		<p>Vestibulum enim wisi, viverra nec, fringilla in, laoreet
		vitae, risus. Donec sit amet nisl. Aliquam semper ipsum
		sit amet velit.</p></li>
		<li><p>Suspendisse id sem consectetuer libero luctus adipiscing.</p></li>
		</ol>
		---
	end

	it "supports multi-paragraph list items followed by paragraph" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		1.  This is a list item with two paragraphs. Lorem ipsum dolor
		    sit amet, consectetuer adipiscing elit. Aliquam hendrerit
		    mi posuere lectus.
    	
		    Vestibulum enim wisi, viverra nec, fringilla in, laoreet
		    vitae, risus. Donec sit amet nisl. Aliquam semper ipsum
		    sit amet velit.
		
		2.  Suspendisse id sem consectetuer libero luctus adipiscing.
		
		This is a following paragraph which shouldn't be part of the list.
		---
		<ol>
		<li><p>This is a list item with two paragraphs. Lorem ipsum dolor
		sit amet, consectetuer adipiscing elit. Aliquam hendrerit
		mi posuere lectus.</p>
		
		<p>Vestibulum enim wisi, viverra nec, fringilla in, laoreet
		vitae, risus. Donec sit amet nisl. Aliquam semper ipsum
		sit amet velit.</p></li>
		<li><p>Suspendisse id sem consectetuer libero luctus adipiscing.</p></li>
		</ol>
		
		<p>This is a following paragraph which shouldn't be part of the list.</p>
		---
	end

	it "supports lazy multi-paragraphs" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		*   This is a list item with two paragraphs.
		
		    This is the second paragraph in the list item. You're
		only required to indent the first line. Lorem ipsum dolor
		sit amet, consectetuer adipiscing elit.
		
		*   Another item in the same list.
		---
		<ul>
		<li><p>This is a list item with two paragraphs.</p>
		
		<p>This is the second paragraph in the list item. You're
		only required to indent the first line. Lorem ipsum dolor
		sit amet, consectetuer adipiscing elit.</p></li>
		<li><p>Another item in the same list.</p></li>
		</ul>
		---
	end

	it "supports blockquotes in list items" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		*   A list item with a blockquote:
		
			> This is a blockquote
			> inside a list item.
		---
		<ul>
		<li><p>A list item with a blockquote:</p>
		
		<blockquote><p>This is a blockquote
		inside a list item.</p></blockquote></li>
		</ul>
		---
	end

	it "supports code blocks in list items" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		*   A list item with a code block:
		
				<code goes here>
		---
		<ul>
		<li><p>A list item with a code block:</p>
		
		<pre><code>&lt;code goes here&gt;
		</code></pre></li>
		</ul>
		---
	end

	it "doesn't transform a backslash-escaped number-period-space into an ordered list" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		1986\\. What a great season.
		---
		<p>1986. What a great season.</p>
		---
	end

end


