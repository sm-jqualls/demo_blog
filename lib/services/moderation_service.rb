module Services
  class ModerationService
    def initialize(reply_content)
      @reply_content = reply_content
      @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    end

    def moderate
      response = send_to_chat_gpt
      parse_response(response)
    end

    private

    def send_to_chat_gpt
      @client.chat(
        parameters: {
          model: 'gpt-4',
          messages: [
            { "content": moderate_for_language_prompt(@reply_content), "role": 'user' },
            { "content": moderate_for_sexual_content_prompt(@reply_content), "role": 'user' }
          ],
          functions: [
            language_moderation_function,
            sexual_content_moderation_function
          ],
          temperature: 0.7
        }
      )
    end

    def moderate_for_language_prompt(text)
      "Post Content: #{text}

      Automated Analysis and Decision:

      Check for Inappropriate Language:
      Search for swear words, offensive language, or inappropriate language.
      Verify against non-english swear words as well.
      Moderation Decision:

      If any of the above checks are positive, return 'Reject'.
      If none of the above issues are present, return 'Accept'."
    end

    def moderate_for_sexual_content_prompt(text)
      "Post Content: #{text}

      Automated Analysis and Decision:

      Scan for Sexual Content:
      Identify any sexual references, implications, or innuendos.

      Moderation Decision:

      If any of the above checks are positive, return 'Reject'.
      If none of the above issues are present, return 'Accept'."
    end


    def language_moderation_function
      {
        name: 'moderate_language',
        description: 'Used to determine if language is acceptable. It accepts one of two strings: "Accept" or "Reject".',
        parameters: {
          type: 'object',
          properties: chat_moderation_properties,
          required: ['decision']
        }
      }
    end

    def sexual_content_moderation_function
      {
        name: 'moderate_sexual_content',
        description: 'Used to determine if post contains sexual content. It accepts one of two strings: "Accept" or "Reject".',
        parameters: {
          type: 'object',
          properties: chat_moderation_properties,
          required: ['decision']
        }
      }
    end

    def chat_moderation_properties
      {
        decision: {
          type: 'string',
          description: 'The decision to accept or reject',
          enum: %w[Accept Reject]
        }
      }
    end

    def parse_response(response)
      message = response.dig('choices', 0, 'message')

      return unless message['role'] == 'assistant' && message['function_call']

      function_name = message.dig('function_call', 'name')
      args =
        JSON.parse(
          message.dig('function_call', 'arguments'),
          { symbolize_names: true }
        )

      send(function_name, **args)
    end

    def moderate_language(decision:)
      case decision
      when 'Accept'
        {}
      when 'Reject'
        {error: 'Your comment contains inappropriate language.'}
      else
        {error: 'Your comment contains inappropriate language.'}
      end
    end

    def moderate_sexual_content(decision:)
      case decision
      when 'Accept'
        {}
      when 'Reject'
        {error: 'Your comment contains sexual content.'}
      else
        {error: 'Your comment contains sexual content.'}
      end
    end
  end
end
