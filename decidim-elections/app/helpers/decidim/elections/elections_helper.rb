# frozen_string_literal: true

module Decidim
  module Elections
    # Custom helpers for the elections views.
    #
    module ElectionsHelper
      def vote_action_button
        if already_voted?
          last_vote_accepted? ? t("change-vote", scope: "decidim.elections.elections.show.action-button") : t("vote-again", scope: "decidim.elections.elections.show.action-button")
        else
          t("vote", scope: "decidim.elections.elections.show.action-button")
        end
      end

      def callout_text
        last_vote_accepted? ? t("already-voted", scope: "decidim.elections.elections.show.callout") : t("vote-rejected", scope: "decidim.elections.elections.show.callout")
      end

      def already_voted?
        last_vote.present?
      end

      def last_vote_accepted?
        !!last_vote&.accepted?
      end
    end
  end
end
