# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      #
      # Presenter for questionnaire response
      #
      class QuestionnaireParticipantPresenter < Rectify::Presenter
        attribute :participant, Decidim::Forms::Answer

        def session_token
          participant.session_token || "-"
        end

        def ip_hash
          participant.ip_hash || "-"
        end

        def answered_at
          participant.created_at
        end

        delegate :questionnaire, to: :participant

        def registered?
          participant.decidim_user_id.present?
        end

        def status
          t(registered? ? "registered" : "unregistered", scope: "decidim.forms.user_answers_serializer")
        end

        def answers
          sibilings.map { |answer| QuestionnaireAnswerPresenter.new(answer: answer) }
        end

        def first_short_answer
          short = sibilings.where("decidim_forms_questions.question_type in (?)", %w(short_answer))
          short.first
        end

        def completion
          with_body = sibilings.where("decidim_forms_questions.question_type in (?)", %w(short_answer long_answer))
                               .where.not(body: "").count
          with_choices = sibilings.where.not("decidim_forms_questions.question_type in (?)", %w(short_answer long_answer))
                                  .where("decidim_forms_answers.id IN (SELECT decidim_answer_id FROM decidim_forms_answer_choices)").count

          (with_body + with_choices).to_f / questionnaire.questions.count * 100
        end

        private

        def sibilings
          Answer.where(session_token: participant.session_token).joins(:question).order("decidim_forms_questions.position ASC")
        end
      end
    end
  end
end
