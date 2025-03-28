# frozen_string_literal: true

module Decidim
  module System
    class RefreshApiUserSecret < Decidim::Command
      include Decidim::System::TokenGenerator

      def initialize(api_user, current_admin)
        @api_user = api_user
        @current_admin = current_admin
      end

      def call
        return broadcast(:invalid) if @api_user.blank?
        return broadcast(:invalid) if @current_admin.blank?

        transaction do
          refresh_secret
        end

        broadcast(:ok, @api_secret)
      end

      private

      def refresh_secret
        Decidim.traceability.update!(
          @api_user,
          @current_admin,
          api_secret:
        )
      end

      def api_secret
        secret_key_length = Decidim::System.api_users_secret_length
        @api_secret ||= generate_token(secret_key_length)
      end
    end
  end
end
