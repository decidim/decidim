# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing all the attachment collections for an assembly.
      #
      class AssemblyAttachmentCollectionsController < Decidim::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        include Decidim::Admin::Concerns::HasAttachmentCollections

        def after_destroy_path
          assembly_attachment_collections_path(current_assembly)
        end

        def collection_for
          current_assembly
        end

        def authorization_object
          @attachment_collection || AttachmentCollection
        end

        def current_participatory_space_manifest_name
          :assemblies
        end
      end
    end
  end
end
