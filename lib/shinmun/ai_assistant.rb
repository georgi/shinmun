require 'ruby_llm'

module Shinmun
  # AI Assistant for generating blog content, auto-tagging, and SEO optimization.
  #
  # Uses the ruby_llm gem to support multiple LLM providers through a unified interface.
  # Configure API keys via environment variables:
  #   - OPENAI_API_KEY for OpenAI
  #   - ANTHROPIC_API_KEY for Anthropic (Claude)
  #
  # The assistant will automatically use whichever API key is available,
  # preferring Anthropic if both are set.
  class AIAssistant
    class Error < StandardError; end
    class ConfigurationError < Error; end
    class APIError < Error; end

    # Default models for each provider
    ANTHROPIC_MODEL = 'claude-sonnet-4-20250514'
    OPENAI_MODEL = 'gpt-4o'

    attr_reader :provider

    def initialize
      @openai_key = ENV['OPENAI_API_KEY']
      @anthropic_key = ENV['ANTHROPIC_API_KEY']

      if @anthropic_key && !@anthropic_key.empty?
        @provider = :anthropic
        @model = ANTHROPIC_MODEL
      elsif @openai_key && !@openai_key.empty?
        @provider = :openai
        @model = OPENAI_MODEL
      else
        @provider = nil
        @model = nil
      end

      configure_ruby_llm if available?
    end

    # Check if AI features are available
    def available?
      !@provider.nil?
    end

    # Generate a draft blog post with structured content
    #
    # @param title [String] The title of the post
    # @param options [Hash] Additional options
    # @option options [String] :category Suggested category
    # @option options [Array<String>] :categories Available categories to choose from
    # @return [Hash] Generated content with :body, :category, :tags, :description
    def generate_draft(title, options = {})
      ensure_available!

      categories_hint = if options[:categories]&.any?
        "Available categories: #{options[:categories].join(', ')}. Choose the most appropriate one."
      else
        "Suggest an appropriate category."
      end

      prompt = <<~PROMPT
        Write a blog post draft for the title: "#{title}"

        Requirements:
        - Write 3-4 well-structured paragraphs
        - The first paragraph should be a compelling summary/introduction
        - Use clear, engaging prose without marketing buzzwords
        - Include practical insights or actionable information
        - Use Markdown formatting (headers, lists, code blocks if relevant)

        #{categories_hint}

        Also provide:
        - 3-5 relevant tags (comma-separated)
        - A concise SEO description (150-160 characters) for search engines

        Format your response as JSON with these keys:
        {
          "body": "The markdown body of the post",
          "category": "Single category name",
          "tags": "tag1, tag2, tag3",
          "description": "SEO meta description"
        }

        Return only valid JSON, no additional text.
      PROMPT

      response = call_llm(prompt)
      parse_json_response(response)
    end

    # Analyze existing post content and suggest metadata
    #
    # @param body [String] The post body content
    # @param options [Hash] Additional options
    # @option options [Array<String>] :categories Available categories
    # @return [Hash] Suggested metadata with :category, :tags, :description
    def analyze_content(body, options = {})
      ensure_available!

      categories_hint = if options[:categories]&.any?
        "Available categories: #{options[:categories].join(', ')}. Choose the most appropriate one."
      else
        "Suggest an appropriate category."
      end

      prompt = <<~PROMPT
        Analyze this blog post content and suggest metadata:

        ---
        #{body[0, 4000]}
        ---

        #{categories_hint}

        Provide:
        - The single most appropriate category
        - 3-5 relevant tags (comma-separated, lowercase)
        - A concise SEO description (150-160 characters) summarizing the content

        Format your response as JSON:
        {
          "category": "Single category name",
          "tags": "tag1, tag2, tag3",
          "description": "SEO meta description"
        }

        Return only valid JSON, no additional text.
      PROMPT

      response = call_llm(prompt)
      parse_json_response(response)
    end

    # Generate only an SEO description for existing content
    #
    # @param title [String] Post title
    # @param body [String] Post body
    # @return [String] SEO description
    def generate_description(title, body)
      ensure_available!

      prompt = <<~PROMPT
        Generate an SEO meta description for this blog post.

        Title: #{title}
        Content preview: #{body[0, 2000]}

        Requirements:
        - 150-160 characters maximum
        - Summarize the main value/topic
        - Include relevant keywords naturally
        - Be compelling for search result clicks

        Return only the description text, nothing else.
      PROMPT

      call_llm(prompt).strip
    end

    # Suggest tags based on content
    #
    # @param body [String] Post body
    # @return [String] Comma-separated tags
    def suggest_tags(body)
      ensure_available!

      prompt = <<~PROMPT
        Analyze this blog post and suggest 3-5 relevant tags.

        Content: #{body[0, 3000]}

        Requirements:
        - Tags should be lowercase
        - Use common, searchable terms
        - Be specific to the content

        Return only comma-separated tags, nothing else.
        Example: ruby, web development, performance
      PROMPT

      call_llm(prompt).strip.downcase
    end

    private

    def configure_ruby_llm
      RubyLLM.configure do |config|
        config.openai_api_key = @openai_key if @openai_key
        config.anthropic_api_key = @anthropic_key if @anthropic_key
      end
    end

    def ensure_available!
      unless available?
        raise ConfigurationError, <<~MSG
          No AI API key configured. Set one of these environment variables:
            - ANTHROPIC_API_KEY for Claude
            - OPENAI_API_KEY for GPT-4
        MSG
      end
    end

    def call_llm(prompt)
      chat = RubyLLM.chat(model: @model)
      response = chat.ask(prompt)
      response.content
    rescue => e
      raise APIError, "LLM API error: #{e.message}"
    end

    def parse_json_response(response)
      # Extract JSON from response (handle markdown code blocks)
      json_str = response.gsub(/```json\n?/, '').gsub(/```\n?/, '').strip

      begin
        result = JSON.parse(json_str)
        # Only include fields that were returned by the API (remove nil values)
        {
          body: result['body'],
          category: result['category'],
          tags: result['tags'],
          description: result['description']
        }.compact
      rescue JSON::ParserError => e
        raise APIError, "Failed to parse AI response as JSON: #{e.message}\nResponse: #{response[0, 500]}"
      end
    end
  end
end
