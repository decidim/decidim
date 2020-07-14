# frozen_string_literal: true

module Decidim
  module Elections
    # Exposes the elections resources so users can participate on them
    class VotesController < Decidim::Elections::ApplicationController
      layout "decidim/election_votes"
      include FormFactory

      helper VotesHelper
      helper_method :elections, :election

      def new
        redirect_to(election_path(election), alert: t("votes.messages.not_allowed", scope: "decidim.elections")) unless allowed_to? :vote, :election, election: election

        @form = form(VotingForm).instance(election: election)
      end

      private

      def elections
        @elections ||= Election.where(component: current_component)
      end

      def election
        @election ||= elections.find(params[:election_id])
      end
    end
  end
end
