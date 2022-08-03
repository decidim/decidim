# frozen_string_literal: true

module Decidim
  # A Helper to render conferences.
  module Conferences
    module ConferenceHelper
      include PaginateHelper

      # Renders the dates of a conference
      #
      def render_date(conference)
        return l(conference.start_date, format: :decidim_with_month_name_short) if conference.start_date == conference.end_date

        "#{l(conference.start_date, format: :decidim_with_month_name_short)} - #{l(conference.end_date, format: :decidim_with_month_name_short)}"
      end
    end
  end
end
