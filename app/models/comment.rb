class Comment < ApplicationRecord
  include Visible
  belongs_to :article

  before_create :moderate_content

  private

  def moderate_content
    moderation_results = Services::ModerationService.new(body).moderate
    if moderation_results[:flagged] == true
      categories = moderation_results[:categories].join(', ')
      errors.add(:body, "This comment has been flagged as inappropriate because it contains the following categories: #{categories}")
      throw(:abort)
    end
  end
end
