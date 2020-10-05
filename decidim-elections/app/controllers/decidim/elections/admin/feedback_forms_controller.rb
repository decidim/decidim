# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows an admin to manage the form to be filled when a user finishes voting
      class FeedbackFormsController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaire
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireAnswers

        def questionnaire_for
          election
        end

        def update_url
          feedback_form_path(election_id: election.id)
        end

        def after_update_url
          edit_feedback_form_path(id: election.id)
        end

        def public_url
          Decidim::EngineRouter.main_proxy(current_component).election_feedback_path(election)
        end

        def answer_options_url(params)
          answer_options_election_feedback_path(**params)
        end

        def questionnaire_participants_url
          answers_feedback_form_path(id: election.id)
        end

        def questionnaire_participant_answers_url(session_token)
          answer_feedback_form_path(id: election.id, session_token: session_token)
        end

        def questionnaire_export_response_url(session_token)
          answer_export_feedback_form_path(id: election.id, session_token: session_token, format: "pdf")
        end

        def questionnaire_url
          edit_feedback_form_path(id: election.id)
        end

        private

        def election
          @election ||= Election.where(component: current_component).find(params[:id])
        end
      end
    end
  end
end
