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

        def after_destroy_path
          participatory_process_attachment_collections_path(current_participatory_process)
        end

        def collection_for
          current_participatory_process
        end
      end
    end
  end
end
