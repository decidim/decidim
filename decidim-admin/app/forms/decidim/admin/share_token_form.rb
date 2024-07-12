# frozen_string_literal: true

module Decidim
  module Admin
    class ShareTokenForm < Decidim::Form
      include TranslatableAttributes

      attribute :token, String
      attribute :automatic_token, Boolean, default: true
      attribute :expires_at, Decidim::Attributes::TimeWithZone
      attribute :no_expiration, Boolean, default: true

      validates :token, presence: true, if: ->(form) { form.automatic_token.blank? }
      validates :expires_at, presence: true, if: ->(form) { form.no_expiration.blank? }

      def token
        super.upcase if super.present?
      end

      def expires_at
        return nil if no_expiration

        super
      end
    end
  end
end
