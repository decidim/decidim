# frozen_string_literal: true

module Decidim
  module System
    class RefreshApiUserToken < Decidim::Command
      include Decidim::System::TokenGenerator

      def initialize(api_user, current_admin)
        @api_user = api_user
        @current_admin = current_admin
      end

      def call
        return broadcast(:invalid) if @api_user.blank?
        return broadcast(:invalid) if @current_admin.blank?

        transaction do
          refresh_token
        end

        broadcast(:ok, @password_token)
      end

      private

      def refresh_token
        Decidim.traceability.update!(
          @api_user,
          @current_admin,
          api_secret: password_token
        )
      end

      def password_token
        secret_key_length = Decidim::System.api_users_secret_length
        @password_token ||= generate_token(secret_key_length)
      end
    end
  end
end
