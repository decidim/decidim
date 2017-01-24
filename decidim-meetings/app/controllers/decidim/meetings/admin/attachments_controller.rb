# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Meetings
    module Admin
      # Controller that allows managing all the attachments for a participatory
      # process.
      #
      class AttachmentsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::Attachable

        def after_destroy_path
          meetings_path
        end

        def attachable
          meeting
        end

        def meeting
          @meeting ||= meetings.find(params[:meeting_id])
        end

        def authorization_object
          meeting.feature
        end
      end
    end
  end
end
