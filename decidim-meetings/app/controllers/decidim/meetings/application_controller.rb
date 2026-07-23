# frozen_string_literal: true

module Decidim
  module Meetings
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      helper Decidim::Meetings::ApplicationHelper

      private

      def add_additional_csp_directives
        return unless respond_to?(:meeting) || meeting.present?

        embedder = MeetingIframeEmbedder.new(meeting.online_meeting_url)
        return unless embedder.embeddable?

        embedded = embedder.embed_transformed_url(request.host)
        content_security_policy.append_csp_directive("frame-src", embedded) if embedded.present?
      end
    end
  end
end
