class BlueCloth

  CodeBlockPart = 

	def transform_code_blocks( str, rs )
		@log.debug " Transforming code blocks"

		str.gsub( CodeBlockRegexp ) {|block|
			codeblock = $1
			remainder = $2

      # Generate the codeblock
      if codeblock =~ /^(?:[ ]{4}|\t)@@(.*?)\n\n(.*)\n\n/m
         "\n\n<pre>%s</pre>\n\n%s" %
          [CodeRay.scan(outdent($2), $1).html(:css => :class, :line_numbers => :inline), remainder]
      else
         "\n\n<pre><code>%s\n</code></pre>\n\n%s" %
          [encode_code(outdent(codeblock), rs).rstrip, remainder]
      end
		}
	end

end
