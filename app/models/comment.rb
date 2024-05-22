class Comment < ApplicationRecord
  include Visible
  belongs_to :article

  before_create :moderate_content

  private

  def moderate_content
    moderation_result = Services::ModerationService.new(body).is_acceptable?
    unless moderation_result
      errors.add(:body, 'Your comment does not meet our community guidelines.')
      throw(:abort)
    end
  end
end
