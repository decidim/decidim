# frozen_string_literal: true

module Decidim
  module Core
    # The attachment attributes for managing an attachment.
    class AttachmentAttributes < Decidim::Api::Types::BaseInputObject
      description "Attributes for attachments"

      argument :collection, AttachmentCollectionInputObject, "The input argument for attachment collection", required: false
      argument :description, GraphQL::Types::JSON, description: "The attachment description localized hash", required: false
      argument :file, FileInputObject, "file that is being attached", required: false
      argument :title, GraphQL::Types::JSON, description: "The attachment title localized hash", required: false
      argument :weight, GraphQL::Types::Int, description: "The attachment weight, i.e. its position, lowest first", required: false, default_value: 0
    end
  end
end
