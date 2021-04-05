# frozen_string_literal: true

module Decidim
  module Elections
    # Service that encapsulates the vote flow used for elections for registered users.
    class CurrentUserVoteFlow < VoteFlow
      def has_voter?
        current_user.present?
      end

      delegate :name, to: :current_user, prefix: :voter, allow_nil: true
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

        @can_vote = current_user && (received_voter_token || context.allowed_to?(:user_vote, :election, election: election))
      end

      def no_access_message
        I18n.t("votes.messages.not_allowed", scope: "decidim.elections")
      end

      def login_path(vote_path); end

      private

      delegate :current_user, to: :context

      def valid_token_flow_data?
        return @valid_token_flow_data if defined?(@valid_token_flow_data)

        @valid_token_flow_data = received_voter_token && received_voter_token_user_id && current_user.id == received_voter_token_user_id
      end

      def received_voter_token_user_id
        @received_voter_token_user_id ||= received_voter_token_data.dig(:flow, :id)&.to_i
      end
    end
  end
end
