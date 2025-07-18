# frozen_string_literal: true

module Decidim
  module Core
    module AttachableMutations
      extend ActiveSupport::Concern

      included do
        field :create_attachment, mutation: CreateAttachmentType,
                                  description: "Create attachment for a resource"
        field :update_attachment, mutation: UpdateAttachmentType,
                                  description: "Update attachment for a resource"
        field :delete_attachment, mutation: DeleteAttachmentType,
                                  description: "Delete resource attachment"
      end
    end
  end
end
