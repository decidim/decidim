# frozen_string_literal: true

module Decidim
  module Gamification
    class BadgeScore < ApplicationRecord
      self.table_name = "decidim_gamification_badge_scores"

      belongs_to :user, class_name: "Decidim::UserBaseEntity"
      validates :value, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end
