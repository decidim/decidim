# frozen_string_literal: true

module Decidim
  # A reportable can be reported one time for each user.
  class Report < ApplicationRecord
    REASONS = %w(spam offensive does_not_belong).freeze

    belongs_to :moderation, foreign_key: "decidim_moderation_id", class_name: "Decidim::Moderation"
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    validates :reason, presence: true
    validates :user, uniqueness: { scope: :decidim_moderation_id }
    validates :reason, inclusion: { in: REASONS }
    validate :user_and_moderation_same_organization

    private

    # Private: check if the moderation and the user have the same organization
    def user_and_moderation_same_organization
      return if !moderation || !user
      errors.add(:moderation, :invalid) unless user.organization == moderation.organization
    end
  end
end
