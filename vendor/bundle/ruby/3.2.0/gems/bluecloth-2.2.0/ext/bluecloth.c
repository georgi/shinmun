/* 
 * BlueCloth -- a Ruby implementation of Markdown
 * $Id: bluecloth.c,v 463bb88e4d08 2011/03/12 17:58:01 ged $
 * 
 * = Authors
 * 
 * - Michael Granger <ged@FaerieMUD.org>
 * 
 * BlueCloth 2 is mostly just a wrapper around the Discount library
 * written by David Loren Parsons <http://www.pell.portland.or.us/~orc>. 
 *
 * = License
 * 
 * Discount:
 * Copyright (C) 2007 David Loren Parsons. All rights reserved.
 * 
 * The Discount library is used under the licensing terms outlined in the
 * COPYRIGHT.discount file included in the distribution.
 * 
 * Ruby bits:
 * See the LICENSE file included in the distribution.
 * 
 */

#include "bluecloth.h"

VALUE bluecloth_cBlueCloth;
VALUE bluecloth_default_opthash;


/* Get a Discount document for the specified text */
static MMIOT *
bluecloth_alloc( VALUE text, int flags ) {
	MMIOT *document;

	document = mkd_string( RSTRING_PTR(text), RSTRING_LEN(text), flags );
	if ( !document )
		rb_raise( rb_eRuntimeError, "Failed to create a BlueCloth object for: %s", RSTRING_PTR(text) );

	return document;
}


/*
 * GC Free function
 */
static void
bluecloth_gc_free( MMIOT *document ) {
	if ( document ) {
		mkd_cleanup( document );
		document = NULL;
	}
}


/* --------------------------------------------------------------
 * Utility functions
 * -------------------------------------------------------------- */

#ifdef HAVE_STDARG_PROTOTYPES
#include <stdarg.h>
void
bluecloth_debug(const char *fmt, ...)
#else
#include <varargs.h>
void
bluecloth_debug( fmt, va_alist )
	 const char *fmt;
	 va_dcl
#endif
{
	char buf[BUFSIZ], buf2[BUFSIZ];
	va_list	args;

	if (!RTEST(ruby_debug)) return;

	snprintf( buf, BUFSIZ, "Debug>>> %s", fmt );

#ifdef HAVE_STDARG_PROTOTYPES
	va_start( args, fmt );
#else
	va_start( args );
#endif
	vsnprintf( buf2, BUFSIZ, buf, args );
	fputs( buf2, stderr );
	fputs( "\n", stderr );
	fflush( stderr );
	va_end( args );
}


/*
 * Object validity checker. Returns the data pointer.
 */
static MMIOT *
bluecloth_check_ptr( VALUE self ) {
	Check_Type( self, T_DATA );

    if ( !rb_obj_is_kind_of(self, bluecloth_cBlueCloth) ) {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected BlueCloth object)",
				  rb_class2name(CLASS_OF( self )) );
    }

	return DATA_PTR( self );
}


/*
 * Fetch the data pointer and check it for sanity.
 */
static MMIOT *
bluecloth_get_ptr( VALUE self ) {
	MMIOT *ptr = bluecloth_check_ptr( self );

	if ( !ptr )
		rb_fatal( "Use of uninitialized BlueCloth object" );

	return ptr;
}


/* --------------------------------------------------------------
 * Class methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     BlueCloth.allocate   -> object
 *
 *  Allocate a new BlueCloth object.
 *
 */
static VALUE
bluecloth_s_allocate( VALUE klass ) {
	return Data_Wrap_Struct( klass, NULL, bluecloth_gc_free, 0 );
}


/*
 *  call-seq:
 *     BlueCloth.discount_version   -> string
 *
 *  Return the version string of the Discount library BlueCloth was built on.
 *
 */
static VALUE
bluecloth_s_discount_version( VALUE klass ) {
	return rb_str_new2( markdown_version );
}

