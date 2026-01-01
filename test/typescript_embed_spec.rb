$:.unshift '../lib'

require 'shinmun'
require 'tmpdir'

RSpec.describe Shinmun::TypeScriptEmbed do

  describe '.process' do
    it 'should pass through content without typescript blocks' do
      src = "# Hello\n\nSome content here."
      expect(Shinmun::TypeScriptEmbed.process(src)).to eq(src)
    end

    it 'should not process typescript blocks inside fenced code blocks' do
      src = <<~MARKDOWN
        # Hello

        ```markdown
            @@typescript[demo]

            const x: number = 1;

        ```

        More content
      MARKDOWN

      # Fenced code blocks should be preserved as-is
      result = Shinmun::TypeScriptEmbed.process(src)
      
      # Should NOT contain compiled script
      expect(result).not_to include('<script type="module">')
      # Should still contain the original fenced block with @@typescript
      expect(result).to include('@@typescript[demo]')
      expect(result).to include('```markdown')
    end

    it 'should detect typescript block pattern' do
      src = <<~MARKDOWN
        # Hello

            @@typescript

            const x: number = 1;

        More content
      MARKDOWN

      # The pattern should match the typescript block
      expect(src).to match(Shinmun::TypeScriptEmbed::TYPESCRIPT_PATTERN)
    end

    it 'should detect typescript block with container id' do
      src = <<~MARKDOWN
        # Hello

            @@typescript[my-app]

            const x: number = 1;

        More content
      MARKDOWN

      expect(src).to match(Shinmun::TypeScriptEmbed::TYPESCRIPT_PATTERN)
      
      # Extract the container id using match object
      match = src.match(Shinmun::TypeScriptEmbed::TYPESCRIPT_PATTERN)
      expect(match[1]).to eq('my-app')
    end

    it 'should capture multiline indented code blocks' do
      src = <<~MARKDOWN
        # Hello

            @@typescript[app]

            interface User {
              name: string;
            }
            
            const user: User = { name: "Alice" };

        More content
      MARKDOWN

      expect(src).to match(Shinmun::TypeScriptEmbed::TYPESCRIPT_PATTERN)
      
      # Extract the code using match object
      match = src.match(Shinmun::TypeScriptEmbed::TYPESCRIPT_PATTERN)
      code = match[2].gsub(/^(?:    |\t)/, '').rstrip
      expect(code).to include('interface User')
      expect(code).to include('const user')
    end

    context 'with esbuild available', :integration do
      before(:each) do
        skip 'esbuild not available' unless system('npx esbuild --version > /dev/null 2>&1')
      end

      it 'should compile and embed simple typescript' do
        src = <<~MARKDOWN
          # Hello

              @@typescript

              const greeting: string = "Hello";
              console.log(greeting);

          More content
        MARKDOWN

        result = Shinmun::TypeScriptEmbed.process(src)
        
        expect(result).to include('<script type="module">')
        expect(result).to include('</script>')
        expect(result).to include('const greeting = "Hello"')
        expect(result).to include('console.log(greeting)')
      end

      it 'should add container div when specified' do
        src = <<~MARKDOWN
          # Hello

              @@typescript[app]

              const x: number = 1;

          More content
        MARKDOWN

        result = Shinmun::TypeScriptEmbed.process(src)
        
        expect(result).to include('<div id="app"></div>')
        expect(result).to include('<script type="module">')
      end

      it 'should handle complex container ids' do
        src = <<~MARKDOWN
          Test

              @@typescript[my-cool-app123]

              const test = true;

          End
        MARKDOWN

        result = Shinmun::TypeScriptEmbed.process(src)
        
        expect(result).to include('<div id="my-cool-app123"></div>')
      end

      it 'should preserve non-typescript content' do
        src = <<~MARKDOWN
          # Title

          Some paragraph text.

              @@typescript

              const x = 1;

          Another paragraph.
        MARKDOWN

        result = Shinmun::TypeScriptEmbed.process(src)
        
        expect(result).to include('# Title')
        expect(result).to include('Some paragraph text.')
        expect(result).to include('Another paragraph.')
      end

      it 'should compile multiline TypeScript with interfaces' do
        src = <<~MARKDOWN
          # Test

              @@typescript[app]

              interface User {
                name: string;
                age: number;
              }
              
              const user: User = { name: "Alice", age: 30 };
              console.log(user);

          End
        MARKDOWN

        result = Shinmun::TypeScriptEmbed.process(src)
        
        expect(result).to include('<div id="app"></div>')
        expect(result).to include('<script type="module">')
        expect(result).to include('const user = { name: "Alice", age: 30 }')
        expect(result).not_to include('interface User')  # TypeScript interfaces are removed
      end
    end
  end

  describe '.compile_typescript' do
    context 'with esbuild available', :integration do
      before(:each) do
        skip 'esbuild not available' unless system('npx esbuild --version > /dev/null 2>&1')
      end

      it 'should compile simple TypeScript' do
        ts_code = 'const x: number = 42;'
        js_code = Shinmun::TypeScriptEmbed.compile_typescript(ts_code)
        
        expect(js_code).to include('const x = 42')
        expect(js_code).not_to include(': number')
      end

      it 'should compile TypeScript with type annotations' do
        ts_code = <<~TS
          interface User {
            name: string;
            age: number;
          }
          
          const user: User = { name: "Alice", age: 30 };
        TS
        
        js_code = Shinmun::TypeScriptEmbed.compile_typescript(ts_code)
        
        expect(js_code).not_to include('interface')
        expect(js_code).to include('const user = { name: "Alice", age: 30 }')
      end

      it 'should handle arrow functions with type annotations' do
        ts_code = 'const add = (a: number, b: number): number => a + b;'
        js_code = Shinmun::TypeScriptEmbed.compile_typescript(ts_code)
        
        expect(js_code).to include('const add = (a, b) => a + b')
      end
    end
  end

  describe 'file references' do
    it 'should detect typescript file reference pattern' do
      src = <<~MARKDOWN
        # Hello

            @@typescript-file[my-app](public/apps/test.tsx)

        More content
      MARKDOWN

      expect(src).to match(Shinmun::TypeScriptEmbed::TYPESCRIPT_FILE_PATTERN)
      
      match = src.match(Shinmun::TypeScriptEmbed::TYPESCRIPT_FILE_PATTERN)
      expect(match[1]).to eq('my-app')
      expect(match[2]).to eq('public/apps/test.tsx')
    end

    it 'should handle file paths with various characters' do
      src = <<~MARKDOWN
        Test

            @@typescript-file[app](public/apps/my-component.tsx)

        End
      MARKDOWN

      match = src.match(Shinmun::TypeScriptEmbed::TYPESCRIPT_FILE_PATTERN)
      expect(match[2]).to eq('public/apps/my-component.tsx')
    end

    context 'with esbuild available', :integration do
      before(:each) do
        skip 'esbuild not available' unless system('npx esbuild --version > /dev/null 2>&1')
      end

      it 'should compile a TypeScript file' do
        # Create a temporary test file
        test_dir = File.join(Dir.tmpdir, 'shinmun-test')
        FileUtils.mkdir_p(test_dir)
        File.write("#{test_dir}/test.ts", 'const x: number = 42; console.log(x);')

        Shinmun::TypeScriptEmbed.base_path = test_dir
        js_code = Shinmun::TypeScriptEmbed.compile_typescript_file('test.ts')
        
        # esbuild may convert const to var when bundling
        expect(js_code).to match(/(?:const|var) x = 42/)
        expect(js_code).to include('console.log(x)')
      ensure
        FileUtils.rm_rf(test_dir)
      end

      it 'should process file references in markdown' do
        test_dir = File.join(Dir.tmpdir, 'shinmun-test')
        FileUtils.mkdir_p(test_dir)
        File.write("#{test_dir}/app.ts", 'const msg: string = "Hello"; console.log(msg);')

        src = <<~MARKDOWN
          # Test

              @@typescript-file[app](app.ts)

          End
        MARKDOWN

        result = Shinmun::TypeScriptEmbed.process(src, base_path: test_dir)
        
        expect(result).to include('<div id="app"></div>')
        expect(result).to include('<script type="module">')
        # esbuild may convert const to var when bundling
        expect(result).to match(/(?:const|var) msg = "Hello"/)
      ensure
        FileUtils.rm_rf(test_dir)
      end

      it 'should show error for missing files' do
        src = <<~MARKDOWN
          # Test

              @@typescript-file[app](nonexistent.tsx)

          End
        MARKDOWN

        result = Shinmun::TypeScriptEmbed.process(src, base_path: Dir.tmpdir)
        
        expect(result).to include('typescript-error')
        expect(result).to include('not found')
      end

      it 'should raise error in strict mode for missing files' do
        src = <<~MARKDOWN
          # Test

              @@typescript-file[app](nonexistent.tsx)

          End
        MARKDOWN

        expect {
          Shinmun::TypeScriptEmbed.process(src, base_path: Dir.tmpdir, strict: true)
        }.to raise_error(Shinmun::TypeScriptEmbed::CompilationError, /not found/)
      end

      it 'should raise error when SHINMUN_STRICT_TYPESCRIPT env var is set' do
        src = <<~MARKDOWN
          # Test

              @@typescript-file[app](nonexistent.tsx)

          End
        MARKDOWN

        ENV['SHINMUN_STRICT_TYPESCRIPT'] = '1'
        begin
          expect {
            Shinmun::TypeScriptEmbed.process(src, base_path: Dir.tmpdir)
          }.to raise_error(Shinmun::TypeScriptEmbed::CompilationError, /not found/)
        ensure
          ENV.delete('SHINMUN_STRICT_TYPESCRIPT')
        end
      end
    end
  end
end
