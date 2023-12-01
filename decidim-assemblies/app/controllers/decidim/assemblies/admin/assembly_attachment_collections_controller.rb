# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing all the attachment collections for an assembly.
      #
      class AssemblyAttachmentCollectionsController < Decidim::Assemblies::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        include Decidim::Admin::Concerns::HasAttachmentCollections
        include Decidim::Admin::Concerns::HasTabbedMenu

        def after_destroy_path
          assembly_attachment_collections_path(current_assembly)
        end

        def collection_for
          current_assembly
        end

        private

        def tab_menu_name = :assemblies_admin_attachments_menu
      end
    end
  end
end
