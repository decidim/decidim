# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders the results
    # for a given instance of an Election
    class ElectionVoteCtaCell < Decidim::ViewModel
      include Decidim::Elections::HasVoteFlow

      delegate :current_user,
               :current_participatory_space,
               :allowed_to?,
               to: :controller

      private

      # This is needed by HasVoteFlow
      def election
        model
      end

      def last_vote
        @last_vote ||= Decidim::Elections::Votes::LastVoteForVoter.for(model, vote_flow.voter_id) if vote_flow.has_voter?
      end

      def new_election_vote_path
        engine_router.new_election_vote_path(
          "#{key_participatory_space_slug}": current_participatory_space.slug,
          component_id: current_component.id,
          election_id: model.id
        )
      end

      def vote_action_button_text
        if !already_voted?
          t("action_button.vote", scope: "decidim.elections.elections.show")
        elsif last_vote_accepted?
          t("action_button.change_vote", scope: "decidim.elections.elections.show")
        else
          t("action_button.vote_again", scope: "decidim.elections.elections.show")
        end
      end

      def election_vote_verify_path
        engine_router.election_vote_verify_path(
          "#{key_participatory_space_slug}": current_participatory_space.slug,
          component_id: current_component.id,
          election_id: model.id,
          vote_id: "_"
        )
      end

      def callout_text
        if last_vote_pending?
          t("callout.pending_vote", scope: "decidim.elections.elections.show")
        elsif last_vote_accepted?
          t("callout.already_voted", scope: "decidim.elections.elections.show")
        else
          t("callout.vote_rejected", scope: "decidim.elections.elections.show")
        end
      end

      def already_voted?
        last_vote.present?
      end

      def last_vote_pending?
        !!last_vote&.pending?
      end

      def last_vote_accepted?
        !!last_vote&.accepted?
      end

      def current_component
        model.component
      end

      def key_participatory_space_slug
        "#{current_participatory_space.underscored_name}_slug".to_sym
      end

      def engine_router
        @engine_router ||= EngineRouter.main_proxy(current_component || model)
      end
    end
  end
end
