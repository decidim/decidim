# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
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
            helper Decidim::Forms::Admin::ApplicationHelper
            include Decidim::TranslatableAttributes

            helper_method :questionnaire_for, :questionnaire, :blank_question, :blank_answer_option, :blank_matrix_row,
                          :blank_display_condition, :question_types, :display_condition_types, :update_url, :public_url, :answer_options_url, :edit_questionnaire_title

            if defined? Decidim::Templates::Admin
              include Decidim::Templates::Admin::Concerns::Templatable
              helper Decidim::DatalistSelectHelper

              def templatable_type
                "Decidim::Forms::Questionnaire"
              end

              def templatable
                questionnaire
              end
            end

            def edit
              enforce_permission_to :update, :questionnaire, questionnaire: questionnaire

              @form = form(Admin::QuestionnaireForm).from_model(questionnaire)

              render template: "decidim/forms/admin/questionnaires/edit"
            end

            def update
              enforce_permission_to :update, :questionnaire, questionnaire: questionnaire

              params["published_at"] = Time.current if params.has_key? "save_and_publish"
              @form = form(Admin::QuestionnaireForm).from_params(params)

              Admin::UpdateQuestionnaire.call(@form, questionnaire, current_user) do
                on(:ok) do
                  # i18n-tasks-use t("decidim.forms.admin.questionnaires.update.success")
                  flash[:notice] = I18n.t("update.success", scope: i18n_flashes_scope)
                  redirect_to after_update_url
                end

                on(:invalid) do
                  # i18n-tasks-use t("decidim.forms.admin.questionnaires.update.invalid")
                  flash.now[:alert] = I18n.t("update.invalid", scope: i18n_flashes_scope)
                  render template: "decidim/forms/admin/questionnaires/edit"
                end
              end
            end

            def answer_options
              respond_to do |format|
                format.json do
                  question_id = params["id"]
                  question = Question.find_by(id: question_id)
                  render json: question.answer_options.map { |answer_option| AnswerOptionPresenter.new(answer_option).as_json } if question.present?
                end
              end
            end

            # Public: The only method to be implemented at the controller. You need to
            # return the object that will hold the questionnaire.
            def questionnaire_for
              raise "#{self.class.name} is expected to implement #questionnaire_for"
            end

            # You can implement this method in your controller to change the URL
            # where the questionnaire will be submitted.
            def update_url
              url_for(questionnaire.questionnaire_for)
            end

            # You can implement this method in your controller to change the URL
            # where the user will be redirected after updating the questionnaire
            def after_update_url
              url_for(questionnaire.questionnaire_for)
            end

            # Implement this method in your controller to set the URL
            # where the questionnaire can be answered.
            def public_url
              raise "#{self.class.name} is expected to implement #public_url"
            end

            # Returns the url to get the answer options json (for the display conditions form)
            # for the question with id = params[:id]
            def answer_options_url(params)
              url_for([questionnaire.questionnaire_for, { action: :answer_options, format: :json, **params }])
            end

            # Implement this method in your controller to set the title
            # of the edit form.
            def edit_questionnaire_title
              t(:title, scope: "decidim.forms.admin.questionnaires.form", questionnaire_for: translated_attribute(questionnaire_for.try(:title)))
            end

            private

            def i18n_flashes_scope
              "decidim.forms.admin.questionnaires"
            end

            def questionnaire
              @questionnaire ||= Questionnaire.find_by(questionnaire_for: questionnaire_for)
            end

            def blank_question
              @blank_question ||= Admin::QuestionForm.new
            end

            def blank_answer_option
              @blank_answer_option ||= Admin::AnswerOptionForm.new
            end

            def blank_display_condition
              @blank_display_condition ||= Admin::DisplayConditionForm.new
            end

            def blank_matrix_row
              @blank_matrix_row ||= Admin::QuestionMatrixRowForm.new
            end

            def question_types
              @question_types ||= Question::QUESTION_TYPES.map do |question_type|
                [question_type, I18n.t("decidim.forms.question_types.#{question_type}")]
              end
            end

            def display_condition_types
              @display_condition_types ||= DisplayCondition.condition_types.keys.map do |condition_type|
                [condition_type, I18n.t("decidim.forms.admin.questionnaires.display_condition.condition_types.#{condition_type}")]
              end
            end
          end
        end
      end
    end
  end
end
