# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin creates a private note proposal.
      class CreateProposalNote < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # current_user - The current user.
        # proposal - the proposal to relate.
        def initialize(form, proposal, current_user)
          @form = form
          @proposal = proposal
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the note proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_proposal_note

          broadcast(:ok, proposal_note)
        end

        private

        attr_reader :form, :proposal_note

        def create_proposal_note
          @proposal_note = ProposalNote.create!(
            body: form.body,
            proposal: @proposal,
            author: @current_user
          )
        end
      end
    end
  end
end
