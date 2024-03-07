# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating an area type.
    class CreateAreaType < Decidim::Commands::CreateResource
      fetch_form_attributes :name, :organization, :plural

      protected

      def resource_class = Decidim::AreaType
    end
  end
end
