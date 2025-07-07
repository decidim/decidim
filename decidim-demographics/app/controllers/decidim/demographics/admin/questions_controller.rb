# frozen_string_literal: true

module Decidim
  module Demographics
    module Admin
      class QuestionsController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaire
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireResponsesUrlHelper

        def edit_questions_template = "decidim/demographics/admin/questions/edit"

        def after_update_url = edit_questions_questions_path

        def questionnaire_participants_url = decidim_admin_demographics.responses_path

        def update_url = update_questions_questions_path

        def response_options_url(_params) = decidim_admin_demographics.responses_path

        def questionnaire
          @questionnaire ||= Decidim::Forms::Questionnaire.where(questionnaire_for:).first_or_initialize
          @questionnaire.override_edit!
          Decidim::Demographics.create_default_questionnaire!(@questionnaire)
          @questionnaire
        end

        def questionnaire_for = demographic

        def edit_questionnaire_title = t(:title, scope: "decidim.demographics.admin.questions.edit")
      end
    end
  end
end
