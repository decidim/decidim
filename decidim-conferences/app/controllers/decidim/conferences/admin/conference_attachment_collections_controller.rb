# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing all the attachment collections for an conference.
      #
      class ConferenceAttachmentCollectionsController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin
        include Decidim::Admin::Concerns::HasAttachmentCollections

        def after_destroy_path
          conference_attachment_collections_path(current_conference)
        end

        def collection_for
          current_conference
        end

        def authorization_object
          @attachment_collection || AttachmentCollection
        end
      end
    end
  end
end
