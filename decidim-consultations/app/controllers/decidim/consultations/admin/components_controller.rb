# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing the Question's Components in the
      # admin panel.
      class ComponentsController < Decidim::Admin::ComponentsController
        include QuestionAdmin

        def current_participatory_space_manifest_name
          :consultations
        end
      end
    end
  end
end
