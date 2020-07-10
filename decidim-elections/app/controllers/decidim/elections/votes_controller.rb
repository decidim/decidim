# frozen_string_literal: true

module Decidim
  module Elections
    # Exposes the elections resources so users can participate on them
    class VotesController < Decidim::Elections::ApplicationController
      layout "decidim/election_votes"
      include FormFactory

      helper_method :elections, :election

      def new
        enforce_permission_to :vote, :election, election: election
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
