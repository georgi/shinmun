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

describe BlueCloth, "titles" do

	# setext-style h1 -- three characters
	it "transforms Setext-style level-one headers (three equals) into an H1" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Title Text
		===
		---
		<h1>Title Text</h1>
		---
	end

	# setext-style h1 -- match title width
	it "transforms Setext-style level-one headers (more than three equals) into an H1" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Title Text
		==========
		---
		<h1>Title Text</h1>
		---
	end


	# setext-style h2 -- one character
	it "transforms Setext-style level-two headers (one dash) into an H2" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Title Text
		-
		---
		<h2>Title Text</h2>
		---
	end

	# setext-style h2 -- three characters
	it "transforms Setext-style level-two headers (three dashes) into an H2" do
		the_indented_markdown( <<-"..." ).should be_transformed_into(<<-"...").without_indentation
		Title Text
		---
		...
		<h2>Title Text</h2>
		...
	end

	# setext-style h2 -- match title width
	it "transforms Setext-style level-two headers (more than three dashes) into an H2" do
		the_indented_markdown( <<-"..." ).should be_transformed_into(<<-"...").without_indentation
		Title Text
		----------
		...
		<h2>Title Text</h2>
		...
	end

	# ATX-style h1 -- Left side only
	it "makes a header out of an ATX-style h1 -- Left side only" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		# Title Text
		---
		<h1>Title Text</h1>
		---
	end

	# ATX-style h1 -- both sides
	it "makes a header out of an ATX-style h1 -- both sides" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		# Title Text #
		---
		<h1>Title Text</h1>
		---
	end

	# ATX-style h1 -- both sides, right side with three characters
	it "makes a header out of an ATX-style h1 -- both sides, right side with three characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		# Title Text ###
		---
		<h1>Title Text</h1>
		---
	end

	# ATX-style h1 -- both sides, right side with five characters
	it "makes a header out of an ATX-style h1 -- both sides, right side with five characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		# Title Text #####
		---
		<h1>Title Text</h1>
		---
	end


	# ATX-style h2 -- left side only
	it "makes a header out of an ATX-style h2 -- left side only" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		## Title Text
		---
		<h2>Title Text</h2>
		---
	end

	# ATX-style h2 -- both sides
	it "makes a header out of an ATX-style h2 -- both sides" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		## Title Text #
		---
		<h2>Title Text</h2>
		---
	end

	# ATX-style h2 -- both sides, right side with three characters
	it "makes a header out of an ATX-style h2 -- both sides, right side with three characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		## Title Text ###
		---
		<h2>Title Text</h2>
		---
	end

	# ATX-style h2 -- both sides, right side with five characters
	it "makes a header out of an ATX-style h2 -- both sides, right side with five characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		## Title Text #####
		---
		<h2>Title Text</h2>
		---
	end


	# ATX-style h3 -- left side only
	it "makes a header out of an ATX-style h3 -- left side only" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		### Title Text
		---
		<h3>Title Text</h3>
		---
	end

	# ATX-style h3 -- both sides, right side with one character
	it "makes a header out of an ATX-style h3 -- both sides, right side with one character" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		### Title Text #
		---
		<h3>Title Text</h3>
		---
	end

	# ATX-style h3 -- both sides, right side with three characters
	it "makes a header out of an ATX-style h3 -- both sides, right side with three characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		### Title Text ###
		---
		<h3>Title Text</h3>
		---
	end

	# ATX-style h3 -- both sides, right side with five characters
	it "makes a header out of an ATX-style h3 -- both sides, right side with five characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		### Title Text #####
		---
		<h3>Title Text</h3>
		---
	end


	# ATX-style h4 -- left side only
	it "makes a header out of an ATX-style h4 -- left side only" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		#### Title Text
		---
		<h4>Title Text</h4>
		---
	end

	# ATX-style h4 -- both sides, right side with one character
	it "makes a header out of an ATX-style h4 -- both sides, right side with one character" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		#### Title Text #
		---
		<h4>Title Text</h4>
		---
	end

	# ATX-style h4 -- both sides, right side with three characters
	it "makes a header out of an ATX-style h4 -- both sides, right side with three characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		#### Title Text ###
		---
		<h4>Title Text</h4>
		---
	end

	# ATX-style h4 -- both sides, right side with five characters
	it "makes a header out of an ATX-style h4 -- both sides, right side with five characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		#### Title Text #####
		---
		<h4>Title Text</h4>
		---
	end


	# ATX-style h5 -- left side only
	it "makes a header out of an ATX-style h5 -- left side only" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		##### Title Text
		---
		<h5>Title Text</h5>
		---
	end

	# ATX-style h5 -- both sides, right side with one character
	it "makes a header out of an ATX-style h5 -- both sides, right side with one character" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		##### Title Text #
		---
		<h5>Title Text</h5>
		---
	end

	# ATX-style h5 -- both sides, right side with three characters
	it "makes a header out of an ATX-style h5 -- both sides, right side with three characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		##### Title Text ###
		---
		<h5>Title Text</h5>
		---
	end

	# ATX-style h5 -- both sides, right side with five characters
	it "makes a header out of an ATX-style h5 -- both sides, right side with five characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		##### Title Text #####
		---
		<h5>Title Text</h5>
		---
	end


	# ATX-style h6 -- left side only
	it "makes a header out of an ATX-style h6 -- left side only" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		###### Title Text
		---
		<h6>Title Text</h6>
		---
	end

	# ATX-style h6 -- both sides, right side with one character
	it "makes a header out of an ATX-style h6 -- both sides, right side with one character" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		###### Title Text #
		---
		<h6>Title Text</h6>
		---
	end

	# ATX-style h6 -- both sides, right side with three characters
	it "makes a header out of an ATX-style h6 -- both sides, right side with three characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		###### Title Text ###
		---
		<h6>Title Text</h6>
		---
	end

	# ATX-style h6 -- both sides, right side with five characters
	it "makes a header out of an ATX-style h6 -- both sides, right side with five characters" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		###### Title Text #####
		---
		<h6>Title Text</h6>
		---
	end

end


