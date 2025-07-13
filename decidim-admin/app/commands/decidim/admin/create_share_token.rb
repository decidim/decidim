# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a share token.
    # This command is called from the controller.
    class CreateShareToken < Decidim::Commands::CreateResource
      fetch_form_attributes :token, :expires_at, :registered_only, :organization, :user, :token_for

      protected

      def resource_class = Decidim::ShareToken

      def extra_params
        {
          participatory_space: {
            title: participatory_space&.title
          },
          resource: {
            title: component&.name
          }
        }
      end

      def participatory_space
        return form.token_for if form.token_for.try(:manifest).is_a?(Decidim::ParticipatorySpaceManifest)
        return current_participatory_space if respond_to?(:current_participatory_space)

        component&.participatory_space
      end

      def component
        return form.token_for if form.token_for.is_a?(Decidim::Component)

        form.token_for.try(:component)
      end
    end
  end
end
