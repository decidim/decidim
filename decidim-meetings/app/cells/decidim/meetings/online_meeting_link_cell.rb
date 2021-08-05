# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the online meeting link section
    # of a online or both type of meeting.
    class OnlineMeetingLinkCell < Decidim::Meetings::OnlineMeetingCell
      include Decidim::LayoutHelper

      def show
        render
      end

      def online_meeting_url?
        model.online_meeting_url.present?
      end

      delegate :embed_code, to: :embedder

      private

      def show_embed?
        model.show_embedded_iframe? && embedder.embeddable?
      end

      def live?
        model.start_time &&
          model.end_time &&
          Time.current >= (model.start_time - 10.minutes) &&
          Time.current <= model.end_time
      end
    end
  end
end
