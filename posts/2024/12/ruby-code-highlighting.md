---
date: 2024-12-15
category: Ruby
tags: ruby, code, syntax-highlighting
title: Beautiful Code Highlighting with CodeRay
---
One of the great features of Shinmun is its built-in syntax highlighting powered by CodeRay.

When writing technical blog posts, having beautiful code examples is essential. Shinmun makes this easy with its CodeRay integration.

## How to Use Code Blocks

To add syntax-highlighted code, simply prefix your code block with `@@` followed by the language name, then a blank line, then the code indented by 4 spaces:

    @@ruby

    class HelloWorld
      def greet(name)
        puts "Hello, #{name}!"
      end
    end
    
    greeter = HelloWorld.new
    greeter.greet("World")

## Supported Languages

CodeRay supports many popular programming languages including:

- Ruby
- JavaScript
- Python
- HTML
- CSS
- JSON
- YAML
- And many more!

## JavaScript Example

Here's how JavaScript code looks:

    @@javascript

    function fibonacci(n) {
      if (n <= 1) return n;
      return fibonacci(n - 1) + fibonacci(n - 2);
    }
    
    console.log(fibonacci(10)); // Output: 55

## Conclusion

With Shinmun's CodeRay integration, your code examples will always look professional and readable!
