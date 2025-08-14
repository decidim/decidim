# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentType < Decidim::Api::Types::BaseObject
      description "A file attachment"
      implements Decidim::Core::TimestampsInterface

      field :content_type, GraphQL::Types::String, "The attached link for this attachment", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this attachment.", null: false
      field :file_size, GraphQL::Types::String, "The attached link for this attachment", null: true
      field :id, GraphQL::Types::ID, "Internal ID for this attachment", null: false
      field :link, GraphQL::Types::String, "The attached link for this attachment", null: true
      field :thumbnail, GraphQL::Types::String, "A thumbnail of this attachment, if it is an image.", method: :thumbnail_url, null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title of this attachment.", null: false
      field :type, GraphQL::Types::String, "The type of this attachment", method: :file_type, null: false
      field :url, GraphQL::Types::String, "The url of this attachment", null: false
      field :weight, GraphQL::Types::Int, "The weight of this participatory process", null: true
    end
  end
end
