# frozen_string_literal: true

module Decidim
  module Meetings
    module Polls
      class ResponsesController < Decidim::Meetings::ApplicationController
        include Decidim::Meetings::PollsResources
        include FormFactory

        helper_method :question

        def admin
          enforce_permission_to(:update, :poll, meeting:)
        end

        def index
          enforce_permission_to(:reply_poll, :meeting, meeting:)
        end

        def create
          enforce_permission_to(:create, :response, question:)
          @form = form(ResponseForm).from_params(params.merge(question:, current_user:))

          CreateResponse.call(@form, questionnaire) do
            # Both :ok and :invalid render the same template, because
            # validation errors are displayed in the template
            respond_to do |format|
              format.js
            end
          end
        end

        private

        def question
          @question ||= questionnaire.questions.find(response_params[:question_id]) if questionnaire
        end

        def response_params
          params.require(:response).permit(:question_id, choices: [:body, :response_option_id])
        end
      end
    end
  end
end
