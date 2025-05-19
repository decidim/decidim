# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      module Concerns
        # Questionnaires can be related to any class in Decidim. In order to
        # manage the questionnaires answers for a given type, you should create a new
        # controller and include the HasQuestionnaire concern as well as this one.
        #
        # In the controller that includes this concern, you should define a
        # `questionnaire_for` method that returns an instance of the model that the
        # questionnaire belongs to. You should also define the routes for:
        # `index_<model>_url` and `export_<model>_url` as well as
        # `show_<model>_url` and `export_response_<model>_url` (which are passed
        # a `:session_token` parameter)
        module HasQuestionnaireAnswers
          extend ActiveSupport::Concern

          included do
            include Decidim::Paginable
            include Decidim::Forms::Admin::Concerns::HasQuestionnaireAnswersUrlHelper
            include Decidim::Forms::Admin::Concerns::HasQuestionnaireAnswersPaginationHelper

            helper Decidim::Forms::Admin::QuestionnaireAnswersHelper

            def index
              enforce_permission_to :index, :questionnaire_answers

              @query = paginate(collection)
              @participants = participants(@query)
              @total = questionnaire.count_participants

              render template: "decidim/forms/admin/questionnaires/answers/index"
            end

            def show
              enforce_permission_to :show, :questionnaire_answers

              @participant = participant(participants_query.participant(params[:id]))

              render template: "decidim/forms/admin/questionnaires/answers/show"
            end

            def export_response
              enforce_permission_to :export_response, :questionnaire_answers

              session_token = params[:id]
              answers = QuestionnaireUserAnswers.for(questionnaire)

              # i18n-tasks-use t("decidim.forms.admin.questionnaires.answers.export_response.title")
              file_name = t("export_response.title", scope: i18n_scope, token: session_token)

              selected_response = answers.select { |a| a.first.session_token == session_token }

              Decidim::Forms::ExportQuestionnaireAnswersJob.perform_later(current_user, file_name, selected_response, :survey_user_answers)

              flash[:notice] = t("decidim.admin.exports.notice")

              redirect_back(fallback_location: questionnaire_participant_answers_url(session_token))
            end

            # Public: The only method to be implemented at the controller. You need to
            # return the object that will hold the questionnaire.
            def questionnaire_for
              raise "#{self.class.name} is expected to implement #questionnaire_for"
            end

            private

            def i18n_scope
              "decidim.forms.admin.questionnaires.answers"
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

            def participant(answer)
              Decidim::Forms::Admin::QuestionnaireParticipantPresenter.new(participant: answer)
            end

            def participants(query)
              query.map { |answer| participant(answer) }
            end
          end
        end
      end
    end
  end
end
