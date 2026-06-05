# frozen_string_literal: true

module Decidim
  module Core
    # This type represents an attachment
    class AttachmentType < Decidim::Api::Types::BaseObject
      description "A file attachment"
      implements Decidim::Core::TimestampsInterface

      field :content_type, GraphQL::Types::String, "The content type of this attachment (could be 'text/uri-list', 'image/jpeg', or any allowed content types)", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this attachment", null: false
      field :file_size, GraphQL::Types::String, "The file size of this attachment", null: true
      field :id, GraphQL::Types::ID, "Internal ID of this attachment", null: false
      field :link, GraphQL::Types::String, "The attached link of this attachment", null: true
      field :thumbnail, GraphQL::Types::String, "A thumbnail of this attachment, if it is an image", method: :thumbnail_url, null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title of this attachment", null: false
      field :type, GraphQL::Types::String, "The type of this attachment (could be 'link', 'jpeg', 'pdf' or any other allowed extensions)", method: :file_type, null: false
      field :url, GraphQL::Types::String, "The url of this attachment", null: false
      field :weight, GraphQL::Types::Int, "The weight of this attachment", null: true
    end
  end
end
