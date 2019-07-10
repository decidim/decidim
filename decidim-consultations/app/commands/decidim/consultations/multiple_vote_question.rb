# frozen_string_literal: true

module Decidim
  module Consultations
    # A command with all the business logic when a user votes a question.
    class MultipleVoteQuestion < Rectify::Command
      # Public: Initializes the command.
      #
      # form   - A Decidim::Consultations::VoteForm object.
      # current_user - The current user.
      def initialize(forms)
        @forms = forms
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        ActiveRecord::Base.transaction do
          check_num_votes
          forms.each do |form|
            vote = build_vote form
            vote.save!
          end
          broadcast(:ok, forms)
        rescue StandardError => e
          broadcast(:invalid, forms, e)
        rescue StandardError
          broadcast(:invalid, forms)
        end
      end

      private

      attr_reader :forms

      def check_num_votes
        question = forms&.first&.context&.current_question
        if question
          return if forms.count.between?(question.min_votes, question.max_votes)
        end
        raise StandardError, I18n.t("activerecord.errors.models.decidim/consultations/vote.attributes.question.invalid_num_votes")
      end

      def build_vote(form)
        form.context.current_question.votes.build(
          author: form.context.current_user,
          response: form.response
        )
      end
    end
  end
end
