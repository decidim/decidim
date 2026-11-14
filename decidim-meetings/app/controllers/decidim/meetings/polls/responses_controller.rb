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
            on(:ok) do
              respond_to do |format|
                format.js
              end
            end

            on(:invalid) do
              respond_to do |format|
                # A rejected response still renders the same template, because
                # validation errors are displayed in the template, but it must
                # not report success or the client discards the unsaved answers.
                format.js { render "create", status: :unprocessable_content }
              end
            end
          end
        end

        private

        def question
          @question ||= questionnaire.questions.find(response_params[:question_id]) if questionnaire
        end

        def response_params
          params.expect(response: [:question_id, { choices: [[:body, :response_option_id]] }])
        end
      end
    end
  end
end
