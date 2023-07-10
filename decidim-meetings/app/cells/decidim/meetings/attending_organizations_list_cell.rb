# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders the list of public participanting
    # organizations of a meeting.
    #
    # Example:
    #
    #    cell("decidim/participating_organizations_list", meeting)
    class AttendingOrganizationsListCell < PublicParticipantsListCell
      private

      def user_group_ids
        model.user_group_registrations.user_group_ids
      end

      def user_groups
        Decidim::UserGroup.where(id: user_group_ids)
      end

      # Finds the public organizations (as user groups) of meeting
      #
      # Returns an Array of presented UserGroups
      def public_participants
        @public_participants ||= user_groups.map { |user_group| present(user_group) }
      end
    end
  end
end
