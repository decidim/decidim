# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a scope.
    class UpdateScope < Decidim::Commands::UpdateResource
      fetch_form_attributes :name, :code, :scope_type

      protected

      def extra_params
        {
          extra: {
            parent_name: resource.parent.try(:name),
            scope_type_name: resource.scope_type.try(:name)
          }
        }
      end
    end
  end
end
