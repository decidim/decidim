# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows the user to update a Page.
      class QuestionnairesController < Admin::ApplicationController
        helper_method :current_meeting, :questionnaire, :blank_question, :blank_answer_option, :question_types

        def new
          enforce_permission_to :create, :questionnaire

          @form = form(Admin::QuestionnaireForm).instance
          @form.questionnaire_type = params[:type]
        end

        def create
          enforce_permission_to :create, :questionnaire

          @form = form(Admin::QuestionnaireForm).from_params(params)

          Admin::CreateQuestionnaire.call(@form, current_meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("questionnaires.create.success", scope: "decidim.meetings.admin")
              redirect_to edit_meeting_registrations_path(meeting_id: current_meeting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questionnaires.create.invalid", scope: "decidim.meetings.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :questionnaire, questionnaire: questionnaire

          @form = form(Admin::QuestionnaireForm).from_model(questionnaire)
        end

        def update
          enforce_permission_to :update, :questionnaire, questionnaire: questionnaire

          @form = form(Admin::QuestionnaireForm).from_params(params)

          Admin::UpdateQuestionnaire.call(@form, questionnaire) do
            on(:ok) do
              flash[:notice] = I18n.t("questionnaires.update.success", scope: "decidim.meetings.admin")
              redirect_to edit_meeting_registrations_path(meeting_id: current_meeting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questionnaires.update.invalid", scope: "decidim.meetings.admin")
              render action: "edit"
            end
          end
        end

        private

        def current_meeting
          @current_meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
        end

        def questionnaire
          @questionnaire ||= Questionnaire.where(meeting: current_meeting).find(params[:id])
        end

        def blank_question
          @blank_question ||= Admin::QuestionnaireQuestionForm.new
        end

        def blank_answer_option
          @blank_answer_option ||= Admin::QuestionnaireAnswerOptionForm.new
        end

        def question_types
          @question_types ||= QuestionnaireQuestion::TYPES.map do |question_type|
            [question_type, I18n.t("decidim.meetings.questionnaires.question_types.#{question_type}")]
          end
        end
      end
    end
  end
end
