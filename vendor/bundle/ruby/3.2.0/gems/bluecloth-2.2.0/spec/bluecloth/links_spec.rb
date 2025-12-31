#!/usr/bin/env ruby
# encoding: utf-8

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent

	libdir = basedir + 'lib'

	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
}

require 'rspec'
require 'bluecloth'

require 'spec/lib/helpers'


#####################################################################
###	C O N T E X T S
#####################################################################

describe BlueCloth, "links" do

	it "supports inline links" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		An [example](http://url.com/).
		---
		<p>An <a href="http://url.com/">example</a>.</p>
		---
	end

	it "supports inline link with a title" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		An [example](http://url.com/ "Check out url.com!").
		---
		<p>An <a href="http://url.com/" title="Check out url.com!">example</a>.</p>
		---
	end

	it "supports reference-style links with no title" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		An [example][ex] reference-style link.

		  [ex]: http://www.bluefi.com/
		---
		<p>An <a href="http://www.bluefi.com/">example</a> reference-style link.</p>
		---
	end

	it "supports indented (less than tabwidth) reference-style links" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		An [example][ex] reference-style link.

		  [ex]: http://www.bluefi.com/
		---
		<p>An <a href="http://www.bluefi.com/">example</a> reference-style link.</p>
		---
	end

	it "supports reference-style links with quoted titles" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		An [example][ex] reference-style link.

		  [ex]: http://www.bluefi.com/ "Check out our air."
		---
		<p>An <a href="http://www.bluefi.com/" title="Check out our air.">example</a> reference-style link.</p>
		---
	end

	it "supports reference-style links with paren titles" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		An [example][ex] reference-style link.

		  [ex]: http://www.bluefi.com/ (Check out our air.)
		---
		<p>An <a href="http://www.bluefi.com/" title="Check out our air.">example</a> reference-style link.</p>
		---
	end

	it "supports reference-style links with intervening spaces" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		You can split the [linked part] [ex] from
		the reference part with a single space.

		[ex]: http://www.treefrog.com/ "for some reason"
		---
		<p>You can split the <a href="http://www.treefrog.com/" title="for some reason">linked part</a> from
		the reference part with a single space.</p>
		---
	end

	it "supports reference-style links with intervening spaces" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		You can split the [linked part]
		[ex] from the reference part
		with a newline in case your editor wraps it there, I guess.

		[ex]: http://www.treefrog.com/
		---
		<p>You can split the <a href="http://www.treefrog.com/">linked part</a> from the reference part
		with a newline in case your editor wraps it there, I guess.</p>
		---
	end

	it "supports reference-style anchors" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		I get 10 times more traffic from [Google] [1] than from
		[Yahoo] [2] or [MSN] [3].

		  [1]: http://google.com/        "Google"
		  [2]: http://search.yahoo.com/  "Yahoo Search"
		  [3]: http://search.msn.com/    "MSN Search"
		---
		<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a> than from
		<a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
		---
	end

	it "supports implicit name-link shortcut anchors" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		I get 10 times more traffic from [Google][] than from
		[Yahoo][] or [MSN][].

		  [google]: http://google.com/        "Google"
		  [yahoo]:  http://search.yahoo.com/  "Yahoo Search"
		  [msn]:    http://search.msn.com/    "MSN Search"
		---
		<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a> than from
		<a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
		---
	end

	it "supports inline anchors" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		I get 10 times more traffic from [Google](http://google.com/ "Google")
		than from [Yahoo](http://search.yahoo.com/ "Yahoo Search") or
		[MSN](http://search.msn.com/ "MSN Search").
		---
		<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a>
		than from <a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or
		<a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
		---
	end

	it "fails gracefully for unclosed brackets (and bug #524)" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is just a [bracket opener; it should fail gracefully.
		---
		<p>This is just a [bracket opener; it should fail gracefully.</p>
		---
	end

	it "fails gracefully for unresolved reference-style links (Bug #620)" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This is an unresolved [url][1].
		---
		<p>This is an unresolved [url][1].</p>
		---
	end


end


