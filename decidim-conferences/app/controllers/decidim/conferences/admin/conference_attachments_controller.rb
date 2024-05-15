# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing all the attachments for a participatory
      # conference.
      #
      class ConferenceAttachmentsController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin
        include Decidim::Admin::Concerns::HasAttachments
        include Decidim::Admin::Concerns::HasTabbedMenu

        def after_destroy_path
          conference_attachments_path(current_conference)
        end

        def attached_to
          current_conference
        end

        def authorization_object
          @attachment || Attachment
        end

        private

        def tab_menu_name = :conferences_admin_attachments_menu
      end
    end
  end
end
