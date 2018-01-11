# frozen_string_literal: true

module Decidim
  module Proposals
    # A class used to find the ids of the UserGroups that can endorse a Proposal and belong to a given User.
    class UserGroupsThatCanEndorse < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - The user to which the queried user_groups belong to.
      # proposal - The Proposal from which the endorsements will be done.
      def self.from(user, proposal)
        new(user, proposal).query
      end

      # Initializes the class.
      #
      # user - The user to which the queried user_groups belong to.
      # proposal - The Proposal from which the endorsements will be done.
      def initialize(user, proposal)
        @user = user
        @proposal = proposal
      end

      # Finds the Proposals scoped to an array of features and filtered
      # by a range of dates.
      def query
        @user.user_groups.verified.where.not(id: to_unendorse).pluck(:id)
      end

      #----------------------------------------------------------------

      private

      #----------------------------------------------------------------

      def to_unendorse
        @to_unendorse ||= UserGroupsThatCanUndoEndorsement.from(@user, @proposal)
      end
    end
  end
end
