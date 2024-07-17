# frozen_string_literal: true

module Decidim
  module Admin
    class ShareTokenForm < Decidim::Form
      include TranslatableAttributes

      attribute :token, String
      attribute :automatic_token, Boolean, default: true
      attribute :expires_at, Decidim::Attributes::TimeWithZone
      attribute :no_expiration, Boolean, default: true
      attribute :registered_only, Boolean, default: true

      validates :token, presence: true, if: ->(form) { form.automatic_token.blank? }

      def map_model(model)
        self.no_expiration = model.expires_at.blank?
      end

      def token
        super.upcase if super.present?
      end

      def expires_at
        return nil if no_expiration.present?

        super
      end

      def token_for
        context[:component]
      end

      def organization
        context[:current_organization]
      end

      def user
        context[:current_user]
      end
    end
  end
end
