# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that creates a new initiative type scope
      class CreateInitiativeTypeScope < Decidim::Commands::CreateResource
        protected

        fetch_form_attributes :supports_required, :decidim_scopes_id

        def attributes = super.merge(decidim_initiatives_types_id: form.context.type_id)

        def resource_class = Decidim::InitiativesTypeScope
      end
    end
  end
end
