# frozen_string_literal: true

module Decidim
  module Meetings
    class WidgetsController < Decidim::WidgetsController
      helper MeetingsHelper
      helper Decidim::SanitizeHelper

      def show
        enforce_permission_to :embed, :meeting, meeting: model if model

        super
      end

      private

      def model
        @model ||= Meeting.except_withdrawn.published.not_hidden.where(component: current_component).find(params[:meeting_id])
      end

      def iframe_url
        @iframe_url ||= meeting_widget_url(model)
      end

      def permission_class_chain
        [Decidim::Meetings::Permissions]
      end
    end
  end
end
