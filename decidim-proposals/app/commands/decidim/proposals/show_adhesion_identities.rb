# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic for when a user requests its adhesion related identities.
    class ShowAdhesionIdentities < Rectify::Command
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
      #    - includes a `groups_split` hash argument with two keys: adhere, unadhere
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # The __groups_split__ hash argument includes with two keys: adhere, unadhere.
      # Each of this keys contains an array with the ids of the **current_user.user_groups**
      # that should offer to adhere or to unadhere respectively.
      #
      # Returns nothing.
      def call
        @to_unadhere= @proposal.adhesions.
          where(author: @current_user).
          where.not(decidim_user_group_id: nil).pluck(:decidim_user_group_id)
        @to_adhere= @current_user.user_groups.verified.
          where.not(id: @to_unadhere).pluck(:id)
        broadcast(:ok, {adhere: @to_adhere, unadhere: @to_unadhere})
      end

      private

    end
  end
end
