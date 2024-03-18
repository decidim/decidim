# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a category in the
    # system.
    class DestroyCategory < Decidim::Commands::DestroyResource
      protected

      def invalid?
        resource.nil? || resource.subcategories.any? || !resource.unused?
      end
    end
  end
end
