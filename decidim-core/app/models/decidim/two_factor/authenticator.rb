# frozen_string_literal: true

module Decidim
  module TwoFactor
    # A second factor attached to a user.
    class Authenticator < ApplicationRecord
      include Decidim::RecordEncryptor

      self.table_name = "decidim_two_factor_authenticators"

      encrypt_attribute :secret, type: :string

      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

      validates :name, length: { maximum: 64 }
      validates :type, uniqueness: { scope: :decidim_user_id }, unless: :multiple_per_user?

      scope :confirmed, -> { where.not(confirmed_at: nil) }

      def self.find_for(user, _form = nil)
        user.two_factor_authenticators.confirmed.find_by(type: name)
      end

      def confirmed?
        confirmed_at.present?
      end

      def multiple_per_user? = false

      def prepare_challenge(_challenge); end

      def verify(_form, _challenge)
        raise NotImplementedError
      end
    end
  end
end
