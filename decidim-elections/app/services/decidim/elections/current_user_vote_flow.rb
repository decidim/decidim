# frozen_string_literal: true

module Decidim
  module Elections
    # Service that encapsulates the vote flow used for elections for registered users.
    class CurrentUserVoteFlow < VoteFlow
      def initialize(election, current_user, &can_vote_block)
        super(election)

        @current_user = current_user
        @can_vote_block = can_vote_block
      end

      def voter_login(params)
        # There is no previous login page for this vote flow
      end

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

      def vote_check(*)
        VoteCheckResult.new(
          allowed: current_user && (received_voter_token || can_vote_block.call),
          error_message: I18n.t("votes.messages.not_allowed", scope: "decidim.elections")
        )
      end

      def login_path(online_vote_path); end

      def questions_for(election)
        election.questions
      end

      def ballot_style_id; end

      private

      attr_accessor :current_user, :can_vote_block

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
