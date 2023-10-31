# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing all the attachment collections for
      # a participatory process.
      #
      class ParticipatoryProcessAttachmentCollectionsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachmentCollections
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::Concerns::HasTabbedMenu

        def after_destroy_path
          participatory_process_attachment_collections_path(current_participatory_process)
        end

        def collection_for
          current_participatory_process
        end

        private

        def tab_menu_name = :participatory_process_admin_attachments_menu
      end
    end
  end
end
