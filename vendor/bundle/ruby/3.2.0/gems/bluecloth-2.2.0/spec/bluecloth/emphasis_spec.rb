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

describe BlueCloth, "emphasis" do

	it "treats single asterisks as indicators of emphasis" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Use *single splats* for emphasis.
		---
		<p>Use <em>single splats</em> for emphasis.</p>
		---
	end

	it "treats single underscores as indicators of emphasis" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Use *underscores* for emphasis.
		---
		<p>Use <em>underscores</em> for emphasis.</p>
		---
	end

	it "treats double asterisks as strong emphasis" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Use **double splats** for more emphasis.
		---
		<p>Use <strong>double splats</strong> for more emphasis.</p>
		---
	end

	it "treats double underscores as strong emphasis" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Use __doubled underscores__ for more emphasis.
		---
		<p>Use <strong>doubled underscores</strong> for more emphasis.</p>
		---
	end

	it "allows you to use both kinds of emphasis in a single span" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Use *single splats* or _single unders_ for normal emphasis.
		---
		<p>Use <em>single splats</em> or <em>single unders</em> for normal emphasis.</p>
		---
	end

	it "allows you to use both kinds of strong emphasis in a single span" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		Use _single unders_ for normal emphasis
		or __double them__ for strong emphasis.
		---
		<p>Use <em>single unders</em> for normal emphasis
		or <strong>double them</strong> for strong emphasis.</p>
		---
	end

	it "allows you to include literal asterisks by escaping them" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		You can include literal *\\*splats\\** by escaping them.
		---
		<p>You can include literal <em>*splats*</em> by escaping them.</p>
		---
	end

	it "allows two instances of asterisked emphasis on one line" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		If there's *two* splatted parts on a *single line* it should still work.
		---
		<p>If there's <em>two</em> splatted parts on a <em>single line</em> it should still work.</p>
		---
	end

	it "allows two instances of double-asterisked emphasis on one line" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This **doubled** one should **work too**.
		---
		<p>This <strong>doubled</strong> one should <strong>work too</strong>.</p>
		---
	end

	it "allows two instances of underscored emphasis on one line" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		If there's _two_ underbarred parts on a _single line_ it should still work.
		---
		<p>If there's <em>two</em> underbarred parts on a <em>single line</em> it should still work.</p>
		---
	end

	it "allows two instances of double-underscored emphasis on one line" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		This __doubled__ one should __work too__.
		---
		<p>This <strong>doubled</strong> one should <strong>work too</strong>.</p>
		---
	end

	it "correctly emphasizes the first span of the text if it's emphasized with asterisks" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		*Something* like this should be bold.
		---
		<p><em>Something</em> like this should be bold.</p>
		---
	end

	it "correctly emphasizes the first span of the text if it's emphasized with underscores" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		_Something_ like this should be bold.
		---
		<p><em>Something</em> like this should be bold.</p>
		---
	end

	it "correctly emphasizes the first span of the text if it's emphasized with double asterisks" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		**Something** like this should be bold.
		---
		<p><strong>Something</strong> like this should be bold.</p>
		---
	end

	it "correctly emphasizes the first span of the text if it's emphasized with double underscores" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		__Something__ like this should be bold.
		---
		<p><strong>Something</strong> like this should be bold.</p>
		---
	end

	# Partial-word emphasis (Bug #568)
	it "correctly emphasizes just a part of a word (bugfix for #568)" do
		the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
		**E**xtended **TURN**
		---
		<p><strong>E</strong>xtended <strong>TURN</strong></p>
		---
	end

end


