$:.unshift '../lib'

require 'shinmun'

RSpec.describe Shinmun::TypeScriptEmbed do

  describe '.process' do
    it 'should pass through content without typescript blocks' do
      src = "# Hello\n\nSome content here."
      expect(Shinmun::TypeScriptEmbed.process(src)).to eq(src)
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
      
      # Extract the container id
      src.match(Shinmun::TypeScriptEmbed::TYPESCRIPT_PATTERN) do |match|
        expect($1).to eq('my-app')
      end
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
      
      # Extract the code
      src.match(Shinmun::TypeScriptEmbed::TYPESCRIPT_PATTERN)
      code = $2.gsub(/^(?:    |\t)/, '').rstrip
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
end
