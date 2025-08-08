# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to update a share token.
    # This command is called from the controller.
    class UpdateShareToken < Decidim::Commands::UpdateResource
      fetch_form_attributes :expires_at, :registered_only

      delegate :participatory_space, :component, to: :resource

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
    end
  end
end
