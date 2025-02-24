# frozen_string_literal: true

module Decidim
  module System
    class RefreshApiUserToken < Decidim::Command
      include ::Decidim::Apiext::TokenGenerator

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
        @password_token ||= generate_token
      end
    end
  end
end
