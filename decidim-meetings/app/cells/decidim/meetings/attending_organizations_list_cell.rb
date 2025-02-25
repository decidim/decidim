# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders the list of public participating
    # organizations of a meeting.
    #
    # Example:
    #
    #    cell("decidim/participating_organizations_list", meeting)
    class AttendingOrganizationsListCell < PublicParticipantsListCell
      private

      def user_group_ids
        model.user_group_registrations.pluck(:decidim_user_id)
      end

      def user_groups
        Decidim::User.where(id: user_group_ids)
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
