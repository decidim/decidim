# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders the results
    # for a given instance of an Election
    class ElectionVoteCtaCell < Decidim::ViewModel
      delegate :current_user,
               :allowed_to?,
               :current_participatory_space,
               to: :controller

      private

      def last_vote
        @last_vote ||= Decidim::Elections::Votes::UserElectionLastVote.new(current_user, model).query
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

      def verify_election_vote_path
        engine_router.verify_election_vote_path(
          "#{key_participatory_space_slug}": current_participatory_space.slug,
          component_id: current_component.id,
          election_id: model.id
        )
      end

      def callout_text
        if last_vote_accepted?
          t("callout.already_voted", scope: "decidim.elections.elections.show")
        else
          t("callout.vote_rejected", scope: "decidim.elections.elections.show")
        end
      end

      def already_voted?
        last_vote.present?
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
