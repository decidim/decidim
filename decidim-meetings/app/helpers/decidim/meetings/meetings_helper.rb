# frozen_string_literal: true

module Decidim
  module Meetings
    # Custom helpers used in meetings views
    module MeetingsHelper
      include Decidim::ApplicationHelper
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper

      # Public: truncates the meeting description
      #
      # meeting - a Decidim::Meeting instance
      # max_length - a number to limit the length of the description
      #
      # Returns the meeting's description truncated.
      def meeting_description(meeting, max_length = 120)
        link = resource_locator(meeting).path
        description = Decidim::Meetings::MeetingPresenter.new(meeting).description
        tail = "... #{link_to(t("read_more", scope: "decidim.meetings"), link)}".html_safe
        CGI.unescapeHTML html_truncate(description, max_length: max_length, tail: tail)
      end

      # Public: The css class applied based on the meeting type to
      #         the css class.
      #
      # type - The String type of the meeting.
      #
      # Returns a String.
      def meeting_type_badge_css_class(type)
        case type
        when "private"
          "alert"
        when "transparent"
          "secondary"
        end
      end

      # Public: This method is used to calculate the start and end time
      #         of each agenda item passed
      #
      # agenda_items - an Active record of agenda items
      # meeting - the meeting of the agenda, to know the start and end time
      # start_time_parent - used to pass the start time of parent agenda item
      #
      # Returns an Array.
      def calculate_start_and_end_time_of_agenda_items(agenda_items, meeting, start_time_parent = nil)
        array = []

        agenda_items.each_with_index do |agenda_item, index|
          hash = {
            agenda_item_id: agenda_item.id,
            start_time: nil,
            end_time: nil
          }
          if index.zero?
            start = if agenda_item.parent?
                      meeting.start_time
                    else
                      start_time_parent
                    end

            hash[:start_time] = start
          else
            hash[:start_time] = array[index - 1][:end_time]
          end

          hash[:end_time] = hash[:start_time] + agenda_item.duration.minutes

          array.push(hash)
        end

        array
      end

      # Public: This method is used to build the html for show start
      # and end time of each agenda item
      #
      # agenda_item_id - an id of agenda item
      # agenda_items_times - is a hash with the two times
      #
      # Returns an HMTL.
      def display_duration_agenda_items(agenda_item_id, index, agenda_items_times)
        html = ""
        if agenda_item_id == agenda_items_times[index][:agenda_item_id]
          html += "[ #{agenda_items_times[index][:start_time].strftime("%H:%M")} - #{agenda_items_times[index][:end_time].strftime("%H:%M")}]"
        end
        html.html_safe
      end
    end
  end
end
