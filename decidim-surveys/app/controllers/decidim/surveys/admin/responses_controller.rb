# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This controller allows the user to update a Page.
      class ResponsesController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireResponses

        def index
          enforce_permission_to :index, :questionnaire_responses

          @query = paginate(collection)
          @participants = participants(@query)
          @total = questionnaire.count_participants
          @survey = questionnaire_for

          render template: "decidim/surveys/admin/responses/index"
        end

        def show
          enforce_permission_to :show, :questionnaire_responses

          @participant = participant(participants_query.participant(params[:id]))

          render template: "decidim/surveys/admin/responses/show"
        end

        def questionnaire_for
          @questionnaire_for ||= Decidim::Surveys::Survey.where(component: current_component).find_by(id: params[:survey_id])
        end

        def questionnaire_export_response_url(id)
          Decidim::EngineRouter.admin_proxy(questionnaire_for.component).export_response_survey_response_path(questionnaire_for, id:)
        end

        def questionnaire_url
          Decidim::EngineRouter.admin_proxy(questionnaire_for.component).edit_questions_survey_path(questionnaire_for)
        end

        # Specify where to redirect after exporting a user response
        def questionnaire_participant_responses_url(id)
          Decidim::EngineRouter.admin_proxy(questionnaire_for.component).survey_response_path(questionnaire_for, id:)
        end

        def questionnaire_participants_url
          Decidim::EngineRouter.admin_proxy(questionnaire_for.component).survey_responses_path(questionnaire_for)
        end

        private

        def questionnaire
          @questionnaire ||= Decidim::Forms::Questionnaire.find_by(questionnaire_for:)
        end

        def participants_query
          Decidim::Forms::QuestionnaireParticipants.new(questionnaire)
        end

        def collection
          @collection ||= participants_query.participants
        end

        def participant(response)
          Decidim::Forms::Admin::QuestionnaireParticipantPresenter.new(participant: response)
        end

        def participants(query)
          query.map { |response| participant(response) }
        end
      end
    end
  end
end
