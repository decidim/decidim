module Decidim
  class UserSuspension < ApplicationRecord
    MINIMUM_JUSTIFICATION_LENGTH = 10

    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    belongs_to :suspending_user, class_name: "Decidim::User"

    # validates :justification, presence: true, length: { minimum: MINIMUM_JUSTIFICATION_LENGTH }
  end
end
