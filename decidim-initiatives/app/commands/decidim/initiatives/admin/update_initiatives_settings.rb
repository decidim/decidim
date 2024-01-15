# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic when updating initiatives
      # settings in admin area.
      class UpdateInitiativesSettings < Decidim::Commands::UpdateResource
        fetch_form_attributes :initiatives_order
      end
    end
  end
end
