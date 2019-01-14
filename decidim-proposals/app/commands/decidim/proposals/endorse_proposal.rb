# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user endorses a proposal.
    class EndorseProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - A Decidim::Proposals::Proposal object.
      # current_user - The current user.
      # current_group_id- (optional) The current_grup that is endorsing the Proposal.
      def initialize(proposal, current_user, current_group_id = nil)
        @proposal = proposal
        @current_user = current_user
        @current_group_id = current_group_id
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        endorsement = build_proposal_endorsement
        if endorsement.save
          notify_endorser_followers
          broadcast(:ok, endorsement)
        else
          broadcast(:invalid)
        end
      end

      private

      def build_proposal_endorsement
        endorsement = @proposal.endorsements.build(author: @current_user)
        endorsement.user_group = user_groups.find(@current_group_id) if @current_group_id.present?
        endorsement
      end

      def user_groups
        Decidim::UserGroups::ManageableUserGroups.for(@current_user).verified
      end

      def notify_endorser_followers
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.proposal_endorsed",
          event_class: Decidim::Proposals::ProposalEndorsedEvent,
          resource: @proposal,
          followers: @current_user.followers,
          extra: {
            endorser_id: @current_user.id
          }
        )
      end
    end
  end
end
