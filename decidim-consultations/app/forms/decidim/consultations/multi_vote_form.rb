# frozen_string_literal: true

module Decidim
  module Consultations
    # This form validates a MultiVote Question
    class MultiVoteForm < Form
      mimic :responses

      attribute :responses, Array[Integer]

      validate :valid_num_of_votes
      validate :valid_responses

      def vote_forms
        @vote_forms ||= responses.map do |response_id|
          VoteForm.from_params(decidim_consultations_response_id: response_id)
        end
      end

      private

      def valid_num_of_votes
        return if responses.count.between?(context.current_question.min_votes, context.current_question.max_votes)

        errors.add(
          :responses,
          I18n.t("activerecord.errors.models.decidim/consultations/vote.attributes.question.invalid_num_votes")
        )
      end

      def valid_responses
        return if vote_forms.all?(&:valid?)

        errors.add(
          :responses,
          I18n.t("decidim_consultations_response_id.not_found", scope: "activemodel.errors.vote")
        )
      end
    end
  end
end
