# frozen_string_literal: true

module Decidim
  module TwoFactor
    # A one-time recovery code, stored as a digest.
    class RecoveryCode < ApplicationRecord
      self.table_name = "decidim_two_factor_recovery_codes"

      FORMAT = /\A\h{32}\z/

      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

      validates :code_digest, presence: true

      scope :unused, -> { where(used_at: nil) }

      # Consumes the code at most once even when it is redeemed concurrently.
      def self.redeem!(user, plain_code)
        normalized = plain_code.to_s.strip.downcase
        code = unused.where(user:).find { |record| CodeDigest.match?(record.code_digest, normalized) }
        return false unless code

        # rubocop:disable-next Rails/SkipsModelValidations
        unused.where(id: code.id).update_all(used_at: Time.current, updated_at: Time.current) == 1
      end
    end
  end
end
