# frozen_string_literal: true

module Decidim
  module Consultations
    # The data store for question's votes in the Decidim::Consultations component.
    class Vote < ApplicationRecord
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"

      belongs_to :question,
                 foreign_key: "decidim_consultation_question_id",
                 class_name: "Decidim::Consultations::Question",
                 counter_cache: :votes_count,
                 inverse_of: :votes

      belongs_to :response,
                 foreign_key: "decidim_consultations_response_id",
                 class_name: "Decidim::Consultations::Response",
                 inverse_of: :votes,
                 counter_cache: :votes_count

      validates :author, uniqueness: { scope: [:decidim_user_group_id, :question] }, unless: -> { question.multiple? }
      validate :votes_per_author
      validate :author_and_question_same_organization

      delegate :organization, to: :question

      private

      # Private: check if the question and the author have the same organization
      def author_and_question_same_organization
        return if !question || !author

        errors.add(:question, :invalid) unless author.organization == question.organization
      end

      # Author can vote multiple times constrained to question limits
      def votes_per_author
        return unless question.multiple?

        total = Vote.where(author:, question:, decidim_user_group_id:).count
        errors.add(:question, :invalid_num_votes) unless total < question.max_votes
      end
    end
  end
end
