# frozen_string_literal: true

module Decidim
  module Core
    module AttachableCollectionMutations
      extend ActiveSupport::Concern

      included do
        field :create_attachment_collection, mutation: CreateAttachmentCollectionType,
                                             description: "Create attachment collection for a resource"
        field :delete_attachment_collection, mutation: DeleteAttachmentCollectionType,
                                             description: "Delete attachment collection from a resource"
        field :update_attachment_collection, mutation: UpdateAttachmentCollectionType,
                                             description: "Update attachment collection for a resource"
      end
    end
  end
end
