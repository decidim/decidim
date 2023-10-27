# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows managing all the attachment collections for
      # a voting.
      class VotingAttachmentCollectionsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachmentCollections
        include Decidim::Admin::Concerns::HasTabbedMenu
        include VotingAdmin

        def after_destroy_path
          voting_attachment_collections_path(current_voting)
        end

        def collection_for
          current_voting
        end

        private

        def tab_menu_name = :votings_admin_attachments_menu
      end
    end
  end
end
