# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentType < Decidim::Api::Types::BaseObject
      description "A file attachment"

      field :description, Decidim::Core::TranslatedFieldType, "The description of this attachment.", null: false
      field :thumbnail, GraphQL::Types::String, "A thumbnail of this attachment, if it is an image.", method: :thumbnail_url, null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title of this attachment.", null: false
      field :type, GraphQL::Types::String, "The type of this attachment", method: :file_type, null: false
      field :url, GraphQL::Types::String, "The url of this attachment", null: false
    end
  end
end
