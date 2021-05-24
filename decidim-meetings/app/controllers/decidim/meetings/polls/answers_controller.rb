# frozen_string_literal: true

module Decidim
  module Meetings
    module Polls
      class AnswersController < Decidim::Meetings::ApplicationController
        helper_method :meeting, :poll, :questionnaire

        def index
        end

        def create
        end

        def update
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
end
