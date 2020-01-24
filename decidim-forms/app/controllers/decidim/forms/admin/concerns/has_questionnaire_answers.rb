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
            include Decidim::Forms::Admin::Concerns::HasQuestionnaireAnswersHelpers

            helper Decidim::Forms::Admin::QuestionnaireAnswersHelper

            helper_method :questionnaire_url, :questionnaire_participants_url,
                          :questionnaire_participant_answers_url, :questionnaire_export_url,
                          :questionnaire_export_response_url
            helper_method :prev_url, :next_url, :first?, :last?

            def index
              enforce_permission_to :index, :questionnaire_answers

              @query = paginate(collection)
              @participants = participants(@query)

              render template: "decidim/forms/admin/questionnaires/answers/index"
            end

            def show
              enforce_permission_to :show, :questionnaire_answers

              @participant = participant

              render template: "decidim/forms/admin/questionnaires/answers/show"
            end

            def export
              enforce_permission_to :export, :questionnaire_answers

              @participants = participants(collection)

              # i18n-tasks-use t("decidim.forms.admin.questionnaires.answers.export.title")
              render_answers_pdf t("export.title", scope: i18n_scope)
            end

            def export_response
              enforce_permission_to :export_response, :questionnaire_answers

              @participants = [participant]

              # i18n-tasks-use t("decidim.forms.admin.questionnaires.answers.export_response.title")
              render_answers_pdf t("export_response.title", scope: i18n_scope, token: participant.session_token)
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

            def render_answers_pdf(title)
              @title = title

              render pdf: title,
                     template: "decidim/forms/admin/questionnaires/answers/export/pdf.html.erb",
                     layout: "decidim/forms/admin/questionnaires/questionnaire_answers.html.erb"
            end

            def questionnaire
              @questionnaire ||= Questionnaire.find_by(questionnaire_for: questionnaire_for)
            end

            def collection
              @collection ||= QuestionnaireParticipants.new(questionnaire).query
            end

            def participant(session_token = nil)
              session_token ||= params[:session_token]
              Decidim::Forms::Admin::QuestionnaireParticipantPresenter.new(questionnaire: questionnaire, session_token: session_token)
            end

            def participants(query)
              query.map { |p| participant(p.session_token) }
            end
          end
        end
      end
    end
  end
end
