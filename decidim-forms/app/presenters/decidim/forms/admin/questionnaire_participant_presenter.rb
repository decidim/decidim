# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      #
      # Presenter for questionnaire response
      #
      class QuestionnaireParticipantPresenter < SimpleDelegator
        def participant
          __getobj__.fetch(:participant)
        end

        def session_token
          participant.session_token || "-"
        end

        def ip_hash
          participant.ip_hash || "-"
        end

        def responded_at
          participant.created_at
        end

        delegate :questionnaire, to: :participant

        def registered?
          participant.decidim_user_id.present?
        end

        def status
          I18n.t(registered? ? "registered" : "unregistered", scope: "decidim.forms.user_responses_serializer")
        end

        def responses
          siblings.map { |response| QuestionnaireResponsePresenter.new(response:) }
        end

        def first_short_response
          short = siblings.where(decidim_forms_questions: { question_type: %w(short_response) })
          short.first
        end

        def completion
          with_body = siblings.where(decidim_forms_questions: { question_type: %w(short_response long_response) })
                              .where.not(body: "").count
          with_choices = siblings.where.not(decidim_forms_questions: { question_type: %w(short_response long_response) })
                                 .where("decidim_forms_responses.id IN (SELECT decidim_response_id FROM decidim_forms_response_choices)").count

          (with_body + with_choices).to_f / questionnaire.questions.not_separator.not_title_and_description.count * 100
        end

        private

        def siblings
          Response.not_separator
                  .not_title_and_description
                  .where(questionnaire:, session_token: participant.session_token)
                  .joins(:question).order("decidim_forms_questions.position ASC")
        end
      end
    end
  end
end
