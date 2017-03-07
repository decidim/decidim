# frozen_string_literal: true
module Decidim
  # A reportable can be reported one time for each user.
  class Report < ApplicationRecord
    REASONS = %w(spam offensive does_not_belong).freeze

    belongs_to :reportable, foreign_key: "decidim_reportable_id", foreign_type: "decidim_reportable_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: Decidim::User

    validates :reportable, :user, :reason, presence: true
    validates :user, uniqueness: { scope: [:decidim_reportable_id, :decidim_reportable_type] }
    validates :reason, inclusion: { in: REASONS }
    validate :user_and_reportable_same_organization

    private

    # Private: check if the reportable and the user have the same organization
    def user_and_reportable_same_organization
      return if !reportable || !user
      errors.add(:reportable, :invalid) unless user.organization == reportable.organization
    end
  end
end
