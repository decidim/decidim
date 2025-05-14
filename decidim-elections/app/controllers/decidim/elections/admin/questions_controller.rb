# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionsController < Admin::ApplicationController
        helper_method :election, :questionnaire_for, :questionnaire, :update_url, :blank_question

        def edit_questions
          # enforce_permission_to(:update, :election_question, election:, questions:)
          @form = form(Decidim::Elections::Admin::QuestionnaireForm).from_model(questionnaire)

          if @form.questions.empty?
            question = Decidim::Elections::Admin::QuestionForm.new
            2.times { question.answers << Decidim::Elections::Admin::AnswerForm.new }
            @form.questions << question
          end

          render template: "decidim/elections/admin/questions/edit_questions"
        end

        def update
          # enforce_permission_to(:create, :question, election:)
          # @form = form(QuestionForm).from_params(params, election:)
          #
          # UpdateQuestion.call(@form) do
          #   on(:ok) do |question|
          #     flash[:notice] = I18n.t("questions.update.success", scope: "decidim.elections.admin")
          #     redirect_to election_question_answers_path(election, question)
          #   end
          #
          #   on(:invalid) do
          #     flash.now[:alert] = I18n.t("questions.update.invalid", scope: "decidim.elections.admin")
          #     render action: "edit_questions"
          #   end
          # end
        end

        private

        def questionnaire
          @questionnaire ||= Decidim::Elections::Questionnaire.find_or_initialize_by(questionnaire_for:)
        end

        def questionnaire_for
          election
        end

        def question_types
          @question_types ||= Decidim::Elections::Questionnaire::QUESTION_TYPES.map do |question_type|
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
      end
    end
  end
end
