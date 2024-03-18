# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a new category in the
    # system.
    class CreateCategory < Decidim::Commands::CreateResource
      fetch_form_attributes :name, :weight, :parent_id, :participatory_space

      protected

      def resource_class = Decidim::Category
    end
  end
end
