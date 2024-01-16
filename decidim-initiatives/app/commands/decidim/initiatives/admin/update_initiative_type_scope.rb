# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that updates an
      # existing initiative type scope.
      class UpdateInitiativeTypeScope < Decidim::Commands::UpdateResource
        fetch_form_attributes :supports_required, :decidim_scopes_id
      end
    end
  end
end
