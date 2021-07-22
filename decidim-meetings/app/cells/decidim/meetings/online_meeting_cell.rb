# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell defines methods required for other cells to render
    # online meeting urls
    class OnlineMeetingCell < Decidim::ViewModel
      protected

      def embedder
        @embedder ||= MeetingIframeEmbedder.new(model.online_meeting_url)
      end

      delegate :live?, to: :model
      delegate :embeddable?, to: :embedder

      def live_event_url
        if embeddable?
          Decidim::EngineRouter.main_proxy(model.component).meeting_live_event_path(meeting_id: model.id)
        else
          model.online_meeting_url
        end
      end

      def future?
        Time.current <= model.start_time && !live?
      end
    end
  end
end
