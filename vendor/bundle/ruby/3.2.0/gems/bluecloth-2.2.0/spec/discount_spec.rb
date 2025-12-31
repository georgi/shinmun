#!/usr/bin/env ruby
#coding: utf-8

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent

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

describe BlueCloth, "implementation of Discount-specific features" do

	before( :all ) do
		@basedir = Pathname.new( __FILE__ ).dirname.parent
		@datadir = @basedir + 'spec/data'
	end


	describe "pseudo-protocols" do

		it "renders abbr: links as <abbr> phrases" do
			the_indented_markdown( <<-"---", :pseudoprotocols => true ).should be_transformed_into(<<-"---").without_indentation
			The [ASPCA](abbr:American Society for the Prevention of Cruelty to Animals).
			---
			<p>The <abbr title="American Society for the Prevention of Cruelty to Animals">ASPCA</abbr>.</p>
			---
		end

		it "renders id: links as anchors with an ID" do
			the_markdown( "[foo](id:bar)", :pseudoprotocols => true ).
				should be_transformed_into( '<p><span id="bar">foo</span></p>' )
		end

		it "renders class: links as SPANs with a CLASS" do
			the_markdown( "[foo](class:bar)", :pseudoprotocols => true ).
				should be_transformed_into( '<p><span class="bar">foo</span></p>' )
		end

		it "renders raw: links as-is with no syntax expansion" do
			the_markdown( "[foo](raw:bar)", :pseudoprotocols => true ).
				should be_transformed_into( '<p>bar</p>' )
		end

		it "renders lang: links as language-specified blocks" do
			the_markdown( "[gift](lang:de)", :pseudoprotocols => true ).
				should be_transformed_into( '<p><span lang="de">gift</span></p>' )
		end

	end


	describe "Markdown-Extra tables" do

		it "doesn't try to render tables if :tables isn't set" do
			the_indented_markdown( <<-"END_MARKDOWN" ).should be_transformed_into(<<-"END_HTML").without_indentation
			 a   |    b
			-----|-----
			hello|sailor
			END_MARKDOWN
			<p> a   |    b
			-----|-----
			hello|sailor</p>
			END_HTML
		end

		it "renders the example from orc's blog" do
			the_indented_markdown( <<-"END_MARKDOWN", :tables => true ).should be_transformed_into(<<-"END_HTML").without_indentation
			 a   |    b
			-----|-----
			hello|sailor
			END_MARKDOWN
			<table>
			<thead>
			<tr>
			<th> a   </th>
			<th>    b</th>
			</tr>
			</thead>
			<tbody>
			<tr>
			<td>hello</td>
			<td>sailor</td>
			</tr>
			</tbody>
			</table>
			END_HTML
		end

		it "renders simple markdown-extra tables" do
			the_indented_markdown( <<-"END_MARKDOWN", :tables => true ).should be_transformed_into(<<-"END_HTML").without_indentation
			First Header  | Second Header
			------------- | -------------
			Content Cell  | Content Cell
			END_MARKDOWN
			<table>
			<thead>
			<tr>
			<th>First Header  </th>
			<th> Second Header</th>
			</tr>
			</thead>
			<tbody>
			<tr>
			<td>Content Cell  </td>
			<td> Content Cell</td>
			</tr>
			</tbody>
			</table>
			END_HTML

		end

  		it "renders tables with leading and trailing pipes", :pedantic => true do
 			pending "Discount doesn't support this kind (yet?)" do
 				the_indented_markdown( <<-"END_MARKDOWN", :tables => true ).should be_transformed_into(<<-"END_HTML").without_indentation
 				| First Header  | Second Header |
 				| ------------- | ------------- |
 				| Content Cell  | Content Cell  |
 				| Content Cell  | Content Cell  |
 				END_MARKDOWN
 				<table>
 				<thead>
 				<tr>
 				<th>First Header  </th>
 				<th> Second Header</th>
 				</tr>
 				</thead>
 				<tbody>
 				<tr>
 				<td>Content Cell  </td>
 				<td> Content Cell</td>
 				</tr>
 				<tr>
 				<td>Content Cell  </td>
 				<td> Content Cell</td>
 				</tr>
 				</tbody>
 				</table>
 				END_HTML
 			end
  		end

  		it "renders tables with aligned columns", :pedantic => true do
 			pending "Discount doesn't support this kind (yet?)" do
 				the_indented_markdown( <<-"END_MARKDOWN", :tables => true ).should be_transformed_into(<<-"END_HTML").without_indentation
 				| Item      | Value |
 				| --------- | -----:|
 				| Computer  | $1600 |
 				| Phone     |   $12 |
 				| Pipe      |    $1 |
 				END_MARKDOWN
 				<table>
 				<thead>
 				<tr>
 				<th>Item      </th>
 				<th align="right"> Value</th>
 				</tr>
 				</thead>
 				<tbody>
 				<tr>
 				<td>Computer </td>
 				<td align="right"> $1600</td>
 				</tr>
 				<tr>
 				<td>Phone    </td>
 				<td align="right">   $12</td>
 				</tr>
 				<tr>
 				<td>Pipe     </td>
 				<td align="right">    $1</td>
 				</tr>
 				</tbody>
 				</table>
 				END_HTML
 			end
		end
	end


	describe "tilde strike-through" do

		it "doesn't render tilde-bracketed test when :strikethrough isn't set" do
			the_markdown( "~~cancelled~~" ).
				should be_transformed_into( '<p>~~cancelled~~</p>' )
		end

		it "renders double tilde-bracketed text as strikethrough" do
			the_markdown( "~~cancelled~~", :strikethrough => true ).
				should be_transformed_into( '<p><del>cancelled</del></p>' )
		end

		it "renders tilde-bracketed text for tilde-brackets of more than two tildes" do
			the_markdown( "~~~~cancelled~~~~", :strikethrough => true ).
				should be_transformed_into( '<p><del>cancelled</del></p>' )
		end

		it "includes extra tildes in tilde-bracketed text" do
			the_markdown( "~~~cancelled~~", :strikethrough => true ).
				should be_transformed_into( '<p><del>~cancelled</del></p>' )
		end

	end


	describe "definition lists" do

		describe "(discount style)" do
			it "aren't rendered by default" do
				the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
				=hey!=
				    This is a definition list
				---
				<p>=hey!=</p>

				<pre><code>This is a definition list
				</code></pre>
				---
			end

			it "are rendered if the :definition_lists option is true" do
				the_indented_markdown( <<-"---", :definition_lists => true ).should be_transformed_into(<<-"---").without_indentation
				=hey!=
				    This is a definition list
				---
				<dl>
				<dt>hey!</dt>
				<dd>This is a definition list</dd>
				</dl>
				---
			end

			it "supports multiple-term list items" do
				the_indented_markdown( <<-"---", :definition_lists => true ).should be_transformed_into(<<-"---").without_indentation
				=tag1=
				=tag2=
				    data.
				---
				<dl>
				<dt>tag1</dt>
				<dt>tag2</dt>
				<dd>data.</dd>
				</dl>
				---
			end
		end

		describe "(markdown-extra style)" do
			it "aren't rendered by default" do
				the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
				Apple
				:   Pomaceous fruit of plants of the genus Malus in 
				    the family Rosaceae.

				Orange
				:   The fruit of an evergreen tree of the genus Citrus.
				---
				<p>Apple
				:   Pomaceous fruit of plants of the genus Malus in</p>

				<pre><code>the family Rosaceae.
				</code></pre>

				<p>Orange
				:   The fruit of an evergreen tree of the genus Citrus.</p>
				---
			end

			it "are rendered if the :definition_lists option is true" do
				the_indented_markdown( <<-"---", :definition_lists => true ).should be_transformed_into(<<-"---").without_indentation
				Apple
				:   Pomaceous fruit of plants of the genus Malus in 
				    the family Rosaceae.

				Orange
				:   The fruit of an evergreen tree of the genus Citrus.
				---
				<dl>
				<dt>Apple</dt>
				<dd>  Pomaceous fruit of plants of the genus Malus in
				  the family Rosaceae.</dd>
				<dt>Orange</dt>
				<dd>  The fruit of an evergreen tree of the genus Citrus.</dd>
				</dl>
				---
			end

			it "are rendered if the :definition_lists option is true" do
				the_indented_markdown( <<-"---", :definition_lists => true ).should be_transformed_into(<<-"---").without_indentation
				Apple
				:   Pomaceous fruit of plants of the genus Malus in 
				the family Rosaceae.

				Orange
				:   The fruit of an evergreen tree of the genus Citrus.
				---
				<dl>
				<dt>Apple</dt>
				<dd>  Pomaceous fruit of plants of the genus Malus in
				the family Rosaceae.</dd>
				<dt>Orange</dt>
				<dd>  The fruit of an evergreen tree of the genus Citrus.</dd>
				</dl>
				---
			end
		end

	end


	describe "footnotes" do

		it "aren't rendered by default" do
			the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
			That's some text with a footnote.[^1]

			[^1]: And that's the footnote.
			---
			<p>That's some text with a footnote.<a href=\"And\">^1</a></p>
			---
		end

		it "are rendered if the :footnotes option is true" do
			the_indented_markdown( <<-"---", :footnotes => true ).should be_transformed_into(<<-"---").without_indentation
			That's some text with a footnote.[^1]

			[^1]: And that's the footnote.
			---
			<p>That's some text with a footnote.<sup id="fnref:1"><a href="#fn:1" rel="footnote">1</a></sup></p>
			<div class="footnotes">
			<hr/>
			<ol>
			<li id="fn:1">
			<p>And that&rsquo;s the footnote.<a href="#fnref:1" rev="footnote">&#8617;</a></p></li>
			</ol>
			</div>
			---
		end

		it "renders a second link to the same footnote as plain text" do
			the_indented_markdown( <<-"---", :footnotes => true ).should be_transformed_into(<<-"---").without_indentation
			That's some text with a footnote.[^afootnote]
			And here's another.[^afootnote]

			[^afootnote]: And that's the footnote.
			---
			<p>That's some text with a footnote.<sup id=\"fnref:1\"><a href=\"#fn:1\" rel=\"footnote\">1</a></sup>
			And here's another.[^afootnote]</p>
			<div class=\"footnotes\">
			<hr/>
			<ol>
			<li id=\"fn:1\">
			<p>And that&rsquo;s the footnote.<a href=\"#fnref:1\" rev=\"footnote\">&#8617;</a></p></li>
			</ol>
			</div>
			---
		end

		it "support multiple block-level elements via indentation", :pedantic => true do
			pending "not yet implemented by Discount" do
				the_indented_markdown( <<-"---", :footnotes => true ).should be_transformed_into(<<-"---").without_indentation
				That's some text with a footnote.[^1]

				[^1]: And that's the footnote.

				    That's the second paragraph.
				---
				<p>That's some text with a footnote.<sup id="fnref:1"><a href="#fn:1" rel="footnote">1</a></sup></p>
				<div class="footnotes">
				<hr/>
				<ol>
				<li id="fn:1">
				<p>And that&rsquo;s the footnote.</p>
				<p>That&rsquo;s the second paragraph.<a href="#fnref:1" rev="footnote">&#8617;</a></p></li>
				</ol>
				</div>
				---
			end
		end

		it "support multiple block-level elements with an empty first line", :pedantic => true do
			pending "not yet implemented by Discount" do
				the_indented_markdown( <<-"---", :footnotes => true ).should be_transformed_into(<<-"---").without_indentation
				That's some text with a footnote.[^cows]

				[^cows]:
				    And that's the footnote.

				    That's the second paragraph.
				---
				<p>That's some text with a footnote.<sup id="fnref:cows"><a href="#fn:cows" rel="footnote">1</a></sup></p>
				<div class="footnotes">
				<hr />
				<ol>
				<li id="fn:cows">
				<p>And that's the footnote.</p>
				<p>That's the second paragraph.&#160;<a href="#fnref:cows" rev="footnote">&#8617;</a></p>
				</li>
				</ol>
				</div>
				---
			end
		end

	end

end


__END__

