# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing categories for questions.
      #
      class CategoriesController < Decidim::Admin::CategoriesController
        include QuestionAdmin

        def current_participatory_space_manifest_name
          :consultations
        end
      end
    end
  end
end
