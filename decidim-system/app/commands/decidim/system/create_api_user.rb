# frozen_string_literal: true

module Decidim
  module System
    class CreateApiUser < Decidim::Command
      include ::Decidim::System::TokenGenerator

      def initialize(form, current_admin)
        @form = form
        @current_admin = current_admin
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        transaction do
          create_api_user
        end

        broadcast(:ok, @api_user, password_token)
      end

      private

      attr_reader :form, :current_admin

      def create_api_user
        @api_user = Decidim.traceability.create!(
          ::Decidim::Api::ApiUser,
          current_admin,
          **api_user_attributes
        )
      end

      def api_user_attributes
        {
          decidim_organization_id: form.organization,
          api_key: key_token,
          name: form.name,
          nickname: ::Decidim::UserBaseEntity.nicknamize(form.name, organization: form.organization),
          admin: true,
          admin_terms_accepted_at: Time.current,
          api_secret: password_token
        }.tap do |attrs|
          attrs[:published_at] = Time.current if ::Decidim::Api::ApiUser.column_names.include?("published_at")
        end
      end

      def key_token
        @key_token ||= generate_unique_token
      end

      def password_token
        @password_token ||= generate_token
      end

      def generate_unique_token
        loop do
          token = generate_token
          return token unless Decidim::Api::ApiUser.exists?(api_key: token)
        end
      end
    end
  end
end
