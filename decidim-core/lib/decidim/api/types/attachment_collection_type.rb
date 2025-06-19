# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentCollectionType < Decidim::Api::Types::BaseObject
      description "A file attachment collection"

      field :attachments, [Decidim::Core::AttachmentType, { null: true }], "This object's attachments", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description of this AttachmentCollection.", null: false
      field :id, GraphQL::Types::ID, "Internal ID for this AttachmentCollection", null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of this AttachmentCollection.", null: false
      field :weight, GraphQL::Types::Int, "The weight of this AttachmentCollection", null: true
    end
  end
end