/* --------------------------------------------------------------
 * Instance methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     BlueCloth.new( string='', options=DEFAULT_OPTIONS )   -> object
 *
 * Create a new BlueCloth object that will process the given +string+. The +options+ 
 * argument is a Hash that can be used to control the generated markup, and to 
 * enable/disable extensions. The supported options are:
 * 
 * [:remove_links]
 *   Ignore links in Markdown, and escape A tags in the output. Defaults to +false+.
 * [:remove_images]
 *   Ignore images in Markdown, and escape IMG tags in the output. Defaults to +false+.
 * [:smartypants]
 *   Do Smartypants-style mangling of quotes, dashes, or ellipses. Defaults to +true+.
 * [:pseudoprotocols]
 *   Support Discount's pseudo-protocol links. Defaults to +false+.
 * [:pandoc_headers]
 *   Support the extraction of 
 *   {Pandoc headers}[http://johnmacfarlane.net/pandoc/README.html#title-blocks], which 
 *   can be fetched as a Hash via the #header method. Defaults to +false+.
 * [:header_labels]
 *   Generate ID attributes for all headers. Defaults to +false+.
 * [:escape_html]
 *   Escape all HTML in the input string. Defaults to +false+.
 * [:strict_mode]
 *   Disables Discount's relaxed emphasis (ignores underscores in the middle of words) and
 *   superscript notation. Defaults to +true+.
 * 
 */
static VALUE
bluecloth_initialize( int argc, VALUE *argv, VALUE self ) {
	if ( !bluecloth_check_ptr(self) ) {
		MMIOT *document;
		VALUE text, optflags, fullhash, opthash = Qnil;
		int flags = 0;
		VALUE utf8text = Qnil;

		rb_scan_args( argc, argv, "02", &text, &opthash );

		/* Default empty string and options */
		if ( argc == 0 ) {
			text = rb_str_new( "", 0 );
		}

		/* One arg could be either the text or the opthash, so shift the args if appropriate */
		else if ( argc == 1 && (TYPE(text) == T_HASH || TYPE(text) == T_FIXNUM) ) {
			opthash = text;
			text = rb_str_new( "", 0 );
		}
		else {
			text = rb_obj_dup( rb_obj_as_string(text) );
		}

		/* Merge the options hash with the defaults and turn it into a flags int */
		if ( NIL_P(opthash) ) opthash = rb_hash_new();
		optflags = rb_funcall( bluecloth_cBlueCloth, rb_intern("flags_from_opthash"), 1, opthash );
		fullhash = rb_funcall( bluecloth_cBlueCloth, rb_intern("opthash_from_flags"), 1, optflags );

		flags = NUM2INT( optflags );

#ifdef M17N_SUPPORTED
		bluecloth_debug( "Bytes before utf8ification: %s",
			RSTRING_PTR(rb_funcall(text, rb_intern("dump"), 0, Qnil)) );
		utf8text = rb_str_export_to_enc( rb_str_dup(text), rb_utf8_encoding() );
		DATA_PTR( self ) = document = bluecloth_alloc( utf8text, flags );
#else
		DATA_PTR( self ) = document = bluecloth_alloc( text, flags );
#endif /* M17N_SUPPORTED */

		if ( !mkd_compile(document, flags) )
			rb_raise( rb_eRuntimeError, "Failed to compile markdown" );

		OBJ_FREEZE( text );
		rb_iv_set( self, "@text", text );
		OBJ_FREEZE( fullhash );
		rb_iv_set( self, "@options", fullhash );

		OBJ_INFECT( self, text );
	}

	return self;
}


/*
 *  call-seq:
 *     bluecloth.to_html   -> string
 *
 *  Transform the document into HTML.
 *
 */
