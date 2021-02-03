# frozen_string_literal: true

module Decidim
  module Elections
    # Custom helpers for the elections views.
    #
    module ElectionsHelper
      def vote_action_button
        if already_voted?
          last_vote_accepted? ? t(".action-button.change-vote") : t(".action-button.vote-again")
        else
          t(".action-button.vote")
        end
      end

      def callout_text
        last_vote_accepted? ? t(".callout.already-voted") : t(".callout.vote-rejected")
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
