# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating a static scope.
    class CreateScope < Decidim::Commands::CreateResource
      fetch_form_attributes :name, :organization, :code, :scope_type
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # parent_scope - A parent scope for the scope to be created
      def initialize(form, parent_scope = nil)
        super(form)
        @parent = parent_scope
      end

      protected

      attr_reader :parent

      def resource_class = Decidim::Scope

      def attributes = super.merge({ parent: })

      def extra_params
        {
          extra: {
            parent_name: @parent_scope.try(:name),
            scope_type_name: form.scope_type.try(:name)
          }
        }
      end
    end
  end
end
