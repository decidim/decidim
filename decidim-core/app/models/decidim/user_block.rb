# frozen_string_literal: true

module Decidim
  class UserBlock < ApplicationRecord
    # temporary code until migrations are changed
    self.table_name = "decidim_user_suspensions"
    MINIMUM_JUSTIFICATION_LENGTH = 10

    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    belongs_to :suspending_user, class_name: "Decidim::User"
  end
end
