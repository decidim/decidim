# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin creates a private note proposal.
      class CreateNoteProposal < Rectify::Command
        # Public: Initializes the command.
        #
        # proposal     - A Decidim::Proposals::Proposal object.
        # current_user - The current user.
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

          transaction do
            create_note_proposal
          end

          broadcast(:ok, note_proposal)
        end

        private

        attr_reader :form, :proposal, :note_proposal

        def create_note_proposal
          @note_proposal = ProposalNote.create!(
            body: form.body,
            proposal: @proposal,
            author: @current_user
          )
        end
      end
    end
  end
end
