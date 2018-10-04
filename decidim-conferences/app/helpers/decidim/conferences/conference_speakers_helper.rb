# frozen_string_literal: true

module Decidim
  module Conferences
    # Helpers related to the Conferences layout.
    module ConferenceSpeakersHelper
      def meetings_selected
        @meetings_selected ||= @conference_speaker.conference_speaker_meetings.pluck(:to_id) if @conference_speaker.present?
      end
    end
  end
end
