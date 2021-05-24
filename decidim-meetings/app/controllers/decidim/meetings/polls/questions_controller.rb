# frozen_string_literal: true

module Decidim
  module Meetings
    module Polls
      class QuestionsController < Decidim::Meetings::ApplicationController
        include Decidim::Meetings::PollsResources

        def index
          respond_to do |format|
            format.js do
              render template: pick_index_template, locals: { open_question: nil }
            end
          end
        end

        def update
          # TODO: permissions
          # TODO: move to command
          if question
            question.closed! if question.published?
            question.published! if question.unpublished?
          end
          respond_to do |format|
            format.js do
              render template: admin_index_template, locals: { open_question: question.id }
            end
          end
        end

        private

        def question
          @question ||= questionnaire.questions.find(params[:id]) if questionnaire
        end

        def admin_index_template
          "decidim/meetings/polls/questions/index_admin"
        end

        def pick_index_template
          params[:admin] ? admin_index_template : "decidim/meetings/polls/questions/index"
        end
      end
    end
  end
end
