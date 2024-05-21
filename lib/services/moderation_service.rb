module Services
  class ModerationService
    def initialize(reply_content)
      @reply_content = reply_content
      @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    end

    def moderate
      response = @client.chat(
        parameters: {
          model: 'gpt-4',
          messages: [
            { role: 'system', content: 'You are a content moderation assistant. Evaluate the following reply for inappropriate content.' },
            { role: 'user', content: @reply_content }
          ]
        }
      )

      parse_response(response)
    end

    private

    def parse_response(response)
      result = response.dig('choices', 0, 'message', 'content').strip
      result
    rescue JSON::ParserError
      'Error processing the moderation response'
    end
  end
end
