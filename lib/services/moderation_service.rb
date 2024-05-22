module Services
  class ModerationService
    def initialize(reply_content)
      @reply_content = reply_content
      @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    end

    def is_acceptable?
      response = send_to_chat_gpt
      parse_response(response)
    end

    private

    def send_to_chat_gpt
      @client.chat(
        parameters: {
          model: 'gpt-4',
          messages: [chat_moderation_message],
          functions: [
            chat_moderation_function
          ],
          temperature: 0.5
        }
      )
    end

    def chat_moderation_message
      { "content": moderation_prompt(@reply_content),
        "role": 'user' }
    end

    def moderation_prompt(text)
      "Post Content: #{text}

      Automated Analysis and Decision:

      Check for Inappropriate Language:
      Search for swear words, offensive language, or inappropriate language.
      Verify against non-english swear words as well.
      Scan for Sexual Content:
      Identify any sexual references, implications, or innuendos.
      Assess for Threatening or Violent Behavior:
      Detect any threats (direct or indirect) or mentions of violence.
      Examine for Hate Speech or Discrimination:
      Look for hate speech or discriminatory remarks based on race, gender, religion, etc.

      Moderation Decision:

      If any of the above checks are positive, return 'Reject'.
      If none of the above issues are present, return 'Accept'."
    end

    def chat_moderation_function
      {
        name: 'content_acceptable',
        description: 'Moderate the content. It accepts one of two strings: "Accept" or "Reject".',
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

    def content_acceptable(decision:)
      case decision
      when 'Accept'
        true
      when 'Reject'
        false
      else
        false
      end
    end
  end
end
