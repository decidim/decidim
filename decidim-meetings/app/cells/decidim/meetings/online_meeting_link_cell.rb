# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the online meeting link section
    # of a online or both type of meeting.
    class OnlineMeetingLinkCell < Decidim::Meetings::OnlineMeetingCell
      include Decidim::LayoutHelper

      def show
        return unless iframe_access_level_allowed?

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

      def iframe_access_level_allowed?
        return unless model.show_embedded_iframe?

        case model.iframe_access_level
        when "all"
          true
        when "signed_in"
          current_user.present?
        else
          model.has_registration_for?(current_user)
        end
      end
    end
  end
end
