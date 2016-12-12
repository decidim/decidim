# frozen_string_literal: true
module Decidim
  module Proposals
    # A command with all the business logic when creating a new participatory
    # process in the system.
    class CreateProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # feature - The feature where the proposal belongs to.
      def initialize(form, feature)
        @form = form
        @feature = feature
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_proposal
        broadcast(:ok, proposal)
      end

      private

      attr_reader :form, :proposal, :feature

      def create_proposal
        @proposal = Proposal.create!(
          title: form.title,
          body: form.body,
          category: form.category,
          scope: form.scope,
          author: form.author,
          feature: feature
        )
      end
    end
  end
end
