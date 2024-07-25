# frozen_string_literal: true

module Decidim
  class ShareToken < ApplicationRecord
    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    belongs_to :token_for, foreign_type: "token_for_type", polymorphic: true

    validates :token, presence: true, uniqueness: { scope: [:decidim_organization_id, :token_for_type, :token_for_id] }
    # validates token no spaces or strange characters
    validates :token, format: { with: /\A[a-zA-Z0-9_-]+\z/ }

    after_initialize :generate

    def self.use!(token_for:, token:, user: nil)
      record = find_by!(token_for:, token:)
      record.use!(user:)
    end

    def use!(user: nil)
      return raise StandardError, "Share token '#{token}' for '#{token_for_type}' with id = #{token_for_id} has expired." if expired?
      return raise StandardError, "Share token '#{token}' for '#{token_for_type}' with id = #{token_for_id} requires a registered user." if registered_only? && user.nil?

      update!(times_used: times_used + 1, last_used_at: Time.zone.now)
    end

    def expired?
      expires_at.past? unless expires_at.nil?
    end

    def url
      token_for.shareable_url(self)
    end

    private

    def generate
      return if token.present?

      loop do
        self.token = SecureRandom.hex(32)
        break if ShareToken.find_by(token:).blank?
      end
    end
  end
end
