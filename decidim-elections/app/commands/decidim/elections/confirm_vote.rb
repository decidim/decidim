# frozen_string_literal: true

module Decidim
  module Elections
    class ConfirmVote < Decidim::Command
      def initialize(election:, votes_data:, voter_credentials:)
        @election = election
        @voter_credentials = voter_credentials
        @votes_data = votes_data
      end

      def call
        return broadcast(:invalid) if @votes_data.blank?

        transaction do
          @votes_data.each do |question_id, data|
            response_option_id = data["response_option_id"]
            next if response_option_id.blank?

            upsert_vote(question_id, response_option_id)
          end
        end

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "#{e.class.name}: #{e.message}"
        broadcast(:invalid)
      end

      private

      attr_reader :election, :voter_credentials, :votes_data

      def upsert_vote(question_id, response_option_id)
        voter_uid = generate_voter_uid

        vote = Vote.find_or_initialize_by(
          voter_uid: voter_uid,
          decidim_elections_question_id: question_id
        )

        vote.assign_attributes(vote_attributes(response_option_id))
        vote.save!
      end

      def vote_attributes(response_option_id)
        attrs = {
          decidim_elections_response_option_id: response_option_id
        }

        if election.internal_census?
          attrs[:decidim_user_id] = current_user&.id
        else
          voter = find_voter_by_credentials
          attrs[:decidim_elections_voter_id] = voter&.id
        end

        attrs
      end

      def find_voter_by_credentials
        return if voter_credentials.blank?

        election.voters.with_email(voter_credentials["email"]).with_token(voter_credentials["token"]).first
      end

      def generate_voter_uid
        manifest = Decidim::Elections.census_registry.find(election.census_manifest)

        if manifest.respond_to?(:voter_uid) && manifest.voter_uid
          manifest.voter_uid.call(voter_credentials)
        elsif current_user
          Digest::SHA256.hexdigest("#{current_user.id}-#{current_user.email}")
        else
          raise "Cannot generate voter_uid: no current_user or voter_credentials"
        end
      end
    end
  end
end
