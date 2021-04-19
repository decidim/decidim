# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentType < Decidim::Api::Types::BaseObject
      description "A file attachment"

      field :url, GraphQL::Types::String, "The url of this attachment", null: false
      field :type, GraphQL::Types::String, "The type of this attachment", method: :file_type, null: false
      field :thumbnail, GraphQL::Types::String, "A thumbnail of this attachment, if it's an image.", method: :thumbnail_url, null: true
    end
  end
end
