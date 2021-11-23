# frozen_string_literal: true

module Decidim
  module Meetings
    #
    # Decorator for meetings in users context
    #
    class MeetingEditionPresenter < MeetingPresenter
      def sanitized(content)
        organization.rich_text_editor_in_public_views? ? decidim_sanitize_editor(content) : decidim_sanitize(content)
      end
    end
  end
end
