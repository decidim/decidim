# frozen_string_literal: true

module Decidim
  module Elections
    class CastVotes < Decidim::Command
      def initialize(election, data, voter_uid)
        @election = election
        @data = data
        @voter_uid = voter_uid
      end

      def call
        return broadcast(:invalid) unless election.ongoing?
        return broadcast(:invalid) if voter_uid.blank?
        return broadcast(:invalid) unless election.per_question? || voted_questions.count == election.questions.count
        return broadcast(:invalid) if voted_questions.blank?

        transaction do
          save_votes!
        end

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid, StandardError => e
        Rails.logger.error "#{e.class.name}: #{e.message}"
        broadcast(:invalid)
      end

      private

      attr_reader :election, :voter_uid, :data

      def voted_questions
        @voted_questions ||= election.available_questions.where(id: data.keys).filter_map do |question|
          responses = question.safe_responses(data[question.id.to_s])
          [question, responses]
        end.to_h
      end

      def save_votes!
        voted_questions.each do |question, responses|
          raise StandardError, "No responses for question #{question.id}" if responses.blank?

          responses.each do |response_option|
            vote = question.votes.find_or_initialize_by(voter_uid:)
            vote.response_option = response_option
            vote.save!
          end
        end
      end
    end
  end
end
