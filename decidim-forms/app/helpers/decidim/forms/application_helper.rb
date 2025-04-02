# frozen_string_literal: true

module Decidim
  module Forms
    # Custom helpers, scoped to the forms engine.
    module ApplicationHelper
      # Show cell for selected models
      def show_public_participation?
        model_name = questionnaire_for.model_name.element

        permitted_models.include?(model_name)
      end

      def permitted_models
        %(meeting)
      end
    end
  end
end
