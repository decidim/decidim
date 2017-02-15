# frozen_string_literal: true
module Decidim
  module Proposals
    # A command with all the business logic when a user reports a proposal.
    class ReportProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # proposal     - The proposal being reported
      # current_user - The current user.
      def initialize(form, proposal, current_user)
        @form = form
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal report.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_proposal_report
        broadcast(:ok, proposal_report)
      end

      private

      attr_reader :form, :proposal_report

      def create_proposal_report
        transaction do
          @proposal_report = ProposalReport.create!(
            proposal: @proposal,
            user: @current_user,
            type: form.type
          )
          @proposal.update_attributes!(report_count: @proposal.report_count + 1)
        end
      end
    end
  end
end
