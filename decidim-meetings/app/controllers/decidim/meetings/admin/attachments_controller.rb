# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Controller that allows managing all the attachments for a participatory
      # process.
      #
      class AttachmentsController < Decidim::Meetings::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          meetings_path
        end

        def attached_to
          meeting
        end

        def meeting
          @meeting ||= meetings.find(params[:meeting_id])
        end
      end
    end
  end
end
