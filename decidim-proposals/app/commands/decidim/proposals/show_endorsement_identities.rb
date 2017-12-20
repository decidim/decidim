# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic for when a user requests its endorsement related identities.
    class ShowEndorsementIdentities < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - A Decidim::Proposals::Proposal object.
      # current_user - The current user.
      def initialize(proposal, current_user)
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      #    - includes a `groups_split` hash argument with two keys: endorse, unendorse
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # The __groups_split__ hash argument includes with two keys: endorse, unendorse.
      # Each of this keys contains an array with the ids of the **current_user.user_groups**
      # that should offer to endorse or to unendorse respectively.
      #
      # Returns nothing.
      def call
        @to_unendorse = @proposal.endorsements
                                 .where(author: @current_user)
                                 .where.not(decidim_user_group_id: nil)
                                 .pluck(:decidim_user_group_id) || []
        @to_endorse = @current_user.user_groups.verified
                                   .where.not(id: @to_unendorse).pluck(:id) || []
        broadcast(:ok, endorse: @to_endorse, unendorse: @to_unendorse)
      end
    end
  end
end
