# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      #
      # Presenter for questionnaire response
      #
      class QuestionnaireParticipantPresenter < Rectify::Presenter
        attribute :questionnaire, Decidim::Forms::Questionnaire
        attribute :session_token

        def query
          @query ||= QuestionnaireParticipant.new(questionnaire, session_token)
        end

        def record
          @record ||= QuestionnaireParticipant.new(questionnaire, session_token).query
        end

        def ip_hash
          record.ip_hash || "-"
        end

        def answered_at
          answers_query.first.created_at
        end

        def registered?
          record.decidim_user_id.present?
        end

        def status
          t(registered? ? "registered" : "unregistered", scope: "decidim.forms.user_answers_serializer")
        end

        def answers
          answers_query.map { |answer| QuestionnaireAnswerPresenter.new(answer: answer) }
        end

        def completion
          answers_query.count / questionnaire.questions.count * 100
        end

        private

        def answers_query
          query.answers.order(:created_at)
        end
      end
    end
  end
end
