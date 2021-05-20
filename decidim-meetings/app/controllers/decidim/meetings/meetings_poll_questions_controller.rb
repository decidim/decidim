# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsPollQuestionsController < Admin::ApplicationController
      helper_method :meeting, :poll, :questionnaire

      def index
        respond_to do |format|
          format.js do
            render template: "decidim/meetings/meetings_poll_questions/index", locals: {
              keep_open: false,
              updated_question: nil
            }
          end
        end
      end

      def update
        # TODO: move to command
        if question
          question.closed! if question.published?
          question.published! if question.unpublished?
        end
        respond_to do |format|
          format.js do
            render template: "decidim/meetings/meetings_poll_questions/index", locals: {
              keep_open: true,
              updated_question: question
            }
          end
        end
      end

      private

      def meeting
        @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
      end

      def poll
        @poll ||= meeting&.poll
      end

      def questionnaire
        @questionnaire ||= Decidim::Meetings::Questionnaire.find_by(questionnaire_for: poll) if poll
      end

      def question
        @question ||= questionnaire.questions.find(params[:id]) if questionnaire
      end
    end
  end
end
