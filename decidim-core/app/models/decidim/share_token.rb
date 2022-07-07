# frozen_string_literal: true

module Decidim
  class ShareToken < ApplicationRecord
    validates :token, presence: true, uniqueness: { scope: [:decidim_organization_id, :token_for_type, :token_for_id] }

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    belongs_to :token_for, foreign_type: "token_for_type", polymorphic: true

    after_initialize :generate, :set_default_expiration

    def self.use!(token_for:, token:)
      record = find_by!(token_for: token_for, token: token)
      record.use!
    end

    def use!
      return raise StandardError, "Share token '#{token}' for '#{token_for_type}' with id = #{token_for_id} has expired." if expired?

      update!(times_used: times_used + 1, last_used_at: Time.zone.now)
    end

    def expired?
      expires_at.past?
    end

    def url
      token_for.shareable_url(self)
    end

    private

    def generate
      return if token.present?

      loop do
        self.token = SecureRandom.hex(32)
        break if ShareToken.find_by(token: token).blank?
      end
    end

    def set_default_expiration
      self.expires_at ||= 1.day.from_now
    end
  end
end
