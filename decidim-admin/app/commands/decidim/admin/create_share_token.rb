# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a taxonomy.
    # This command is called from the controller.
    class CreateShareToken < Decidim::Commands::CreateResource
      fetch_form_attributes :token, :expires_at, :organization, :user, :token_for

      protected

      def resource_class = Decidim::ShareToken
    end
  end
end
