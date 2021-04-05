# frozen_string_literal: true

module Decidim
  module Elections
    # Service that encapsulates the vote flow used for elections for registered users.
    class CurrentUserVoteFlow < VoteFlow
      def has_voter?
        current_user.present?
      end

      def voter_name
        current_user&.name
      end

      delegate :email, to: :current_user, allow_nil: true

      def user
        current_user
      end

      def voter_data
        return nil unless current_user

        {
          id: current_user.id,
          created: current_user.created_at.to_i
        }
      end

      def can_vote?
        return @can_vote if defined?(@can_vote)

        @can_vote = user && context.allowed_to?(:user_vote, :election, election: election)
      end

      def valid_token_flow_data?
        return false unless current_user.id == voter_token_parsed_data[:flow][:id].to_i

        @can_vote = true
      end

      def no_access_message
        I18n.t("votes.messages.not_allowed", scope: "decidim.elections")
      end

      def login_path(vote_path); end

      private

      attr_accessor :election, :context

      delegate :current_user, to: :context
    end
  end
end
