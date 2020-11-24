# frozen_string_literal: true

module Decidim
  module Elections
    # This controller allows a user to give feedback once finished voting
    class FeedbacksController < Decidim::Elections::ApplicationController
      include Decidim::Forms::Concerns::HasQuestionnaire
      helper_method :election

      def questionnaire_for
        election
      end

      # where the questionnaire will be submitted.
      def update_url
        answer_election_feedback_path(election)
      end

      private

      def election
        @election ||= Election.where(component: current_component).includes(:questionnaire).find(params[:election_id])
      end

      def allow_answers?
        current_user.present? && election.ongoing?
      end

      def i18n_flashes_scope
        "decidim.elections.feedback"
      end

      def enforce_permission_to_answer_questionnaire
        enforce_permission_to :answer, :questionnaire, election: election
      end
    end
  end
end
