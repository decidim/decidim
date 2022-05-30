# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A form object used to create initiatives settings from the admin dashboard.
      class InitiativesSettingsForm < Form
        mimic :initiatives_settings

        attribute :initiatives_order, String
      end
    end
  end
end
