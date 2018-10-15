# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Helpers related to the Conferences Speakers admin layout.
      module ConferenceSpeakersHelper
        def meetings_selected
          @meetings_selected ||= @conference_speaker.conference_meetings.pluck(:id) if @conference_speaker.present?
        end
      end
    end
  end
end
