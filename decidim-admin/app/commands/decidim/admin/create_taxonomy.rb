# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a taxonomy.
    # This command is called from the controller.
    class CreateTaxonomy < Decidim::Commands::CreateResource
      fetch_form_attributes :name, :organization, :parent_id

      protected

      def resource_class = Decidim::Taxonomy

      def extra_params
        {
          extra: {
            parent_name: form.try(:parent).try(:name)
          }
        }
      end
    end
  end
end
