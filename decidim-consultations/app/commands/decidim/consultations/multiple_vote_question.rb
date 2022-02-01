# frozen_string_literal: true

module Decidim
  module Consultations
    # A command with all the business logic when a user votes a multivote question.
    class MultipleVoteQuestion < Decidim::Command
      # Public: Initializes the command.
      #
      # form   - A Decidim::Consultations::MultiVoteForm object.
      # current_user - The current user.
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid, form, form.errors[:responses].first) if form.invalid?

        ActiveRecord::Base.transaction do
          form.vote_forms.each do |form|
            create_vote! form
          end
          broadcast(:ok, form)
        rescue StandardError => e
          broadcast(:invalid, form, e.message)
        end
      end

      private

      attr_reader :form

      def create_vote!(vote_form)
        @form.context.current_question.votes.create!(
          author: @current_user,
          response: vote_form.response
        )
      end
    end
  end
end
