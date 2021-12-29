# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders the list of public participants of a meeting.
    #
    # Example:
    #
    #    cell("decidim/public_participants_list", meeting)
    class PublicParticipantsListCell < Decidim::ViewModel
      include Decidim::Meetings::MeetingsHelper
      include ApplicationHelper

      def show
        return if public_participants.blank?

        render
      end

      private

      # Finds the public participants (as users) of meeting
      #
      # Returns an Array of presented Users
      def public_participants
        @public_participants ||= model.public_participants.map { |user| present(user) }
      end
    end
  end
end
