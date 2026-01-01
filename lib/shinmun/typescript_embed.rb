# TypeScript embedding for Shinmun pages
# Allows embedding runnable TypeScript mini apps in markdown content
#
# Usage in markdown (inline code):
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
#
# To reference an external TypeScript/TSX file:
#   @@typescript-file[app](public/apps/my-component.tsx)
#
# This reads and compiles the file, bundling any imports (great for React).

require 'open3'
require 'tempfile'
require 'json'

module Shinmun
  module TypeScriptEmbed
    # Pattern for inline TypeScript blocks with optional container ID
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

    # Pattern for TypeScript file references with container ID and file path
    # Format: @@typescript-file[container-id](path/to/file.tsx)
    #
    # Pattern breakdown:
    # ^(?:[ ]{4}|\t)  - Line starts with 4 spaces or tab (indented code block)
    # @@typescript-file  - Literal marker for file references
    # \[([a-zA-Z][\w-]*)\]  - Required container ID in brackets (captured in group 1)
    # \(([^)]+)\)     - File path in parentheses (captured in group 2)
    # \n\n            - Ends with blank line
    TYPESCRIPT_FILE_PATTERN = /^(?:[ ]{4}|\t)@@typescript-file\[([a-zA-Z][\w-]*)\]\(([^)]+)\)\n\n/m

    class << self
      attr_accessor :base_path

      # Check if esbuild is available
      def esbuild_available?
        return @esbuild_available if defined?(@esbuild_available)
        @esbuild_available = system('which esbuild > /dev/null 2>&1') ||
                             system('npx esbuild --version > /dev/null 2>&1')
      end

      # Compile TypeScript to JavaScript using esbuild
      # @param code [String] TypeScript source code
      # @param options [Hash] Compilation options
      # @option options [Boolean] :bundle Whether to bundle imports (default: false)
      # @option options [Boolean] :jsx Whether to enable JSX support (default: false)
      # @option options [String] :working_dir Working directory for resolving imports
      def compile_typescript(code, options = {})
        bundle = options.fetch(:bundle, false)
        jsx = options.fetch(:jsx, false)
        working_dir = options[:working_dir]

        # Determine file extension based on JSX support
        ext = jsx ? '.tsx' : '.ts'
        ts_file = Tempfile.new(['shinmun', ext])

        begin
          ts_file.write(code)
          ts_file.close

          args = [
            'npx', 'esbuild', ts_file.path,
            '--format=esm',
            '--target=es2020'
          ]

          # Add bundling options for React/imports
          if bundle
            args << '--bundle'
            # Use CDN for external packages (React, etc.)
            args << '--external:react'
            args << '--external:react-dom'
          end

          # Enable JSX transformation
          if jsx
            args << '--jsx=automatic'
          end

          env = {}
          if working_dir
            env['PWD'] = working_dir
          end

          stdout, stderr, status = Open3.capture3(env, *args, chdir: working_dir || Dir.pwd)

          if status.success?
            stdout
          else
            raise CompilationError, "TypeScript compilation failed: #{stderr}"
          end
        ensure
          ts_file.unlink
        end
      end

      # Compile a TypeScript file from the filesystem
      # @param file_path [String] Path to the TypeScript file (relative to base_path)
      # @param options [Hash] Additional compilation options
      def compile_typescript_file(file_path, options = {})
        full_path = if base_path
                      File.join(base_path, file_path)
                    else
                      file_path
                    end

        unless File.exist?(full_path)
          raise CompilationError, "TypeScript file not found: #{file_path}"
        end

        # Determine if JSX is needed based on file extension
        jsx = file_path.end_with?('.tsx', '.jsx')
        working_dir = File.dirname(full_path)

        # Read the file and compile it
        code = File.read(full_path)
        compile_typescript(code, options.merge(bundle: true, jsx: jsx, working_dir: working_dir))
      end

      # Process markdown source to convert @@typescript blocks to embedded scripts
      # @param src [String] Markdown source
      # @param options [Hash] Processing options
      # @option options [String] :base_path Base path for resolving file references
      def process(src, options = {})
        self.base_path = options[:base_path]
        result = src

        # Process file references first
        if result =~ TYPESCRIPT_FILE_PATTERN
          result = result.gsub(TYPESCRIPT_FILE_PATTERN) do
            match_data = Regexp.last_match
            container_id = match_data[1]
            file_path = match_data[2].strip

            begin
              js_code = compile_typescript_file(file_path)
              generate_html(js_code, container_id, jsx: file_path.end_with?('.tsx', '.jsx'))
            rescue StandardError => e
              error_html(file_path, e.message)
            end
          end
        end

        # Process inline TypeScript blocks
        if result =~ TYPESCRIPT_PATTERN
          result = result.gsub(TYPESCRIPT_PATTERN) do
            match_data = Regexp.last_match
            container_id = match_data[1]
            code = match_data[2]
            # Strip leading indentation from the code (4 spaces or tab)
            code = code.gsub(/^(?:    |\t)/, '')

            begin
              js_code = compile_typescript(code)
              generate_html(js_code, container_id)
            rescue StandardError => e
              error_html(code, e.message)
            end
          end
        end

        result
      end

      private

      # Generate HTML for the embedded script
      # @param js_code [String] Compiled JavaScript code
      # @param container_id [String, nil] Optional container element ID
      # @param options [Hash] Additional options
      # @option options [Boolean] :jsx Whether this is a React/JSX component
      def generate_html(js_code, container_id, options = {})
        html = "\n\n"

        # Add container div if specified
        if container_id
          html += "<div id=\"#{container_id}\"></div>\n"
        end

        # For React components, add import map for CDN imports
        if options[:jsx]
          html += <<~IMPORTMAP
            <script type="importmap">
            {
              "imports": {
                "react": "https://esm.sh/react@18",
                "react-dom": "https://esm.sh/react-dom@18",
                "react-dom/client": "https://esm.sh/react-dom@18/client",
                "react/jsx-runtime": "https://esm.sh/react@18/jsx-runtime"
              }
            }
            </script>
          IMPORTMAP
        end

        # Wrap JavaScript in a module script
        html += "<script type=\"module\">\n#{js_code}</script>\n\n"
        html
      end

      # Generate error HTML when compilation fails
      def error_html(source, error_message)
        escaped_source = html_escape(source)
        escaped_error = html_escape(error_message)

        <<~HTML

          <div class="typescript-error" style="background: #fee; border: 1px solid #c00; padding: 1em; margin: 1em 0;">
            <strong>TypeScript compilation error:</strong>
            <pre style="color: #c00;">#{escaped_error}</pre>
            <details>
              <summary>Source</summary>
              <pre>#{escaped_source}</pre>
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
