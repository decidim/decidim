# frozen_string_literal: true

module Decidim
  module Forms
    # Custom helpers, scoped to the forms engine.
    module ApplicationHelper
      # Show cell for selected models
      def show_represent_user_group?
        model_name = questionnaire_for.model_name.element

        permited_models.include?(model_name)
      end

      def permited_models
        %(meeting)
      end
    end
  end
end
