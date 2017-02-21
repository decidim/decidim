# frozen_string_literal: true
module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when a user hides a proposal.
      class HideProposal < Rectify::Command
        # Public: Initializes the command.
        #
        # proposal - A Decidim::Proposals::Proposal
        def initialize(proposal)
          @proposal = proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the proposal is already hidden
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if @proposal.hidden?

          hide_proposal
          broadcast(:ok, @proposal)
        end

        private

        def hide_proposal
          @proposal.update_attributes!(hidden_at: Time.current)
        end
      end
    end
  end
end
