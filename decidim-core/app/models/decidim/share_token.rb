# frozen_string_literal: true

module Decidim
  class ShareToken < ApplicationRecord
    validates :organization, presence: true
    validates :user, presence: true
    validates :token, presence: true, uniqueness: { scope: [:decidim_organization_id, :token_for_type, :token_for_id] }

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    belongs_to :token_for, foreign_key: "token_for_id", foreign_type: "token_for_type", polymorphic: true

    after_initialize :generate

    def self.use!(token_for:, token:)
      record = find_by!(token_for: token_for, token: token)

      return raise StandardError, "Share token '#{token}' for '#{token_for_type}' with id = #{token_for_id} has expired." if record.expired?

      record.use!
    end

    def use!
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
      self.expires_at ||= 1.day.from_now

      return if token.present?

      loop do
        self.token = Digest::MD5.hexdigest("#{token_for_type}-#{token_for_id}-#{Time.zone.now}-#{Rails.application.secrets.secret_key_base}")
        break if ShareToken.find_by(token: token).blank?
      end
    end
  end
end
