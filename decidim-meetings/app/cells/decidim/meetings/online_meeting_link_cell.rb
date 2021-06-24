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

      delegate :live?, :show_iframe?, to: :model
      delegate :embed_code, :embeddable?, to: :embedder
    end
  end
end
