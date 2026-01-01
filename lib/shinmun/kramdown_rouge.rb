# Rouge extension for Kramdown
# Provides a wrapper module to process code blocks with syntax highlighting

module Shinmun
  module KramdownRouge
    CODE_BLOCK_PATTERN = /^(?:[ ]{4}|\t)@@(\w+)\n\n(.*?)\n\n/m

    class << self
      # Pre-process markdown source to convert @@language code blocks
      # to highlighted HTML before Kramdown processing
      def preprocess(src, formatter = nil)
        fmt = formatter || Rouge::Formatters::HTML.new
        src.gsub(CODE_BLOCK_PATTERN) do |_|
          language = $1
          code = $2
          # Strip leading indentation from the code
          code = code.gsub(/^    /, '')
          lexer = Rouge::Lexer.find(language) || Rouge::Lexers::PlainText.new
          highlighted = fmt.format(lexer.lex(code))
          "\n\n<div class=\"highlight\"><pre>#{highlighted}</pre></div>\n\n"
        end
      end

      # Process markdown with optional Rouge highlighting
      # If the source contains @@language patterns, pre-process them
      def process(src, options = {})
        if src =~ CODE_BLOCK_PATTERN
          preprocess(src, options[:formatter])
        else
          src
        end
      end
    end
  end
end
