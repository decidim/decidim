# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a new category in the
    # system.
    class CreateCategory < Decidim::Commands::CreateResource
      fetch_form_attributes :name, :weight, :parent_id

      protected

      def resource_class = Decidim::Category

      def attributes = super.merge({ participatory_space: form.current_participatory_space })
    end
  end
end
