# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class VersionsController < Decidim::Meetings::ApplicationController
      include Decidim::ResourceVersionsConcern

      def versioned_resource
        @versioned_resource ||= Meeting.not_hidden.where(component: current_component).find(params[:meeting_id])
      end
    end
  end
end
