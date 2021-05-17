# frozen_string_literal: true

module Decidim
  module Votings
    # Service that encapsulates the vote flow used for Votings, using a census instead of users.
    class CensusVoteFlow < Decidim::Elections::VoteFlow
      def has_voter?
        datum.present?
      end

      alias can_vote? has_voter?

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

      def no_access_message
        I18n.t("vote_flow.datum_not_found", scope: "decidim.votings.census")
      end

      def login_path(vote_path)
        EngineRouter.main_proxy(election.component.participatory_space).voting_login_path(election_id: election.id, vote_path: vote_path)
      end

      def questions_for(election)
        if ballot_style.present?
          ballot_style.questions.where(election: election)
        else
          election.questions
        end
      end

      def ballot_style_id
        ballot_style&.slug
      end

      private

      def ballot_style
        return @ballot_style if defined?(@ballot_style)

        @ballot_style = datum&.ballot_style
      end

      def datum
        return @datum if defined?(@datum)

        if received_voter_token
          @datum = Decidim::Votings::Census::Datum.find_by(id: received_voter_token_datum_id) if received_voter_token_datum_id
        else
          @datum = Decidim::Votings::Census::Datum.find_by(hashed_online_data: form.hashed_online_data, dataset: election.participatory_space.dataset)
        end
      end

      def received_voter_token_datum_id
        @received_voter_token_datum_id ||= received_voter_token_data.dig(:flow, :id)&.to_i
      end

      def form
        @form ||= Decidim::Votings::Census::LoginForm.from_params(context.params, election: election)
      end

      def valid_token_flow_data?
        @valid_token_flow_data ||= begin
          has_voter? && received_voter_token_data[:flow].as_json == voter_data.as_json
        end
      end
    end
  end
end
