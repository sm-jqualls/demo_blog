class Comment < ApplicationRecord
  include Visible
  belongs_to :article

  before_create :moderate_content

  private

  def moderate_content
    moderation_result = Services::ModerationService.new(body).moderate
    if moderation_result.downcase.include?('inappropriate')
      errors.add(:body, moderation_result)
      throw(:abort)
    end
  end
end
