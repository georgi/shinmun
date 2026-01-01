# CodeRay extension for Kramdown
# Provides a wrapper module to process code blocks with syntax highlighting

module Shinmun
  module KramdownCodeRay
    CODE_BLOCK_PATTERN = /^(?:[ ]{4}|\t)@@(\w+)\n\n(.*?)\n\n/m

    class << self
      attr_accessor :code_css

      # Pre-process markdown source to convert @@language code blocks
      # to highlighted HTML before Kramdown processing
      def preprocess(src)
        code_css_setting = code_css || :class
        src.gsub(CODE_BLOCK_PATTERN) do |_|
          language = $1
          code = $2
          # Strip leading indentation from the code
          code = code.gsub(/^    /, '')
          highlighted = CodeRay.scan(code, language.to_sym).html(:css => code_css_setting, :line_numbers => nil)
          "\n\n<div class=\"CodeRay\"><pre>#{highlighted}</pre></div>\n\n"
        end
      end

      # Process markdown with optional CodeRay highlighting
      # If the source contains @@language patterns, pre-process them
      def process(src, options = {})
        self.code_css = options[:code_css]
        if src =~ CODE_BLOCK_PATTERN
          preprocess(src)
        else
          src
        end
      end
    end
  end
end
