# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a taxonomy.
    # This command is called from the controller.
    class CreateTaxonomy < Decidim::Commands::CreateResource
      # Public: Initializes the command.
      # form - A form object with the params.
      def initialize(form, organization)
        @form = form
        @organization = organization
      end

      def call
        return broadcast(:invalid) if @form.invalid?

        taxonomy = create_taxonomy

        broadcast(:ok, taxonomy)
      end

      private

      attr_reader :form, :organization

      def create_taxonomy
        Decidim::Taxonomy.create!(
          name: form.name,
          parent_id: form.parent_id,
          weight: form.weight,
          organization:
        )
      end
    end
  end
end
