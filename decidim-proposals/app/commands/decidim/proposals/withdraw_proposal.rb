# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user withdraws a new proposal.
    class WithdrawProposal < Decidim::Command
      # Public: Initializes the command.
      #
      # proposal     - The proposal to withdraw.
      # current_user - The current user.
      def initialize(proposal, current_user)
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :has_supports if the proposal already has supports or does not belong to current user.
      #
      # Returns nothing.
      def call
        return broadcast(:has_supports) if @proposal.votes.any?

        transaction do
          change_proposal_state_to_withdrawn
          reject_emendations_if_any
        end

        broadcast(:ok, @proposal)
      end

      private

      def change_proposal_state_to_withdrawn
        @proposal.update state: "withdrawn"
      end

      def reject_emendations_if_any
        return if @proposal.emendations.empty?

        @proposal.emendations.each do |emendation|
          @form = form(Decidim::Amendable::RejectForm).from_params(id: emendation.amendment.id)
          result = Decidim::Amendable::Reject.call(@form)
          return result[:ok] if result[:ok]
        end
      end
    end
  end
end
