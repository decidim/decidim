# frozen_string_literal: true
module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when a user unreports a proposal.
      class UnreportProposal < Rectify::Command
        # Public: Initializes the command.
        #
        # proposal - A Decidim::Proposals::Proposal
        def initialize(proposal)
          @proposal = proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the proposal is not reported
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @proposal.reported?

          unreport_proposal
          broadcast(:ok, @proposal)
        end

        private

        def unreport_proposal
          @proposal.update_attributes!(report_count: 0, hidden_at: nil)
        end
      end
    end
  end
end
