# frozen_string_literal: true

module Decidim
  class UserReport < ApplicationRecord
    include Decidim::DownloadYourData

    REASONS = %w(spam offensive does_not_belong).freeze

    belongs_to :moderation, foreign_key: :user_moderation_id, class_name: "Decidim::UserModeration"
    belongs_to :user, class_name: "Decidim::User"

    validates :reason, presence: true
    validates :reason, inclusion: { in: REASONS }
    validates :user, uniqueness: { scope: :user_moderation_id }
    validate :user_and_moderation_same_organization

    def self.export_serializer
      raise NotImplementedError
      # Decidim::DownloadYourDataSerializers::DownloadYourDataReportSerializer
    end

    private

    # Private: check if the moderation and the user have the same organization
    def user_and_moderation_same_organization
      return if !moderation || !user

      errors.add(:moderation, :invalid) unless user.organization == moderation.organization
    end
  end
end
