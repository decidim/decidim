# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing the Consultation Component
      # permissions in the admin panel.
      class ComponentPermissionsController < Decidim::Admin::ComponentPermissionsController
        include QuestionAdmin

        def current_participatory_space_manifest_name
          :consultations
        end
      end
    end
  end
end
