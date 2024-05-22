class Comment < ApplicationRecord
  include Visible
  belongs_to :article

  before_create :moderate_content

  private

  def moderate_content
    moderation_result = Services::ModerationService.new(body).moderate
    if moderation_result[:error]
      errors.add(:body, moderation_result[:error])
      throw(:abort)
    end
  end
end
