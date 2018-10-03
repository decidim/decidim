# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This controller allows the user to update a Page.
      class SurveysController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaire

        def questionnaire_for
          survey
        end

        private

        def i18n_flashes_scope
          "decidim.surveys.admin.surveys"
        end

        def survey
          @survey ||= Survey.find_by(component: current_component)
        end
      end
    end
  end
end
