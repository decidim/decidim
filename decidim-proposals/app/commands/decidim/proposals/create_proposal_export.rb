# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user creates a new proposal.
    class CreateProposalExport < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      def initialize(participatory_process)
        @participatory_process = participatory_process
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the proposal wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if participatory_process.invalid?

        create_proposal_export
        broadcast(:ok, export)
      end

      private

      attr_reader :participatory_process

      def create_proposal_export
        ProposalsExporterJob.perform_later(participatory_process)
      end
    end
  end
end
