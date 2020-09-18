# frozen_string_literal: true

module Decidim
  module Elections
    # This controller allows a user to give feedback once finished voting
    class FeedbacksController < Decidim::Elections::ApplicationController
      include Decidim::Forms::Concerns::HasQuestionnaire
      helper_method :election

      def answer
        enforce_permission_to :answer, :questionnaire, election: election

        @form = form(Decidim::Forms::QuestionnaireForm).from_params(params, session_token: session_token, ip_hash: ip_hash)

        Decidim::Forms::AnswerQuestionnaire.call(@form, current_user, questionnaire) do
          on(:ok) do
            flash[:notice] = I18n.t("feedback.create.success", scope: "decidim.elections")
            redirect_to after_answer_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("feedback.create.invalid", scope: "decidim.elections")
            render template: "decidim/forms/questionnaires/show"
          end
        end
      end

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
        current_user.present?
      end
    end
  end
end
