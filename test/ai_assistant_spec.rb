$:.unshift '../lib'

require 'shinmun'

RSpec.describe Shinmun::AIAssistant do
  describe '#initialize' do
    it 'detects Anthropic provider when ANTHROPIC_API_KEY is set' do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('test-key')
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
      
      ai = Shinmun::AIAssistant.new
      expect(ai.provider).to eq(:anthropic)
      expect(ai.available?).to be true
    end

    it 'detects OpenAI provider when OPENAI_API_KEY is set' do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return('test-key')
      
      ai = Shinmun::AIAssistant.new
      expect(ai.provider).to eq(:openai)
      expect(ai.available?).to be true
    end

    it 'prefers Anthropic when both keys are set' do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('anthropic-key')
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return('openai-key')
      
      ai = Shinmun::AIAssistant.new
      expect(ai.provider).to eq(:anthropic)
    end

    it 'is not available when no API keys are set' do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
      
      ai = Shinmun::AIAssistant.new
      expect(ai.provider).to be_nil
      expect(ai.available?).to be false
    end

    it 'treats empty string API key as not set' do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('')
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return('')
      
      ai = Shinmun::AIAssistant.new
      expect(ai.available?).to be false
    end
  end

  describe '#generate_draft' do
    let(:ai) { Shinmun::AIAssistant.new }

    before do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
    end

    it 'raises ConfigurationError when no API key is available' do
      expect { ai.generate_draft('Test Title') }
        .to raise_error(Shinmun::AIAssistant::ConfigurationError, /No AI API key configured/)
    end
  end

  describe '#analyze_content' do
    let(:ai) { Shinmun::AIAssistant.new }

    before do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
    end

    it 'raises ConfigurationError when no API key is available' do
      expect { ai.analyze_content('Some blog content') }
        .to raise_error(Shinmun::AIAssistant::ConfigurationError, /No AI API key configured/)
    end
  end

  describe '#generate_description' do
    let(:ai) { Shinmun::AIAssistant.new }

    before do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
    end

    it 'raises ConfigurationError when no API key is available' do
      expect { ai.generate_description('Title', 'Body content') }
        .to raise_error(Shinmun::AIAssistant::ConfigurationError, /No AI API key configured/)
    end
  end

  describe '#suggest_tags' do
    let(:ai) { Shinmun::AIAssistant.new }

    before do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
    end

    it 'raises ConfigurationError when no API key is available' do
      expect { ai.suggest_tags('Body content') }
        .to raise_error(Shinmun::AIAssistant::ConfigurationError, /No AI API key configured/)
    end
  end

  describe 'JSON parsing' do
    let(:ai) { Shinmun::AIAssistant.new }

    before do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('test-key')
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
    end

    it 'parses valid JSON response' do
      json_response = '{"body": "Test body", "category": "Ruby", "tags": "ruby, test", "description": "A test post"}'
      result = ai.send(:parse_json_response, json_response)
      
      expect(result[:body]).to eq('Test body')
      expect(result[:category]).to eq('Ruby')
      expect(result[:tags]).to eq('ruby, test')
      expect(result[:description]).to eq('A test post')
    end

    it 'parses JSON wrapped in markdown code blocks' do
      json_response = "```json\n{\"body\": \"Test\", \"category\": \"Ruby\"}\n```"
      result = ai.send(:parse_json_response, json_response)
      
      expect(result[:body]).to eq('Test')
      expect(result[:category]).to eq('Ruby')
    end

    it 'handles partial JSON results' do
      json_response = '{"category": "Ruby", "tags": "ruby"}'
      result = ai.send(:parse_json_response, json_response)
      
      expect(result[:body]).to be_nil
      expect(result[:category]).to eq('Ruby')
      expect(result[:tags]).to eq('ruby')
    end

    it 'raises APIError on invalid JSON' do
      expect { ai.send(:parse_json_response, 'not valid json') }
        .to raise_error(Shinmun::AIAssistant::APIError, /Failed to parse AI response/)
    end
  end
end
