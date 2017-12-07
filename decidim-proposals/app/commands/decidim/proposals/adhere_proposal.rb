# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user adheres to a proposal.
    class AdhereProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - A Decidim::Proposals::Proposal object.
      # current_user - The current user.
      # current_group- (optional) The current_grup that is adhering to the Proposal.
      def initialize(proposal, current_user, current_group=nil)
        @proposal = proposal
        @current_user = current_user
        @current_group = current_group
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        build_proposal_adhesion
        return broadcast(:invalid) unless @adhesion.valid?

        @adhesion.save!
        broadcast(:ok, adhesion)
      end

      attr_reader :adhesion

      private

      def build_proposal_adhesion
        @adhesion= @proposal.adhesions.build(author: @current_user)
        @adhesion.user_group= @current_group if @current_group.present?
        @adhesion
      end
    end
  end
end
