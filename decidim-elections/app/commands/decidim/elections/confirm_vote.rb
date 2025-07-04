# frozen_string_literal: true

module Decidim
  module Elections
    class ConfirmVote < Decidim::Command
      attr_reader :election, :voter, :votes_data

      def initialize(election:, voter:, votes_data:)
        @election = election
        @voter = voter
        @votes_data = votes_data
      end

      def call
        return broadcast(:invalid) unless voter && votes_data.present?

        transaction do
          votes_data.each do |question_id, data|
            response_option_id = data["response_option_id"]
            next if response_option_id.blank?

            create_vote(question_id, response_option_id)
          end
        end

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "#{e.class.name}: #{e.message}"
        broadcast(:invalid)
      end

      private

      def create_vote(question_id, response_option_id)
        Vote.create!(
          voter: voter,
          decidim_elections_question_id: question_id,
          decidim_elections_response_option_id: response_option_id
        )
      end
    end
  end
end
