#!/usr/bin/env ruby
# encoding: utf-8

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


### Output some debugging if $DEBUG is true
def debug_msg( *args )
	$stderr.puts( *args ) if $DEBUG
end



#####################################################################
###	C O N T E X T S
#####################################################################

describe BlueCloth do
	include BlueCloth::TestConstants,
		BlueCloth::Matchers

	it "defines the top-level Markdown constant" do
		Object.const_defined?('Markdown').should be_true()
		# :FIXME: This is probably a fragile test, as anything else that defines it before
		# the BlueCloth tests run could lead to a false failure. I at least know that it'll
		# work in my environment, and I'm not sure how else to test it.
		::Markdown.should be_equal( ::BlueCloth )
	end

	it "knows what version of Discount was used to build it" do
		BlueCloth.discount_version.should =~ /^\d+\.\d+\.\d+.*GITHUB-TAGS/
	end

	it "can build a flags bitmask out of an options hash" do
		flags = BlueCloth.flags_from_opthash(
			:remove_links => true,
			:header_labels => true,
			:pandoc_headers => false
		  )

		( flags & BlueCloth::MKD_NOLINKS ).should be_nonzero()
		( flags & BlueCloth::MKD_TOC ).should be_nonzero()
		( flags & BlueCloth::MKD_NOHEADER ).should be_nonzero()
	end


	it "handles non-string content safely" do
		BlueCloth.new( nil ).text.should == ''
	end


	it "inherits the taintedness of its input" do
		str = "a string"
		BlueCloth.new( str ).should_not be_tainted()

		str.taint
		BlueCloth.new( str ).should be_tainted()
	end


	it "allows output to be rendered several times" do
		bc = BlueCloth.new( "Some text" )
		bc.to_html.should == bc.to_html
	end


	it "correctly applies the :remove_links option to the output" do
		input = "An [example](http://url.com/). A <a href='http://example.com/'>link</a>."
		expected = "<p>An [example](http://url.com/). A &lt;a href='http://example.com/'>link</a>.</p>"

		the_markdown( input, :remove_links => true ).should be_transformed_into( expected )
	end

	it "correctly applies the :remove_images option to the output" do
		input = %{An ![alt text](/path/img.jpg "Title"). An <img href='http://example.com/1.jpg' />.}
		expected = %{<p>An ![alt text](/path/img.jpg "Title"). An &lt;img href='http://example.com/1.jpg' />.</p>}

		the_markdown( input, :remove_images => true ).should be_transformed_into( expected )
	end

	it "correctly applies the :smartypants option to the output" do
		input = %{He was known to frequent that "other establishment"...}
		expected = %{<p>He was known to frequent that &ldquo;other establishment&rdquo;&hellip;</p>}

		the_markdown( input, :smartypants => true ).should be_transformed_into( expected )
	end

	it "correctly applies the :auto_links option to the output" do
		the_indented_markdown( <<-"---", :auto_links => true ).should be_transformed_into(<<-"---").without_indentation
		I wonder how many people have
		http://google.com/ as their home page.
		---
		<p>I wonder how many people have
		<a href="http://google.com/">http://google.com/</a> as their home page.</p>
		---
	end

	it "doesn't form links for protocols it doesn't know about under :safe_links mode" do
		the_indented_markdown( <<-"---", :safe_links => true ).should be_transformed_into(<<-"---").without_indentation
		This is an example 
		[of something](javascript:do_something_bad(\\)) 
		you might want to prevent.
		---
		<p>This is an example
		[of something](javascript:do<em>something</em>bad())
		you might want to prevent.</p>
		---
	end

	it "forms links for protocols it doesn't know about when not under :safe_links mode" do
		the_indented_markdown( <<-"---", :safe_links => false ).should be_transformed_into(<<-"---").without_indentation
		This is an example 
		[of something](javascript:do_something_benign(\\)) 
		you might want to allow.
		---
		<p>This is an example
		<a href="javascript:do_something_benign()">of something</a>
		you might want to allow.</p>
		---
	end


	describe "Discount extensions" do

		it "correctly applies the :pandoc_headers option" do
			input = "% title\n% author1, author2\n% date\n\nStuff."

			bc = BlueCloth.new( input, :pandoc_headers => true )
			bc.header.should == {
				:title => 'title',
				:author => 'author1, author2',
				:date => 'date'
			}
			bc.to_html.should == '<p>Stuff.</p>'
		end

		it "correctly expands id: links when :pseudoprotocols are enabled" do
			input = "It was [just as he said](id:foo) it would be."
			expected = %{<p>It was <span id="foo">just as he said</span> it would be.</p>}

			the_markdown( input, :pseudoprotocols => true ).should be_transformed_into( expected )
		end

		it "correctly expands class: links when :pseudoprotocols are enabled" do
			input = "It was [just as he said](class:foo) it would be."
			expected = %{<p>It was <span class="foo">just as he said</span> it would be.</p>}

			the_markdown( input, :pseudoprotocols => true ).should be_transformed_into( expected )
		end

		it "correctly expands raw: links when :pseudoprotocols are enabled" do
			input = %{I have node idea [what this is for](raw:really "but") it's here.}
			expected = %{<p>I have node idea really it's here.</p>}

			the_markdown( input, :pseudoprotocols => true ).should be_transformed_into( expected )
		end

		it "correctly adds IDs to headers when :header_labels is enabled" do
			input = %{# A header\n\nSome stuff\n\n## Another header\n\nMore stuff.\n\n}
			expected = %{<a name=\"A.header\"></a>\n<h1>A header</h1>\n\n<p>Some stuff</p>\n\n} +
			           %{<a name=\"Another.header\"></a>\n<h2>Another header</h2>\n\n<p>More stuff.</p>}

			the_markdown( input, :header_labels => true ).should be_transformed_into( expected )
		end

		it "expands superscripts only when :superscript is enabled" do
			input = %{It used to be that E = mc^2 used to be the province of physicists.}
			expected = %{<p>It used to be that E = mc<sup>2</sup> used to be the province} +
			           %{ of physicists.</p>}
			disabled = %{<p>It used to be that E = mc^2 used to be the province} +
			         %{ of physicists.</p>}

			the_markdown( input, :superscript => false ).should be_transformed_into( disabled )
			the_markdown( input, :superscript => true ).should be_transformed_into( expected )
		end

		it "uses relaxed emphasis when :relaxed is enabled" do
			input = %{If you use size_t instead, you _won't_ have to worry as much about portability.}
			relaxed = %{<p>If you use size_t instead, you <em>won't</em> have to worry as much about portability.</p>}
			strict = %{<p>If you use size<em>t instead, you </em>won't_ have to worry as much about portability.</p>}

			the_markdown( input, :relaxed => true ).should be_transformed_into( relaxed )
			the_markdown( input, :relaxed => false ).should be_transformed_into( strict )
		end

	end

	### Test email address output
	describe " email obfuscation" do
		TESTING_EMAILS = %w[
			address@example.com
			foo-list-admin@bar.com
			fu@bar.COM
			baz@ruby-lang.org
			foo-tim-bazzle@bar-hop.co.uk
			littlestar@twinkle.twinkle.band.CO.ZA
			ll@lll.lllll.ll
			Ull@Ulll.Ulllll.ll
			UUUU1@UU1.UU1UUU.UU
			l@ll.ll
			Ull.Ullll@llll.ll
			Ulll-Ull.Ulllll@ll.ll
			1@111.ll
		]
		# I can't see a way to handle IDNs clearly yet, so these will have to wait.
		#	info@öko.de
		#	jemand@büro.de
		#	irgendwo-interreßant@dÅgta.se
		#]

		def decode( str )
			str.gsub( /&#(x[a-f0-9]+|\d{1,3});/i ) do |match|
				code = $1
				debug_msg "Decoding &##{code};"

				case code
				when /^x([a-f0-9]+)/i
					debug_msg "-> #{$1.to_i(16).chr}"
					$1.to_i(16).chr
				when /^\d+$/
					debug_msg "-> #{code.to_i.chr}"
					code.to_i.chr
				else
					raise "Hmmm... malformed entity %p" % code
				end
			end
		end

		TESTING_EMAILS.each do |addr|
			it( "obfuscates the email address %p" % addr ) do
				html = BlueCloth.new( "<#{addr}>" ).to_html

				expected_output = %r{<p><a href="([^"]+)">[^<]+</a></p>}
				match = expected_output.match( html )
				match.should be_an_instance_of( MatchData )

				match[1].should_not == addr

				decoded_href = decode( match[1] )
				debug_msg "Unencoded href = %p" % [ decoded_href ]
				decoded_href.should == "mailto:#{addr}"
			end
		end
	end


	describe "encoding under Ruby 1.9.x", :ruby_19_only => true do

		before( :each ) do
			pending "only valid under a version of Ruby that has the Encoding class" unless
				Object.const_defined?( :Encoding )
		end


		it "outputs HTML in UTF8 if given a UTF8 string" do
			input = "a ∫‡®îñg".encode( Encoding::UTF_8 )
			output = BlueCloth.new( input ).to_html

			output.encoding.should == Encoding::UTF_8
		end

		it "outputs HTML in KOI8-U if given a KOI8-U string" do
			input = "Почему Молчишь".encode( Encoding::KOI8_U )
			output = BlueCloth.new( input ).to_html

			output.should == "<p>\xF0\xCF\xDE\xC5\xCD\xD5 \xED\xCF\xCC\xDE\xC9\xDB\xD8</p>".
				force_encoding( Encoding::KOI8_U )
		end

		it "outputs HTML in Shift-JIS if given a Shift-JIS string" do
			input = "日本語".encode( Encoding::SHIFT_JIS )
			output = BlueCloth.new( input ).to_html

			output.should == "<p>\x93\xFA\x96{\x8C\xEA</p>".
				force_encoding( Encoding::SHIFT_JIS )
		end

	end

end

# vim: set nosta noet ts=4 sw=4:
