# frozen_string_literal: true

module Decidim
  module Core
    # This type represents an attachment collection
    class AttachmentCollectionType < Decidim::Api::Types::BaseObject
      description "A file attachment collection"

      field :attachments, [Decidim::Core::AttachmentType, { null: true }], "This object's attachments", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description of this Attachment Collection", null: false
      field :id, GraphQL::Types::ID, "Internal ID of this Attachment Collection", null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of this Attachment Collection", null: false
      field :weight, GraphQL::Types::Int, "The weight of this Attachment Collection", null: true
    end
  end
end