static VALUE
bluecloth_to_html( VALUE self ) {
	MMIOT *document = bluecloth_get_ptr( self );
	char *output;
	int length;
	VALUE result = Qnil;

	bluecloth_debug( "Compiling document %p", document );

	if ( (length = mkd_document( document, &output )) != EOF ) {
#ifdef M17N_SUPPORTED
		VALUE orig_encoding = rb_obj_encoding( rb_iv_get(self, "@text") );
		VALUE utf8_result = rb_enc_str_new( output, strlen(output), rb_utf8_encoding() );
		result = rb_str_encode( utf8_result, orig_encoding, 0, Qnil );
		bluecloth_debug( "Bytes after un-utf8ification (if necessary): %s",
			RSTRING_PTR(rb_funcall(result, rb_intern("dump"), 0, Qnil)) );
#else
		result = rb_str_new2( output );
#endif /* M17N_SUPPORTED */

		OBJ_INFECT( result, self );

		return result;
	} else {
		return Qnil;
	}
}


char * (*header_functions[3])(MMIOT *) = {
	mkd_doc_title,
	mkd_doc_author,
	mkd_doc_date
};

/*
 *  call-seq:
 *     bluecloth.header   -> hash
 *
 *  Return the hash of 
 *  {Pandoc-style headers}[http://johnmacfarlane.net/pandoc/README.html#title-blocks]
 *  from the parsed document. If there were no headers, or the BlueCloth object was not
 *  constructed with the :pandoc_headers option enabled, an empty Hash is returned.
 *
 *     markdown = "%title My Essay\n%author Me\n%date Today\n\nSome stuff..."
 *     bc = BlueCloth.new( markdown, :pandoc_headers => true )
 *     # => 
 *     bc.header
 *     # => 
 */
static VALUE
bluecloth_header( VALUE self ) {
	MMIOT *document = bluecloth_get_ptr( self );
	char *field;
	VALUE fieldstring, headers = rb_hash_new();

	bluecloth_debug( "Fetching pandoc headers for document %p", document );

	if ( (field = mkd_doc_title(document)) ) {
		fieldstring = rb_str_new2( field );
		OBJ_INFECT( fieldstring, self );
		rb_hash_aset( headers, ID2SYM(rb_intern("title")), fieldstring );
	}
	if ( (field = mkd_doc_author(document)) ) {
		fieldstring = rb_str_new2( field );
		OBJ_INFECT( fieldstring, self );
		rb_hash_aset( headers, ID2SYM(rb_intern("author")), fieldstring );
	}
	if ( (field = mkd_doc_date(document)) ) {
		fieldstring = rb_str_new2( field );
		OBJ_INFECT( fieldstring, self );
		rb_hash_aset( headers, ID2SYM(rb_intern("date")), fieldstring );
	}

	return headers;
}



/* --------------------------------------------------------------
 * Initializer
 * -------------------------------------------------------------- */

