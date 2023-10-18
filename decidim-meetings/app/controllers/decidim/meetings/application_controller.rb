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

      def add_addtional_csp_directives
        return unless respond_to?(:meeting) || meeting.present?

        embedded = MeetingIframeEmbedder.new(meeting.online_meeting_url).embed_transformed_url(request.host)
        return if embedded.blank?

        content_security_policy.append_csp_directive("frame-src", embedded)
      end
    end
  end
end
