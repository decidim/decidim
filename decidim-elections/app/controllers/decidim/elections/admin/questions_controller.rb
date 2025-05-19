# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionsController < Admin::ApplicationController
        helper_method :election, :questionnaire_for, :questionnaire, :update_url, :blank_question, :question_types, :blank_response_option, :response_options_url

        helper Decidim::Forms::Admin::ApplicationHelper

        def edit_questions
          # enforce_permission_to(:update, :election_question, election:, questions:)
          @form = form(Decidim::Elections::Admin::QuestionnaireForm).from_model(questionnaire)

          render template: "decidim/elections/admin/questions/edit_questions"
        end

        def update
          # enforce_permission_to(:create, :question, election:)
          current_questions_forms = form(Admin::QuestionnaireForm).from_model(questionnaire).questions
          @form = form(Admin::QuestionnaireForm).from_params(params)

          @form.questions = @form.questions.map do |question_form|
            next question_form if question_form.editable?

            full_question_form = current_questions_forms.find { |form| form.id.to_s == question_form.id.to_s }
            full_question_form.position = question_form.position
            full_question_form
          end

          Admin::UpdateQuestionnaire.call(@form, questionnaire) do
            on(:ok) do
              flash[:notice] = I18n.t("update.success", scope: "decidim.elections.admin.questions")
              redirect_to edit_questions_election_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("update.invalid", scope: "decidim.elections.admin.questions")
              render template: "decidim/elections/admin/questions/edit_questions"
            end
          end
        end

        def response_options
          respond_to do |format|
            format.json do
              question_id = params["id"]
              question = Decidim::Elections::Question.find_by(id: question_id)
              render json: question.response_options.map { |response_option| Decidim::Forms::ResponseOptionPresenter.new(response_option).as_json } if question.present?
            end
          end
        end

        def response_options_url(params)
          url_for([questionnaire.questionnaire_for, { action: :response_options, format: :json, **params }])
        end

        def questionnaire_for
          election
        end

        private

        def questionnaire
          @questionnaire ||= Decidim::Elections::Questionnaire.find_or_initialize_by(questionnaire_for:)
        end

        def question_types
          @question_types ||= Decidim::Elections::Question::QUESTION_TYPES.map do |question_type|
            [question_type, I18n.t("decidim.forms.question_types.#{question_type}")]
          end
        end

        def election
          @election ||= Decidim::Elections::Election.where(component: current_component).find(params[:id])
        end

        def update_url
          update_questions_election_path(election)
        end

        def blank_question
          @blank_question ||= Decidim::Elections::Admin::QuestionForm.new
        end

        def blank_response_option
          @blank_response_option ||= Decidim::Elections::Admin::ResponseOptionForm.new
        end
      end
    end
  end
end
