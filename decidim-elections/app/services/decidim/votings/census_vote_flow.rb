# frozen_string_literal: true

module Decidim
  module Votings
    # Service that encapsulates the vote flow used for Votings.
    class CensusVoteFlow < Decidim::Elections::VoteFlow
      def initialize(election, context)
        @election = election
        @context = context
      end

      def has_voter?
        datum.present?
      end

      def voter_name
        datum&.full_name
      end

      delegate :email, to: :datum

      def user
        nil
      end

      def voter_data
        {
          id: datum.id,
          created: datum.created_at.to_i,
          name: datum.full_name
        }
      end

      def can_vote?
        @can_vote ||= begin
          @datum ||= Decidim::Votings::Census::Datum.find_by(hashed_check_data: form.hashed_check_data)
          has_voter?
        end
      end

      def form
        @form ||= context.form(Decidim::Votings::Census::LoginForm).from_params(context.params, election: election)
      end

      def valid_token_flow_data?
        @valid_token_flow_data ||= begin
          @datum = Decidim::Votings::Census::Datum.find_by(id: voter_token_parsed_data[:flow][:id].to_i)
          has_voter? && voter_token_parsed_data[:flow].as_json == voter_data.as_json
        end
      end

      def no_access_message
        I18n.t("vote_flow.datum_not_found", scope: "decidim.votings.census")
      end

      def login_path(vote_path)
        EngineRouter.main_proxy(context.current_participatory_space).voting_login_path(election_id: election.id, vote_path: vote_path)
      end

      private

      attr_accessor :election, :context, :datum
    end
  end
end
