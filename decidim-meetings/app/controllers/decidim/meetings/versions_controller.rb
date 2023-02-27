# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class VersionsController < Decidim::Meetings::ApplicationController
      include Decidim::ResourceVersionsConcern
      include BreadcrumbItem

      redesign active: true

      def versioned_resource
        @versioned_resource ||= Meeting.not_hidden.where(component: current_component).find(params[:meeting_id])
      end

      def meeting
        versioned_resource
      end
    end
  end
end
