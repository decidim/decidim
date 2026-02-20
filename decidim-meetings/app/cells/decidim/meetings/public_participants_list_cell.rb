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

      DESKTOP_VISIBLE_COUNT = 12
      MOBILE_VISIBLE_COUNT = 8

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

      def participants_count
        @participants_count ||= public_participants.length
      end

      def desktop_visible_count
        DESKTOP_VISIBLE_COUNT
      end

      def mobile_visible_count
        MOBILE_VISIBLE_COUNT
      end

      def show_toggle?
        participants_count > mobile_visible_count
      end

      def show_more_text
        t("show_more", scope: "decidim.meetings.public_participants_list")
      end

      def show_less_text
        t("show_less", scope: "decidim.meetings.public_participants_list")
      end
    end
  end
end
