# frozen_string_literal: true

module Decidim
  module Demographics
    module Admin
      class ResponsesController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireResponses
        helper_method :questionnaire_for, :questionnaire

        def index
          enforce_permission_to :index, permission_subject

          @query = paginate(collection)
          @participants = participants(@query)
          @total = questionnaire.count_participants
          @survey = questionnaire_for

          render template: "decidim/demographics/admin/responses/index"
        end


        def permission_subject = :demographics_responses

        def questionnaire_for = demographic

        def questionnaire_export_response_url(id) = export_response_response_path( id:)

        def questionnaire_url = edit_questions_questions_path

        # Specify where to redirect after exporting a user response
        def questionnaire_participant_responses_url(id) = response_path(id:)

        def questionnaire_participants_url = decidim_admin_demographics.responses_path
      end
    end
  end
end
