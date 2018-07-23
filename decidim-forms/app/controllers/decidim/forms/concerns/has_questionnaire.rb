# frozen_string_literal: true

module Decidim
  module Forms
    module Concerns
      # Questionnaires can be related to any class in Decidim, in order to
      # manage the questionnaires for a given type, you should create a new
      # controller and include this concern.
      #
      # The only requirement is to define a `questionnaire_for` method that
      # returns an instance of the model that questionnaire belongs to.
      module HasQuestionnaire
        extend ActiveSupport::Concern

        included do
          include FormFactory

          helper_method :questionnaire_for, :questionnaire

          def show
            @form = form(Decidim::Forms::QuestionnaireForm).from_model(questionnaire)
            render template: "decidim/forms/questionnaires/show"
          end

          def answer
            enforce_permission_to :answer, :questionnaire

            @form = form(Decidim::Forms::QuestionnaireForm).from_params(params)

            Decidim::Forms::AnswerQuestionnaire.call(@form, current_user, questionnaire) do
              on(:ok) do
                flash[:notice] = I18n.t("questionnaires.answer.success", scope: "decidim.forms")
                redirect_to after_answer_path
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("questionnaires.answer.invalid", scope: "decidim.forms")
                render template: "decidim/forms/questionnaires/show"
              end
            end
          end

          # Public: Returns a String or Object that will be passed to `redirect_to` after
          # answering the questionnaire. By default it redirects to the questionnaire_for.
          #
          # It can be redefined at controller level if you need to redirect elsewhere.
          def after_answer_path
            questionnaire_for
          end

          # Public: The only method to be implemented at the controller. You need to
          # return the object that will hold the questionnaire.
          def questionnaire_for
            raise "#{self.class.name} is expected to implement #questionnaire_for"
          end

          private

          def questionnaire
            @questionnaire ||= Questionnaire.includes(questions: :answer_options).find_by(questionnaire_for: questionnaire_for)
          end
        end
      end
    end
  end
end
