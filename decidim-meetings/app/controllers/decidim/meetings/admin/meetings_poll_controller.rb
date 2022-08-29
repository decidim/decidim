# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class MeetingsPollController < Admin::ApplicationController
        include Decidim::TranslatableAttributes

        helper_method :questionnaire_for, :questionnaire, :blank_question, :blank_answer_option,
                      :question_types, :update_url, :answer_options_url, :edit_questionnaire_title,
                      :meeting, :poll

        helper Decidim::Forms::Admin::ApplicationHelper

        def edit
          enforce_permission_to :update, :poll, meeting: meeting, poll: poll

          @form = form(Admin::QuestionnaireForm).from_model(questionnaire)

          render template: "decidim/meetings/admin/poll/edit"
        end

        def update
          enforce_permission_to :update, :poll, meeting: meeting, poll: poll

          @form = form(Admin::QuestionnaireForm).from_params(params)

          Admin::UpdateQuestionnaire.call(@form, questionnaire) do
            on(:ok) do
              # i18n-tasks-use t("decidim.forms.admin.questionnaires.update.success")
              flash[:notice] = I18n.t("update.success", scope: "decidim.meetings.admin.meetings_poll")
              redirect_to after_update_url
            end

            on(:invalid) do
              # i18n-tasks-use t("decidim.forms.admin.questionnaires.update.invalid")
              flash.now[:alert] = I18n.t("update.invalid", scope: "decidim.meetings.admin.meetings_poll")
              render template: "decidim/meetings/admin/poll/edit"
            end
          end
        end

        def answer_options
          respond_to do |format|
            format.json do
              question_id = params["id"]
              question = Decidim::Meetings::Question.find_by(id: question_id)
              render json: question.answer_options.map { |answer_option| AnswerOptionPresenter.new(answer_option).as_json } if question.present?
            end
          end
        end

        def questionnaire_for
          poll
        end

        # Returns the url to get the answer options json (for the display conditions form)
        # for the question with id = params[:id]
        def answer_options_url(params)
          url_for([questionnaire.questionnaire_for, { action: :answer_options, format: :json, **params }])
        end

        # Implement this method in your controller to set the title
        # of the edit form.
        def edit_questionnaire_title
          t(:title, scope: "decidim.meetings.admin.meetings_poll.form", questionnaire_for: translated_attribute(meeting.try(:title)))
        end

        private

        def questionnaire
          @questionnaire ||= Decidim::Meetings::Questionnaire.find_or_initialize_by(questionnaire_for:)
        end

        def blank_question
          @blank_question ||= Decidim::Meetings::Admin::QuestionForm.new
        end

        def blank_answer_option
          @blank_answer_option ||= Decidim::Meetings::Admin::AnswerOptionForm.new
        end

        def question_types
          @question_types ||= Decidim::Meetings::Poll::QUESTION_TYPES.map do |question_type|
            [question_type, I18n.t("decidim.forms.question_types.#{question_type}")]
          end
        end

        def update_url
          meeting_poll_path(meeting_id: meeting.id)
        end

        def after_update_url
          edit_meeting_poll_path(meeting_id: meeting.id)
        end

        def meeting
          @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
        end

        def poll
          @poll ||= Poll.find_or_initialize_by(meeting:)
        end
      end
    end
  end
end
