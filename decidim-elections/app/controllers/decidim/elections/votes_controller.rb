# frozen_string_literal: true

module Decidim
  module Elections
    # Exposes the elections resources so users can participate on them
    class VotesController < Decidim::Elections::ApplicationController
      layout "decidim/election_votes"
      include FormFactory

      helper VotesHelper
      helper_method :elections, :election, :questions, :questions_count, :booth_mode

      delegate :count, to: :questions, prefix: true

      def new
        redirect_to(election_path(election), alert: t("votes.messages.not_allowed", scope: "decidim.elections")) unless booth_mode
      end

      private

      def booth_mode
        @booth_mode ||= if allowed_to? :vote, :election, election: election
                          :vote
                        elsif allowed_to? :preview, :election, election: election
                          :preview
                        end
      end

      def elections
        @elections ||= Election.where(component: current_component)
      end

      def election
        @election ||= elections.find(params[:election_id])
      end

      def questions
        @questions ||= election.questions.includes(:answers).order(weight: :asc, id: :asc)
      end
    end
  end
end
