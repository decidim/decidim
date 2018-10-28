# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Controller that allows managing all the attachment collections for an assembly.
      #
      class AttachmentCollectionsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachmentCollections

        def after_destroy_path
          meeting_attachment_collections_path(meeting, meeting.component, current_participatory_space)
        end

        def collection_for
          meeting
        end

        def meeting
          @meeting ||= meetings.find(params[:meeting_id])
        end
      end
    end
  end
end
