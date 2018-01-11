# frozen_string_literal: true

module Decidim
  module Proposals
    # A class used to find the ids of the UserGroups that can undo an already endorsed Proposal and belong to a given User.
    class UserGroupsThatCanUndoEndorsement < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - The user to which the queried user_groups belong to.
      # proposal - The Proposal from which the endorsements will be undone.
      def self.from(user, proposal)
        new(user, proposal).query
      end

      # Initializes the class.
      #
      # user - The user to which the queried user_groups belong to.
      # proposal - The Proposal from which the endorsements will be undone.
      def initialize(user, proposal)
        @user = user
        @proposal = proposal
      end

      # Finds the Proposals scoped to an array of features and filtered
      # by a range of dates.
      def query
        @proposal.endorsements.where(author: @user).where.not(decidim_user_group_id: nil)
                 .pluck(:decidim_user_group_id)
      end
    end
  end
end
