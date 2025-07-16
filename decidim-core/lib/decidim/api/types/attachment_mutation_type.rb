# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentMutationType < Decidim::Api::Types::BaseObject
      description "Attachment mutations"
      graphql_name "AttachmentMutation"

      field :create_attachment, mutation: Decidim::Core::CreateAttachmentType, description: "Create an attachment"
      # field :delete_attachment, mutation: DeleteAttachmentType, description: "Delete an attachment"
      # field :update_attachment, mutation: UpdateAttachmentType, description: "Update an attachment"
    end
  end
end
