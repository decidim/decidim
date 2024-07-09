# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a taxonomy.
    class DestroyTaxonomy < Decidim::Commands::DestroyResource
      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        destroy_resource
        broadcast(:ok)
      rescue ActiveRecord::RecordNotDestroyed
        broadcast(:has_children)
      end
    end
  end
end
