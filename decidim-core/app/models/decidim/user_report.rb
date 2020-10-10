# frozen_string_literal: true

module Decidim
  class UserReport < ApplicationRecord

    REASONS = %w(spam offensive does_not_belong).freeze

    belongs_to :reporter, class_name: "Decidim::User", foreign_key: :reporter_id
    belongs_to :reported, class_name: "Decidim::User", foreign_key: :reported_id

    validates :reason, presence: true
    validates :reason, inclusion: { in: REASONS }
    validate :reporter_and_reported_in_same_organization

    private
    def reporter_and_reported_in_same_organization
      errors.add(:reported, :invalid) unless reported.organization == reporter.organization
    end
  end
end
