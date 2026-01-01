# TypeScript embedding for Shinmun pages
# Allows embedding runnable TypeScript mini apps in markdown content
#
# Usage in markdown:
#   @@typescript
#
#   const greeting: string = "Hello, World!";
#   document.body.innerHTML = `<h1>${greeting}</h1>`;
#
# This will compile the TypeScript to JavaScript and embed it as a
# <script type="module"> block that runs when the page loads.
#
# For mini apps that need a container element, use:
#   @@typescript[app]
#
#   const container = document.getElementById('app')!;
#   container.innerHTML = '<p>Mini app content</p>';
#
# This creates a <div id="app"></div> container before the script.

require 'open3'
require 'tempfile'
require 'json'

module Shinmun
  module TypeScriptEmbed
    # Pattern for TypeScript blocks with optional container ID
    # Format: @@typescript or @@typescript[container-id]
    #
    # Pattern breakdown:
    # ^(?:[ ]{4}|\t)  - Line starts with 4 spaces or tab (indented code block)
    # @@typescript    - Literal marker for TypeScript blocks
    # (?:\[([a-zA-Z][\w-]*)\])?  - Optional container ID in brackets (captured in group 1)
    # \n\n            - Followed by blank line
    # (.*?)           - Non-greedy capture of code content (captured in group 2)
    # \n\n            - Ends with blank line
    #
    # Uses same pattern style as KramdownRouge for consistency
    TYPESCRIPT_PATTERN = /^(?:[ ]{4}|\t)@@typescript(?:\[([a-zA-Z][\w-]*)\])?\n\n(.*?)\n\n/m

    class << self
      # Check if esbuild is available
      def esbuild_available?
        return @esbuild_available if defined?(@esbuild_available)
        @esbuild_available = system('which esbuild > /dev/null 2>&1') ||
                             system('npx esbuild --version > /dev/null 2>&1')
      end

      # Compile TypeScript to JavaScript using esbuild
      def compile_typescript(code)
        # Create a temporary file for the TypeScript code
        ts_file = Tempfile.new(['shinmun', '.ts'])
        begin
          ts_file.write(code)
          ts_file.close

          # Try esbuild first (direct or via npx)
          stdout, stderr, status = Open3.capture3(
            'npx', 'esbuild', ts_file.path,
            '--format=esm',
            '--target=es2020',
            '--bundle=false'
          )

          if status.success?
            stdout
          else
            raise CompilationError, "TypeScript compilation failed: #{stderr}"
          end
        ensure
          ts_file.unlink
        end
      end

      # Process markdown source to convert @@typescript blocks to embedded scripts
      def process(src)
        return src unless src =~ TYPESCRIPT_PATTERN

        src.gsub(TYPESCRIPT_PATTERN) do
          # Use Regexp.last_match to avoid global variable warnings
          match_data = Regexp.last_match
          container_id = match_data[1]
          code = match_data[2]
          # Strip leading indentation from the code (4 spaces or tab)
          code = code.gsub(/^(?:    |\t)/, '')

          begin
            js_code = compile_typescript(code)
            generate_html(js_code, container_id)
          rescue StandardError => e
            # On compilation failure, show error message
            error_html(code, e.message)
          end
        end
      end

      private

      # Generate HTML for the embedded script
      def generate_html(js_code, container_id)
        html = "\n\n"

        # Add container div if specified
        if container_id
          html += "<div id=\"#{container_id}\"></div>\n"
        end

        # Wrap JavaScript in a module script
        html += "<script type=\"module\">\n#{js_code}</script>\n\n"
        html
      end

      # Generate error HTML when compilation fails
      def error_html(code, error_message)
        escaped_code = html_escape(code)
        escaped_error = html_escape(error_message)

        <<~HTML

          <div class="typescript-error" style="background: #fee; border: 1px solid #c00; padding: 1em; margin: 1em 0;">
            <strong>TypeScript compilation error:</strong>
            <pre style="color: #c00;">#{escaped_error}</pre>
            <details>
              <summary>Source code</summary>
              <pre>#{escaped_code}</pre>
            </details>
          </div>

        HTML
      end

      def html_escape(s)
        s.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
      end
    end

    class CompilationError < StandardError; end
  end
end
