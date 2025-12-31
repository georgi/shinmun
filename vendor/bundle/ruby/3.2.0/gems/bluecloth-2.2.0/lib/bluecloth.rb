#!/usr/bin/ruby

# 
# Bluecloth is a Ruby implementation of Markdown, a text-to-HTML conversion
# tool.
# 
# == Authors
# 
# * Michael Granger <ged@FaerieMUD.org>
# 
# == Contributors
#
# * Martin Chase <stillflame@FaerieMUD.org> - Peer review, helpful suggestions
# * Florian Gross <flgr@ccan.de> - Filter options, suggestions
#
# This product includes software developed by David Loren Parsons
# <http://www.pell.portland.or.us/~orc>.
# 
# == Version
#
# 2.1.0
#
# == Revision
# 
# $Revision: 34dd000f535c $
#
# == License
#
# Copyright (c) 2004-2011, Michael Granger
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the author/s, nor the names of the project's
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
class BlueCloth

	# Release Version
	VERSION = '2.2.0'

	# Version control revision
	REVISION = %q$Revision: 34dd000f535c $

	# The defaults for all supported options.
	DEFAULT_OPTIONS = {
		:alphalists       => true,
		:auto_links       => false,
		:definition_lists => false,
		:divquotes        => false,
		:escape_html      => false,
		:expand_tabs      => true,
		:header_labels    => false,
		:mdtest_1_compat  => false,
		:pandoc_headers   => false,
		:pseudoprotocols  => false,
		:relaxed          => false,
		:remove_images    => false,
		:remove_links     => false,
		:safe_links       => false,
		:smartypants      => true,
		:strict_mode      => true,
		:strikethrough    => true,
		:superscript      => false,
		:tables           => false,
		:tagtext_mode     => false,
		:xml_cdata        => false,
		:footnotes        => false,
	}.freeze

	# The number of characters of the original markdown source to include in the 
	# output of #inspect
	INSPECT_TEXT_LENGTH = 50


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Convert the specified +opthash+ into a flags bitmask. If it's already a
	### Fixnum (e.g., if someone passed in an ORed flags argument instead of an
	### opthash), just return it as-is.
	def self::flags_from_opthash( opthash={} )
		return opthash if opthash.is_a?( Integer )

		# Support BlueCloth1-style options
		if opthash == :filter_html || opthash == [:filter_html]
			opthash = { :escape_html => true }
		elsif opthash == :filter_styles
			opthash = {}
		elsif !opthash.is_a?( Hash )
			raise ArgumentError, "option %p not supported" % [ opthash ]
		end

		flags = 0

		if   opthash[:remove_links]     then flags |= MKD_NOLINKS;         end
		if   opthash[:remove_images]    then flags |= MKD_NOIMAGE;         end
		if ! opthash[:smartypants]      then flags |= MKD_NOPANTS;         end
		if   opthash[:escape_html]      then flags |= MKD_NOHTML;          end
		if   opthash[:strict_mode]      then flags |= MKD_STRICT;          end
		if   opthash[:tagtext_mode]     then flags |= MKD_TAGTEXT;         end
		if ! opthash[:pseudoprotocols]  then flags |= MKD_NO_EXT;          end
		if   opthash[:xml_cdata]        then flags |= MKD_CDATA;           end
		if ! opthash[:superscript]      then flags |= MKD_NOSUPERSCRIPT;   end
		if ! opthash[:relaxed]          then flags |= MKD_NORELAXED;       end
		if ! opthash[:tables]           then flags |= MKD_NOTABLES;        end
		if ! opthash[:strikethrough]    then flags |= MKD_NOSTRIKETHROUGH; end
		if   opthash[:header_labels]    then flags |= MKD_TOC;             end
		if   opthash[:mdtest_1_compat]  then flags |= MKD_1_COMPAT;        end
		if   opthash[:auto_links]       then flags |= MKD_AUTOLINK;        end
		if   opthash[:safe_links]       then flags |= MKD_SAFELINK;        end
		if ! opthash[:pandoc_headers]   then flags |= MKD_NOHEADER;        end
		if   opthash[:expand_tabs]      then flags |= MKD_TABSTOP;         end
		if ! opthash[:divquotes]        then flags |= MKD_NODIVQUOTE;      end
		if ! opthash[:alphalists]       then flags |= MKD_NOALPHALIST;     end
		if ! opthash[:definition_lists] then flags |= MKD_NODLIST;         end
		if   opthash[:footnotes]        then flags |= MKD_EXTRA_FOOTNOTE;  end

		return flags
	end


	### Returns a Hash that reflects the settings from the specified +flags+ Integer.
	def self::opthash_from_flags( flags=0 )
		flags = flags.to_i

		opthash = {}
		if  ( flags & MKD_NOLINKS         ).nonzero? then opthash[:remove_links]     = true; end
		if  ( flags & MKD_NOIMAGE         ).nonzero? then opthash[:remove_images]    = true; end
		if !( flags & MKD_NOPANTS         ).nonzero? then opthash[:smartypants]      = true; end
		if  ( flags & MKD_NOHTML          ).nonzero? then opthash[:escape_html]      = true; end
		if  ( flags & MKD_STRICT          ).nonzero? then opthash[:strict_mode]      = true; end
		if  ( flags & MKD_TAGTEXT         ).nonzero? then opthash[:tagtext_mode]     = true; end
		if !( flags & MKD_NO_EXT          ).nonzero? then opthash[:pseudoprotocols]  = true; end
		if  ( flags & MKD_CDATA           ).nonzero? then opthash[:xml_cdata]        = true; end
		if !( flags & MKD_NOSUPERSCRIPT   ).nonzero? then opthash[:superscript]      = true; end
		if !( flags & MKD_NORELAXED       ).nonzero? then opthash[:relaxed]          = true; end
		if !( flags & MKD_NOTABLES        ).nonzero? then opthash[:tables]           = true; end
		if !( flags & MKD_NOSTRIKETHROUGH ).nonzero? then opthash[:strikethrough]    = true; end
		if  ( flags & MKD_TOC             ).nonzero? then opthash[:header_labels]    = true; end
		if  ( flags & MKD_1_COMPAT        ).nonzero? then opthash[:mdtest_1_compat]  = true; end
		if  ( flags & MKD_AUTOLINK        ).nonzero? then opthash[:auto_links]       = true; end
		if  ( flags & MKD_SAFELINK        ).nonzero? then opthash[:safe_links]       = true; end
		if !( flags & MKD_NOHEADER        ).nonzero? then opthash[:pandoc_headers]   = true; end
		if  ( flags & MKD_TABSTOP         ).nonzero? then opthash[:expand_tabs]      = true; end
		if !( flags & MKD_NODIVQUOTE      ).nonzero? then opthash[:divquotes]        = true; end
		if !( flags & MKD_NOALPHALIST     ).nonzero? then opthash[:alphalists]       = true; end
		if !( flags & MKD_NODLIST         ).nonzero? then opthash[:definition_lists] = true; end
		if  ( flags & MKD_EXTRA_FOOTNOTE  ).nonzero? then opthash[:footnotes]        = true; end

		return opthash
	end


	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Return a human-readable representation of the object suitable for debugging.
	def inspect
		return "#<%s:0x%x text: %p; options: %p>" % [
			self.class.name,
			self.object_id / 2,
			self.text.length > INSPECT_TEXT_LENGTH ?
				self.text[ 0, INSPECT_TEXT_LENGTH - 5] + '[...]' :
				self.text,
			self.options,
		]
	end

end # class BlueCloth

begin
	require 'bluecloth_ext'
rescue LoadError => err
	# If it's a Windows binary gem, try the <major>.<minor> subdirectory
	if RUBY_PLATFORM =~/(mswin|mingw)/i
		major_minor = RUBY_VERSION[ /^(\d+\.\d+)/ ] or
			raise "Oops, can't extract the major/minor version from #{RUBY_VERSION.dump}"
		require "#{major_minor}/bluecloth_ext"
	else
		raise
	end

end




# Set the top-level 'Markdown' constant if it isn't already set
::Markdown = ::BlueCloth unless defined?( ::Markdown )


