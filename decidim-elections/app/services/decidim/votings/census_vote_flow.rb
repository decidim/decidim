# frozen_string_literal: true

module Decidim
  module Votings
    # Service that encapsulates the vote flow used for Votings, using a census instead of users.
    class CensusVoteFlow < Decidim::Elections::VoteFlow
      def voter_login(params)
        @login_params = params
      end

      def voter_in_person(params)
        @in_person_params = params
      end

      def has_voter?
        datum.present?
      end

      def voter_name
        datum&.full_name
      end

      delegate :email, to: :datum, allow_nil: true

      def user
        nil
      end

      def voter_data
        return nil unless datum

        {
          id: datum.id,
          created: datum.created_at.to_i,
          name: datum.full_name
        }
      end

      def vote_check(online_vote_path: nil)
        VoteCheckResult.new(
          allowed: has_voter? && !voted_in_person?,
          error_message: I18n.t("vote_flow.#{voted_in_person? ? "already_voted_in_person" : "datum_not_found"}", scope: "decidim.votings.census"),
          exit_path: login_path(online_vote_path)
        )
      end

      def questions_for(election)
        if ballot_style.present?
          ballot_style.questions.where(election:)
        else
          election.questions
        end
      end

      def ballot_style_id
        ballot_style&.slug
      end

      def voted_in_person?
        Decidim::Votings::Votes::InPersonVoteForVoter.for(election, voter_id)
      end

      def login_path(online_vote_path)
        EngineRouter.main_proxy(election.component.participatory_space).voting_login_path(election_id: election.id, vote_path: online_vote_path) if online_vote_path
      end

      private

      attr_accessor :login_params, :in_person_params

      def ballot_style
        return @ballot_style if defined?(@ballot_style)

        @ballot_style = datum&.ballot_style
      end

      def datum
        return @datum if defined?(@datum)

        @datum = if received_voter_token
                   Decidim::Votings::Census::Datum.find_by(id: received_voter_token_datum_id) if received_voter_token_datum_id
                 elsif login_params || in_person_params
                   Decidim::Votings::Census::Datum.find_by(dataset: election.participatory_space.dataset, **datum_query)
                 end
      end

      def received_voter_token_datum_id
        @received_voter_token_datum_id ||= received_voter_token_data.dig(:flow, :id)&.to_i
      end

      def datum_query
        if login_params
          { hashed_online_data: Decidim::Votings::Census::LoginForm.from_params(login_params, election:).hashed_online_data }
        elsif in_person_params
          { hashed_in_person_data: Decidim::Votings::Census::InPersonForm.from_params(in_person_params, election:).hashed_in_person_data }
        end
      end

      def valid_token_flow_data?
        @valid_token_flow_data ||= has_voter? && received_voter_token_data[:flow].as_json == voter_data.as_json
      end
    end
  end
end
