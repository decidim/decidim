# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentCollectionType < Decidim::Api::Types::BaseObject
      description "A file attachment collection"

      field :description, Decidim::Core::TranslatedFieldType, "The description of this AttachmentCollection.", null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of this AttachmentCollection.", null: false

      field :attachments, [Decidim::Core::AttachmentType, { null: true }], "The collection's attachments", null: false
      field :id, GraphQL::Types::ID, "The id of this attachment collection", null: false
      field :key, GraphQL::Types::String, "A technical key for the attachment collection to identify a specific correct collection", null: true
      # @deprecated Use `#key` instead.
      field :slug, GraphQL::Types::String, "DEPRECATED: Use 'key' instead", null: true, method: :key
      field :weight, GraphQL::Types::Int, "The weight of this attachment collection", null: false
    end
  end
end
