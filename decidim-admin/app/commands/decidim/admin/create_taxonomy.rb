# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a taxonomy.
    # This command is called from the controller.
    class CreateTaxonomy < Decidim::Commands::CreateResource
      fetch_form_attributes :name, :organization

      protected

      def resource_class = Decidim::Taxonomy
    end
  end
end
