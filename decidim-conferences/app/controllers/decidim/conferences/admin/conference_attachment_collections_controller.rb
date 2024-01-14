# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing all the attachment collections for a Conference.
      #
      class ConferenceAttachmentCollectionsController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin
        include Decidim::Admin::Concerns::HasAttachmentCollections
        include Decidim::Admin::Concerns::HasTabbedMenu

        def after_destroy_path
          conference_attachment_collections_path(current_conference)
        end

        def collection_for
          current_conference
        end

        def authorization_object
          @attachment_collection || AttachmentCollection
        end

        private

        def tab_menu_name = :conferences_admin_attachments_menu
      end
    end
  end
end
