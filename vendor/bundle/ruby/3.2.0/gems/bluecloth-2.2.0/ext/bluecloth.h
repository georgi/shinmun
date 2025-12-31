/* 
 * BlueCloth -- a Ruby implementation of Markdown
 * $Id: bluecloth.h,v 055519ec5f78 2010/09/17 20:42:27 ged $
 * 
 */

#ifndef BLUECLOTH_H
#define BLUECLOTH_H

#include "config.h"
#include "assert.h"

#include "mkdio.h"
#include "ruby.h"

void mkd_initialize  		_(( void ));
void mkd_with_html5_tags	_(( void ));

#if defined(HAVE_RUBY_ENCODING_H) && HAVE_RUBY_ENCODING_H
#	define M17N_SUPPORTED
#	include "ruby/encoding.h"
#endif

/* Replace the macro from encoding.h that refers to static 'rb_encoding_list' */
#ifdef ENC_FROM_ENCINDEX
#undef ENC_FROM_ENCINDEX
#define ENC_FROM_ENCINDEX(idx) (rb_enc_from_index(idx))
#endif

#endif
