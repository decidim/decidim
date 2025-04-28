# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      module Concerns
        # Questionnaires can be related to any class in Decidim. In order to
        # manage the questionnaires responses for a given type, you should create a new
        # controller and include the HasQuestionnaire concern as well as this one.
        #
        # In the controller that includes this concern, you should define a
        # `questionnaire_for` method that returns an instance of the model that the
        # questionnaire belongs to. You should also define the routes for:
        # `index_<model>_url` and `export_<model>_url` as well as
        # `show_<model>_url` and `export_response_<model>_url` (which are passed
        # a `:session_token` parameter)
        module HasQuestionnaireResponses
          extend ActiveSupport::Concern

          included do
            include Decidim::Paginable
            include Decidim::Forms::Admin::Concerns::HasQuestionnaireResponsesUrlHelper
            include Decidim::Forms::Admin::Concerns::HasQuestionnaireResponsesPaginationHelper

            helper Decidim::Forms::Admin::QuestionnaireResponsesHelper

            def index
              enforce_permission_to :index, permission_subject

              @query = paginate(collection)
              @participants = participants(@query)
              @total = questionnaire.count_participants

              render template: "decidim/forms/admin/questionnaires/responses/index"
            end

            def show
              enforce_permission_to :show, permission_subject

              @participant = participant(participants_query.participant(params[:id]))

              render template: "decidim/forms/admin/questionnaires/responses/show"
            end

            def export_response
              enforce_permission_to :export_response, permission_subject

              session_token = params[:id]
              responses = QuestionnaireUserResponses.for(questionnaire)

              # i18n-tasks-use t("decidim.forms.admin.questionnaires.responses.export_response.title")
              title = t("export_response.title", scope: i18n_scope, token: session_token)

              Decidim::Forms::ExportQuestionnaireResponsesJob.perform_later(current_user, title, responses.select { |a| a.first.session_token == session_token })

              flash[:notice] = t("decidim.admin.exports.notice")

              redirect_back(fallback_location: questionnaire_participant_responses_url(session_token))
            end

            # Public: The only method to be implemented at the controller. You need to
            # return the object that will hold the questionnaire.
            def questionnaire_for
              raise "#{self.class.name} is expected to implement #questionnaire_for"
            end

            private

            def permission_subject
              :questionnaire_responses
            end

            def i18n_scope
              "decidim.forms.admin.questionnaires.responses"
            end

            def questionnaire
              @questionnaire ||= Questionnaire.find_by(questionnaire_for:)
            end

            def participants_query
              QuestionnaireParticipants.new(questionnaire)
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
  end
end