void Init_bluecloth_ext( void ) {
	bluecloth_cBlueCloth = rb_define_class( "BlueCloth", rb_cObject );

	mkd_with_html5_tags();
	mkd_initialize();

	rb_define_alloc_func( bluecloth_cBlueCloth, bluecloth_s_allocate );
	rb_define_singleton_method( bluecloth_cBlueCloth, "discount_version",
		bluecloth_s_discount_version, 0 );

	rb_define_method( bluecloth_cBlueCloth, "initialize", bluecloth_initialize, -1 );

	rb_define_method( bluecloth_cBlueCloth, "to_html", bluecloth_to_html, 0 );
	rb_define_method( bluecloth_cBlueCloth, "header", bluecloth_header, 0 );
	rb_define_alias( bluecloth_cBlueCloth, "pandoc_header", "header" );

	/* The original Markdown text the object was constructed with */
	rb_define_attr( bluecloth_cBlueCloth, "text", 1, 0 );

	/* The options hash that describes the options in effect when the object was created */
	rb_define_attr( bluecloth_cBlueCloth, "options", 1, 0 );


	/* --- Constants ----- */

	/* Do not process `[]' and remove A tags from the output. */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NOLINKS",  INT2FIX(MKD_NOLINKS) );

	/* Do not process `![]' and remove IMG tags from the output. */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NOIMAGE",  INT2FIX(MKD_NOIMAGE) );

	/* Do not do Smartypants-style mangling of quotes, dashes, or ellipses. */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NOPANTS",  INT2FIX(MKD_NOPANTS) );

	/* Escape all opening angle brackets in the input text instead of allowing block-level HTML */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NOHTML",   INT2FIX(MKD_NOHTML) );

	/* disable SUPERSCRIPT, RELAXED_EMPHASIS */
	rb_define_const( bluecloth_cBlueCloth, "MKD_STRICT",   INT2FIX(MKD_STRICT) );

	/* process text inside an html tag; no <em>, no <bold>, no html or [] expansion */
	rb_define_const( bluecloth_cBlueCloth, "MKD_TAGTEXT",  INT2FIX(MKD_TAGTEXT) );

	/* don't allow pseudo-protocols */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NO_EXT",   INT2FIX(MKD_NO_EXT) );

	/* Generate code for xml ![CDATA[...]] */
	rb_define_const( bluecloth_cBlueCloth, "MKD_CDATA", INT2FIX(MKD_CDATA) );

	/* Don't use superscript extension */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NOSUPERSCRIPT", INT2FIX(MKD_NOSUPERSCRIPT) );

	/* Relaxed emphasis -- emphasis happens everywhere */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NORELAXED", INT2FIX(MKD_NORELAXED) );

	/* disallow tables */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NOTABLES", INT2FIX(MKD_NOTABLES) );

	/* forbid ~~strikethrough~~ */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NOSTRIKETHROUGH", INT2FIX(MKD_NOSTRIKETHROUGH) );

	/* do table-of-contents processing */
	rb_define_const( bluecloth_cBlueCloth, "MKD_TOC",      INT2FIX(MKD_TOC) );

	/* MarkdownTest 1.0 Compatibility Mode */
	rb_define_const( bluecloth_cBlueCloth, "MKD_1_COMPAT", INT2FIX(MKD_1_COMPAT) );

	/* MKD_NOLINKS|MKD_NOIMAGE|MKD_TAGTEXT */
	rb_define_const( bluecloth_cBlueCloth, "MKD_EMBED",    INT2FIX(MKD_EMBED) );

	/* Create links for inline URIs */
	rb_define_const( bluecloth_cBlueCloth, "MKD_AUTOLINK", INT2FIX(MKD_AUTOLINK) );

	/* Be paranoid about link protocols */
	rb_define_const( bluecloth_cBlueCloth, "MKD_SAFELINK", INT2FIX(MKD_SAFELINK) );

	/* don't process header blocks */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NOHEADER", INT2FIX(MKD_NOHEADER) );

	/* Expand tabs to 4 spaces */
	rb_define_const( bluecloth_cBlueCloth, "MKD_TABSTOP", INT2FIX(MKD_TABSTOP) );

	/* Forbid '>%class%' blocks */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NODIVQUOTE", INT2FIX(MKD_NODIVQUOTE) );

	/* Forbid alphabetic lists */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NOALPHALIST", INT2FIX(MKD_NOALPHALIST) );

	/* Forbid definition lists */
	rb_define_const( bluecloth_cBlueCloth, "MKD_NODLIST", INT2FIX(MKD_NODLIST) );

	/* Markdown-extra Footnotes */
	rb_define_const( bluecloth_cBlueCloth, "MKD_EXTRA_FOOTNOTE", INT2FIX(MKD_EXTRA_FOOTNOTE) );


	/* Make sure the Ruby side is loaded */
	rb_require( "bluecloth" );

	bluecloth_default_opthash = rb_const_get( bluecloth_cBlueCloth, rb_intern("DEFAULT_OPTIONS") );
}

