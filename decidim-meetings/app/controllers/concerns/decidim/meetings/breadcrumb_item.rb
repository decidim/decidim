# frozen_string_literal: true

module Decidim
  module Meetings
    # This module, allows to include a breadcrumb item for meeting if present.
    # Ensure to define the meeting method in the controller if this concern is
    # included
    module BreadcrumbItem
      extend ActiveSupport::Concern

      included do
        before_action :set_meeting_breadcrumb_item

        def set_meeting_breadcrumb_item
          return unless meeting

          context_breadcrumb_items << {
            label: meeting.title,
            url: meeting_path(meeting),
            active: true,
            resource: meeting
          }
        end
      end
    end
  end
end
