# frozen_string_literal: true

module Decidim
  module Admin
    class ShareTokenForm < Decidim::Form
      mimic :share_token

      attribute :token, String
      attribute :automatic_token, Boolean, default: true
      attribute :expires_at, Decidim::Attributes::TimeWithZone
      attribute :no_expiration, Boolean, default: true
      attribute :registered_only, Boolean, default: false

      validates :token, presence: true, if: ->(form) { form.automatic_token.blank? }
      validate :token_uniqueness, if: ->(form) { form.automatic_token.blank? }

      validates_format_of :token, with: /\A[a-zA-Z0-9_-]+\z/, allow_blank: true
      validates :expires_at, presence: true, if: ->(form) { form.no_expiration.blank? }

      def map_model(model)
        self.no_expiration = model.expires_at.blank?
      end

      def token
        super.strip.upcase.gsub(/\s+/, "-") if super.present?
      end

      def expires_at
        return nil if no_expiration.present?

        super
      end

      def token_for
        context[:resource]
      end

      def organization
        context[:current_organization]
      end

      def user
        context[:current_user]
      end

      private

      def token_uniqueness
        return unless Decidim::ShareToken.where(organization:, token_for:, token:).where.not(id:).any?

        errors.add(:token, :taken)
      end
    end
  end
end
