# frozen_string_literal: true
module Decidim
  module Proposals
    # A command with all the business logic when a user creates a new proposal.
    class CreateProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_proposal
        broadcast(:ok, proposal)
      end

      private

      attr_reader :form, :proposal

      def create_proposal
        @proposal = Proposal.create!(
          title: form.title,
          body: form.body,
          category: form.category,
          scope: form.scope,
          author: form.author,
          feature: form.feature
        )
      end
    end
  end
end
