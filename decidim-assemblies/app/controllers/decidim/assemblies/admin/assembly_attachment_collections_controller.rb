# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing all the attachment collections for an assembly.
      #
      class AssemblyAttachmentCollectionsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachmentCollections
        include Concerns::AssemblyAdmin

        def after_destroy_path
          assembly_attachment_collections_path(current_assembly)
        end

        def authorization_object
          @attachment_collection || AttachmentCollection
        end
      end
    end
  end
end
