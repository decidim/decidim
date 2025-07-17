# frozen_string_literal: true

module Decidim
  module Elections
    class Vote < Elections::ApplicationRecord
      include Decidim::Traceable
      belongs_to :question, class_name: "Decidim::Elections::Question", counter_cache: true, inverse_of: :votes
      belongs_to :response_option, class_name: "Decidim::Elections::ResponseOption", counter_cache: true, inverse_of: :votes

      attr_readonly :voter_uid, :question_id

      validates :voter_uid, presence: true
      validate :response_belong_to_question
      validates :response_option, uniqueness: { scope: [:question_id, :voter_uid, :response_option_id] }
      validate :max_votable_options

      delegate :election, to: :question
      # To ensure records cannot be deleted
      before_destroy { |_record| raise ActiveRecord::ReadOnlyRecord }

      after_save :update_election_votes_count

      private

      def response_belong_to_question
        return unless question && response_option
        return if question.response_options.include?(response_option)

        errors.add(:response_option, :invalid)
      end

      def max_votable_options
        return unless question && response_option
        return if question.votes.where.not(id: id).where(voter_uid: voter_uid).count < question.max_votable_options

        errors.add(:response_option, :invalid)
      end

      def update_election_votes_count
        question.election.update_votes_count!
      end
    end
  end
end
