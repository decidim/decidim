# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating an area
    class CreateArea < Decidim::Commands::CreateResource
      fetch_form_attributes :name, :organization, :area_type

      protected

      def resource_class = Decidim::Area
    end
  end
end
